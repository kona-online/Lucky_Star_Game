class_name MinigameBase
extends Node2D
## 모든 챕터 루트 씬이 상속하는 공통 베이스 클래스.
## 세부 설계: _game_output/planning-artifacts/architecture-dev-environment.md §4

var _is_running: bool = false

## 챕터 진입 시 호출. 서브클래스에서 오버라이드해 초기화 수행.
func start() -> void:
	_is_running = true

## 클리어 조건 달성 시 호출. 클리어 신호만 전달 — 점수/시간 데이터 없음.
func on_clear() -> void:
	_is_running = false
	return_to_album()

## 실패 조건 달성 시 호출. 서브클래스에서 오버라이드해 UI 분기 처리.
func on_fail() -> void:
	_is_running = false

## on_clear() 경로에서만 호출. ProgressManager 업데이트 후 앨범으로 씬 전환.
## !! on_fail() 경로에서 절대 호출 금지 — mark_cleared()가 내부에 있어 오기록됨.
func return_to_album() -> void:
	push_warning("MinigameBase.return_to_album() called without chapter override")
	get_tree().change_scene_to_file("res://scenes/album/album.tscn")
