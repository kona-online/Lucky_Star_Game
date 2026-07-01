# 개발 환경 기획 문서 — Claude_Game (러키스타 팬게임)

- **작성일**: 2026-06-30
- **상태**: 확정 (엔진/플랫폼), 프로젝트 실제 생성은 보류 — 다음 라운드에서 진행
- **범위**: 엔진 선정, 프로젝트 폴더 구조 제안, 챕터 간 공통 시스템 설계. 각 미니게임의 세부 로직/화면 기획은 별도 챕터별 라운드에서 다룸.

## 1. 엔진 선정

**Godot 4.7.stable** (`v4.7.stable.official[5b4e0cb0f]`)

| 검토 항목 | 내용 |
|---|---|
| 라이선스 | MIT, 무료/오픈소스, 로열티 없음 — 비상업 동인 배포에 적합 |
| 언어 | GDScript (Python과 유사한 문법, 첫 게임 진입장벽 낮음) |
| 대상 | 2D 전용, 4개 미니게임(반사신경/QTE/퀴즈/카루타) 모두 Input + UI + Timer 조합으로 구현 가능 |
| 플러그인 | Dialogic(대화/비주얼노벨 텍스트 연출) — **후보, 도입 여부 미정.** 사진앨범 프레임 내레이션·챕터 결과 대사에 쓸지는 첫 챕터(코나타) 기획 시 결정 |
| 배포 | Windows(.exe) export preset 기본 제공, 추가 비용 없음 |

**제외된 후보**
- RPG Maker — 사용자 비선호로 제외
- Unity — C# 진입장벽 + 2D 전용 프로젝트치고는 빌드/설정 복잡도가 과함
- GameMaker — 유료 export 모듈(라이선스 비용 발생)
- Construct — 구독제 + 웹 기반이라 커스터마이징 자유도가 낮음

## 2. 플랫폼

- **PC(Windows) 전용.** 모바일/웹 미고려 — 첫 게임이므로 볼륨을 의도적으로 제한.

## 3. 프로젝트 폴더 구조 (제안)

```
res://
├── project.godot
├── scenes/
│   ├── album/              # 메인 화면: 사진앨범 (허브)
│   │   └── album.tscn
│   ├── chapters/
│   │   ├── konata/         # 졸음 자원관리 + 반사신경
│   │   │   ├── konata.tscn       # 챕터 루트 씬 (MinigameBase 상속)
│   │   │   ├── konata.gd
│   │   │   └── assets/            # 이 챕터에서만 쓰는 에셋 (예: 나나코 선생님 스프라이트)
│   │   ├── kagami/         # QTE 츳코미, '오늘의 헛소리'
│   │   │   ├── kagami.tscn
│   │   │   ├── kagami.gd
│   │   │   └── assets/
│   │   ├── miyuki/         # 트리비아 퀴즈
│   │   │   ├── miyuki.tscn
│   │   │   ├── miyuki.gd
│   │   │   └── assets/
│   │   └── tsukasa/        # 카루타 그림 맞추기
│   │       ├── tsukasa.tscn
│   │       ├── tsukasa.gd
│   │       └── assets/
│   └── ending/              # 4챕터 클리어 후 엔딩 연출
├── autoload/
│   ├── progress_manager.gd  # 챕터별 클리어 상태 저장/로드 (싱글톤)
│   └── game_state.gd        # 세션 전역 상태 (저장되지 않음, 예: 현재 열려있는 챕터). ProgressManager와 역할 분리: ProgressManager=영구 저장되는 클리어 기록, GameState=휘발성 진행 상태
├── scripts/
│   └── minigame_base.gd     # 모든 챕터가 상속하는 공통 베이스 클래스 (아래 §4 참고)
├── assets/                  # 챕터 2개 이상이 공유하는 에셋만 (예: 앨범에도 쓰이는 캐릭터 초상화)
│   ├── art/                 # 캐릭터(고등학생/성인 버전), 배경, UI
│   ├── audio/                # BGM(노스탤직 편곡), SFX
│   └── fonts/
└── addons/
    └── dialogic/             # 대화/내레이션 플러그인 (도입 시)
```

**챕터별 에셋 배치 원칙**: 그 챕터에서만 쓰는 에셋(예: 코나타 챕터의 나나코 선생님 스프라이트)은 `scenes/chapters/<이름>/assets/`에 둔다. 2개 이상의 챕터 또는 앨범 화면에서 공유되는 에셋(예: 네 캐릭터의 고등학생/성인 초상화)만 전역 `assets/`로 올린다. 챕터를 독립적으로 만들고 나중에 떼어내기 쉽게 하기 위한 원칙.

## 4. 챕터 간 공통 시스템

- **화면 전환 방식**: 앨범과 챕터는 **완전한 씬 전환**(`get_tree().change_scene_to_file()`)으로 오간다. 앨범을 띄워둔 채 챕터를 자식 노드로 얹는 방식은 쓰지 않는다 — 4개 챕터를 독립적으로 만드는 이 프로젝트에선, 매번 새 씬을 로드/언로드하는 단순한 모델이 메모리 누수·노드 정리 실수 위험이 적고 첫 Godot 프로젝트에 더 적합하다.
- **`MinigameBase`(`scripts/minigame_base.gd`)**: 모든 챕터 루트 씬이 상속하는 Node 베이스 클래스.
  - `start()`: 챕터 진입 시 호출.
  - `on_clear()`: 클리어 시 호출. **클리어 여부(성공/실패) 신호만 넘긴다 — 점수·시간 등 부가 데이터는 넘기지 않는다.** (스테이지 클리어/실패 형식으로 가기로 확정. 점수제가 필요해지면 그때 `on_clear(data: Dictionary)`로 확장)
  - `on_fail()`: 실패가 있는 챕터에서만 사용.
  - `return_to_album()`: `on_clear()`/`on_fail()` 내부에서 호출. 내부적으로 (1) `ProgressManager.mark_cleared(chapter_id)` 호출 후 (2) `change_scene_to_file("res://scenes/album/album.tscn")` 실행. 즉, 클리어 데이터는 씬 전환 인자로 넘기지 않고 **autoload(ProgressManager)를 경유**해 전달한다 — 씬이 통째로 교체돼도 데이터가 살아남는 유일한 통로이기 때문.
- **`ProgressManager`(autoload)**: 4개 챕터의 클리어 여부를 `user://progress.cfg`(Godot `ConfigFile`)에 저장. 앨범 화면은 이 상태를 읽어 사진을 "클리어 버전"으로 교체하고, 4개 전부 클리어 시 엔딩 씬으로 분기.
- **이유**: 챕터별 라운드(코나타/카가미/미유키/츠카사)를 독립적으로 기획·구현해도 앨범 허브·엔딩과의 연결점(전환 방식, 데이터 전달 통로)이 처음부터 고정되어 있어, 나중에 통합할 때 재설계가 필요 없음.

## 5. 네이밍 컨벤션

- 씬/스크립트 파일: `snake_case.tscn` / `snake_case.gd`
- 노드/클래스명: `PascalCase`
- 챕터 폴더명은 캐릭터 한글 발음 로마자 표기(`konata`, `kagami`, `miyuki`, `tsukasa`)로 통일

## 6. 다음 단계 (보류된 작업)

- 실제 Godot 프로젝트 생성 및 위 폴더 구조 스캐폴딩 (현재 라운드에서는 문서만 — 사용자 결정)
- 챕터별 세부 기획 문서 (코나타부터 순차 진행 예정)
- 배포 전 법적 검토(음원/보이스 사용 범위) — 동인 배포 전제 하에 별도 확인 필요
