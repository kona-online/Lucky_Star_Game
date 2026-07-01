extends Node
## 챕터별 클리어 상태를 영구 저장/로드하는 싱글톤.
## 세이브 경로: user://progress.cfg
## Windows 실제 경로: %APPDATA%\Godot\app_userdata\Lucky Star Game\progress.cfg

const SAVE_PATH := "user://progress.cfg"
const SECTION := "chapters"
const CHAPTER_IDS := ["konata", "kagami", "miyuki", "tsukasa"]

var _config: ConfigFile

func _ready() -> void:
	_config = ConfigFile.new()
	_config.load(SAVE_PATH)  # 파일 없으면 ERR_FILE_NOT_FOUND — 무시하고 빈 상태로 시작

func mark_cleared(chapter_id: String) -> void:
	_config.set_value(SECTION, chapter_id, true)
	_config.save(SAVE_PATH)

func is_cleared(chapter_id: String) -> bool:
	return _config.get_value(SECTION, chapter_id, false)

func all_cleared() -> bool:
	for id in CHAPTER_IDS:
		if not is_cleared(id):
			return false
	return true

func reset_all() -> void:
	for id in CHAPTER_IDS:
		_config.set_value(SECTION, id, false)
	_config.save(SAVE_PATH)
