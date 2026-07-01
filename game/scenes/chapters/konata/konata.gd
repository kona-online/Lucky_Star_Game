extends MinigameBase
## 코나타 챕터 — 졸음 자원관리 + 반사신경
## 세부 기획: _game_output/planning-artifacts/chapter-design-konata.md

const CHAPTER_ID := "konata"

enum TeacherState { TEACHING, CHECKING, FAKE }
enum SideAction { IDLE, GAMING, READING_MANGA }

var class_timer: float = 120.0
var drowsiness: float = 0.0
var teacher_state: TeacherState = TeacherState.TEACHING
var side_action_state: SideAction = SideAction.IDLE

func start() -> void:
	super.start()
	class_timer = 120.0
	drowsiness = 0.0
	teacher_state = TeacherState.TEACHING
	side_action_state = SideAction.IDLE
	_schedule_next_teacher_turn()

func _process(delta: float) -> void:
	if not _is_running:
		return
	class_timer -= delta
	drowsiness = clamp(drowsiness + _get_drowsiness_rate() * delta, 0.0, 100.0)
	if teacher_state != TeacherState.CHECKING and drowsiness >= 100.0:
		_trigger_fail("sleep")
	if class_timer <= 0.0:
		on_clear()

func _get_drowsiness_rate() -> float:
	var elapsed := 120.0 - class_timer
	if elapsed < 40.0:
		return 3.0
	elif elapsed < 80.0:
		return 5.0
	else:
		return 7.5

func _schedule_next_teacher_turn() -> void:
	pass  # TODO: 랜덤 딜레이 후 _on_teacher_check() 호출

func _on_teacher_check() -> void:
	pass  # TODO: CHECKING / FAKE 분기 판정 구현

func _trigger_fail(_reason: String) -> void:
	on_fail()

func on_clear() -> void:
	_is_running = false
	return_to_album()

func on_fail() -> void:
	_is_running = false
	# TODO: 실패 연출 후 "다시 도전" / "앨범으로" UI 표시

func return_to_album() -> void:
	ProgressManager.mark_cleared(CHAPTER_ID)
	get_tree().change_scene_to_file("res://scenes/album/album.tscn")
