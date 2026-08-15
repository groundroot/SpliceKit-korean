---
name: longform-subtitle
description: Final Cut Pro 프로젝트(FCPXMLD)에서 STT로 롱폼 Caption 자막을 자동 생성한다. 자막 없는 FCP 추출본을 입력받아 (1) 공백메움 자막본과 (2) 무음제거 압축본 2개의 FCPXMLD를 만든다. "자막 만들어줘", "자막 작업", "○○ 인터뷰/설교 자막", FCPXMLD 자막 생성, Silence-Cutter resub 요청 시 사용.
---

# 롱폼 자막 자동 생성 (Silence-Cutter resub)

FCP 촬영본 프로젝트에서 추출한(자막 없는) FCPXMLD를 입력받아, STT로 분석해
**롱폼 영상용 Caption 자막**이 포함된 FCPXMLD 2개를 생성한다.

## 도구 위치 (고정)

- 실행: `$HOME/Movies/Subtitle\ Automation/Silence-Cutter/.venv/bin/silence-cutter`
- Python: `.venv` (3.11). AI 모델(Qwen3-ASR-1.7B + ForcedAligner)은 자동 다운로드/캐시됨.

## 출력 (반드시 2개)

| 파일 | 내용 |
|---|---|
| `프로젝트명/원본_롱폼자막_공백메움.fcpxmld` | 원본 컷편집·타임라인 유지, Caption만 추가 |
| `프로젝트명/원본_롱폼자막_공백메움_무음제거.fcpxmld` | 무음 구간 제거로 타임라인 압축 + 자막 재배치 |

각 결과물은 **번들(`.fcpxmld`) + 평면(`.fcpxml`)** 둘 다 생성된다.
**FCP의 File > Import > XML은 평면 `.fcpxml`로 하는 것이 가장 안정적.**

> **출력 폴더 구조**: 원본(`인터뷰1.fcpxmld`) → 같은 위치에 `인터뷰1/` 서브폴더 자동 생성 후 결과물을 그 안에 저장.

## 실행 절차

### 1. 입력 FCPXMLD 점검
- `.fcpxmld/Info.fcpxml`을 읽어 `media-rep`의 `src` 경로가 **실제 존재**하는지 확인.
- NAS 경로(`/Volumes/...`)면 마운트 여부 확인.
- 경로가 깨졌으면(인코딩 오류) 실제 파일을 찾아 `src` 바이트를 교정. macOS FCPXML 경로는 **한글 NFD + percent-encoding**.

### 2. resub 실행
```bash
cd "$HOME/Movies/Subtitle Automation"
$HOME/Movies/Subtitle\ Automation/Silence-Cutter/.venv/bin/silence-cutter resub \
  "경로/원본.fcpxmld" \
  --min-silence-sec 0.6
```
- 출력 경로 미지정 시 **원본 옆에 프로젝트명 서브폴더**를 만들어 `원본_롱폼자막_공백메움.fcpxmld`(+무음제거)가 생성됨.
- ASR이 7분 영상 기준 수 분 소요 → **백그라운드 실행 권장** (`run_in_background`).

### 영상 유형별 `--min-silence-sec` (제거할 최소 무음 길이)
| 유형 | 값 | 유형 | 값 |
|---|---|---|---|
| 기본 | 0.7 | 인터뷰 | 0.6 |
| 강의 | 0.4 | 설교 | 0.8 |

### 주요 옵션
- `--max-subtitle-chars 44` / `--min-subtitle-chars 18` (한 줄 길이)
- `--gap-bridge-sec 0.4` (메울 짧은 끊김 한계 — 이보다 긴 침묵은 공백 유지)
- `--no-gap-fill` (순수 단어 타이밍, 끊김 메움 끔)
- `--script 대본.md` (오타/고유명사 보수적 교정 — 음성 우선)
- `--no-remove-silence` (결과물 2 생성 안 함)
- `--num-speakers N` (화자 수 고정, 2~4. 생략 시 실루엣 점수로 자동 감지)
- `--itt` (iTT 자막 파일도 함께 생성)

### 화자 분리 (`--num-speakers`)
- resemblyzer + SpectralClustering 기반. **HuggingFace 토큰 불필요**, Apple Silicon CPU 동작.
- resemblyzer가 없으면 화자 분리 없이 정상 동작(비활성화 로그 출력).
- 화자별 자막은 FCP 타임라인에서 **Dialogue 서브롤**(`Dialogue.화자1`, `Dialogue.화자2`, …)로 구분돼 표시됨.
- `--num-speakers` 생략 시 2~4명 범위에서 실루엣 점수로 최적 화자 수 자동 결정.

