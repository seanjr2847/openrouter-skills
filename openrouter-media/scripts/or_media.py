#!/usr/bin/env python3
"""or_media.py - OpenRouter image / video / speech helper (stdlib only).

Replaces the "higgsfield" CLI used by the higgsfield-* skills.

    or_media.py models image|video|speech
    or_media.py price <model>
    or_media.py voices <tts-model>
    or_media.py image  --model M --prompt "..." [--ratio 16:9] [--resolution 2K]
                       [--quality high] [--format png] [--n 1] [--ref F]... [--out DIR]
    or_media.py video  --model M [--prompt "..."] [--duration 8] [--resolution 1080p]
                       [--ratio 16:9] [--audio true|false] [--seed N]
                       [--first-frame F] [--last-frame F] [--ref F]... [--out DIR]
                       [--timeout 1800] [--interval 10]
    or_media.py speech --model M [--voice V] --input "..." [--instructions "..."]
                       [--format mp3|pcm] [--speed 1.0] [--ref sample]... [--out DIR]
    or_media.py poll <job_id>

    --dry-run on image/video/speech prints the request JSON and sends nothing.

Local files are inlined as base64 data URLs, so no upload step exists.
"""
import argparse
import base64
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.request

BASE = os.environ.get("OPENROUTER_BASE_URL", "https://openrouter.ai/api/v1").rstrip("/")
KEY = os.environ.get("OPENROUTER_API_KEY", "")


def die(msg, code=1):
    print("error: " + msg, file=sys.stderr)
    sys.exit(code)


def need_key():
    if not KEY:
        die("OPENROUTER_API_KEY is not set")


def as_url(value):
    if value.startswith(("http://", "https://", "data:")):
        return value
    if not os.path.isfile(value):
        die("file not found: " + value)
    mime = mimetypes.guess_type(value)[0] or "application/octet-stream"
    with open(value, "rb") as fh:
        return "data:%s;base64,%s" % (mime, base64.b64encode(fh.read()).decode())


def ref_kind(value):
    mime = None
    if value.startswith("data:"):
        mime = value[5:].split(";")[0]
    elif os.path.isfile(value):
        mime = mimetypes.guess_type(value)[0]
    elif value.lower().endswith((".mp4", ".mov", ".webm")):
        return "video_url"
    return "video_url" if (mime or "").startswith("video/") else "image_url"


def call(method, path, payload=None, raw=False):
    url = BASE + path
    data = None
    headers = {"Authorization": "Bearer " + KEY}
    if payload is not None:
        data = json.dumps(payload).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=600) as res:
            body = res.read()
            return (body, res.status) if raw else (json.loads(body or b"{}"), res.status)
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        try:
            err = json.loads(body).get("error")
            msg = err.get("message") if isinstance(err, dict) else err
        except Exception:
            msg = body[:400]
        die("HTTP %s: %s" % (exc.code, msg or body[:400]))


def post_json(path, payload):
    if payload is not None and payload.get("_dry_run"):
        print(json.dumps({k: v for k, v in payload.items() if k != "_dry_run"}, indent=2))
        return None
    return call("POST", path, payload)[0]


def get_json(path):
    return call("GET", path)[0]


def download(url, dest, with_auth=True):
    headers = {"Authorization": "Bearer " + KEY} if with_auth else {}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=600) as res, open(dest, "wb") as out:
        out.write(res.read())
    if os.path.getsize(dest) == 0:
        die("download produced an empty file: " + url)
    return dest

def cmd_models(args):
    if args.kind == "image":
        for m in get_json("/images/models").get("data", []):
            params = ",".join(sorted((m.get("supported_parameters") or {}).keys()))
            print("%s\t%s" % (m.get("id"), params))
    elif args.kind == "speech":
        for m in get_json("/audio/speech/models").get("data", []):
            voices = []
            for om in m.get("output_modalities") or []:
                if om.get("type") == "speech":
                    voices = ((om.get("supported_parameters") or {}).get("voice") or {}).get("values") or []
            print("%s\t%s" % (m.get("id"), ",".join(voices[:8])))
    else:
        for m in get_json("/videos/models").get("data", []):
            print("%s\tdur=%s\tres=%s\tar=%s\tframes=%s\t%s" % (
                m.get("id"),
                "/".join(str(x) for x in (m.get("supported_durations") or [])),
                "/".join(m.get("supported_resolutions") or []),
                "/".join(m.get("supported_aspect_ratios") or []),
                "/".join(m.get("supported_frame_images") or []),
                json.dumps(m.get("pricing_skus") or {}),
            ))


