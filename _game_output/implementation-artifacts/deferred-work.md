# Deferred Work

<!-- Append-only log of issues found during quick-dev runs that are real but out of scope for the spec that surfaced them. -->

## From `spec-dev-environment.md` (2026-07-01)

- **Godot 버전 고정 확인**: 문서는 "최신 stable, 4.4.x 기준"이라고만 적어둠. 실제 프로젝트 생성 라운드에서 설치된 에디터 버전을 확인하고 문서에 정확한 버전을 박아넣을 것.
- **소스 관리 / 세이브 데이터 제외**: `.gitignore` 작성 및 `user://progress.cfg`(세이브 데이터)를 버전관리에서 제외하는 규칙 — 실제 Godot 프로젝트가 생성된 뒤에야 의미가 있으므로 그때 처리.
- **법적 검토 범위 확장**: 기존 문서(§6)는 음원/보이스 사용 범위만 언급. 캐릭터 일러스트 자체의 IP 리스크(원작 캐릭터 디자인을 동인 게임에 쓰는 것)도 검토 범위에 포함해야 함 — 배포 전 별도 라운드에서 다룰 것.
