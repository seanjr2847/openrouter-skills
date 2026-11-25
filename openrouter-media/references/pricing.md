# Price snapshot - 2026-11-25

Read live values with `bash scripts/or-media.sh price <model>` or
`curl -s https://openrouter.ai/api/v1/videos/models | jq`.
These are the SKUs returned that day: a reference point, not a contract.

## Video (USD per second of output)

| Model | Duration | Resolution | Price |
|---|---|---|---|
| `google/veo-3.1` | 4/6/8s | 720p-1080p | $0.40 with audio, $0.20 without (4K: $0.60 / $0.40) |
| `google/veo-3.1-fast` | 4/6/8s | 720p-4K | $0.12 with audio ($0.10 at 720p), $0.10 without ($0.08 at 720p) |
| `google/veo-3.1-lite` | 4/6/8s | 720p-1080p | $0.08 with audio ($0.05 at 720p), $0.05 without ($0.03 at 720p) |
| `google/gemini-omni-1.2-flash` | 3-15s | 360p-4K | $0.104 with audio (720p $0.069, 360p $0.023, 4K $0.209) |
| `minimax/hailuo-3` | 5-15s | 2K only | $0.13 + $0.04 per reference image |
| `minimax/hailuo-3-max` | 5-15s | 480p/768p | $0.05 / $0.08 |
| `minimax/hailuo-2.3` | 6/10s | 1080p | $0.0817 |
| `alibaba/wan-3.0` | 2-30s | 480p/720p/1080p | $0.05 / $0.10 / $0.20 |
| `alibaba/wan-3.0-prime` | 2-30s | 480p/720p/1080p | $0.068 / $0.14 / $0.28 |
| `alibaba/happyhorse-1.1` | 3-15s | 720p/1080p | $0.0988 / $0.1278 |
| `runway/gen-4.5` | 2-10s | 720p | $0.12 |
| `runway/aleph-2` | - | - | $0.28/s, minimum $0.56 |
| `x-ai/grok-imagine-video-1.5` | 1-15s | 480p/720p/1080p | $0.08 / $0.14 / $0.25 (+$0.01 per input image) |
| `x-ai/grok-imagine-video-1.5-lite` | 1-15s | 480p/720p/1080p | $0.02 / $0.03 / $0.14 |
| `black-forest-labs/flux-3-video` | 5-20s | 720p-4K | $0.17 (720p), $0.29 (1080p), $0.28 (2K), $0.41 (4K) |
| `black-forest-labs/flux-video-edit` | - | - | $0.03 |
| `black-forest-labs/flux-video-upscale` | - | - | $0.035 / megapixel-second (precise), $0.05 (creative) |
| `heygen/heygen-video-1` | 5-30s | 480p-2K | $0.02 / $0.036 / $0.10 / $0.10 |
| `heygen/heygen-avatar-6` | - | 1080p/2K | $0.10 / $0.145 |
| `heygen/heygen-avatar-6-turbo` | - | 1080p/2K | $0.05 / $0.0875 |
| `heygen/avatar-iv` | - | 720p/1080p | $0.05 |

### Token-priced video

`bytedance/seedance-*` bills per video token, so cost depends on resolution,
duration and aspect ratio.

| Model | Per token | 1080p per token | With video input |
|---|---|---|---|
| `bytedance/seedance-2.5` | $0.0000107 | $0.0000117 | $0.0000064 |
| `bytedance/seedance-2.0` | $0.000007 | $0.0000077 | $0.0000043 |
| `bytedance/seedance-2.0-fast` | $0.0000056 | - | $0.0000033 |
| `bytedance/seedance-2.5-flash` | $0.000007 | - | $0.0000043 |
| `bytedance/seedance-2.0-mini` | $0.0000035 | - | $0.0000021 |

Do not guess these totals. Submit the cheapest draft first and read `usage.cost`
from the poll response; quote that number from then on.

Rule of thumb: 8s of `veo-3.1-lite` at 720p with audio is about $0.40; 8s of
`veo-3.1` with audio is about $3.20. That 8x gap is why drafts run on lite models.

## Speech (TTS)

TTS is priced per **input character** on most models, per **second of generated
audio** on some (Seed Audio 1.0). Read the model entry, do not guess:

```bash
curl -s https://openrouter.ai/api/v1/audio/speech/models | jq -r '.data[] | .id'
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" voices elevenlabs/eleven-v3
```

Rule of thumb: a 10-second narration block is about 26-30 words, roughly 150-180
characters. A 60-second video therefore needs about 900-1100 characters of speech.

## Images (USD per output)

| Model | Price |
|---|---|
| `bytedance-seed/seedream-5-5` | $0.02 ($0.035 high-res) |
| `bytedance-seed/seedream-5-0-pro` | $0.045 ($0.09 high-res) |
| `black-forest-labs/flux-3-image` | $0.041 (768) / $0.048 (1K) / $0.07 (1.5K) / $0.10 (2K) / $0.607 (4K) |
| `recraft/recraft-v4.1-vector` | $0.08 |
| `x-ai/grok-imagine-image-2.0` | $0.04-0.08 by size and quality |
| `openai/gpt-image-2.x` | per token, roughly $0.02-0.13 per image |
| `google/gemini-*-image` | per token, roughly $0.02-0.15 per image |