def cmd_price(args):
    found = False
    for m in get_json("/videos/models").get("data", []):
        if m.get("id") == args.model:
            found = True
            print(m["id"])
            for k, v in sorted((m.get("pricing_skus") or {}).items()):
                print("  %s: %s" % (k, v))
    if not found:
        print(args.model + " is not a video model (see `models image` / `models speech`)")


def cmd_voices(args):
    data = get_json("/audio/speech/models/" + args.model)
    params = {}
    for om in data.get("output_modalities") or []:
        if om.get("type") == "speech":
            params = om.get("supported_parameters") or {}
    voices = (params.get("voice") or {}).get("values") or []
    print("voices: " + (", ".join(voices) if voices else "(not published)"))
    fmt = (params.get("response_format") or {}).get("values") or []
    if fmt:
        print("formats: " + ", ".join(fmt))
    if "instructions" in params:
        print("instructions: supported")
    speed = params.get("speed")
    if speed:
        print("speed: %s-%s" % (speed.get("min"), speed.get("max")))


def cmd_image(args):
    payload = {"model": args.model, "prompt": args.prompt, "n": args.n, "response_format": "url"}
    if args.ratio:
        payload["aspect_ratio"] = args.ratio
    if args.resolution:
        payload["resolution"] = args.resolution
    if args.quality:
        payload["quality"] = args.quality
    if args.format:
        payload["output_format"] = args.format
    if args.ref:
        payload["input_references"] = [
            {"type": "image_url", "image_url": {"url": as_url(r)}} for r in args.ref]
    if args.dry_run:
        payload["_dry_run"] = True
        post_json("/images", payload)
        return
    need_key()
    os.makedirs(args.out, exist_ok=True)
    result = post_json("/images", payload)
    cost = (result.get("usage") or {}).get("cost")
    print("cost_usd=%s" % (cost if cost is not None else "n/a"), file=sys.stderr)
    paths = []
    for i, item in enumerate(result.get("data") or [], 1):
        dest = os.path.join(args.out, "image-%d.png" % i)
        if item.get("url"):
            download(item["url"], dest, with_auth=False)
        elif item.get("b64_json"):
            with open(dest, "wb") as fh:
                fh.write(base64.b64decode(item["b64_json"]))
        else:
            continue
        paths.append(dest)
    if not paths:
        die("no image returned")
    for p in paths:
        print(p)

def cmd_video(args):
    payload = {"model": args.model}
    if args.prompt:
        payload["prompt"] = args.prompt
    if args.duration:
        payload["duration"] = int(args.duration)
    if args.resolution:
        payload["resolution"] = args.resolution
    if args.ratio:
        payload["aspect_ratio"] = args.ratio
    if args.size:
        payload["size"] = args.size
    if args.audio is not None:
        payload["generate_audio"] = str(args.audio).lower() == "true"
    if args.seed:
        payload["seed"] = int(args.seed)
    frames = []
    if args.first_frame:
        frames.append({"type": "image_url", "image_url": {"url": as_url(args.first_frame)},
                       "frame_type": "first_frame"})
    if args.last_frame:
        frames.append({"type": "image_url", "image_url": {"url": as_url(args.last_frame)},
                       "frame_type": "last_frame"})
    if frames:
        payload["frame_images"] = frames
    if args.ref:
        payload["input_references"] = [
            {"type": ref_kind(r), ref_kind(r): {"url": as_url(r)}} for r in args.ref]
    if args.dry_run:
        payload["_dry_run"] = True
        post_json("/videos", payload)
        return
    need_key()
    os.makedirs(args.out, exist_ok=True)
    job = post_json("/videos", payload)
    job_id = job.get("id")
    if not job_id:
        die("no job id returned: %s" % json.dumps(job)[:300])
    print("job=%s status=%s" % (job_id, job.get("status")), file=sys.stderr)
    started = time.time()
    while True:
        time.sleep(args.interval)
        status = get_json("/videos/" + job_id)
        state = status.get("status")
        print("status=%s elapsed=%ds" % (state, int(time.time() - started)), file=sys.stderr)
        if state == "completed":
            break
        if state in ("failed", "cancelled", "expired"):
            die("job %s: %s" % (state, status.get("error") or "unknown"))
        if time.time() - started > args.timeout:
            die("timed out after %ds (job %s is %s)" % (args.timeout, job_id, state))
    cost = (status.get("usage") or {}).get("cost")
    print("cost_usd=%s" % (cost if cost is not None else "n/a"), file=sys.stderr)
    dest = os.path.join(args.out, job_id + ".mp4")
    download("%s/videos/%s/content?index=0" % (BASE, job_id), dest)
    print(dest)


