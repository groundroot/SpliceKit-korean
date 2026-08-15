#!/usr/bin/env python3
"""폴더의 영상들 -> 영상 1개당 프로젝트 1개인 FCPXML 생성 (원본 링크, 복사 안 함).

    python3 folder_to_fcpxml.py <folder> [-o out.fcpxml] [-e 이벤트명] [--ext mp4 mov]

포맷(해상도/프레임레이트)은 ffprobe로 소스마다 읽어 시퀀스에 그대로 맞춘다.
출력 XML을 import_fcpxml(xml=..., internal=True) 로 넘기면 FCP에 들어간다.
"""
import argparse, glob, json, os, subprocess, sys, urllib.parse
from xml.sax.saxutils import quoteattr


def probe(path):
    j = json.loads(subprocess.check_output([
        "ffprobe", "-v", "error", "-print_format", "json",
        "-show_streams", "-show_format", path]))
    v = next(s for s in j["streams"] if s["codec_type"] == "video")
    a = next((s for s in j["streams"] if s["codec_type"] == "audio"), None)
    num, den = (int(x) for x in v["r_frame_rate"].split("/"))
    frames = int(v.get("nb_frames") or round(float(j["format"]["duration"]) * num / den))
    return dict(w=int(v["width"]), h=int(v["height"]), fnum=num, fden=den, frames=frames,
                achan=int(a["channels"]) if a else 0,
                arate=int(a["sample_rate"]) if a else 0)


def build(paths, event):
    res, body = [], []
    for i, path in enumerate(paths, 1):
        m = probe(path)
        name = os.path.splitext(os.path.basename(path))[0]
        fid, aid = f"f{i}", f"a{i}"
        # r_frame_rate=num/den -> frameDuration=den/num s  (30000/1001 fps => 1001/30000s)
        fd = f"{m['fden']}/{m['fnum']}s"
        dur = f"{m['frames'] * m['fden']}/{m['fnum']}s"
        src = "file://" + urllib.parse.quote(os.path.abspath(path))
        res.append(f'<format id="{fid}" frameDuration="{fd}" width="{m["w"]}" '
                   f'height="{m["h"]}" colorSpace="1-1-1 (Rec. 709)"/>')
        audio = (f' hasAudio="1" audioSources="1" audioChannels="{m["achan"]}"'
                 f' audioRate="{m["arate"]}"') if m["achan"] else ""
        res.append(f'<asset id="{aid}" name={quoteattr(name)} start="0s" duration="{dur}" '
                   f'hasVideo="1" videoSources="1"{audio} format="{fid}">'
                   f'<media-rep kind="original-media" src="{src}"/></asset>')
        body.append(
            f'<project name={quoteattr(name)}><sequence format="{fid}" duration="{dur}" '
            f'tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k"><spine>'
            f'<asset-clip name={quoteattr(name)} ref="{aid}" offset="0s" start="0s" '
            f'duration="{dur}" format="{fid}" tcFormat="NDF" audioRole="dialogue"/>'
            f'</spine></sequence></project>')
    return ('<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE fcpxml>\n'
            '<fcpxml version="1.9">\n<resources>\n' + "\n".join(res) +
            f'\n</resources>\n<library>\n<event name={quoteattr(event)}>\n' +
            "\n".join(body) + '\n</event>\n</library>\n</fcpxml>\n')


p = argparse.ArgumentParser()
p.add_argument("folder")
p.add_argument("-o", "--out", default="")
p.add_argument("-e", "--event", default="Imported")
p.add_argument("--ext", nargs="+", default=["mp4", "mov", "m4v", "mxf"])
a = p.parse_args()

paths = sorted(f for e in a.ext for f in glob.glob(os.path.join(a.folder, f"*.{e}")))
if not paths:
    sys.exit(f"영상 없음: {a.folder}")

out = a.out or os.path.join(a.folder, "import.fcpxml")
with open(out, "w") as fh:
    fh.write(build(paths, a.event))
subprocess.run(["xmllint", "--noout", out], check=True)
print(f"{out}  (프로젝트 {len(paths)}개)")
