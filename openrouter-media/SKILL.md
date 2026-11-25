---
name: openrouter-media
description: |
  Generate images and videos through OpenRouter's media APIs. This is the
  generation layer that replaces the Higgsfield CLI (`higgsfield generate create`)
  used by the higgsfield-* skills. Use when: "generate an image", "make a video",
  "image to video", "animate this photo", "first and last frame", "upscale this
  video", "edit this video", "which model should I use", "how much will this cost".
  Covers text-to-image, image editing with reference images, text-to-video,
  first/last-frame video, reference-to-video, video edit and video upscale.
  Also covers narration and voiceover through the TTS endpoint.
  NOT for: 3D/GLB generation, character/Soul training, marketing-studio avatar ads, or
  virality scoring. Those have no OpenRouter equivalent; say so instead of improvising.
argument-hint: "[prompt] [--model <openrouter-model>] [--image|--video <path-or-url>]"
allowed-tools: Bash
---

# OpenRouter media

Two endpoints do everything here:

| Task | Endpoint | Sync? |
|---|---|---|
| Image generation / editing | `POST https://openrouter.ai/api/v1/images` | synchronous, returns in seconds to ~2 min |
| Video generation / edit / upscale | `POST https://openrouter.ai/api/v1/videos` | asynchronous: submit, poll, download |
| Speech / narration / SFX (TTS) | `POST https://openrouter.ai/api/v1/audio/speech` | synchronous, returns raw audio bytes |

Discovery: `GET /api/v1/images/models` and `GET /api/v1/videos/models`. Both are
public, so model ids, supported durations/resolutions/aspect ratios and prices are
always checkable instead of guessed.

## Step 0 - Bootstrap

1. `OPENROUTER_API_KEY` must be in the environment. If it is missing, ask the user
   to add it (Claude Code: `~/.claude/settings.json` -> `"env": {"OPENROUTER_API_KEY": "sk-or-..."}`,
   or export it in the shell). Never print the key.
2. Tools: Python 3 (the helper is stdlib-only, no jq/curl needed; `or-media-jq.sh` is a bash+jq fallback). `ffmpeg` only when encoding frames.
3. `bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models video` (or `models image`, `models speech`) to see what is live. Add `--dry-run` to `image`/`video`/`speech` to print the request JSON without sending it.

## UX rules

1. Be concise. Return the generated file path or URL plus a one-line summary
   (model, duration for video). No job ids, no JSON dumps.
2. Reply in the user's language. Model ids and flags stay English.
3. Do not pre-estimate cost unless asked, but **before every paid video job state
   the per-second price and the computed total** (duration x price) in one short
   line, and keep a running total when a task needs several clips.
4. Pick a sane default model and ask only what is genuinely missing. One question
   at a time.
5. Prefer a cheap low-resolution draft, show it, then re-run approved clips at the
   final resolution. That is the only cost optimization worth doing unasked.

## Default model routing

Use these unless the user names a model. Full catalog and prices:
`references/pricing.md`, mappings from Higgsfield model ids: `references/model-map.md`.

| Intent | Model |
|---|---|
| General image, graphic design, UI, banners, typography, on-image text | `openai/gpt-image-2.6-sunburst` |
| Cheap image drafts, reference edits | `google/gemini-3.1-flash-lite-image` |
| Cartoon / illustrated characters, heavy texture | `google/gemini-3.1-flash-image` (Nano Banana 2) |
| Character sheet, face consistency from photos, precise edits | `google/gemini-3-pro-image` (Nano Banana Pro) or `bytedance-seed/seedream-5-0-pro` |
| Logo, icon, vector-like mark | `recraft/recraft-v4.1-vector` |
| Photoreal product / lifestyle / brand scene | `bytedance-seed/seedream-5-0-pro` |
| Default video: motion, multi-shot, image-to-video | `bytedance/seedance-2.5` |
| Native 4K video | `bytedance/seedance-2.0` (`resolution: "4K"`) |
| Cheaper / faster video | `google/veo-3.1-lite` or `bytedance/seedance-2.0-fast` |
| Cinematic 2K with audio | `minimax/hailuo-3` |
| Long clips up to 30s | `alibaba/wan-3.0` or `bytedance/seedance-2.5` |
| Edit an existing video | `black-forest-labs/flux-video-edit` |
| Upscale an existing video | `black-forest-labs/flux-video-upscale` |
| Talking presenter / avatar video | `heygen/heygen-video-1` |

## Image generation

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model openai/gpt-image-2.6-sunburst \
  --prompt "neon city at dusk, editorial photograph" \
  --ratio 16:9 --quality high --out ./out
