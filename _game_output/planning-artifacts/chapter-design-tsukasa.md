# 츠카사 챕터 세부 기획 — 카루타 그림 맞추기

- **작성일**: 2026-07-01
- **상태**: 확정
- **MinigameBase 구현 대상**: `scenes/chapters/tsukasa/tsukasa.gd`

---

## 1. 챕터 개요

| 항목 | 내용 |
|---|---|
| 장르 | 카루타 그림 맞추기 (클릭 기반 순발력) |
| 배경 설정 | 히이라기 츠카사, 방 안에서 혼자 카루타 카드를 펼쳐놓고 그림을 보며 맞추는 놀이를 한다 |
| 핵심 목표 | 3라운드를 모두 클리어 — 각 라운드에서 제한 시간 내 지정된 카드를 모두 찾아 클릭한다 |
| 플레이 시간 | 약 2~3분 (라운드 3개, 라운드당 최대 25초) |
| 분위기 | 앞의 코나타(긴장), 카가미(리듬감), 미유키(지식) 챕터 이후 **차분하고 아기자기한 템포로 숨을 고르는** 챕터 |
| 실패 시 재시도 | 라운드 단위 재시도 가능 (실패한 라운드부터 재시작) |

---

## 2. 게임 기본 규칙

카루타 카드가 화면에 뒤집혀(그림이 보이는 상태) 펼쳐져 있다.

- 매 라운드 시작 시 화면 상단에 **"이 카드를 찾아봐요~!"** 와 함께 **목표 카드 그림**이 표시된다.
- 플레이어는 화면에 펼쳐진 카드 중 **목표 카드와 일치하는 것**을 클릭한다.
- 정답 클릭 → 다음 목표 카드 제시 → 반복
- 라운드 내 목표 카드를 모두 찾으면 라운드 클리어

---

## 3. 핵심 상태 변수

| 변수 | 타입 | 설명 |
|---|---|---|
| `round_num` | int 1~3 | 현재 라운드 번호 |
| `round_phase` | enum | `READY` / `PLAYING` / `RESULT` |
| `targets_remaining` | int | 현재 라운드에서 남은 목표 카드 수. 0이 되면 라운드 클리어. |
| `time_remaining` | float | 현재 라운드 남은 시간(초). 0 도달 시 라운드 실패. |
| `current_target_idx` | int | 지금 찾아야 할 목표 카드의 인덱스 (카드 데이터 배열 기준). |

---

## 4. 라운드 구성

### 라운드 레이아웃

카드는 격자 배치. 라운드마다 카드 수와 제한 시간이 달라진다.

| 라운드 | 카드 수 (격자) | 찾아야 할 카드 수 | 제한 시간 |
|---|---|---|---|
| 1 | 9장 (3×3) | 2장 | 25초 |
| 2 | 12장 (3×4) | 3장 | 25초 |
| 3 | 16장 (4×4) | 4장 | 25초 |

> 라운드가 진행될수록 카드 수가 늘어나 찾기 어려워진다. 제한 시간은 동일하게 유지해 단순 비교로 체감 난이도를 조절.

### 카드 배치

- 각 라운드는 **독립적인 카드 풀**에서 그 라운드에 필요한 수만큼 카드를 새로 뽑는다 (이전 라운드에서 제거된 카드가 다음 라운드로 이어지지 않음).
- 각 라운드 시작 시 뽑힌 카드의 위치는 **랜덤 셔플**.
- 목표 카드는 반드시 해당 라운드 배치에 포함된다 (찾을 수 없는 상황 불가).
- 같은 그림의 카드는 없다 — 모든 카드는 고유한 그림.
- **카드 식별자**: 그리드 위치(위치 인덱스)가 아닌 **카드 데이터 ID**로 동일성 판별. `current_target_idx`와 클릭된 카드 비교는 데이터 ID 기준.

### 목표 카드 순서

라운드 내에서 목표 카드는 **순차 제시**. 한 번에 하나씩 표시되며, 클릭 성공 시 다음 목표 카드로 넘어간다.

예시 (라운드 2, 3장 찾기):
```
[목표: 고양이 그림] → 클릭 성공 → [목표: 별 그림] → 클릭 성공 → [목표: 케이크 그림] → 클릭 성공 → 라운드 클리어
```

---

## 5. 입력 판정

### 정답 클릭

- 화면에 표시된 목표 카드(`current_target_idx`)와 **동일한 카드**를 클릭한 경우.
- 정답 시: 클릭한 카드 뒤집힘(제거) 연출 + 짧은 효과음 + 다음 목표 카드로 진행.

### 오답 클릭

- 목표와 다른 카드를 클릭한 경우.
- **패널티 없음** — 오답 클릭은 카드를 제거하지 않고, 시간 감소도 없다. 단, 시간이 계속 흐르므로 반복 오답은 자연스럽게 시간 압박이 된다.
- 오답 시: 짧은 "틀림" 이펙트(카드 살짝 흔들림 or 효과음)만 표시.

> **패널티 없음 설계 의도**: 이 챕터는 긴장을 푸는 구간. 오답에 강한 페널티를 주면 분위기가 깨진다. 시간 제한만으로 충분히 도전적.

---

## 6. 화면 구성

**시점**: 카루타 카드가 깔린 책상/바닥을 위에서 내려다보는 탑뷰. 츠카사 캐릭터는 화면 한쪽 구석에 작게 표시.