## 자막 규칙 (코드에 구현됨 — 참고)
- 한 줄만, **줄바꿈 절대 금지**, 18~44자, 의미 단위·호흡 우선
- 길이 초과 시 **마지막 절 경계까지 되돌려 분할** → 어절 중간 분할 방지. 앞 조각이 18자 미만이면 그 경계에서 안 끊음(쇼츠식 단편 방지)
- 조사·짧은 수식어 단독 분리 금지
- **타이밍 = forced-alignment 단어 시간 그대로** (글자수 재분배 안 함). 미세 끊김(≤0.4s)만 메우고 실제 호흡/침묵은 공백 유지
- 무음제거(결과물2) 자막 분배는 **교집합 기반**: 각 클립 구간과 겹치는 자막을 잘라 구간 전체를 빈틈없이 덮음 (silence 이미 제거돼 연속)
- title(lane1)은 Position `0 -440`으로 하단 배치 → iTT 캡션과 같은 위치
- 화자 분리 활성 시 title에 `role="Dialogue.화자N"` 속성 추가 (FCP Roles 패널에서 색상 구분 가능)
- **남은 한계:** 오인식("삼미탕" 등)은 Qwen3-ASR 정확도 문제 — 타이밍/끊기로 해결 불가. `--script` 또는 더 정밀한 ASR 필요

## 작업 완료 요약 로그

resub 완료 후 콘솔에 요약 통계가 출력된다:
```
====================================================
  작업 완료 요약
====================================================
  원본 클립 길이  : 12분 34.5초  (754.5s)
  잘라낸 분량     : 3분 21.2초   (201.2s, 26.7%)
  최종 분량(무음제거): 9분 13.3초 (553.3s)
====================================================
```

## 검증 (생성 후 자동 + 수동 재확인)

resub는 생성 직후 `_verify_fcpxml`로 자동 검증해 로그에 `✓`/`⚠️`를 출력한다.
**작업 완료 후 반드시 아래를 직접 재검증**한다:

```python
import xml.etree.ElementTree as ET
from fractions import Fraction
def t(s):
    s=s.rstrip("s"); return float(Fraction(s)) if s else 0.0
def verify(path, label):
    r = ET.parse(path).getroot()
    caps=[]
    for clip in r.iter("asset-clip"):
        co=t(clip.get("offset","0s")); cstart=t(clip.get("start","0s"))
        for cap in clip.findall("caption"):
            o=t(cap.get("offset","0s")); d=t(cap.get("duration","0s"))
            abs_s=co+(o-cstart)               # 절대 타임라인 위치
            ts=cap.find(".//text-style")
            caps.append((abs_s, abs_s+d, ts.text if ts is not None else ""))
    caps.sort()
    # 겹침/줄바꿈/짧은단편이 실제 오류. 빈공간은 결과물1에선 정상(발화 사이 침묵)
    gaps=[(caps[i-1][1],caps[i][0]) for i in range(1,len(caps)) if caps[i][0]-caps[i-1][1]>0.1]
    overlap=sum(1 for i in range(1,len(caps)) if caps[i-1][1]-caps[i][0]>0.1)
    multiline=sum(1 for _,_,x in caps if "\n" in x)
    tooShort=sum(1 for _,_,x in caps if 0<len(x)<18)
    print(f"{label}: caption {len(caps)} | 겹침 {overlap} 줄바꿈 {multiline} 18자미만 {tooShort} | 침묵공백 {len(gaps)}(결과물1은 정상)",
          "✓" if not overlap and not multiline else "✗")
```

**검증 해석:** 결과물1은 실제 발화 타이밍이라 발화 사이 침묵 공백이 정상(오류 아님). 결과물2(무음제거)는 연속이어야 하므로 빈공간 0이어야 함. 겹침·줄바꿈·18자미만 단편이 실제 점검 대상.

### FCP DTD 검증 (Import 가능 여부 확정)
```bash
DTD="/Applications/Final Cut Pro.app/Contents/Frameworks/Interchange.framework/Versions/A/Resources/FCPXMLv1_14.dtd"
cp "$DTD" /tmp/FCPXMLv1_14.dtd
python3 -c "open('/tmp/c.fcpxml','w').write(open('출력.fcpxmld/Info.fcpxml').read().replace('<!DOCTYPE fcpxml>','<!DOCTYPE fcpxml SYSTEM \"/tmp/FCPXMLv1_14.dtd\">'))"
xmllint --noout --valid /tmp/c.fcpxml   # 종료코드 0 = 통과
```

### 검증 체크리스트 (양 결과물)
- [ ] caption 생성됨 (0개면 실패)
- [ ] 한 줄, 줄바꿈 없음
- [ ] 자막 사이 빈 공간 없음 (>0.1s)
- [ ] 겹침 없음 / 클립 경계 내
- [ ] 원본 미변경 (원본 caption 0개 유지)
- [ ] FCP DTD 1.14 통과

## FCP Import 실패 시 (자주 겪는 함정)
1. **`.fcpxmld`인데 단일 파일** → 번들(디렉토리+`Info.fcpxml`)이어야 함. Import는 평면 `.fcpxml` 사용.
2. **프로젝트 안 생김(에러 없음)** → 라이브러리에 같은 UID 프로젝트 존재 → resub가 새 UID+이름 접미사 부여하므로 최신 출력 사용.
3. **자막 위치 이상/빈 결과** → `asset-clip.start`는 카메라 TC지 파일 위치 아님. `asset.start`를 빼야 파일 위치.
4. **Import 시 hang/크래시** → `media-rep`의 stale `<bookmark>`(NAS/SMB) 때문. resub가 자동 제거함.

상세는 메모리 `fcpxml-import-gotchas`, `resub-longform-workflow` 참조.
