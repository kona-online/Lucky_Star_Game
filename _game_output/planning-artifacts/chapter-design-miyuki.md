# 미유키 챕터 세부 기획 — 트리비아 퀴즈

- **작성일**: 2026-07-01
- **상태**: 확정
- **MinigameBase 구현 대상**: `scenes/chapters/miyuki/miyuki.gd`

---

## 1. 챕터 개요

| 항목 | 내용 |
|---|---|
| 장르 | 트리비아 퀴즈 (4지선다) |
| 배경 설정 | 다케아라 미유키, "걸어다니는 백과사전"답게 다양한 분야의 지식을 정중하게 출제한다 |
| 핵심 목표 | 5문제 중 3문제 이상 정답 → 클리어 |
| 플레이 시간 | 약 2~3분 (문제당 최대 10초 × 5문제 + 정오답 연출) |
| 실패 시 재시도 | 챕터 전체 재시작 (문제 순서 동일, 답은 기억 안 해줌) |
| 패스 기준 | 5문제 중 3문제 이상 정답 — 지식이 없어도 캐릭터를 즐길 수 있는 난이도 |

---

## 2. 핵심 상태 변수

| 변수 | 타입 | 설명 |
|---|---|---|
| `question_index` | int 0~4 | 현재 문제 번호 (0부터 시작). |
| `correct_count` | int 0~5 | 맞힌 문제 수. 게임 종료 시 클리어/실패 판정에 사용. |
| `quiz_phase` | enum | `SHOWING` / `ANSWERING` / `FEEDBACK` / `DONE` |
| `selected_answer` | int -1~3 | 플레이어가 고른 선택지 인덱스 (0~3). 미선택 = -1. |
| `time_remaining` | float 0.0~10.0 | 현재 문제 남은 시간(초). 0 도달 시 자동 시간초과 처리. |

---

## 3. 퀴즈 진행 흐름

```
[start()]
    │
    ▼
[문제 표시 — SHOWING] (0.5초, 입력 불가)
    │ (0.5초 후 자동 전환)
    ▼
[입력 대기 — ANSWERING] ──(10초 경과)──► [시간초과 — FEEDBACK 전환]
    │ (선택지 클릭)                                   │
    │ quiz_phase = FEEDBACK                           │ quiz_phase = FEEDBACK
    ▼                                                 │
[정오답 피드백 — FEEDBACK] ◄────────────────────────┘
    │ (1.5초 후 _advance() 호출 — 피드백 완료 이후)
    ▼
 question_index < 4? ──(Yes)──► [SHOWING으로 돌아가 다음 문제 표시]
    │ (No, 마지막 문제 피드백 완료 후)
    ▼
 correct_count ≥ 3? ──(Yes)──► on_clear()
    │ (No)
    ▼
 on_fail()
```

**`SHOWING` 단계 (0.5초)**: 문제 텍스트와 선택지가 화면에 슬라이드인. 입력 불가. 미유키 대사 연출 시작.

**`ANSWERING` 단계**: 입력 대기. 타이머 카운트다운. 선택지 클릭 또는 시간초과로 종료.

**`FEEDBACK` 단계 (1.5초)**: 정답 선택지 강조 표시, 미유키 반응 연출. 입력 불가.

---

## 4. 시간초과 처리

`time_remaining` = 0.0 도달 시:

1. `selected_answer` = -1 로 고정 (미선택 상태 유지)
2. `quiz_phase` = `FEEDBACK`로 전환
3. 정답 강조 + 미유키 "아, 시간이 다 됐군요…" 반응
4. 오답(incorrect)으로 처리 — `correct_count` 증가 없음
5. 1.5초 후 다음 문제 또는 종료 판정으로 진행

---

## 5. 문제 구성 (5문제)

미유키의 성격을 반영해 문제는 "진지하고 정중하게 출제되는 잡학 상식"으로 구성. 딱딱한 시험 문제가 아니라 미유키가 일상 대화 중 자연스럽게 꺼낼 법한 지식.

