# Lucky Star Game (가제)

> 러키스타(らき☆すた) 팬이 만드는, 비상업 동인 팬게임 기획/개발 저장소입니다.

## 소개

2027년이면 애니메이션 「러키스타」 방영 20주년을 맞습니다. 이 게임은 그 시간의 흐름을 게임의 형식 자체로 담아낸 팬게임입니다.

> 어른이 된 코나타가 사진앨범을 연다. 빛바랜 사진 네 장 — 그게 곧 네 개의 챕터다.

플레이어는 사진 한 장 한 장을 통해 코나타·카가미·미유키·츠카사, 네 친구의 고등학교 시절로 돌아가 각자의 색깔이 담긴 미니게임을 플레이합니다.

## 게임 구성

**장르**: 캐릭터별 미니게임 컬렉션 (메타게임 구조)

**프레임**: 성인이 된 코나타가 사진앨범을 여는 것으로 시작. 네 장의 사진(=네 챕터)은 원하는 순서로 플레이할 수 있고, 클리어하면 사진이 "클리어 버전"으로 바뀐다.

| 챕터 | 장르 | 컨셉 |
|---|---|---|
| 코나타 | 자원관리 + 반사신경 | 나나코 선생님 수업 중 졸음 게이지를 관리하다, 선생님이 뒤돌아보면 깨어나야 한다 |
| 카가미 | 스테이지형 QTE | '오늘의 헛소리' — 매번 다른 친구의 엉뚱함에 정확한 타이밍으로 츳코미를 날린다 |
| 미유키 | 트리비아 퀴즈 | 걸어다니는 백과사전다운 정직한 지식 퀴즈 |
| 츠카사 | 카루타 그림 맞추기 | 빡센 세 챕터 사이, 차분한 템포로 숨을 고르는 챕터 |

**엔딩**: 네 장을 모두 클리어하면, 어른이 된 카가미·츠카사·미유키가 밖에서 코나타를 기다리다 부른다. 코나타가 "지금 갈게~" 하며 나가고, 네 명이 한 컷에 모이는 순간 — 그들은 다시 고등학생 시절의 모습으로 그려진다.

## 개발 현황

- [x] 장르 / 프레임 / 4챕터 / 엔딩 기획 확정
- [x] 개발 환경 확정 ([`_game_output/planning-artifacts/architecture-dev-environment.md`](_game_output/planning-artifacts/architecture-dev-environment.md))
- [x] 챕터별 세부 기획 완료
  - [x] 코나타 — 졸음 자원관리 + 반사신경 ([기획서](_game_output/planning-artifacts/chapter-design-konata.md))
  - [x] 카가미 — 스테이지형 QTE 츳코미 ([기획서](_game_output/planning-artifacts/chapter-design-kagami.md))
  - [x] 미유키 — 트리비아 퀴즈 ([기획서](_game_output/planning-artifacts/chapter-design-miyuki.md))
  - [x] 츠카사 — 카루타 그림 맞추기 ([기획서](_game_output/planning-artifacts/chapter-design-tsukasa.md))
- [ ] Godot 프로젝트 스캐폴딩 (폴더 구조 생성, 공통 시스템 구현)
- [ ] 챕터별 프로토타입 개발
- [ ] 앨범 허브 + 엔딩 씬 개발

## 개발 환경

- **엔진**: Godot 4
- **플랫폼**: PC(Windows) 전용
- 자세한 내용은 [`_game_output/planning-artifacts/architecture-dev-environment.md`](_game_output/planning-artifacts/architecture-dev-environment.md) 참고

## 저작권 고지

이 프로젝트는 애니메이션 「러키스타(らき☆すた)」를 원작으로 하는 **비공식 2차 창작 팬게임**이며, **비상업적으로 동인 배포**될 예정입니다. 원작의 캐릭터·세계관에 대한 저작권은 원저작자 및 관련 권리자에게 있으며, 본 프로젝트는 원작자/제작위원회와 아무런 관련이 없습니다.
