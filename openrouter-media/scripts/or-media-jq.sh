#!/usr/bin/env bash
# or-media.sh - OpenRouter image/video generation helper (replaces the `higgsfield` CLI)
# Requires: bash, curl, jq, OPENROUTER_API_KEY. ffmpeg optional.
#
#   or-media.sh models image|video
#   or-media.sh price <model>
#   or-media.sh image --model openai/gpt-image-2 --prompt "..." [--ratio 16:9] [--resolution 2K]
#                     [--quality high] [--format png] [--n 1] [--ref <path|url>]... [--out DIR]
#   or-media.sh video --model google/veo-3.1 --prompt "..." [--duration 8] [--resolution 1080p]
#                     (--ref accepts images or a source video for edit/upscale models)
#                     [--ratio 16:9] [--audio true|false] [--seed 7]
#                     [--first-frame <path|url>] [--last-frame <path|url>] [--ref <path|url>]...
#                     [--out DIR] [--timeout 1800] [--interval 10]
#   or-media.sh models speech | voices <tts-model>
#   or-media.sh speech --model elevenlabs/eleven-v3 --voice sarah --input "..." \
#                      [--instructions "warm, clear"] [--format mp3|pcm] [--speed 1.0]
#                      [--ref <audio-sample>]... [--out DIR]
#   or-media.sh poll <job_id>
#
# Local files are inlined as base64 data URLs, so no upload step is needed.
set -euo pipefail
BASE="${OPENROUTER_BASE_URL:-https://openrouter.ai/api/v1}"

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
need_key() { [ -n "${OPENROUTER_API_KEY:-}" ] || die "OPENROUTER_API_KEY is not set"; }

mime_of() {
  case "${1##*.}" in
    png|PNG) echo image/png;;
    jpg|jpeg|JPG|JPEG) echo image/jpeg;;
    webp|WEBP) echo image/webp;;
    gif|GIF) echo image/gif;;
    mp4|MP4) echo video/mp4;;
    mov|MOV) echo video/quicktime;;
    webm|WEBM) echo video/webm;;
    mp3|MP3) echo audio/mpeg;;
    wav|WAV) echo audio/wav;;
    *) echo application/octet-stream;;
  esac
}

as_url() {
  local v="$1"
  case "$v" in
    http://*|https://*|data:*) printf '%s' "$v";;
    *)
      [ -f "$v" ] || die "file not found: $v"
      printf 'data:%s;base64,%s' "$(mime_of "$v")" "$(base64 < "$v" | tr -d '\n')"
      ;;
  esac
}

api() { # method path [json]
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    curl -sS -X "$method" "$BASE$path" \
      -H "Authorization: Bearer $OPENROUTER_API_KEY" \
      -H "Content-Type: application/json" -d "$body"
  else
    curl -sS -X "$method" "$BASE$path" -H "Authorization: Bearer $OPENROUTER_API_KEY"
  fi
}

fail_if_error() {
  if ! jq -e '.error // empty | length > 0' >/dev/null 2>&1 <<<"$1"; then return 0; fi
  jq -r '"OpenRouter error: " + ((.error.message // (.error|tostring)))' <<<"$1" >&2
  exit 1
}

cmd_models() {
  need jq; local kind="${1:-video}"
  if [ "$kind" = "speech" ]; then
    api GET /audio/speech/models | jq -r '.data[] | "\(.id)\t\((.output_modalities[0].supported_parameters.voice.values // []) | join(","))"'
  elif [ "$kind" = "image" ]; then
    api GET /images/models | jq -r '.data[] | "\(.id)\t\((.architecture.input_modalities // []) | join(","))\t\((.supported_parameters // {}) | keys | join(","))"'
  else
    api GET /videos/models | jq -r '.data[] | "\(.id)\t\(.name)\tdur=\((.supported_durations // [])|join("/"))\tres=\((.supported_resolutions // [])|join("/"))\tar=\((.supported_aspect_ratios // [])|join("/"))\tframes=\((.supported_frame_images // [])|join("/"))\t\(.pricing_skus // {} | to_entries | map("\(.key)=\(.value)") | join(" "))"'
  fi
}

cmd_price() {
  need jq; local model="${1:?usage: price <model>}"
  api GET /videos/models | jq -r --arg m "$model" '.data[] | select(.id==$m) | "\(.id)\n" + (.pricing_skus // {} | to_entries | map("  \(.key): \(.value)") | join("\n"))'
  api GET /images/models | jq -r --arg m "$model" '.data[] | select(.id==$m) | "\(.id) (image)"'
}