| # | 분야 | 문제 (예시) | 정답 | 오답 선택지 |
|---|---|---|---|---|
| 1 | 동물 | 문어의 혈액 색깔은? | 파란색 | 빨간색 / 투명 / 노란색 |
| 2 | 지리 | 세계에서 가장 긴 강은? | 나일강 | 아마존강 / 양쯔강 / 미시시피강 |
| 3 | 언어 | 일본어로 '고양이'를 뜻하는 단어는? | ねこ(네코) | いぬ(이누) / さかな(사카나) / とり(도리) |
| 4 | 음식 | 초콜릿의 주원료가 되는 식물은? | 카카오 | 커피 / 바닐라 / 코코넛 |
| 5 | 천문 | 태양계에서 가장 큰 행성은? | 목성 | 토성 / 해왕성 / 천왕성 |

> **문제/정답은 초안**. 개발 전 러키스타 세계관과 잘 어울리는 문제로 교체 가능. 문제 1(문어 혈액)은 카가미 챕터 스테이지 3 대사와 연결되는 이스터에그.

---

## 6. 미유키 반응 연출

### 문제 출제 시

미유키가 정중하게 문제를 소개하는 짧은 대사.

| 문제 번호 | 출제 대사 (예시) |
|---|---|
| 1 | "그럼 첫 번째 문제입니다, 후후." |
| 2 | "다음은 지리에 관한 문제예요." |
| 3 | "언어에 관한 문제입니다." |
| 4 | "이건 제가 특히 좋아하는 분야예요." |
| 5 | "마지막 문제입니다. 파이팅이에요~!" |

### 정오답 피드백

| 결과 | 미유키 반응 | 대사 (예시) |
|---|---|---|
| 정답 | 밝게 웃는 표정 | "정답입니다! 잘 아시는군요~" |
| 오답 | 살짝 놀라는 표정 | "아, 정답은 ○○이었어요. 어렵죠?" |
| 시간초과 | 걱정하는 표정 | "아, 시간이 다 됐군요… 정답은 ○○예요." |

### 챕터 종료 연출

| 결과 | 대사 |
|---|---|
| 클리어 (3~4/5) | "대단해요! 이 정도면 충분히 합격이에요~" |
| 클리어 (5/5 전체 정답) | "완벽해요! 미유키 못지않으시네요, 후후." |
| 실패 (2 이하) | "괜찮아요, 다음에 또 도전해 보세요~!" |

---

## 7. 화면 구성

**시점**: 대화형 VN(비주얼노벨) 스타일. 미유키가 화면 중앙~우측에 크게, 배경은 학교 도서관 또는 교실.

```
┌───────────────────────────────────────────────────────┐
│  [문제 2 / 5]                    [⏱ 07.3s ▓▓▓▓░░░░] │ ← 진행+타이머 (상단)
│                                                       │
│                    [미유키 스프라이트]                  │
│                     (중앙~우측, 크게)                  │
│                                                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  세계에서 가장 긴 강은?                        │    │ ← 문제 텍스트 박스
│  └──────────────────────────────────────────────┘    │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ A. 나일강    │  │ B. 아마존강  │                  │ ← 선택지 (2×2 배치)
│  └──────────────┘  └──────────────┘                  │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ C. 양쯔강    │  │ D. 미시시피강│                  │
│  └──────────────┘  └──────────────┘                  │
└───────────────────────────────────────────────────────┘
```

**타이머**: 우상단 수평 바 (10초 → 0초, **오른쪽에서 왼쪽으로** 채워진 바가 줄어듦). 3초 이하 시 빨간색으로 변경.

**선택지 피드백**:
- 클릭한 선택지: 선택 중 표시 (파란 테두리)
- FEEDBACK 단계: 정답 선택지는 초록색 강조, 오답 선택지는 회색 처리

---

## 8. 클리어 / 실패 조건 요약

| 조건 | 결과 |
|---|---|
| 5문제 완료 후 `correct_count` ≥ 3 | **챕터 CLEAR** |
| 5문제 완료 후 `correct_count` ≤ 2 | FAIL |

클리어/실패 판정은 반드시 5문제를 모두 진행한 후에 내린다 — 도중에 실패 확정되어도 남은 문제를 계속 진행한다 (이미 틀렸다고 바로 끝내지 않음 — 미유키와의 대화를 끝까지 즐기는 경험을 위해).

**실패 시 흐름**:
1. 실패 연출 (미유키 "다음에 또 도전해 보세요~!" 대사)
2. "다시 도전" / "앨범으로 돌아가기" 선택지
3. "다시 도전" → `start()` 재호출 (전체 초기화)
4. "앨범으로 돌아가기" → `get_tree().change_scene_to_file("res://scenes/album/album.tscn")` 직접 호출 (`return_to_album()` **호출 금지**)

