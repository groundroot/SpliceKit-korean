---
name: fcp-marker-convert
description: 현재 Final Cut Pro 타임라인의 기존 마커를 다른 종류(챕터/할 일/완료/표준)로 일괄 변환한다. 이름과 위치는 유지된다. "마커를 챕터마커로 바꿔줘", "챕터마커로 변환", "할 일 마커로 변경", "특정 이름 마커만 챕터로", "마커 종류 바꾸기" 요청 시 사용.
---

# FCP 마커 종류 일괄 변환

splicekit MCP로 FCP 프로세스 안의 마커 객체를 직접 수정한다. 이름·위치·노트는 건드리지 않고 종류 플래그만 바꾼다.

## 먼저 알아야 할 것

- splicekit에는 마커 **조회/수정 RPC가 없다**. `timeline.addMarkers`(추가)뿐이라 ObjC 객체를 직접 다뤄야 한다.
- 마커 클래스는 `FFAnchoredTimeMarker`. 변환 가능한 플래그:
  | 목표 | 키 |
  |---|---|
  | 챕터 마커 | `isChapter` |
  | 할 일 마커 | `isTodo` |
  | 완료 표시 | `isCompleted` |
  표준 마커로 되돌리려면 `isChapter`/`isTodo`를 모두 `false`로.
- 표시 이름은 `displayName`(읽기 전용). 변환해도 그대로 남는다.
- **⌘Z로 되돌릴 수 없다.** ObjC 세터 직접 호출이라 FCP undo 스택에 안 들어간다. 실행 전 대상 개수를 반드시 세어 사용자에게 알릴 것.

## 절차

### 1. 연결 확인
`bridge_status()` — FCP가 떠 있고 SpliceKit이 붙었는지.

### 2. 마커 집합 잡기 (`lua_execute`)

```lua
-- 시퀀스 전체의 앵커 객체 (중첩 스토리라인·복합 클립 안까지 포함)
local s = sk.rpc("debug.eval",{
  expression="NSApp.delegate.activeEditorContainer.editorModule.sequence.anchoredObjects",
  storeResult=true})
SEQALL = s.handle

-- 마커만 필터
local p = sk.rpc("system.callMethodWithArgs",{target="NSPredicate",
  selector="predicateWithFormat:",
  args={{type="string", value="className == 'FFAnchoredTimeMarker'"}},
  classMethod=true, returnHandle=true})
local m = sk.rpc("system.callMethodWithArgs",{target=SEQALL,
  selector="filteredSetUsingPredicate:",
  args={{type="handle", value=p.handle}},
  classMethod=false, returnHandle=true})
TARGET = m.handle
return "markers="..tostring(sk.rpc("debug.eval",{expression=TARGET..".count"}).result)
```

이름으로 좁히려면 predicate에 조건을 더한다 — 한글도 그대로 통한다:

```
className == 'FFAnchoredTimeMarker' AND displayName BEGINSWITH '명산초'
className == 'FFAnchoredTimeMarker' AND displayName CONTAINS '인터뷰'
className == 'FFAnchoredTimeMarker' AND isChapter == NO
```

### 3. 개수 보고 후 일괄 적용

개수를 사용자에게 알리고 나서 KVC로 한 번에 적용한다:

```lua
local yes = sk.rpc("system.callMethodWithArgs",{target="NSNumber",
  selector="numberWithBool:", args={{type="bool", value=true}},
  classMethod=true, returnHandle=true})
sk.rpc("system.callMethodWithArgs",{target=TARGET, selector="setValue:forKey:",
  args={{type="handle", value=yes.handle},{type="string", value="isChapter"}},
  classMethod=false, returnHandle=false})
```

`NSSet`/`NSArray`의 `setValue:forKey:`는 모든 원소에 전달되고, KVC가 `isChapter` → `setIsChapter:`를 찾아 호출한다. 만 개 규모도 한 번에 끝난다.

### 4. 검증

```lua
local p2 = sk.rpc("system.callMethodWithArgs",{target="NSPredicate",
  selector="predicateWithFormat:", args={{type="string", value="isChapter == YES"}},
  classMethod=true, returnHandle=true})
local c = sk.rpc("system.callMethodWithArgs",{target=TARGET,
  selector="filteredSetUsingPredicate:", args={{type="handle", value=p2.handle}},
  classMethod=false, returnHandle=true})
return sk.rpc("debug.eval",{expression=c.handle..".count"}).result
```

변환 후 타임라인 UI가 바로 다시 그려지지 않을 수 있다. 사용자에게 마커 모양을 눈으로 확인하라고 안내하고, 안 바뀌어 보이면 프로젝트를 닫았다 열게 한다.

## 하지 말 것 (실패한 접근)

- **클립을 하나씩 순회하지 말 것.** `lua_execute`의 Lua VM은 한 호출에 RPC 500회쯤에서 `not enough memory`로 죽고, **그 뒤 모든 호출이 계속 실패한다.** 복구하려면 `lua_reset`이 필요하고 전역 변수와 obj 핸들이 전부 날아간다. NSPredicate + KVC 일괄 적용이면 RPC 대여섯 번으로 끝난다.
- **spine의 `containedItems`만 훑지 말 것.** `valueForKeyPath:"@unionOfSets.anchoredItems"`로 최상위 클립의 앵커 마커는 모을 수 있지만, 중첩 스토리라인·복합 클립 안의 마커가 빠진다. 검색은 반드시 `sequence.anchoredObjects`로.
- `sequence.containedItems`는 nil이다. spine 컬렉션이 필요하면 `sk.clips()`의 첫 아이템에서 `.parentItem`으로 잡는다.
