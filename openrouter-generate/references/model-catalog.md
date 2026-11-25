# Model catalog (OpenRouter, 2026-11-25)

Live source: `GET /api/v1/images/models` and `GET /api/v1/videos/models`.
Durations, resolutions and prices below are what the catalog advertised that day.
Re-check before promising a capability or a price.

## Images

| Model | Strength | Params worth using |
|---|---|---|
| `openai/gpt-image-2.6-sunburst` | default: graphic design, UI, banners, typography, on-image text, gif | `quality`, `aspect_ratio`, `output_format`, `background`, `n`, `input_references` |
| `openai/gpt-image-2.6-flare` | same family, different look | same |
| `openai/gpt-image-2` / `gpt-image-1` / `gpt-image-1-mini` | previous generation, still fine | `quality`, `background` (`transparent`) |
| `google/gemini-3-pro-image` (Nano Banana Pro) | precise edits, identity preservation, up to 4K tiers | `resolution`, `aspect_ratio`, `input_references` |
| `google/gemini-3.1-flash-image` (Nano Banana 2) | cartoon, illustration, textured photography, cheap edits | `resolution`, `n` |
| `google/gemini-3.1-flash-lite-image` | cheapest drafts and quick reference edits | `resolution` |
| `bytedance-seed/seedream-5-0-pro` | photoreal product, character sheets, 2K/4K | `resolution`, `seed`, `background` |
| `bytedance-seed/seedream-5-5` | cheaper Seedream, $0.02 per image | `resolution`, `output_format` |
| `bytedance-seed/seedream-5-0-lite` | cheapest Seedream | `resolution` |
| `black-forest-labs/flux-3-image` | strong photoreal look, price scales by resolution | `resolution` (768-4K) |
| `recraft/recraft-v4.1-vector` | logos, icons, vector output | `output_format: "svg"` |
| `recraft/recraft-v4.1` | brand illustrations, controlled palettes | `aspect_ratio` |
| `x-ai/grok-imagine-image-2.0` | fast, cheap, quality tiers | `quality`, `resolution` |
| `qwen/qwen-image-2.1-pro` | text-in-image, dense layouts | `resolution`, `seed` |
| `microsoft/mai-image-2.7` | alternative general model | `background` |

On-image text: `gpt-image-2.6-sunburst` and `qwen-image-2.1` are the reliable pair.
Everyone else produces mangled letterforms often enough to verify before delivery.

## Video

| Model | Duration | Resolution | Frames | Audio | Use |
|---|---|---|---|---|---|
| `bytedance/seedance-2.5` | 4-30s | 480p-1080p | first+last | yes | default: motion, multi-shot, image-to-video |
| `bytedance/seedance-2.0` | 4-15s | up to 4K | first+last | yes | when 4K is required |
| `bytedance/seedance-2.0-fast` | 4-15s | 480p/720p | first+last | yes | cheap drafts |
| `bytedance/seedance-2.5-flash` | 4-30s | 480p/720p | first+last | yes | cheapest long clips |
| `google/veo-3.1` | 4/6/8s | 720p-4K | first+last | yes | premium cinematic, best prompt adherence |
| `google/veo-3.1-fast` | 4/6/8s | 720p-4K | first+last | yes | mid tier |
| `google/veo-3.1-lite` | 4/6/8s | 720p/1080p | first+last | yes | cheap drafts with audio |
| `google/gemini-omni-1.2-flash` | 3-15s | 360p-4K | first+last | yes | long-ish cheap clips |
| `minimax/hailuo-3` | 5-15s | 2K | first+last | yes | cinematic 2K |
| `minimax/hailuo-3-max` | 5-15s | 480p/768p | first+last | no | cheaper Hailuo |
| `minimax/hailuo-2.3` | 6/10s | 1080p | first | no | older, stable |
| `alibaba/wan-3.0` | 2-30s | 480p-1080p | first+last | yes | long takes, good price |
| `alibaba/wan-3.0-prime` | 2-30s | 480p-1080p | first+last | yes | higher quality tier |
| `alibaba/happyhorse-1.1` | 3-15s | 720p/1080p | first | - | alternative |
| `black-forest-labs/flux-3-video` | 5-20s | 720p-4K | first+last | yes | FLUX look, continuation |
| `runway/gen-4.5` | 2-10s | 720p | first | no | Runway look |
| `runway/aleph-2` | - | - | - | no | video-to-video edit |
| `x-ai/grok-imagine-video-1.5` | 1-15s | 480p-1080p | first+last | yes | cheap, permissive, fast |
| `x-ai/grok-imagine-video-1.5-lite` | 1-15s | 480p-1080p | first | yes | cheapest |
| `heygen/heygen-video-1` | 5-30s | 480p-2K | first | no | presenter / avatar ads |
| `heygen/heygen-avatar-6` / `-turbo` / `avatar-iv` | - | 720p-2K | - | no | talking avatar |
| `black-forest-labs/flux-video-edit` | - | - | - | no | edit existing video |
| `black-forest-labs/flux-video-upscale` | - | - | - | no | upscale existing video |
| `tbc/mischief-1` | 3/5s | 480p/720p | first | no | very cheap short clips |

## Rules that save money

1. Any paid video job that will be re-run: run a 4-5s 480p/720p draft first.
2. `veo-3.1` with audio costs 4-8x `veo-3.1-lite`. Draft on lite, final on the
   model the user asked for.
3. Image drafts: `gemini-3.1-flash-lite-image` or `seedream-5-5` before a 2K/4K run.
4. One continuous shot beats several clips: fewer submissions, and the scroll and
   website skills need one uninterrupted film anyway.
5. Do not chain `n: 4` on a model that returns one image per call; loop instead.
