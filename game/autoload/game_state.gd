extends Node
## 세션 전역 상태 (저장 안 됨). 씬 전환 후에도 autoload로 유지.
## ProgressManager(영구 저장)와 역할 분리 — 이쪽은 휘발성 진행 상태만.

var current_chapter: String = ""  # 현재 플레이 중인 챕터 ID