```

Raw API shape (same thing, when you need a field the script does not expose):

```bash
curl -sS -X POST https://openrouter.ai/api/v1/images \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"openai/gpt-image-2.6-sunburst","prompt":"...","aspect_ratio":"16:9","quality":"high","response_format":"url"}'
```

Key fields: `n` (1-10), `resolution` (`512`/`768`/`1K`/`1.5K`/`2K`/`4K`),
`aspect_ratio`, `quality` (`low`/`medium`/`high`), `output_format`
(`png`/`jpeg`/`webp`/`svg`/`gif`), `background` (`transparent` needs png/webp),
`input_references` (image-to-image / edits), `response_format` (`url` recommended;
signed URLs expire in 24h), `seed`.

Billing is all-or-nothing: a completed image is charged in full, a failed one is
not charged. `usage.cost` in the response is the real amount.

## Video generation

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model bytedance/seedance-2.5 \
  --prompt "camera dollies in through a clinic reception at golden hour" \
  --duration 8 --resolution 1080p --ratio 16:9 \
  --first-frame ./start.png --last-frame ./end.png \
  --out ./out
```

The script submits, polls every 10s, downloads `videos/<id>/content?index=0` and
prints the local path plus `cost_usd`. Manual flow:

```bash
# 1 submit -> {"id": "...", "polling_url": "...", "status": "pending"}
curl -sS -X POST https://openrouter.ai/api/v1/videos -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" -d '{"model":"google/veo-3.1","prompt":"...","duration":8}'
# 2 poll until status is completed|failed|cancelled|expired
curl -sS https://openrouter.ai/api/v1/videos/<id> -H "Authorization: Bearer $OPENROUTER_API_KEY"
# 3 download (needs the auth header; unsigned_urls is not presigned)
curl -sS -o out.mp4 -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  "https://openrouter.ai/api/v1/videos/<id>/content?index=0"
```

Frame vs reference input, this distinction matters:

- `frame_images` with `frame_type: first_frame | last_frame` = image-to-video, the
  model must actually move between those two frames. Takes precedence if both are sent.
- `input_references` = style/content guidance only, not exact frames.

Always validate `duration`, `resolution`, `aspect_ratio` against the model's
supported values from `GET /api/v1/videos/models`; unsupported values return 400.
Video is never ZDR-eligible and cannot be routed with `zdr: true`.

## Speech and narration (TTS)

`POST /api/v1/audio/speech` returns raw audio bytes (`mp3` or `pcm`), so write the
response straight to a file. Discovery: `GET /api/v1/audio/speech/models`.

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models speech                      # 38 models, voice lists included
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" voices elevenlabs/eleven-v3        # voices + formats for one model
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" speech \
  --model elevenlabs/eleven-v3 --voice sarah \
  --input "진료실에서 가장 자주 듣는 질문 세 가지를 정리했습니다." \
  --instructions "warm, clear, conversational" \
  --format mp3 --out ./voice
```

Raw call:

```bash
curl -sS https://openrouter.ai/api/v1/audio/speech \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"elevenlabs/eleven-v3","input":"...","voice":"sarah","response_format":"mp3"}' \
  -o out.mp3
```

Model picks: `elevenlabs/eleven-v3` (multilingual, `instructions`), `google/gemini-3.8-flash-tts`
(multilingual, multi-speaker `input` array), `qwen/qwen3-tts-1.7b` (Korean-capable voices),
`heygen/heygen-voice-1` (inline audio tags like `[sighs]`, pcm only),
`bytedance-seed/seed-audio-1-0` (prompt-driven; also does SFX/ambience, 120s cap, voice
cloning from `input_references`), `fish-audio/s2.1-pro` (voice cloning).

Rules: voices are model-specific, so never invent one - read `voices <model>`. Delivery
direction goes in `instructions`, not inside the text you will caption. `pcm` output is
raw 24kHz mono; convert with `ffmpeg -f s16le -ar 24000 -ac 1`. Music: `google/lyria-3-*`
previews exist on the models page - verify the call shape and price before promising a
soundtrack; Seed Audio is ambience/SFX grade, not a licensed music library.

## What does not exist on OpenRouter

Say this plainly instead of faking it:

- Soul / character training, marketing-studio avatars, virality scoring, 3D/GLB.
- A licensed music library (Lyria previews aside).
- A server-side prompt enhancer. The product-photoshoot and marketplace-cards
  skills in this plugin carry their own local prompt templates instead.

## References

- `references/image-api.md` - full image request/response reference
- `references/video-api.md` - full video request/response reference, statuses, webhooks
- `references/model-map.md` - Higgsfield model id -> OpenRouter model id, and what has no equivalent
**Capability warning** - not every model takes every field. `resolution` exists on
Gemini image models (1K/2K/4K) and Seedream (1K/1.5K/2K) but **not** on
`openai/gpt-image-*`, which uses `quality` (auto/low/medium/high/xhigh/max) plus
`aspect_ratio`. Recraft vector only supports `output_format: svg`. Sending an
unsupported field returns 400, so check the model first:
`bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models image` or `GET /api/v1/images/models/{id}/endpoints`.

- `references/audio-api.md` - TTS request/response, model quirks, formats, cloning
- `references/pricing.md` - price snapshot (2026-11-25) and how to read token-based pricing
- `references/troubleshooting.md` - 400/402/403, expired jobs, missing content
- `scripts/or-media.sh` - `models`, `price`, `voices`, `image`, `video`, `speech`, `poll`