def cmd_speech(args):
    payload = {"model": args.model, "input": args.input, "response_format": args.format}
    if args.voice:
        payload["voice"] = args.voice
    if args.instructions:
        payload["instructions"] = args.instructions
    if args.speed:
        payload["speed"] = float(args.speed)
    if args.ref:
        payload["input_references"] = [
            {"type": "input_audio", "input_audio": {"data": as_url(r)}} for r in args.ref]
    if args.dry_run:
        payload["_dry_run"] = True
        post_json("/audio/speech", payload)
        return
    need_key()
    os.makedirs(args.out, exist_ok=True)
    dest = os.path.join(args.out, "speech-%d.%s" % (int(time.time()), args.format))
    body, _ = call("POST", "/audio/speech", payload, raw=True)
    if not body:
        die("empty audio response")
    with open(dest, "wb") as fh:
        fh.write(body)
    if args.format == "pcm":
        print("note: raw PCM - convert with: ffmpeg -f s16le -ar 24000 -ac 1 -i %s %s.wav" % (dest, dest),
              file=sys.stderr)
    print(dest)


def cmd_poll(args):
    print(json.dumps(get_json("/videos/" + args.job_id), indent=2))


def main(argv=None):
    p = argparse.ArgumentParser(prog="or_media.py", description="OpenRouter image/video/speech helper")
    sub = p.add_subparsers(dest="cmd", required=True)

    m = sub.add_parser("models")
    m.add_argument("kind", nargs="?", default="video", choices=["image", "video", "speech"])
    m.set_defaults(func=cmd_models)

    pr = sub.add_parser("price")
    pr.add_argument("model")
    pr.set_defaults(func=cmd_price)

    v = sub.add_parser("voices")
    v.add_argument("model")
    v.set_defaults(func=cmd_voices)

    im = sub.add_parser("image")
    im.add_argument("--model", required=True)
    im.add_argument("--prompt", required=True)
    im.add_argument("--n", type=int, default=1)
    im.add_argument("--ratio", "--aspect_ratio", dest="ratio")
    im.add_argument("--resolution")
    im.add_argument("--quality")
    im.add_argument("--format", "--output_format", dest="format")
    im.add_argument("--ref", "--image", dest="ref", action="append")
    im.add_argument("--out", default="./or-media-out")
    im.add_argument("--dry-run", action="store_true")
    im.set_defaults(func=cmd_image)

    vi = sub.add_parser("video")
    vi.add_argument("--model", required=True)
    vi.add_argument("--prompt")
    vi.add_argument("--duration")
    vi.add_argument("--resolution")
    vi.add_argument("--ratio", "--aspect_ratio", dest="ratio")
    vi.add_argument("--size")
    vi.add_argument("--audio", "--generate_audio", dest="audio")
    vi.add_argument("--seed")
    vi.add_argument("--first-frame", dest="first_frame")
    vi.add_argument("--last-frame", dest="last_frame")
    vi.add_argument("--ref", "--reference", dest="ref", action="append")
    vi.add_argument("--out", default="./or-media-out")
    vi.add_argument("--timeout", type=int, default=1800)
    vi.add_argument("--interval", type=int, default=10)
    vi.add_argument("--dry-run", action="store_true")
    vi.set_defaults(func=cmd_video)

    sp = sub.add_parser("speech")
    sp.add_argument("--model", required=True)
    sp.add_argument("--input", "--text", "--prompt", dest="input", required=True)
    sp.add_argument("--voice", "--voice-id", dest="voice")
    sp.add_argument("--instructions")
    sp.add_argument("--format", "--response_format", dest="format", default="mp3")
    sp.add_argument("--speed")
    sp.add_argument("--ref", dest="ref", action="append")
    sp.add_argument("--out", default="./or-media-out")
    sp.add_argument("--dry-run", action="store_true")
    sp.set_defaults(func=cmd_speech)

    po = sub.add_parser("poll")
    po.add_argument("job_id")
    po.set_defaults(func=cmd_poll)

    args = p.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
