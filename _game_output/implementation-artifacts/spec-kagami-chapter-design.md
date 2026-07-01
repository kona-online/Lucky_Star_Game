---
title: '카가미 챕터 세부 기획 — 스테이지형 QTE 츳코미'
type: 'planning'
created: '2026-07-01'
status: 'done'
route: 'one-shot'
---

# 카가미 챕터 세부 기획 — 스테이지형 QTE 츳코미

## Intent

**Problem:** 카가미 챕터의 QTE 메커니즘(판정 구간 정의, 스테이지 분기 방식, 입력 처리 규칙, MinigameBase 연결 방식)이 정의되지 않아 프로토타입 제작 시 구현 기준이 없는 상태였다.

**Approach:** 3스테이지 순차 구조 + 타이밍 윈도우 판정(PERFECT/GOOD/MISS)으로 설계. 스테이지마다 헛소리 주체(코나타→츠카사→미유키)와 윈도우 길이(1.2→0.9→0.6초)가 달라 자연스러운 난이도 커브를 형성. 리뷰에서 발견된 11개 구현 모호성(판정 이중 호출, GOOD 구간 정의, EARLY/MISS 규칙 충돌, `_is_running` retry 미복구, RESULT 상태 누락 등)은 모두 패치 완료.

## Suggested Review Order

**판정 시스템**

- PERFECT/GOOD 구간 정의 및 EARLY·LATE 입력 처리 규칙
  [`chapter-design-kagami.md:72`](../planning-artifacts/chapter-design-kagami.md#L72)

- 타이밍 바 방향 및 윈도우 가시성 규칙 (빌드업 중 숨김)
  [`chapter-design-kagami.md:152`](../planning-artifacts/chapter-design-kagami.md#L152)

**코드 흐름**

- `_open_window()` 이중 호출 방지 패턴 — 타이머 만료 시 `stage_phase` 확인
  [`chapter-design-kagami.md:191`](../planning-artifacts/chapter-design-kagami.md#L191)

- `_judge()` 내 실패 컷신 선행 호출 및 `stage_phase = RESULT` 입력 차단
  [`chapter-design-kagami.md:203`](../planning-artifacts/chapter-design-kagami.md#L203)

- `_start_stage()` 내 `_is_running = true` — retry 경로에서의 상태 복구
  [`chapter-design-kagami.md:185`](../planning-artifacts/chapter-design-kagami.md#L185)

**스테이지 구성**

- 3개 스테이지 헛소리 대사 초안 및 윈도우 수치
  [`chapter-design-kagami.md:94`](../planning-artifacts/chapter-design-kagami.md#L94)

**미결 사항**

- 대사 확정·Dialogic 결정 등 다음 라운드 이관 항목
  [`chapter-design-kagami.md:236`](../planning-artifacts/chapter-design-kagami.md#L236)
