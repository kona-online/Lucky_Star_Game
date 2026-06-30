---
title: '개발 환경 기획 — 엔진/플랫폼/프로젝트 구조 확정'
type: 'chore'
created: '2026-06-30'
status: 'done'
route: 'one-shot'
---

# 개발 환경 기획 — 엔진/플랫폼/프로젝트 구조 확정

## Intent

**Problem:** 러키스타 팬게임(주인공 4인방 미니게임 컬렉션) 제작을 시작하기 전, 엔진·플랫폼·프로젝트 구조에 대한 기준이 없어 이후 챕터별(코나타/카가미/미유키/츠카사) 기획이 흔들릴 위험이 있었다.

**Approach:** Godot 4 + PC(Windows) 전용으로 엔진/플랫폼을 확정하고, 폴더 구조와 챕터 간 공통 인터페이스(`MinigameBase`, `ProgressManager`)를 설계 문서로 정리했다. 사용자 요청에 따라 이번 라운드는 문서 작업까지만 진행하고, 실제 Godot 프로젝트 생성은 다음 라운드로 보류한다.

## Suggested Review Order

- 엔진 선정 근거와 제외된 후보 — 비상업 동인 배포, 첫 게임 진입장벽을 기준으로 선택
  [`architecture-dev-environment.md:7`](../planning-artifacts/architecture-dev-environment.md#L7)

- 제안된 프로젝트 폴더 구조 — 챕터별 독립 기획이 가능하도록 미리 분리
  [`architecture-dev-environment.md:29`](../planning-artifacts/architecture-dev-environment.md#L29)

- 챕터 간 공통 시스템(`MinigameBase`, `ProgressManager`) — 씬 전환 방식·클리어 데이터 전달 경로까지 확정
  [`architecture-dev-environment.md:70`](../planning-artifacts/architecture-dev-environment.md#L70)

- 보류된 다음 단계 — 실제 프로젝트 생성은 사용자 결정에 따라 다음 라운드로
  [`architecture-dev-environment.md:87`](../planning-artifacts/architecture-dev-environment.md#L87)

- 검토에서 나왔으나 이번 라운드 범위 밖인 항목들
  [`deferred-work.md:7`](deferred-work.md#L7)
