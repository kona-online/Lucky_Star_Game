extends MinigameBase
## 카가미 챕터 — 스테이지형 QTE 츳코미
## 세부 기획: _game_output/planning-artifacts/chapter-design-kagami.md

const CHAPTER_ID := "kagami"

enum StagePhase { BUILDUP, WINDOW_OPEN, JUDGING, RESULT }

var stage_num: int = 1
var stage_phase: StagePhase = StagePhase.BUILDUP
var input_time: float = -1.0
var window_duration: float = 1.2

func start() -> void:
	super.start()
	stage_num = 1
	_start_stage(stage_num)

func _start_stage(n: int) -> void:
	_is_running = true
	stage_phase = StagePhase.BUILDUP
	input_time = -1.0
	window_duration = _get_window_duration(n)
	_play_buildup_sequence(n)

func _get_window_duration(n: int) -> float:
	match n:
		1: return 1.2
		2: return 0.9
		3: return 0.6
	return 1.2

func _play_buildup_sequence(_n: int) -> void:
	pass  # TODO: 빌드업 대사 재생, 완료 시 _open_window() 호출

func _open_window() -> void:
	stage_phase = StagePhase.WINDOW_OPEN
	# TODO: 타이밍 바 표시
	await get_tree().create_timer(window_duration).timeout
	if stage_phase == StagePhase.WINDOW_OPEN:  # 이중 호출 방지
		_judge()

func _on_player_input() -> void:
	if stage_phase != StagePhase.WINDOW_OPEN:
		return
	input_time = 0.0  # TODO: _elapsed_since_window_open()
	stage_phase = StagePhase.JUDGING
	_judge()

func _judge() -> void:
	var verdict := _calculate_verdict()
	if verdict == "MISS":
		_play_fail_cutscene()
		on_fail()
	else:
		stage_phase = StagePhase.RESULT
		_play_result_cutscene(verdict)
		if stage_num == 3:
			on_clear()
		else:
			stage_num += 1
			_start_stage(stage_num)

func _calculate_verdict() -> String:
	if input_time < 0.0:
		return "MISS"
	var ratio := input_time / window_duration
	if ratio <= 0.333:
		return "PERFECT"
	return "GOOD"

func _play_fail_cutscene() -> void:
	pass  # TODO: 실패 컷신 연출

func _play_result_cutscene(_verdict: String) -> void:
	pass  # TODO: PERFECT/GOOD 결과 연출

func on_clear() -> void:
	_is_running = false
	return_to_album()

func on_fail() -> void:
	_is_running = false
	# TODO: "다시 도전" → _start_stage(stage_num) / "앨범으로" → change_scene_to_file 직접 호출

func return_to_album() -> void:
	ProgressManager.mark_cleared(CHAPTER_ID)
	get_tree().change_scene_to_file("res://scenes/album/album.tscn")