---

## 9. MinigameBase 인터페이스 구현

```gdscript
# miyuki.gd (MinigameBase 상속)

func start():
    question_index = 0
    correct_count = 0
    quiz_phase = QuizPhase.SHOWING   # 스테일 상태 방지 (retry 경로 포함)
    selected_answer = -1
    _show_question(question_index)

func _show_question(idx: int):
    quiz_phase = QuizPhase.SHOWING
    selected_answer = -1
    _display_question_ui(idx)          # 문제+선택지 슬라이드인
    await get_tree().create_timer(0.5).timeout
    time_remaining = 10.0              # ANSWERING 전환 시점에 타이머 초기화 (SHOWING 중 소비 방지)
    quiz_phase = QuizPhase.ANSWERING   # 입력 허용

func _process(delta):
    if quiz_phase != QuizPhase.ANSWERING: return
    time_remaining -= delta
    if time_remaining <= 0.0:
        time_remaining = 0.0
        _on_timeout()

func _on_answer_selected(idx: int):
    if quiz_phase != QuizPhase.ANSWERING: return  # 이중 입력/시간초과 동시 방지
    quiz_phase = QuizPhase.FEEDBACK    # 먼저 전환 (재진입 차단)
    selected_answer = idx
    _show_feedback()

func _on_timeout():
    if quiz_phase != QuizPhase.ANSWERING: return  # _process 이중 호출 방지
    quiz_phase = QuizPhase.FEEDBACK    # 먼저 전환 (클릭 동시 발생 차단)
    selected_answer = -1               # 미선택 상태 유지 (-1은 절대 정답 인덱스가 될 수 없음, 정답은 0~3)
    _show_feedback()

func _show_feedback():
    # 정답 강조, 미유키 반응 표시
    var is_correct = (selected_answer == _get_correct_answer(question_index))
                     # _get_correct_answer()는 항상 0~3 반환 — -1(시간초과)과 절대 일치하지 않음
    if is_correct:
        correct_count += 1
    _display_feedback_ui(is_correct, selected_answer)
    await get_tree().create_timer(1.5).timeout
    _advance()                         # 반드시 1.5초 피드백 완료 후 호출

func _advance():
    if question_index < 4:
        question_index += 1
        _show_question(question_index)
    else:
        quiz_phase = QuizPhase.DONE
        if correct_count == 5:
            _play_perfect_cutscene()   # 5/5 전체 정답 특별 연출 후 on_clear()
        if correct_count >= 3:
            on_clear()
        else:
            on_fail()

func on_clear():
    _is_running = false
    return_to_album()

func on_fail():
    _is_running = false
    # 실패 연출 후 UI 선택:
    #   "다시 도전" → start() 호출 (전체 초기화 — quiz_phase/selected_answer도 start() 내에서 리셋됨)
    #   "앨범으로" → get_tree().change_scene_to_file("res://scenes/album/album.tscn") 직접 호출
    #   !! 절대 return_to_album() 호출 금지

func return_to_album():
    # on_clear() 경로에서만 호출.
    ProgressManager.mark_cleared("miyuki")
    get_tree().change_scene_to_file("res://scenes/album/album.tscn")
```

---

## 10. 미결 사항 / 다음 라운드 이관

- **문제 확정**: 위 5문제는 컨셉 초안. 러키스타 세계관·캐릭터 성격과 어울리는 문제로 교체 필요.
- **문제 데이터 구조**: 문제/선택지/정답을 GDScript 배열로 하드코딩할지, JSON/Resource 파일로 분리할지 — 첫 프로토타입 시 결정.
- **빌드업 대사 구현**: 출제 대사를 Dialogic으로 처리할지, Label 애니메이션으로 처리할지 — 다른 챕터와 동일하게 첫 프로토타입 시 결정.
- **5/5 전체 정답 보너스**: 현재 클리어 메시지만 다름. 별도 연출(미유키 특별 리액션)을 추가할지 — 스코프 검토 후 결정.
- **배경 에셋 범위**: 미유키 스프라이트(기본/정답/오답/시간초과 4종), 도서관 or 교실 배경 1장.