```
┌─────────────────────────────────────────────────────┐
│  [라운드 1/3]        [목표: 🐱]        [⏱ 18.2s]   │ ← 상단 HUD
│                                                     │
│  ┌──┐ ┌──┐ ┌──┐      ← 카드 그리드 (3×3 예시)      │
│  │🌸│ │⭐│ │🎂│                                    │
│  └──┘ └──┘ └──┘                                    │
│  ┌──┐ ┌──┐ ┌──┐                                    │
│  │🐠│ │🐱│ │🎵│      ← 목표 카드(🐱)가 여기 있음    │
│  └──┘ └──┘ └──┘                                    │
│  ┌──┐ ┌──┐ ┌──┐                                    │
│  │🎈│ │🌙│ │🌺│                                    │
│  └──┘ └──┘ └──┘                                    │
│                      [츠카사 — 우하단 소형]           │
└─────────────────────────────────────────────────────┘
```

**목표 카드 표시**: 상단 HUD 중앙에 현재 찾아야 할 카드 그림을 크게 표시. "이 카드를 찾아봐요~!" 텍스트와 함께.

**카드 상태**:
- 기본: 그림이 보이는 상태
- 정답 클릭 후: 카드가 사라지는 연출 (뒤집히거나 페이드아웃)
- 오답 클릭: 살짝 흔들리는 이펙트

**타이머**: 상단 우측 숫자+바. 5초 이하 시 빨간색.

---

## 7. 클리어 / 실패 조건 요약

| 조건 | 결과 |
|---|---|
| 라운드 3 목표 카드 전부 클릭 완료 | **챕터 CLEAR** |
| `time_remaining` = 0.0 도달 (목표 카드 미완료) | 라운드 FAIL |

**라운드 실패 시 흐름**:
1. 실패 연출 (츠카사 "앗, 시간이 다 됐어…!" 대사)
2. "다시 도전" / "앨범으로 돌아가기" 선택지
3. "다시 도전" → 실패한 라운드부터 재시작 (`round_num` 유지, 카드 배치 재셔플)
4. "앨범으로 돌아가기" → `get_tree().change_scene_to_file("res://scenes/album/album.tscn")` 직접 호출 (`return_to_album()` **호출 금지**)

---

## 8. MinigameBase 인터페이스 구현

```gdscript
# tsukasa.gd (MinigameBase 상속)

func start():
    round_num = 1
    _start_round(round_num)

func _start_round(n: int):
    _is_running = true             # retry 경로에서도 반드시 복구
    round_phase = RoundPhase.READY
    var config = _get_round_config(n)  # {card_count, target_count, time_limit=25}
    time_remaining = config.time_limit
    targets_remaining = config.target_count
    _shuffle_and_display_cards(config.card_count)  # 독립 풀에서 새로 뽑아 배치
    _pick_next_target()            # current_target_idx 설정 (카드 데이터 ID 기준)
    round_phase = RoundPhase.PLAYING
    # READY → PLAYING 전환은 동기 처리 — 전환 직후 입력은 PLAYING으로 판정됨 (의도된 동작)

func _process(delta):
    if not _is_running: return     # on_fail() 후 timeout 이중 호출 방지
    if round_phase != RoundPhase.PLAYING: return
    time_remaining -= delta
    if time_remaining <= 0.0:
        time_remaining = 0.0
        round_phase = RoundPhase.RESULT  # 클릭 이중 처리 차단
        on_fail()

func _on_card_clicked(card_data_id: int):
    if round_phase != RoundPhase.PLAYING: return  # READY/RESULT 중 클릭 무시
    if card_data_id == current_target_idx:         # 데이터 ID로 비교
        round_phase = RoundPhase.RESULT            # 정답 처리 중 추가 클릭 차단
        await _play_correct_effect(card_data_id)  # 카드 제거 애니메이션 완료 대기
        targets_remaining -= 1
        if targets_remaining == 0:
            if round_num == 3:
                on_clear()
            else:
                round_num += 1
                _start_round(round_num)  # 애니메이션 완료 후 다음 라운드
        else:
            round_phase = RoundPhase.PLAYING  # 다음 목표 카드로 진행
            _pick_next_target()
    else:
        _play_wrong_effect(card_data_id)  # 패널티 없음, 이펙트만. round_phase 변경 없음.

func on_clear():
    _is_running = false
    return_to_album()

func on_fail():
    _is_running = false
    # 실패 연출 후 UI 선택:
    #   "다시 도전" → _start_round(round_num) 호출 (round_num 유지, 카드 재셔플)
    #   "앨범으로" → get_tree().change_scene_to_file("res://scenes/album/album.tscn") 직접 호출
    #   !! 절대 return_to_album() 호출 금지

func return_to_album():
    # on_clear() 경로에서만 호출.
    ProgressManager.mark_cleared("tsukasa")
    get_tree().change_scene_to_file("res://scenes/album/album.tscn")
```

---

## 9. 미결 사항 / 다음 라운드 이관

- **카드 그림 에셋**: 라운드 3 기준 16종의 고유 그림 필요. 아기자기한 일러스트 스타일로 츠카사 성격과 어울리게. 구체적 소재는 에셋 제작 시 결정.
- **카드 그리드 크기**: 해상도/화면 비율에 따라 카드 크기 조정 필요 — Godot 프로젝트 생성 후 확인.
- **빌드업 연출**: 라운드 시작 시 츠카사 대사("자, 찾아봐요~!")와 카드 배치 슬라이드인 연출 — Dialogic 여부는 다른 챕터와 동일하게 결정.
- **카드 데이터 구조**: 그림 배열을 GDScript 하드코딩 vs Resource 파일 — 프로토타입 시 결정.
- **라운드 간 연출**: 라운드 클리어 후 "잘했어요~" 대사 + 짧은 전환 연출 여부.
- **부분 진행 저장 없음**: `ProgressManager`는 챕터 전체 클리어 시에만 업데이트. 라운드 1·2 완료 후 라운드 3 실패 종료 시 저장되는 진행 없음 — 의도된 설계.