cmd_image() {
  need curl; need jq; need_key
  local model="" prompt="" n=1 ratio="" res="" quality="" fmt="" outdir="./or-media-out" refs=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --model) model="$2"; shift 2;;
      --prompt) prompt="$2"; shift 2;;
      --n) n="$2"; shift 2;;
      --ratio|--aspect_ratio) ratio="$2"; shift 2;;
      --resolution) res="$2"; shift 2;;
      --quality) quality="$2"; shift 2;;
      --format|--output_format) fmt="$2"; shift 2;;
      --ref|--image) refs+=("$2"); shift 2;;
      --out) outdir="$2"; shift 2;;
      *) die "unknown option: $1";;
    esac
  done
  [ -n "$model" ] || die "--model required"
  [ -n "$prompt" ] || die "--prompt required"
  mkdir -p "$outdir"

  local refsjson='[]' r payload resp
  for r in ${refs[@]+"${refs[@]}"}; do
    refsjson=$(jq -c --arg u "$(as_url "$r")" '. + [{type:"image_url",image_url:{url:$u}}]' <<<"$refsjson")
  done
  payload=$(jq -n \
    --arg m "$model" --arg p "$prompt" --argjson n "$n" --argjson refs "$refsjson" \
    --arg ratio "$ratio" --arg res "$res" --arg q "$quality" --arg f "$fmt" '
    {model:$m, prompt:$p, n:$n, response_format:"url"}
    + (if $ratio != "" then {aspect_ratio:$ratio} else {} end)
    + (if $res   != "" then {resolution:$res} else {} end)
    + (if $q     != "" then {quality:$q} else {} end)
    + (if $f     != "" then {output_format:$f} else {} end)
    + (if ($refs|length) > 0 then {input_references:$refs} else {} end)')

  resp=$(api POST /images "$payload")
  fail_if_error "$resp"
  echo "$resp" | jq -r '"cost_usd=\(.usage.cost // "n/a")"' >&2
  local i=0 url ext
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    i=$((i+1)); ext="png"
    curl -sS -o "$outdir/image-$i.$ext" "$url"
    echo "$outdir/image-$i.$ext"
  done < <(echo "$resp" | jq -r '.data[] | .url // empty')
  if [ "$i" -eq 0 ]; then
    while IFS= read -r b64; do
      [ -n "$b64" ] || continue
      i=$((i+1))
      echo "$b64" | base64 -d > "$outdir/image-$i.png"
      echo "$outdir/image-$i.png"
    done < <(echo "$resp" | jq -r '.data[] | .b64_json // empty')
  fi
  [ "$i" -gt 0 ] || die "no image returned"
}

