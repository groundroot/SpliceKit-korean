# SpliceKit

[![Release](https://img.shields.io/github/v/release/elliotttate/SpliceKit)](https://github.com/elliotttate/SpliceKit/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-FCP%20Cafe-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/HD3FPc4Azu)
[![Docs](https://img.shields.io/badge/docs-splicekit.fcp.cafe-0A84FF)](https://splicekit.fcp.cafe)

**Final Cut Pro를 더 깊게 열어주는 Command Palette, MCP 서버, 그리고 개방형 플러그인 프레임워크입니다.**

## 새로운 기능

- **한국어 자연어 편집 명령 지원 강화**: Command Palette에서 `재생`, `여기서 잘라`, `1분 30초로 이동`, `무음 제거`, `크로스 디졸브 추가` 같은 한국어 표현을 영어 편집 의도로 정규화해 더 자연스럽게 편집할 수 있습니다.
- **텍스트 기반 편집기 전사 언어 선택 추가**: `Auto / Korean / English` 전사 언어 선택을 넣었고, `Apple Speech`가 더 이상 영어로 고정되지 않도록 바꿨습니다.
- **핵심 패널 UI 한글화 시작**: 텍스트 편집기, 자막 패널, Lua 패널, Command Palette 일부 문구가 한국어 환경에서 더 자연스럽게 보이도록 정리했습니다.

| 🎹 Command Palette | 🤖 MCP Server | 🧩 Plugin Framework |
|---|---|---|
| `Cmd+Shift+P`를 누르고 원하는 작업을 입력하세요. Apple Intelligence가 실행합니다. | 어떤 LLM이든 타임라인을 읽고 편집하며, 필요한 새 도구까지 만들어갈 수 있습니다. | 내장 기능 하나하나가 모두 예제 플러그인입니다. 당신도, AI도 더 많은 기능을 배포할 수 있습니다. |

> **에디터라면 여기서 시작하세요.** [공식 SpliceKit 사이트](https://splicekit.fcp.cafe)와 [FAQ](https://splicekit.fcp.cafe/faq/)가 가장 편한 입문 경로입니다. 질문, 도움 요청, 기능 제안은 [FCP Cafe Discord](https://discord.com/invite/HD3FPc4Azu)의 SpliceKit 채널로 오세요. 버그 제보는 [GitHub Issue](https://github.com/elliotttate/SpliceKit/issues)에 남겨주세요.
>
> 어떤 작업을 만들게 될지 기대하고 있겠습니다. 🥳

---

## 세 가지 핵심 축

### 🎹 1. Command Palette

*한 번의 단축키로 거의 모든 작업에 접근합니다.*

패치된 FCP 안에서 **Cmd+Shift+P**를 누르세요. 100개가 넘는 내장 편집 액션을 fuzzy search로 찾을 수 있습니다. blade, trim, color, speed, marker, effect, transition, export까지 다 포함됩니다. 또는 자연어로 입력하면 **Apple Intelligence**가 의도를 해석해 실행합니다. 이제 여기에 한국어 질의도 더 잘 대응합니다.

[![Command Palette Demo](https://img.youtube.com/vi/Q4GjHmmUISw/maxresdefault.jpg)](https://youtu.be/Q4GjHmmUISw)

#### 이렇게 말해보세요

- *"5초마다 마커 추가해줘"*
- *"이 클립 반속으로 해줘"*
- *"장면 전환마다 잘라줘"*
- *"무음을 전부 제거해줘"*
- *"크로스 디졸브 추가해줘"*

> 더 이상 메뉴를 뒤질 필요도, 단축키를 외울 필요도, 클라우드에 올릴 필요도 없습니다.

---

### 🤖 2. MCP 서버

*Claude를 포함한 어떤 LLM이든 당신의 편집기를 직접 다루고, 필요한 기능까지 가르칠 수 있습니다.*

SpliceKit는 Final Cut Pro의 주요 서브시스템 전반을 다루는 약 200개의 도구를 MCP 서버로 제공합니다. 여기에 **Claude Code**, **Claude Desktop**, 또는 MCP 호환 AI 클라이언트를 연결하면 이런 식으로 말할 수 있습니다.

- *"40분짜리 인터뷰를 핵심 장면만 남겨서 줄여줘"*
- *"이 팟캐스트에서 무음을 제거하고 자막을 넣고 내보내줘"*
- *"이 클립들로 노래 비트에 맞춘 러프컷을 만들어줘"*

이건 단순히 키보드 단축키를 흉내 내는 채팅 래퍼가 아닙니다. MCP는 FCP의 내부 ObjC 런타임과 직접 통신하기 때문에 타임라인 상태를 읽고, 클립을 검사하고, blade/retime/color correction/effect/render까지 UI를 건드리지 않고 수행할 수 있습니다.

#### 점점 더 똑똑해지는 편집기

처음 복잡한 작업을 시키면 AI가 조금 서툴 수 있습니다. 가지고 있는 primitive를 조합하고, 타임라인을 상대로 시행착오를 하고, 때로는 돌아가는 길을 택할 수 있습니다.

그럴 때는 우회로에 만족하지 마세요. **그 능력을 직접 만들라고 시키면 됩니다.**

| 단계 | 무슨 일이 일어나는가 |
|---|---|
| **1. 요청** | 복잡한 작업을 요청하면 LLM이 현재 가진 primitive를 조합해 즉석에서 해결합니다. |
| **2. 구현** | "이걸 진짜 명령으로 만들어줘"라고 하면 Claude가 플러그인을 작성하고, 새로운 MCP 도구로 등록하고, 편집기에 연결합니다. |
| **3. 재사용** | 다음부터는, 혹은 백 번째부터는, 즉시 실행되고 안정적이며 같은 플러그인을 쓰는 모두와 공유됩니다. |

> 처음의 어설픈 시도 하나하나는 그 워크플로를 1급 기능으로 끌어올릴 기회입니다. 6개월 뒤 당신이 쓰게 될 편집기는 오늘 설치한 편집기보다 더 똑똑해질 것이고, 그 향상의 대부분은 SpliceKit 팀이 아니라 당신과 커뮤니티가 만든 플러그인에서 올 것입니다.

---

### 🧩 3. 플러그인 프레임워크

*모든 것이 플러그인입니다.*

SpliceKit는 기능 목록이 아니라 플랫폼입니다. SpliceKit dylib가 Final Cut Pro에 로드되면 전체 ObjC 런타임(비공개 API 포함 78,000개 이상의 클래스)이 플러그인에 열립니다.

#### 플러그인으로 할 수 있는 것

- FCP 안에 새로운 패널과 윈도우 추가
- 툴바, 메뉴, Enhancements 메뉴에 버튼 추가
- Command Palette에 명령 등록
- MCP 서버를 통해 새 도구 노출
- 타임라인 이벤트, 선택 변경, 재생 상태에 훅 걸기
- Motion 템플릿, FxPlug 효과, Workflow Extension 배포
- Objective-C / C++, Swift, Lua, Python으로 작성

#### 그리고 이것도 AI에게 만들라고 시킬 수 있습니다

원하는 기능을 설명하고 그 스펙을 Claude에게 넘기면 됩니다. 프로젝트에는 AI가 읽기 좋게 구성된 전체 API 레퍼런스 문서가 포함되어 있어서, Claude가 SpliceKit 프레임워크에 맞춰 플러그인을 작성할 수 있습니다.

---

## 기본 제공 예제 플러그인

여기 나오는 기능은 전부 플러그인입니다. 설치하자마자 바로 쓸 수 있도록 번들되어 있고, 동시에 직접 기능을 만들 사람에게는 살아 있는 예제이기도 합니다.

### 텍스트 기반 편집기
타임라인의 모든 클립을 온디바이스 음성 인식으로 전사합니다. NVIDIA Parakeet 기반이며 25개 언어를 지원하고 클라우드를 쓰지 않습니다. 화자 분리도 가능합니다. 단어를 클릭하면 그 지점으로 이동하고, 문장을 선택한 뒤 Delete를 누르면 영상도 그에 맞춰 잘립니다. 단어를 드래그해 클립 순서를 바꿀 수 있고, SRT나 일반 텍스트로 내보낼 수 있습니다. 이제 한국어 전사 시 전사 언어 선택도 가능합니다.

[![Text-Based Editor Demo](https://img.youtube.com/vi/JxxDSH4Ly0I/maxresdefault.jpg)](https://www.youtube.com/watch?v=JxxDSH4Ly0I)

### 오디오 믹서
클립별이 아니라 **role** 단위로 믹싱합니다. Dialogue 버스에 compressor, EQ, reverb를 걸면 Dialogue role이 붙은 모든 클립이 과거/현재/미래를 가리지 않고 그 처리를 공유합니다. 클립의 role을 바꾸면 즉시 새 버스 설정을 따라갑니다. 볼륨, solo, mute도 role 단위로 한 패널에서 조절합니다.

[![Audio Mixer Demo](https://img.youtube.com/vi/k_HL35lXFOA/maxresdefault.jpg)](https://www.youtube.com/watch?v=k_HL35lXFOA)

### 섹션 바
타임라인 위에 컬러 코딩된 섹션 바를 띄워 편집 구조를 한눈에 보여줍니다. 섹션 이름 지정, 색상 지정, 원클릭 이동이 가능해서 장편 편집, 팟캐스트, 챕터가 많은 프로젝트처럼 구조를 자주 봐야 하는 작업에 특히 좋습니다.

[![Sections Demo](https://img.youtube.com/vi/plirvqHe6o0/maxresdefault.jpg)](https://youtu.be/plirvqHe6o0)

### 무음 제거
인터뷰나 팟캐스트 녹음을 넣으면 모든 무음 구간을 찾아 잘라냅니다. threshold, 최소 길이, 앞뒤 padding을 설정할 수 있으며, 내부적으로는 Apple 네이티브 AVFoundation + Accelerate를 사용합니다.

### 소셜 미디어 자막
13가지 내장 스타일(Bold Pop, Neon Glow, Karaoke, Typewriter, Bounce 등)로 단어별 하이라이트 애니메이션 자막을 생성합니다. 자막은 편집 가능한 Motion title 형태로 타임라인에 바로 들어갑니다.

### 장면 전환 감지
vImage histogram 비교를 이용해 영상의 샷 체인지를 찾아냅니다. 마커 추가, 타임라인 blade, 또는 둘 다 수행할 수 있습니다.

### 비트 감지와 Song Cut
음악 파일에서 BPM, beat, bar, song section을 추출합니다. 여기에 **Song Cut**을 사용하면 음악 트랙과 영상 폴더를 받아 비트에 맞춰 자동으로 뮤직비디오 스타일 컷을 만들어줍니다. pacing은 natural, medium, fast, aggressive 중에서 고르거나 직접 가중치를 줄 수 있습니다.

### LiveCam
웹캠을 라이브러리나 현재 타임라인으로 바로 녹화하는 내장 부스입니다. 실시간 프리뷰, 색 보정, 오디오 미터, 인물과 사물 모두에 작동하는 subject-lift 그린스크린 matte를 제공합니다(macOS 14+). 그린스크린 색상을 "Transparent"로 두면 ProRes 4444와 실제 alpha channel로 저장합니다.

### URL Import
YouTube, Vimeo, Twitter 링크를 붙여 넣으면 라이브러리에 실제 클립으로 가져옵니다. `yt-dlp`와 `ffmpeg`를 셸 PATH에서 자동으로 찾아 연결합니다.

### Batch Export
한 번의 명령으로 타임라인의 모든 클립을 각자 별도 파일로 내보냅니다. 효과, 색보정, 전환까지 전부 bake된 결과로 출력합니다.

### Native BRAW 및 VP9 지원
Blackmagic RAW(`.braw`)와 VP9/WebM 파일을 타임라인에 바로 넣을 수 있습니다. 트랜스코딩도, wrapper도, 별도 서드파티 툴킷 설치도 필요 없습니다. SpliceKit는 BRAW RAW Processor와 VP9 decoder를 Apple MediaExtension 프레임워크를 통해 FCP에 연결하므로, 썸네일, scrubbing, 전체 품질 decode가 되는 1급 미디어처럼 동작합니다. Blackmagic 카메라 푸티지나 웹에서 받은 WebM 영상을 자주 쓰는 사람에게 큰 해방입니다.

### Dual Timelines, FlexMusic, Montage Maker, OpenTimelineIO 교환, Lua REPL, in-process debugger…
…그리고 더 많습니다. 전부 `Sources/` 안에 있는 실제 코드이므로 읽고, 포크하고, 필요한 부분만 가져다 쓸 수 있습니다.

---

## 60초 설치

가장 쉬운 경로는 GUI 패처입니다. 최신 릴리즈를 내려받고, 열고, 버튼을 누르면 됩니다.

[![Installation Guide](https://img.youtube.com/vi/NxbInKlXQVs/maxresdefault.jpg)](https://www.youtube.com/watch?v=NxbInKlXQVs)

1. [최신 릴리즈](https://github.com/elliotttate/SpliceKit/releases/latest)에서 **SpliceKit**을 다운로드합니다.
2. 압축을 풀고 앱을 엽니다.
3. **Patch**를 누르면 나머지는 자동으로 처리됩니다.

<img src="docs/patcher-screenshot.jpg" width="500" alt="SpliceKit Patcher">

패처는 Final Cut Pro를 `~/Applications/SpliceKit/`로 복사하고, SpliceKit dylib를 주입하고, 재서명하고, MCP 서버를 설정합니다. **원본 Final Cut Pro는 절대 건드리지 않습니다.**

완료되면 패처에서 **Launch FCP**를 누르거나 `~/Applications/SpliceKit/` 안의 새 복사본을 직접 열면 됩니다. **Cmd+Shift+P**를 눌러 Command Palette를 열고 바로 시작하세요.

터미널이 더 편하다면 `./patcher/patch_fcp.sh`가 같은 일을 수행합니다.

---

## Claude와 연결하기 (또는 다른 MCP 클라이언트)

GUI 패처는 MCP 서버 설정까지 함께 해줍니다. 이 단계를 건너뛰었거나 저장소 체크아웃에서 직접 실행 중이라면 아래 수동 경로를 사용하면 됩니다.

### 한 줄 설정

```bash
make mcp-setup
```

이 명령은 `~/.venvs/splicekit-mcp`에 격리된 Python 가상환경을 만들고 `mcp/requirements.txt`의 고정된 의존성을 설치합니다.

직접 하고 싶다면:

```bash
python3 -m venv ~/.venvs/splicekit-mcp
~/.venvs/splicekit-mcp/bin/python -m pip install -r mcp/requirements.txt
```

### 연결 상태 확인

```bash
make mcp-doctor
```

이 명령은 venv 존재 여부, `mcp` import 성공 여부, `.mcp.json`이 올바른 Python을 가리키는지, FCP bridge가 `127.0.0.1:9876`에서 듣고 있는지를 점검합니다.

### MCP 클라이언트에 서버 연결

MCP `command`에는 가상환경의 Python을 사용하세요. `args` 경로는 SpliceKit를 어떻게 설치했는지에 따라 달라집니다.

**저장소 체크아웃에서 실행하는 경우:**

```json
{
  "mcpServers": {
    "splicekit": {
      "command": "/Users/yourname/.venvs/splicekit-mcp/bin/python",
      "args": ["/absolute/path/to/SpliceKit/mcp/server.py"]
    }
  }
}
```

**패키지 설치본에서 실행하는 경우:**

```json
{
  "mcpServers": {
    "splicekit": {
      "command": "/Users/yourname/.venvs/splicekit-mcp/bin/python",
      "args": ["/Applications/SpliceKit.app/Contents/Resources/mcp/server.py"]
    }
  }
}
```

MCP 서버는 Final Cut Pro 안에서 돌아가는 SpliceKit bridge(`127.0.0.1:9876`)에 연결하므로, 패치된 Final Cut Pro가 실행 중이어야 합니다.

---

## 이거 안전한가요? 합법인가요? Apple 계정이 정지되진 않나요?

짧게 답하면: **네, 안전합니다. 네, 합법입니다. 아니요, Apple이 계정을 정지시키지 않습니다.**

- **기존 FCP는 건드리지 않습니다.** SpliceKit는 `~/Applications/SpliceKit/`에 *복사본*을 만듭니다. App Store의 원본 FCP는 수정되지 않으며, 라이브러리, 프로젝트, 미디어 파일도 설치 과정에서 건드리지 않습니다.
- **합법입니다.** 상호운용성을 위한 리버스 엔지니어링은 미국 [DMCA §1201(f)](https://www.law.cornell.edu/uscode/text/17/1201)와 EU Software Directive에서 명시적으로 보호됩니다. SpliceKit는 MIT 라이선스입니다.
- **Apple은 로컬 개조 앱을 실행한다고 Apple ID를 정지시키지 않습니다.** 그런 선례도 없고, 사용하는 메커니즘(dyld injection + code signing)도 BetterTouchTool, Alfred, Hammerspoon, 접근성 도구, 모든 Xcode 디버거 세션이 쓰는 방식과 같습니다.
- **현실적인 리스크**는 FCP 업데이트로 호환성이 깨질 수 있다는 점(다시 패치하면 됨), 비공개 API가 특정 edge case에서 예상 밖 동작을 할 수 있다는 점 정도입니다. 이럴 때는 `Cmd+Z`가 친구입니다.

### 안정성을 고려해 설계되었습니다

**SpliceKit는 순정 FCP와 최소한 같은 수준, 몇몇 부분에서는 더 높은 안정성을 목표로 설계되었습니다.**

- **언제든 완전히 되돌릴 수 있습니다.** SpliceKit는 FCP가 프로젝트, 라이브러리, 미디어를 저장하는 방식을 바꾸지 않습니다. 패치된 복사본을 종료하고 동일한 라이브러리를 원본 App Store FCP에서 열어 그대로 계속 편집할 수 있습니다. 락인도, 마이그레이션도 없습니다.
- **FXPlug 4 플러그인과 같은 수준의 안전성, 그리고 더 큰 여유.** SpliceKit 플러그인은 Apple의 FXPlug 시스템과 같은 신뢰 레벨에서 실행되며, 아키텍처상 더 많은 제어 수단을 가집니다. 무거운 작업은 백그라운드 스레드에서 돌고, hot path는 서로 경합하지 않게 설계되며, state change는 FCP 내부와 충돌하지 않도록 보호됩니다.
- **SpliceKit는 실제로 FCP 자체의 버그도 고칩니다.** 오래된 FCP 버그 몇 가지는 이미 패치된 복사본에서 수정되어 있어, 그 부분에서는 오히려 순정보다 더 안정적입니다. [예시 영상 보기](https://youtu.be/SNUpQvBef0k)
- **자동 크래시 리포팅이 내장되어 있습니다.** 패처와 주입된 런타임 모두 Sentry를 통해 예상치 못한 문제를 빠르게 수집합니다. 추가 맥락을 위해 [Discord](https://discord.com/invite/HD3FPc4Azu)나 [GitHub Issues](https://github.com/elliotttate/SpliceKit/issues)에 로그를 공유해주시면 더 좋습니다.

더 쉬운 설명 버전은 [docs/WHAT_IS_SPLICEKIT.md](docs/WHAT_IS_SPLICEKIT.md)에 있습니다.

---

## 플러그인 만들기

무언가 직접 만들고 싶다면 이 섹션이 시작점입니다.

### 내부적으로 실제로 일어나는 일

SpliceKit는 재서명된 Final Cut Pro 복사본에 동적 라이브러리를 주입합니다. 로드가 끝나면:

- 전체 ObjC 런타임이 노출됩니다. 비공개 API 포함 78,000개 이상의 클래스에 접근할 수 있습니다.
- JSON-RPC 2.0 서버가 `127.0.0.1:9876`에서 대기합니다.
- MCP 서버가 tool call을 bridge RPC로 변환합니다.
- Flexo, Ozone, TimelineKit, LunaKit, Helium, ProCore 등 FCP 내부 프레임워크를 직접 `objc_msgSend`로 호출할 수 있습니다.
- 재서명 앱이 갖지 못하는 entitlement 때문에 생기는 CloudKit / ImagePlayground 관련 크래시 포인트는 swizzle로 제거됩니다.

```
┌─────────────────────────────────────────────┐
│  Final Cut Pro (patched copy)               │
│  ┌───────────────────────────────────────┐  │
│  │  SpliceKit.framework (LC_LOAD_DYLIB)  │  │
│  │  ├── Command Palette                  │  │
│  │  ├── MCP / JSON-RPC server on :9876   │  │
│  │  ├── Plugin loader (hot-reload)       │  │
│  │  └── your plugins here                │  │
│  └───────────┬───────────────────────────┘  │
│              │ objc_msgSend                  │
│  ┌───────────▼───────────────────────────┐  │
│  │  Flexo / Ozone / TimelineKit / ...    │  │
│  └───────────────────────────────────────┘  │
└──────────────────────┬──────────────────────┘
                       │ TCP :9876
        ┌──────────────▼──────────────┐
        │  MCP server / Python REPL / │
        │  nc / curl / Lua / your app │
        └─────────────────────────────┘
```

### 만드는 방법

- **네이티브 플러그인** (ObjC / Swift / C++) — `SpliceKit.framework`에 링크하고, dylib를 plugins 폴더에 넣고, `debug.loadPlugin`으로 핫로드합니다. 예제는 `Plugins/`와 `Sources/`에 있습니다.
- **FCP 내부 Lua** — `Ctrl+Opt+L`로 `sk` 모듈이 들어있는 REPL을 열 수 있습니다. `.lua` 파일을 `~/Library/Application Support/SpliceKit/lua/auto/`에 넣으면 라이브 코딩이 가능합니다. 전체 SDK는 [docs/LUA_SDK_REFERENCE.md](docs/LUA_SDK_REFERENCE.md)에 있습니다.
- **Python 또는 TCP socket을 다룰 수 있는 어떤 언어든** — `python3 Scripts/splicekit_client.py`로 대화형 런타임 REPL을 열 수 있습니다. 또는 `echo '{"jsonrpc":"2.0","method":"system.version","id":1}' | nc 127.0.0.1 9876`
- **MCP 도구** — 당신의 플러그인 기능을 MCP 도구로 노출하면 어떤 AI 클라이언트든 바로 사용할 수 있습니다.
- **AI에게 만들라고 요청** — `docs/` 안의 API 레퍼런스는 AI가 읽기 좋게 정리되어 있습니다. 원하는 기능을 설명하고 Claude에게 넘기면 플러그인을 작성할 수 있습니다.
- **SpliceKit 자체로 PR 보내기** — 당신이 만든 기능이 다른 편집자에게도 유용하다면 upstream으로 보내세요. Text-Based Editor, Silence Remover, LiveCam, Song Cut 같은 번들 기능도 모두 처음에는 플러그인이었습니다. 저장소를 포크하고 `Plugins/`나 `Sources/`에 코드를 넣은 뒤 [pull request](https://github.com/elliotttate/SpliceKit/pulls)를 열면 됩니다. 커뮤니티 플러그인이 SpliceKit를 키웁니다.

### 알아두면 좋은 FCP 내부 구조

| Class | Methods | Purpose |
|-------|---------|---------|
| `FFAnchoredTimelineModule` | 1435 | 메인 타임라인 컨트롤러 |
| `FFAnchoredSequence` | 1074 | 타임라인 데이터 모델 |
| `FFLibrary` / `FFLibraryDocument` | 203 / 231 | 라이브러리 관리 |
| `FFEditActionMgr` | 42 | 편집 명령 디스패처 |
| `FFPlayer` | 228 | 재생 엔진 |
| `PEAppController` | 484 | 앱 컨트롤러 |

| Prefix | Framework | Classes |
|--------|-----------|---------|
| FF | Flexo — core engine, timeline, editing | 2849 |
| OZ | Ozone — effects, compositing, color | 841 |
| PE | ProEditor — app controller, windows | 271 |
| LK | LunaKit — UI framework | 220 |
| TK | TimelineKit — timeline UI | 111 |
| IX | Interchange — FCPXML import/export | 155 |

### 소스에서 빌드

```bash
git clone https://github.com/elliotttate/SpliceKit.git
cd SpliceKit
make all && make deploy
```

### 문서 안내

- [`docs/WHAT_IS_SPLICEKIT.md`](docs/WHAT_IS_SPLICEKIT.md) — 쉬운 설명으로 보는 SpliceKit 소개
- [`docs/FCP_API_REFERENCE.md`](docs/FCP_API_REFERENCE.md) — FCP 내부 전체 API 레퍼런스
- [`docs/COMMAND_PALETTE_GUIDE.md`](docs/COMMAND_PALETTE_GUIDE.md) — Command Palette와 Apple Intelligence
- [`docs/LUA_SDK_REFERENCE.md`](docs/LUA_SDK_REFERENCE.md) · [`docs/LUA_SCRIPTING_GUIDE.md`](docs/LUA_SCRIPTING_GUIDE.md) — Lua 플러그인 스크립팅
- [`docs/TRANSCRIPT_EDITING_GUIDE.md`](docs/TRANSCRIPT_EDITING_GUIDE.md) — 텍스트 기반 편집기 플러그인
- [`docs/FXPLUG_PLUGIN_GUIDE.md`](docs/FXPLUG_PLUGIN_GUIDE.md) — FxPlug 4 플러그인 개발
- [`docs/WORKFLOW_EXTENSIONS_GUIDE.md`](docs/WORKFLOW_EXTENSIONS_GUIDE.md) — Workflow Extension
- [`docs/DEBUG_TOOLS_GUIDE.md`](docs/DEBUG_TOOLS_GUIDE.md) — in-process debugging, tracing, hot-loading
- [`docs/RUNTIME_INTROSPECTION_GUIDE.md`](docs/RUNTIME_INTROSPECTION_GUIDE.md) — ObjC 런타임 탐색
- [`docs/FCPXML_FORMAT_REFERENCE.md`](docs/FCPXML_FORMAT_REFERENCE.md) — FCPXML 포맷
- [`docs/SCENE_BEAT_DETECTION_GUIDE.md`](docs/SCENE_BEAT_DETECTION_GUIDE.md) · [`docs/FLEXMUSIC_AND_MONTAGE_GUIDE.md`](docs/FLEXMUSIC_AND_MONTAGE_GUIDE.md) — 감지와 몽타주 플러그인

---

## 커뮤니티

- **질문, 도움 요청, 기능 제안**: [FCP Cafe Discord](https://discord.com/invite/HD3FPc4Azu) (SpliceKit 채널)
- **버그 제보**: [GitHub Issues](https://github.com/elliotttate/SpliceKit/issues)
- **기능, 영상, FAQ**: [splicekit.fcp.cafe](https://splicekit.fcp.cafe)

커뮤니티 모딩 프로젝트가 결국 공식 제품에 영향을 주는 일은 오래된 전통입니다. SpliceKit가 Final Cut Pro를 앞으로 밀어주는 데 도움이 된다면 모두가 이깁니다.

---

## 라이선스

[MIT](LICENSE). 자유롭게 사용하고, 수정하고, 자신만의 플러그인과 함께 배포하세요.

계속 앞으로 나아갑시다 🥳
