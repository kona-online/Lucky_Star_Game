# 코나타 챕터 세부 기획 — 졸음 자원관리 + 반사신경

- **작성일**: 2026-07-01
- **상태**: 확정
- **MinigameBase 구현 대상**: `scenes/chapters/konata/konata.gd`

---

## 1. 챕터 개요

| 항목 | 내용 |
|---|---|
| 장르 | 자원관리 + 반사신경 |
| 배경 설정 | 이즈미 코나타, 쿠로이 나나코 선생님 수업 중 졸다가 들킬 위기 |
| 핵심 목표 | 수업 타이머(120초)가 끝날 때까지 졸음 게이지가 MAX에 도달하지 않고, 나나코 선생님에게 졸고 있는 모습을 들키지 않기 |
| 플레이 시간 | 약 2~3분 (120초 수업 + 연출) |
| 실패 시 재시도 | 가능 (앨범으로 돌아가지 않고 챕터 내에서 재시작 선택지 제공) |

---

## 2. 핵심 상태 변수

| 변수 | 타입 | 설명 |
|---|---|---|
| `class_timer` | float | 남은 수업 시간(초). 120.0에서 카운트다운. 0이 되면 클리어. |
| `drowsiness` | float 0.0~100.0 | 졸음 게이지. 시간이 지남에 따라 자동 증가. 100.0 도달 시 즉시 실패. |
| `teacher_state` | enum | `TEACHING` / `CHECKING` / `FAKE` |
| `side_action_state` | enum | `IDLE` / `NOTE_PASSING` / `DOODLING` |

---

## 3. 졸음 게이지 시스템

### 자동 증가율

수업 진행 시간에 따라 단계적으로 빨라진다.

> **구현 주의**: 아래 표의 "경과 시간"은 `elapsed = 120.0 - class_timer`로 계산한다 (`class_timer`는 카운트다운이므로 직접 사용하지 않는다).

| 수업 경과 시간 (elapsed) | 초당 증가량 |
|---|---|
| 0 ≤ elapsed < 40초 | +3.0 / 초 |
| 40 ≤ elapsed < 80초 | +5.0 / 초 |
| 80 ≤ elapsed | +7.5 / 초 |

### 구간별 의미

| 게이지 구간 | 코나타 상태 | 시각 연출 |
|---|---|---|
| 0 ~ 49 | 멀쩡하게 앉아 있음 | 눈 동그랗게 뜸 |
| 50 ~ 69 | 슬슬 눈이 감기는 중 | 눈꺼풀이 절반 내려옴 |
| 70 ~ 89 | 많이 졸림 — **위험 구간** | 눈꺼풀 거의 닫힘, 고개 까딱 |
| 90 ~ 99 | 직전 | 눈 완전히 감김, 기절 직전 연출 |
| 100 | 완전히 잠들어버림 | FAIL 트리거 |

---

## 4. 나나코 선생님 뒤돌아보기 시스템

### 상태 흐름

```
TEACHING ──(랜덤 딜레이 후)──► CHECKING or FAKE
    ▲                               │
    └───────────(판정 종료 후)──────┘
```

### 상태 상세

| 상태 | 지속 시간 | 설명 |
|---|---|---|
| `TEACHING` | 랜덤 3~8초 (후반\* 3~5초) | 칠판을 보며 수업 진행. 플레이어 액션 가능 구간. |
| `CHECKING` | 1.5~2.0초 (랜덤) | 나나코가 뒤를 돌아보며 학생들을 확인. **CHECKING 상태 전체 지속 시간이 판정 윈도우**. |
| `FAKE` | 0.8초 | 돌아보는 척 하다가 돌아서지 않고 다시 TEACHING. 판정 없음. |

\* **"후반"의 정의**: `class_timer < 40.0` (경과 80초 이상)일 때 TEACHING 간격을 3~5초로 단축.

### 페이크 확률

| 수업 경과 시간 (elapsed) | FAKE 확률 |
|---|---|
| 0 ≤ elapsed < 40초 | 0% |
| 40 ≤ elapsed < 80초 | 30% |
| 80 ≤ elapsed | 50% |

### CHECKING 판정 규칙

`CHECKING` 상태 진입 시 다음 우선순위 순서로 판정:

1. `side_action_state` ≠ `IDLE` → **"수업 중 딴짓 발각"** = 즉시 FAIL (졸음 게이지 무관)
2. `drowsiness` ≥ 70 이고, **CHECKING 지속 시간 전체** 내 **각성 키 미입력** → **"졸고 있는 거 들킴"** = FAIL
3. `drowsiness` ≥ 70 이고, CHECKING 중 **각성 키 입력** → 안전 (퍼뜩 깬 연출)
4. `drowsiness` < 70 → 자동 안전 (게이지가 낮으면 들키지 않음)

**CHECKING 중 `drowsiness` 100 도달 처리**: CHECKING 상태가 활성인 동안은 `drowsiness = 100` 판정을 유예한다. CHECKING 종료 후에도 100이면 그때 "잠들어버림" FAIL 처리. (CHECKING 판정이 먼저 해소된 뒤 drowsiness 100 체크를 순차 실행해 충돌 방지.)

> **설계 의도**: 게이지를 낮게 유지하면 반사신경 판정 없이도 안전하지만, 후반부 증가율 때문에 항상 낮게 유지할 수는 없다. 위험 구간(70+)에 진입했을 때만 반사신경이 요구되는 구조. 또한 사이드 액션(쪽지/낙서) 중 CHECKING이 발생하면 게이지와 무관하게 즉시 FAIL — 사이드 액션은 발동 시 리스크를 전적으로 감수하는 설계.

---

## 5. 플레이어 액션

### 5-1. 각성 키 (스페이스바 또는 좌클릭)

| 항목 | 내용 |
|---|---|
| 사용 가능 조건 | 항상 (쿨다운 없음) |
| 효과 | `drowsiness` -15 감소 |
| CHECKING 중 사용 | -15 + 추가 -5 (총 -20), 판정 안전 확정 |
| 시각 연출 | 코나타가 번쩍 눈을 뜨는 1프레임 컷 |

> 쿨다운이 없으므로 스팸 가능. 그러나 스팸해도 -15/회 × 입력 빈도만큼만 감소하므로 자동 증가율을 무력화하지 않도록 수치 조정 필요 (playtesting 시 확인).

### 5-2. 쪽지 돌리기 (E키)

| 항목 | 내용 |
|---|---|
| 사용 가능 조건 | `teacher_state` = `TEACHING` & `side_action_state` = `IDLE` & 쿨다운 없음 |
| 모션 지속 시간 | 0.5초 (`side_action_state` = `NOTE_PASSING`) |
| 성공 효과 | `drowsiness` -10 감소, `side_action_state` = `IDLE` 복귀 |
| 실패 조건 | 모션 중 `CHECKING` 전환 발생 (CHECKING이 모션 완료 프레임과 동시에 발생해도 CHECKING 우선 → FAIL) |
| 취소 | **없음** — 발동한 순간 완료까지 취소 불가 |
| 쿨다운 | 성공 후 15초 |
| 시각 연출 | 코나타가 쪽지를 옆으로 건네는 스프라이트 |

### 5-3. 낙서하기 (Q키)

| 항목 | 내용 |
|---|---|
| 사용 가능 조건 | `teacher_state` = `TEACHING` & `side_action_state` = `IDLE` & 쿨다운 없음 |
| 모션 지속 시간 | 1.5초 (`side_action_state` = `DOODLING`) |
| 성공 효과 | `drowsiness` -20 감소, `side_action_state` = `IDLE` 복귀 |
| 실패 조건 | 모션 중 `CHECKING` 전환 발생 (동시 발생 시 CHECKING 우선 → FAIL) |
| 취소 | **없음** — 발동한 순간 완료까지 취소 불가 |
| 쿨다운 | 성공 후 25초 |
| 시각 연출 | 코나타가 고개를 숙이고 낙서하는 스프라이트 |

> 쪽지(빠름·낮은 리워드)와 낙서(느림·높은 리워드)로 리스크/리워드 차등화. 사이드 액션은 발동 후 취소 불가 — 타이밍을 잘못 재면 낮은 게이지에도 FAIL할 수 있다.

---

## 6. 화면 구성

```
┌────────────────────────────────────────────────┐
│  [남은 시간: 01:45]          [졸음 ████░░░░ 52%] │  ← HUD 상단
├────────────────────────────────────────────────┤
│                                                │
│        [나나코 선생님 — 칠판 앞 스프라이트]        │  ← 배경 상단
│                                                │
│                                                │
│         [코나타 — 책상 앞 스프라이트]             │  ← 배경 하단 중앙
│                                                │
├────────────────────────────────────────────────┤
│  [각성: SPACE/클릭]  [쪽지: E ■8s]   [낙서: Q ──] │  ← 액션 UI 하단
└────────────────────────────────────────────────┘
```

