---
title: '코나타 챕터 세부 기획 — 졸음 자원관리 + 반사신경'
type: 'planning'
created: '2026-07-01'
status: 'done'
route: 'one-shot'
---

# 코나타 챕터 세부 기획 — 졸음 자원관리 + 반사신경

## Intent

**Problem:** 코나타 챕터의 구체적인 게임 메커니즘(졸음 게이지 수치, 선생님 뒤돌아보기 판정 규칙, 사이드 액티비티 리스크/리워드 구조, MinigameBase 연결 방식)이 정의되어 있지 않아 프로토타입 제작 시 개발자가 설계를 즉흥적으로 결정해야 하는 상황이었다.

**Approach:** 졸음 자원관리(게이지 자동 증가 + 각성 키로 감소)와 반사신경(위험 구간 진입 시 CHECKING 대응)을 분리해 설계했다. 게이지가 낮을 때는 반사신경 판정 없이 자동 안전 → 후반 증가율 상승으로 위험 구간 진입 불가피 → 반사신경 요구의 자연스러운 난이도 커브. 리뷰에서 발견된 12개 구현 모호성(경과 시간 계산 방향, 판정 윈도우 충돌, return_to_album() 경로 오용 위험 등)은 모두 문서 내 패치로 해소했다.

## Suggested Review Order

**핵심 메커니즘**

- 졸음 증가율 테이블 — elapsed 계산 방향 및 경계값(< 부등호) 확인
  [`chapter-design-konata.md:38`](../planning-artifacts/chapter-design-konata.md#L38)

- CHECKING 판정 우선순위 규칙 — side action > drowsiness ≥ 70 > 자동 안전, drowsiness 100 유예 처리
  [`chapter-design-konata.md:84`](../planning-artifacts/chapter-design-konata.md#L84)

- "후반" 임계값 정의 — class_timer < 40.0 (경과 80초)
  [`chapter-design-konata.md:73`](../planning-artifacts/chapter-design-konata.md#L73)

**사이드 액티비티**

- 쪽지/낙서 성공·실패·취소 규칙 — 동시 발생 시 CHECKING 우선, 취소 없음, 완료 시 IDLE 복귀
  [`chapter-design-konata.md:115`](../planning-artifacts/chapter-design-konata.md#L115)

**MinigameBase 연결**

- on_fail() 경로 — return_to_album() 호출 금지 이유 및 올바른 씬 전환 방법
  [`chapter-design-konata.md:178`](../planning-artifacts/chapter-design-konata.md#L178)

**미결 사항**

- 수치 밸런싱·Dialogic 결정 등 다음 라운드로 이관된 항목
  [`chapter-design-konata.md:220`](../planning-artifacts/chapter-design-konata.md#L220)
