---
title: '미유키 챕터 세부 기획 — 트리비아 퀴즈'
type: 'planning'
created: '2026-07-01'
status: 'done'
route: 'one-shot'
---

# 미유키 챕터 세부 기획 — 트리비아 퀴즈

## Intent

**Problem:** 미유키 챕터의 퀴즈 메커니즘(문제 진행 흐름, 시간초과/클릭 동시 처리, 판정 기준, MinigameBase 연결)이 정의되지 않아 구현 기준이 없었다.

**Approach:** 5문제 4지선다, 문제당 10초 제한, 3/5 이상 정답 시 클리어 구조로 설계. 미유키의 박식한 성격을 살린 정중한 출제 대사와 단계별 피드백 연출 포함. 리뷰에서 발견된 10개 모호성(시간초과+클릭 동시 처리 재진입 버그, SHOWING 중 타이머 소비, 플로우차트 누락, 5/5 분기 미정의, start() 초기화 누락, 타이머 바 방향 등) 모두 패치 완료.

## Suggested Review Order

**퀴즈 흐름**

- 플로우차트 — SHOWING 포함 전체 상태 전환 및 _advance() 호출 시점
  [`chapter-design-miyuki.md:30`](../planning-artifacts/chapter-design-miyuki.md#L30)

**핵심 코드 패턴**

- `_on_answer_selected()` / `_on_timeout()` — quiz_phase 선행 전환으로 재진입 차단
  [`chapter-design-miyuki.md:185`](../planning-artifacts/chapter-design-miyuki.md#L185)

- `_show_question()` — ANSWERING 전환 시점에 time_remaining 초기화 (SHOWING 중 소비 방지)
  [`chapter-design-miyuki.md:173`](../planning-artifacts/chapter-design-miyuki.md#L173)

- `_advance()` — correct_count == 5 특별 연출 분기 및 판정
  [`chapter-design-miyuki.md:203`](../planning-artifacts/chapter-design-miyuki.md#L203)

- `start()` — quiz_phase/selected_answer 포함 전체 초기화 (retry 경로 대응)
  [`chapter-design-miyuki.md:166`](../planning-artifacts/chapter-design-miyuki.md#L166)

**미결 사항**

- 문제 확정·5/5 보너스 연출·데이터 구조 결정 항목
  [`chapter-design-miyuki.md:230`](../planning-artifacts/chapter-design-miyuki.md#L230)