**졸음 게이지 표시**: 오른쪽에서 왼쪽으로 줄어드는 바. 70 이상 구간은 빨간색으로 표시해 위험 구간임을 시각적으로 인지하도록.

**나나코 뒤돌아보기 예고**: TEACHING 상태 말미 0.3초 동안 "삐빅" SFX 또는 나나코 스프라이트 어깨가 움직이는 예비 동작 1프레임이 발생한다. 예비 동작 0.3초 완료 후 CHECKING 또는 FAKE 상태로 전환. FAKE와 CHECKING의 예비 동작은 동일하게 — 구분 불가. (즉, 0.3초는 TEACHING 상태에 포함되며 FAKE/CHECKING 지속 시간에는 산입하지 않는다.)

---

## 7. 클리어 / 실패 조건 요약

| 조건 | 결과 |
|---|---|
| `class_timer` = 0.0 도달 | **CLEAR** |
| `drowsiness` = 100.0 도달 | FAIL — "코나타 완전히 잠들어버림" |
| CHECKING 중 `drowsiness` ≥ 70 & 각성 키 미입력 | FAIL — "졸고 있는 거 들킴" |
| CHECKING 중 사이드 액션 모션 중 | FAIL — "딴짓 들킴" |

**실패 시 흐름**:
1. 실패 연출 (나나코 "이즈미~!" 대사 + 코나타 깜짝 놀람 컷)
2. "다시 도전" / "앨범으로 돌아가기" 선택지 표시
3. "다시 도전" → `start()` 재호출, 게이지·타이머 초기화
4. "앨범으로 돌아가기" → `on_fail()` → `get_tree().change_scene_to_file("res://scenes/album/album.tscn")` 직접 호출. `return_to_album()`을 **사용하지 않는다** — 그 함수는 `mark_cleared()`를 포함하므로 실패 경로에서 호출하면 클리어 기록이 남아버린다.

---

## 8. MinigameBase 인터페이스 구현

```gdscript
# konata.gd (MinigameBase 상속)

func start():
    class_timer = 120.0
    drowsiness = 0.0
    teacher_state = TeacherState.TEACHING
    side_action_state = SideAction.IDLE
    _schedule_next_teacher_turn()

func _process(delta):
    if not _is_running: return
    class_timer -= delta
    drowsiness = clamp(drowsiness + _get_drowsiness_rate() * delta, 0.0, 100.0)
    if drowsiness >= 100.0:
        _trigger_fail("sleep")
    if class_timer <= 0.0:
        on_clear()

func on_clear():
    _is_running = false
    return_to_album()

func on_fail():
    _is_running = false
    # 실패 연출 후 UI 선택:
    #   "다시 도전" → start() 호출
    #   "앨범으로" → get_tree().change_scene_to_file("res://scenes/album/album.tscn") 직접 호출
    #   !! 절대 return_to_album() 호출 금지 — mark_cleared()가 포함되어 있어 클리어 기록이 남는다

func return_to_album():
    # on_clear() 경로에서만 호출. on_fail() 경로에서는 호출하지 않는다.
    ProgressManager.mark_cleared("konata")
    get_tree().change_scene_to_file("res://scenes/album/album.tscn")
```

> **on_fail() 경로에서 `return_to_album()` 호출 금지**: `return_to_album()`은 내부적으로 `ProgressManager.mark_cleared()`를 포함하므로, 실패 경로에서 이 함수를 호출하면 클리어하지 않았는데도 앨범에 "클리어 완료" 사진이 표시된다. 실패 후 앨범 복귀는 반드시 `change_scene_to_file()`을 직접 호출한다.

---

## 9. 미결 사항 / 다음 라운드 이관

- **수치 밸런싱**: 각성 키 감소량(-15), 증가율, 페이크 확률 등은 실제 프로토타입 playtesting 후 조정 필요 — 이 문서의 수치는 초안.
- **Dialogic 사용 여부**: 실패 대사("이즈미~!")를 Dialogic으로 처리할지, 단순 Label 애니메이션으로 처리할지 — 코나타 챕터 프로토타입 제작 시 결정.
- **쪽지·낙서 성공 연출**: 쪽지 받은 상대 캐릭터(미유키? 카가미?) 표시 여부 — 스코프 초과 우려, 보류.
- **배경 에셋 범위**: 나나코 스프라이트(TEACHING / CHECKING / FAKE 3개), 코나타 스프라이트(게이지 구간별 4개), 교실 배경 1장 최소 필요.
