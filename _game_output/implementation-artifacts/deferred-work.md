# Deferred Work

<!-- Append-only log of issues found during quick-dev runs that are real but out of scope for the spec that surfaced them. -->

## From `spec-dev-environment.md` (2026-07-01)

- ~~**Godot 버전 고정 확인**~~ → **완료** (2026-07-01): `v4.7.stable.official[5b4e0cb0f]` — architecture-dev-environment.md 및 project.godot에 반영.
- ~~**소스 관리 / 세이브 데이터 제외**~~ → **완료** (2026-07-01): `.gitignore` 생성, `game/.godot/` 및 빌드 결과물 제외 규칙 포함. `user://` 데이터는 AppData에 저장되므로 프로젝트 폴더에 없음 — `.gitignore` 주석으로 명시.
- **법적 검토 범위 확장**: 기존 문서(§6)는 음원/보이스 사용 범위만 언급. 캐릭터 일러스트 자체의 IP 리스크(원작 캐릭터 디자인을 동인 게임에 쓰는 것)도 검토 범위에 포함해야 함 — 배포 전 별도 라운드에서 다룰 것.
