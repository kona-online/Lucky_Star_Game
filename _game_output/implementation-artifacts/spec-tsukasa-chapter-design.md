---
title: '츠카사 챕터 세부 기획 — 카루타 그림 맞추기'
type: 'planning'
created: '2026-07-01'
status: 'done'
route: 'one-shot'
---

# 츠카사 챕터 세부 기획 — 카루타 그림 맞추기

## Intent

**Problem:** 츠카사 챕터의 카루타 메커니즘(라운드 구성, 카드 식별 방식, 정답/오답 처리 흐름, timeout+클릭 충돌, MinigameBase 연결)이 정의되지 않아 구현 기준이 없었다.

**Approach:** 3라운드(9→12→16장, 찾기 2→3→4장), 라운드당 25초 제한, 순차 목표 제시 방식으로 설계. 오답 패널티 없이 시간 압박만으로 난이도를 조절해 "차분한 템포" 챕터 분위기를 유지. 리뷰에서 발견된 10개 모호성(RESULT→PLAYING 동기 전환 경쟁 조건, 카드 애니메이션 중 클릭 허용, 카드 ID vs 위치 혼동, 카드 풀 라운드 독립성, _is_running 이중 호출, 플레이 시간 기술 오류, 부분 저장 정책 등) 8개 패치, 2개 reject 완료.

## Suggested Review Order

**카드 식별 및 라운드 구성**

- 카드 데이터 ID 기준 동일성 판별, 라운드별 독립 풀 원칙
  [`chapter-design-tsukasa.md:57`](../planning-artifacts/chapter-design-tsukasa.md#L57)

- 라운드별 카드 수·목표 수·제한 시간 테이블
  [`chapter-design-tsukasa.md:46`](../planning-artifacts/chapter-design-tsukasa.md#L46)

**핵심 코드 패턴**

- `_on_card_clicked()` — RESULT 선행 전환 후 await 애니메이션, 정답 후 _pick_next_target()
  [`chapter-design-tsukasa.md:175`](../planning-artifacts/chapter-design-tsukasa.md#L175)

- `_process()` — `_is_running` guard로 on_fail() 후 이중 timeout 방지
  [`chapter-design-tsukasa.md:163`](../planning-artifacts/chapter-design-tsukasa.md#L163)

- `_start_round()` — retry 시 _is_running 복구, 독립 풀 재셔플
  [`chapter-design-tsukasa.md:152`](../planning-artifacts/chapter-design-tsukasa.md#L152)

**미결 사항**

- 카드 에셋·데이터 구조·빌드업 연출·부분 저장 없음 명시
  [`chapter-design-tsukasa.md:208`](../planning-artifacts/chapter-design-tsukasa.md#L208)
