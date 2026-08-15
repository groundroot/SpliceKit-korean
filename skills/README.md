# Final Cut Pro × Claude Code 스킬 모음

Final Cut Pro를 Claude Code로 자동화하는 스킬 3종과, 그 중 하나가 만들어진 실제 작업 기록.

| 스킬 | 하는 일 |
|---|---|
| `fcp-marker-convert` | 타임라인의 기존 마커를 다른 종류(챕터/할 일/완료)로 일괄 변환 |
| `final-cut-pro` | FCPXML 포맷 레퍼런스 + 폴더 일괄 임포트/내보내기 레시피 |
| `longform-subtitle` | FCPXMLD에서 STT로 롱폼 자막 자동 생성 |

## 설치

이 디렉토리의 스킬 폴더를 `~/.claude/skills/` 아래로 복사하면 Claude Code가 바로 인식합니다.

```bash
cp -R skills/fcp-marker-convert ~/.claude/skills/
cp -R skills/final-cut-pro      ~/.claude/skills/
cp -R skills/longform-subtitle  ~/.claude/skills/
chmod +x ~/.claude/skills/final-cut-pro/scripts/folder_to_fcpxml.py
```

### 필요한 것

- **`fcp-marker-convert`**: [SpliceKit](https://splicekit.app) MCP 서버 (FCP 프로세스에 붙어 동작). 검증 환경 = FCP 12.3 / SpliceKit 3.3.9 / macOS 26.5
- **`final-cut-pro`**: `ffprobe`(ffmpeg), `xmllint`. 레시피 부분은 SpliceKit 필요
- **`longform-subtitle`**: 로컬 Silence-Cutter 설치. 스킬은 `$HOME/Movies/Subtitle Automation/` 기준으로 적혀 있으니, 다른 곳에 설치했다면 경로를 바꾸세요

---

## 작업 기록 — `fcp-marker-convert`는 이렇게 나왔다

이 스킬은 실제 프로젝트 작업 도중에 만들어졌습니다. 아래는 요청과 그 결과입니다.
막다른 길까지 그대로 남겨둔 이유는, 같은 삽질을 반복하지 않기 위해서입니다.

대상: `2026 재능누리마당 4K 29.97 ver AI Editing` — 7,466초(약 2시간 4분), 793개 클립, 멀티캠 기반 타임라인.

### 요청 1 — "지금 떠 있는 타임라인의 마커들을 모두 챕터마커로 변경하라. 이름은 그대로 유지"

먼저 도구부터 막혔습니다. SpliceKit에는 마커 **조회·수정 RPC가 아예 없습니다.** `timeline.addMarkers`(추가)가 전부라, FCP 프로세스 안의 ObjC 객체를 직접 다루는 수밖에 없었습니다.

찾아낸 것:
- 마커 클래스는 `FFAnchoredMarker`의 하위인 **`FFAnchoredTimeMarker`**
- 종류는 별도 타입이 아니라 **불리언 플래그** — `isChapter` / `isTodo` / `isCompleted`
- 표시 이름은 `displayName`. 플래그만 바꾸면 이름·위치는 그대로 남음 → "이름 유지" 요구가 자동 충족

그 다음이 진짜 벽이었습니다. 793개 클립을 순회하며 각 클립의 `anchoredItems`를 훑는 방식으로 짰더니:

> `{'message': 'not enough memory', 'code': -32000}`

`lua_execute`의 Lua VM은 **한 호출에 RPC 500회쯤에서 죽고, 그 뒤로는 모든 호출이 계속 실패합니다.** `lua_reset`으로 되살려야 하는데 그러면 전역 변수와 obj 핸들이 전부 날아갑니다. 배치를 100 → 50 → 20으로 줄이고, 클립마다 `collectgarbage()`를 넣고, 응답 크기를 줄이려 KVC 경로를 바꿔봐도 마찬가지였습니다. 20클립은 통과, 100클립은 사망 — 재시작 비용까지 감안하면 40회 넘게 호출해야 하는 방식이었습니다.

**전환점은 순회를 버린 것입니다.** `NSPredicate`로 마커만 골라낸 뒤 KVC `setValue:forKey:`를 컬렉션 전체에 한 번 적용하면 됩니다. `NSSet`/`NSArray`의 `setValue:forKey:`는 모든 원소에 전달되고, KVC가 `isChapter` → `setIsChapter:`를 찾아 호출합니다. **RPC 대여섯 번으로 끝.**

### 요청 2 — "명산초 로 시작하는 마커를 챕터마커로 변경"

범위가 좁혀졌는데, 여기서 두 번째 함정이 나왔습니다. 처음엔 spine(최상위 트랙)의 `containedItems`만 훑고 있었는데 — 결과 **0건**.

한글 인코딩 문제인가 싶어 마커 이름 32종을 전부 뽑아보니 `교육감 소개`, `MC 멘트` 같은 한글이 멀쩡히 나왔습니다. 인코딩이 아니라 **탐색 범위**가 문제였습니다. 찾던 마커는 중첩 스토리라인 안쪽(`FFAnchoredClip`)에 앵커돼 있어서, spine 최상위만 보는 경로에서는 구조적으로 잡힐 수 없었습니다.

`sequence.anchoredObjects`(재귀 수집)로 바꾸자 바로 나왔습니다 — `명산초 - 명산초댄스팀`, 시퀀스 전체에서 "명산"이 들어간 유일한 마커. 챕터로 변환 완료.

### 요청 3 — "마커에서 다른 마커로 변환하는 것을 스킬로 저장하라"

위 두 함정(Lua VM 한계, 탐색 범위)을 **"하지 말 것"** 섹션에 명시한 스킬로 정리했습니다. 그게 `fcp-marker-convert`입니다.

### 요청 4 — "나머지 마커도 챕터로 변경"

시퀀스 전체 마커 **10,029개** (이미 챕터였던 430개 포함). KVC 일괄 적용으로 한 번에 전부 변환, 검증 결과 `nowChapter=10029`.

고유 이름은 32종뿐인데 마커가 1만 개인 이유는 멀티캠 앵글마다 소스 마커가 붙어 있기 때문입니다. 대상이 예상보다 크면 **실행 전에 개수를 세어 알리는 것**이 중요합니다 — 다음 항목 때문에.

---

## 알아둘 것

**⌘Z로 되돌릴 수 없습니다.** ObjC 세터를 직접 호출하므로 FCP의 undo 스택에 들어가지 않습니다. 실행 전 대상 개수를 반드시 확인하고, 중요한 프로젝트는 라이브러리를 백업해두세요.

**UI가 즉시 갱신되지 않을 수 있습니다.** 마커 모양이 그대로면 프로젝트를 닫았다 열어보세요.

**SpliceKit 버전을 탑니다.** 여기 나온 ObjC 클래스명과 프로퍼티는 비공개 API라 FCP 업데이트로 바뀔 수 있습니다. 검증 시점은 FCP 12.3 / 2026-08.

## 출처

`final-cut-pro` 스킬은 [madappgang/claude-code](https://github.com/madappgang/claude-code)(MIT License, Copyright (c) MadAppGang)의 `plugins/video-editing/skills/final-cut-pro`에서 가져와, "Recipes" 및 "함정" 섹션을 실사용 기준으로 덧붙인 것입니다. `fcp-marker-convert`와 `longform-subtitle`은 자체 작성이며, 이 저장소와 동일하게 MIT License를 따릅니다.
