---
name: openrouter-generate
description: |
  Generate images and videos through OpenRouter. Defaults: gpt-image-2.6-sunburst
  for images, seedance-2.5 for video, gemini-3-pro-image for edits and identity,
  veo-3.1-lite for cheap drafts. Use when: "generate an image", "make a video",
  "animate this photo", "image-to-video", "edit/stylize/remix this image",
  "first and last frame", "upscale this video", "edit this video", "make a GIF",
  "make a logo", "which model should I use". Supports generic generation and
  reference-image chaining across requests.
  Narration and voiceover live in openrouter-media (`speech`), not here.
  NOT for: 3D/GLB, Soul character training, marketing-studio ads, virality scoring. Also NOT for brand systems
  (use openrouter-brandkit), product photoshoots (use openrouter-product-photoshoot),
  marketplace cards (use openrouter-marketplace-cards), thumbnails (use
  openrouter-youtube-thumbnail), or websites (use openrouter-websites).
argument-hint: "[prompt] [--model <openrouter-model>] [--image|--video <path-or-url>]"
allowed-tools: Bash
---

# OpenRouter Generate

Submit image and video jobs to OpenRouter. This replaces `higgsfield generate create`
from the original Higgsfield skill. The model ids are different: always resolve them
with `GET /api/v1/images/models` / `GET /api/v1/videos/models` (or
`openrouter-media/scripts/or-media.sh models`) instead of trusting memory.

## Step 0 - Bootstrap

1. `OPENROUTER_API_KEY` in the environment, plus `curl` and `jq`. Missing key: ask
   the user to set it, never print it.
2. If a request needs a feature OpenRouter does not have (audio out, 3D, soul
   training, ad studio, virality), say so in one line and offer the nearest option.

## UX rules

1. Be concise: file path or URL plus a one-line summary (model, duration for video).
   No job ids, no JSON.
2. Reply in the user's language; model ids and flags stay English.
3. Pick a sane default and ask one thing at a time only when genuinely missing. Do
   not batch-interrogate.
4. Do not pre-estimate cost unless asked, but quote the per-second price before a
   paid video job and keep a running total across clips.
5. A model the user names stays in use for follow-ups on the same work.
6. Prompt-only or explanation-only requests return text; no job is submitted.

## Picking a model

**Images**

- Standalone image, graphic design, UI, banner, on-image text -> `openai/gpt-image-2.6-sunburst`
- Edit / restyle / remix an existing image -> `google/gemini-3-pro-image` (precise) or
  `google/gemini-3.1-flash-image` (cheap)
- Cartoon, illustration, heavy texture -> `google/gemini-3.1-flash-image`
- Character sheet, one face from references, photoreal product -> `bytedance-seed/seedream-5-0-pro`
- Cheapest draft -> `google/gemini-3.1-flash-lite-image`
- Logo / icon / vector -> `recraft/recraft-v4.1-vector` (`output_format: "svg"`)
- Animated GIF -> `openai/gpt-image-2.6-sunburst` with `output_format: "gif"` and
  `frame_count` / `frame_duration_ms`; set the field before the first call
- **Default for everything else -> `openai/gpt-image-2.6-sunburst`**

**Video**

- Default (motion, multi-shot, image-to-video, 4-30s) -> `bytedance/seedance-2.5`
- Native 4K -> `bytedance/seedance-2.0`
- Cheap draft -> `google/veo-3.1-lite` or `bytedance/seedance-2.0-fast`
- Cinematic 2K with audio -> `minimax/hailuo-3`
- Long single take up to 30s -> `alibaba/wan-3.0`
- Edit an existing video -> `black-forest-labs/flux-video-edit`
- Upscale -> `black-forest-labs/flux-video-upscale`
- Talking presenter -> `heygen/heygen-video-1`

Full table with durations, resolutions and prices: `references/model-catalog.md`.

## Media inputs

| Need | Field |
|---|---|
| Reference image for an edit / style match | `input_references: [{type:"image_url",image_url:{url}}]` |
| First frame of a video (image-to-video) | `frame_images: [{...,"frame_type":"first_frame"}]` |
| Last frame (transition target) | same array, `"frame_type":"last_frame"` |
| Source video for edit / upscale | `input_references: [{type:"video_url",video_url:{url}}]` |

Local files are accepted as base64 data URLs, so there is no upload step. When both
`frame_images` and `input_references` are sent, the request becomes image-to-video.

## Examples

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model openai/gpt-image-2.6-sunburst --prompt "neon city at dusk" --ratio 16:9 --out ./out

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model google/gemini-3-pro-image --prompt "same subject, watercolor" --ref ./photo.jpg --out ./out

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model bytedance/seedance-2.5 --prompt "camera dollies in" \
  --duration 12 --resolution 1080p --first-frame ./a.png --last-frame ./b.png --out ./out

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model black-forest-labs/flux-video-upscale --ref ./clip.mp4 --out ./out
```

If the user asks for a model OpenRouter does not carry (Soul, Kling, Marketing
Studio, Virality Predictor), map it with
`openrouter-media/references/model-map.md` and say plainly which one you swapped in.

## Errors

| Symptom | Cause |
|---|---|
| `Missing prompt` / `400` on prompt | prompt required (except upscale, image-only generation) |
| `400` with allowed values | unsupported duration / resolution / ratio / reference count |
| `402` credits | balance too low - tell the user the amount |
| `403` key limit | this key's spending cap is spent |
| job `expired` | TTL exceeded - retry shorter or lower resolution |
| job `failed` + policy | rewrite the prompt |

More: `openrouter-media/references/troubleshooting.md`.

## References

- `references/model-catalog.md` - every image/video model worth using, and when
- `references/media-inputs.md` - reference images, first/last frames, video sources
- `references/workflows.md` - edit, upscale, extend, reframe without a workflow API
- `references/prompt-engineering.md` - prompt rules (kept from the original skill)