cmd_video() {
  need curl; need jq; need_key
  local model="" prompt="" duration="" res="" ratio="" size="" audio="" seed="" outdir="./or-media-out"
  local timeout=1800 interval=10 firstframe="" lastframe="" refs=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --model) model="$2"; shift 2;;
      --prompt) prompt="$2"; shift 2;;
      --duration) duration="$2"; shift 2;;
      --resolution) res="$2"; shift 2;;
      --ratio|--aspect_ratio) ratio="$2"; shift 2;;
      --size) size="$2"; shift 2;;
      --audio|--generate_audio) audio="$2"; shift 2;;
      --seed) seed="$2"; shift 2;;
      --first-frame) firstframe="$2"; shift 2;;
      --last-frame) lastframe="$2"; shift 2;;
      --ref|--reference) refs+=("$2"); shift 2;;
      --out) outdir="$2"; shift 2;;
      --timeout) timeout="$2"; shift 2;;
      --interval) interval="$2"; shift 2;;
      *) die "unknown option: $1";;
    esac
  done
  [ -n "$model" ] || die "--model required"
  mkdir -p "$outdir"

  local frames='[]' inputs='[]' r payload resp id status
  if [ -n "$firstframe" ]; then
    frames=$(jq -c --arg u "$(as_url "$firstframe")" '. + [{type:"image_url",image_url:{url:$u},frame_type:"first_frame"}]' <<<"$frames")
  fi
  if [ -n "$lastframe" ]; then
    frames=$(jq -c --arg u "$(as_url "$lastframe")" '. + [{type:"image_url",image_url:{url:$u},frame_type:"last_frame"}]' <<<"$frames")
  fi
  for r in ${refs[@]+"${refs[@]}"}; do
    local kind="image_url"
    case "$r" in
      *".mp4"|*".mov"|*".webm"|data:video/*) kind="video_url";;
      *)
        if [ -f "$r" ]; then
          case "$(mime_of "$r")" in video/*) kind="video_url";; esac
        fi
        ;;
    esac
    inputs=$(jq -c --arg u "$(as_url "$r")" --arg k "$kind" '. + [{type:$k, ($k):{url:$u}}]' <<<"$inputs")
  done

  payload=$(jq -n \
    --arg m "$model" --arg p "$prompt" --argjson frames "$frames" --argjson inputs "$inputs" \
    --arg duration "$duration" --arg res "$res" --arg ratio "$ratio" --arg size "$size" \
    --arg audio "$audio" --arg seed "$seed" '
    {model:$m}
    + (if $p != "" then {prompt:$p} else {} end)
    + (if $duration != "" then {duration:($duration|tonumber)} else {} end)
    + (if $res != "" then {resolution:$res} else {} end)
    + (if $ratio != "" then {aspect_ratio:$ratio} else {} end)
    + (if $size != "" then {size:$size} else {} end)
    + (if $audio != "" then {generate_audio:($audio == "true")} else {} end)
    + (if $seed != "" then {seed:($seed|tonumber)} else {} end)
    + (if ($frames|length) > 0 then {frame_images:$frames} else {} end)
    + (if ($inputs|length) > 0 then {input_references:$inputs} else {} end)')

  resp=$(api POST /videos "$payload")
  fail_if_error "$resp"
  id=$(jq -r '.id // empty' <<<"$resp")
  [ -n "$id" ] || die "no job id returned: $resp"
  echo "job=$id status=$(jq -r '.status // "pending"' <<<"$resp")" >&2

  local start elapsed
  start=$(date +%s)
  while :; do
    sleep "$interval"
    resp=$(api GET "/videos/$id")
    fail_if_error "$resp"
    status=$(jq -r '.status // "unknown"' <<<"$resp")
    echo "status=$status elapsed=$(( $(date +%s) - start ))s" >&2
    case "$status" in
      completed) break;;
      failed|cancelled|expired)
        jq -r '"job " + .status + ": " + ((.error // "unknown")|tostring)' <<<"$resp" >&2
        exit 1;;
    esac
    elapsed=$(( $(date +%s) - start ))
    [ "$elapsed" -lt "$timeout" ] || die "timed out after ${timeout}s (job $id is still $status)"
  done

  jq -r '"cost_usd=\(.usage.cost // "n/a")"' <<<"$resp" >&2
  local outfile="$outdir/$id.mp4"
  curl -sS -o "$outfile" -H "Authorization: Bearer $OPENROUTER_API_KEY" "$BASE/videos/$id/content?index=0"
  [ -s "$outfile" ] || die "download produced an empty file"
  echo "$outfile"
}

cmd_voices() {
  need jq; local model="${1:?usage: voices <tts-model>}"
  api GET "/audio/speech/models/$model" | jq -r '
    .output_modalities[0].supported_parameters as $p
    | "voices: " + (($p.voice.values // ["(not published)"]) | join(", "))
      + "\nformats: " + (($p.response_format.values // []) | join(", "))'
}

cmd_speech() {
  need curl; need jq; need_key
  local model="" voice="" input="" instructions="" fmt="mp3" speed="" outdir="./or-media-out" refs=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --model) model="$2"; shift 2;;
      --voice|--voice-id) voice="$2"; shift 2;;
      --input|--text|--prompt) input="$2"; shift 2;;
      --instructions) instructions="$2"; shift 2;;
      --format|--response_format) fmt="$2"; shift 2;;
      --speed) speed="$2"; shift 2;;
      --ref) refs+=("$2"); shift 2;;
      --out) outdir="$2"; shift 2;;
      *) die "unknown option: $1";;
    esac
  done
  [ -n "$model" ] || die "--model required"
  [ -n "$input" ] || die "--input required"
  mkdir -p "$outdir"

  local refjson='[]' r payload
  for r in ${refs[@]+"${refs[@]}"}; do
    refjson=$(jq -c --arg u "$(as_url "$r")" '. + [{type:"input_audio",input_audio:{data:$u}}]' <<<"$refjson")
  done
  payload=$(jq -n --arg m "$model" --arg v "$voice" --arg i "$input" --arg ins "$instructions" \
    --arg f "$fmt" --arg sp "$speed" --argjson refs "$refjson" '
    {model:$m, input:$i, response_format:$f}
    + (if $v != "" then {voice:$v} else {} end)
    + (if $ins != "" then {instructions:$ins} else {} end)
    + (if $sp != "" then {speed:($sp|tonumber)} else {} end)
    + (if ($refs|length) > 0 then {input_references:$refs} else {} end)')

  local outfile="$outdir/speech-$(date +%s).$fmt"
  local code
  code=$(curl -sS -w '%{http_code}' -o "$outfile" -X POST "$BASE/audio/speech" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "Content-Type: application/json" -d "$payload")
  if [ "$code" != "200" ]; then
    echo "OpenRouter TTS error ($code): $(head -c 500 "$outfile")" >&2
    rm -f "$outfile"; exit 1
  fi
  [ -s "$outfile" ] || die "empty audio file"
  [ "$fmt" = "pcm" ] && echo "note: raw PCM - convert with ffmpeg -f s16le -ar 24000 -ac 1 -i $outfile $outfile.wav" >&2
  echo "$outfile"
}

cmd_poll() {
  need jq; need_key; local id="${1:?usage: poll <job_id>}"
  api GET "/videos/$id" | jq .
}

case "${1:-}" in
  models) shift; cmd_models "$@";;
  price) shift; cmd_price "$@";;
  voices) shift; cmd_voices "$@";;
  speech) shift; cmd_speech "$@";;
  image) shift; cmd_image "$@";;
  video) shift; cmd_video "$@";;
  poll) shift; cmd_poll "$@";;
  ""|-h|--help) sed -n '2,20p' "$0";;
  *) die "unknown command: $1";;
esac
