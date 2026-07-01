extends MinigameBase
## 츠카사 챕터 — 카루타 그림 맞추기
## 세부 기획: _game_output/planning-artifacts/chapter-design-tsukasa.md

const CHAPTER_ID := "tsukasa"

enum RoundPhase { READY, PLAYING, RESULT }

var round_num: int = 1
var round_phase: RoundPhase = RoundPhase.READY
var targets_remaining: int = 0
var time_remaining: float = 25.0
var current_target_idx: int = -1  # 카드 데이터 ID 기준

func start() -> void:
	super.start()
	round_num = 1
	_start_round(round_num)

func _start_round(n: int) -> void:
	_is_running = true
	round_phase = RoundPhase.READY
	var config := _get_round_config(n)
	time_remaining = config.time_limit
	targets_remaining = config.target_count
	_shuffle_and_display_cards(config.card_count)
	_pick_next_target()
	round_phase = RoundPhase.PLAYING

func _get_round_config(n: int) -> Dictionary:
	match n:
		1: return { "card_count": 9,  "target_count": 2, "time_limit": 25.0 }
		2: return { "card_count": 12, "target_count": 3, "time_limit": 25.0 }
		3: return { "card_count": 16, "target_count": 4, "time_limit": 25.0 }
	return { "card_count": 9, "target_count": 2, "time_limit": 25.0 }

func _process(delta: float) -> void:
	if not _is_running:
		return
	if round_phase != RoundPhase.PLAYING:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		round_phase = RoundPhase.RESULT
		on_fail()

func _on_card_clicked(card_data_id: int) -> void:
	if round_phase != RoundPhase.PLAYING:
		return
	if card_data_id == current_target_idx:
		round_phase = RoundPhase.RESULT
		await _play_correct_effect(card_data_id)
		targets_remaining -= 1
		if targets_remaining == 0:
			if round_num == 3:
				on_clear()
			else:
				round_num += 1
				_start_round(round_num)
		else:
			round_phase = RoundPhase.PLAYING
			_pick_next_target()
	else:
		_play_wrong_effect(card_data_id)

func _shuffle_and_display_cards(_count: int) -> void:
	pass  # TODO: 독립 카드 풀에서 count장 랜덤 배치

func _pick_next_target() -> void:
	pass  # TODO: 남은 목표 카드 중 다음 것을 current_target_idx에 설정

func _play_correct_effect(_card_id: int) -> void:
	pass  # TODO: 카드 제거 애니메이션 (await 필요)

func _play_wrong_effect(_card_id: int) -> void:
	pass  # TODO: 오답 흔들림 이펙트

func on_clear() -> void:
	_is_running = false
	return_to_album()

func on_fail() -> void:
	_is_running = false
	# TODO: "다시 도전" → _start_round(round_num) / "앨범으로" → change_scene_to_file 직접 호출

func return_to_album() -> void:
	ProgressManager.mark_cleared(CHAPTER_ID)
	get_tree().change_scene_to_file("res://scenes/album/album.tscn")
