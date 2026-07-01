extends MinigameBase
## 미유키 챕터 — 트리비아 퀴즈
## 세부 기획: _game_output/planning-artifacts/chapter-design-miyuki.md

const CHAPTER_ID := "miyuki"
const PASS_THRESHOLD := 3  # 5문제 중 3개 이상 정답

enum QuizPhase { SHOWING, ANSWERING, FEEDBACK, DONE }

var question_index: int = 0
var correct_count: int = 0
var quiz_phase: QuizPhase = QuizPhase.SHOWING
var selected_answer: int = -1
var time_remaining: float = 10.0

func start() -> void:
	super.start()
	question_index = 0
	correct_count = 0
	quiz_phase = QuizPhase.SHOWING
	selected_answer = -1
	_show_question(question_index)

func _show_question(idx: int) -> void:
	quiz_phase = QuizPhase.SHOWING
	selected_answer = -1
	_display_question_ui(idx)
	await get_tree().create_timer(0.5).timeout
	time_remaining = 10.0  # ANSWERING 전환 시점에 초기화
	quiz_phase = QuizPhase.ANSWERING

func _process(delta: float) -> void:
	if quiz_phase != QuizPhase.ANSWERING:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_on_timeout()

func _on_answer_selected(idx: int) -> void:
	if quiz_phase != QuizPhase.ANSWERING:
		return
	quiz_phase = QuizPhase.FEEDBACK  # 재진입 차단
	selected_answer = idx
	_show_feedback()

func _on_timeout() -> void:
	if quiz_phase != QuizPhase.ANSWERING:
		return
	quiz_phase = QuizPhase.FEEDBACK  # 재진입 차단
	selected_answer = -1
	_show_feedback()

func _show_feedback() -> void:
	var is_correct := (selected_answer == _get_correct_answer(question_index))
	if is_correct:
		correct_count += 1
	_display_feedback_ui(is_correct, selected_answer)
	await get_tree().create_timer(1.5).timeout
	_advance()

func _advance() -> void:
	if question_index < 4:
		question_index += 1
		_show_question(question_index)
	else:
		quiz_phase = QuizPhase.DONE
		if correct_count == 5:
			_play_perfect_cutscene()
		if correct_count >= PASS_THRESHOLD:
			on_clear()
		else:
			on_fail()

func _get_correct_answer(_idx: int) -> int:
	# TODO: 문제 데이터 배열에서 정답 인덱스(0~3) 반환
	return 0

func _display_question_ui(_idx: int) -> void:
	pass  # TODO: 문제+선택지 UI 표시

func _display_feedback_ui(_is_correct: bool, _selected: int) -> void:
	pass  # TODO: 정오답 강조 + 미유키 반응

func _play_perfect_cutscene() -> void:
	pass  # TODO: 5/5 전체 정답 특별 연출

func on_clear() -> void:
	_is_running = false
	return_to_album()

func on_fail() -> void:
	_is_running = false
	# TODO: "다시 도전" → start() / "앨범으로" → change_scene_to_file 직접 호출

func return_to_album() -> void:
	ProgressManager.mark_cleared(CHAPTER_ID)
	get_tree().change_scene_to_file("res://scenes/album/album.tscn")
