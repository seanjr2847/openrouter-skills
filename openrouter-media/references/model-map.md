# Higgsfield model id -> OpenRouter model id

Source: higgsfield-ai/skills `higgsfield-generate` (v0.14.0), mapped against
`GET /api/v1/videos/models` and `GET /api/v1/images/models` on 2026-11-25.
Model ids change; re-check before quoting a model.

## Images

| Higgsfield | OpenRouter | Notes |
|---|---|---|
| `gpt_image_2_6` (GPT Image 2.6 Sunburst) | `openai/gpt-image-2.6-sunburst` | default image model, on-image text |
| `gpt_image_2_6_flare` | `openai/gpt-image-2.6-flare` | same family |
| `gpt_image_2` | `openai/gpt-image-2` | previous default |
| `nano_banana_pro` | `google/gemini-3-pro-image` | precise edits, identity |
| `nano_banana_flash` / `nano_banana_2` | `google/gemini-3.1-flash-image` | cartoon / illustrated |
| newer Nano Banana 2 | `google/gemini-nano-banana-2.1` | check which variant is live |
| `nano_banana_2_lite` | `google/gemini-3.1-flash-lite-image` | cheap drafts, reference edits |
| `seedream_v5_pro` | `bytedance-seed/seedream-5-0-pro` | character sheets, photoreal product |
| Seedream 5.0 | `bytedance-seed/seedream-5-0-lite` / `bytedance-seed/seedream-5-5` | 5-5 is cheaper per image |
| `recraft_v4_1` | `recraft/recraft-v4.1` | vector logo -> `recraft/recraft-v4.1-vector` |
| `z_image` | `google/gemini-3.1-flash-lite-image` | cheaper/faster draft tier |
| Soul 2.0 (`text2image_soul_v2`) | no equivalent | use `google/gemini-3-pro-image` with faces in `input_references` and an identity clause in the prompt |
| Soul Cinema (`soul_cinematic`) | no equivalent | cinematic still: `openai/gpt-image-2.6-sunburst` |
| Soul Location (`soul_location`) | no equivalent | empty scene: `bytedance-seed/seedream-5-0-pro` |

GIF and SVG: set `output_format` to `gif` or `svg` on a model that supports it
(`gpt-image-2.x` for gif, `recraft-v4.1-vector` for svg). Mentioning the format in
the prompt does not change the output format.

## Video

| Higgsfield | OpenRouter | Notes |
|---|---|---|
| `seedance_2_5` | `bytedance/seedance-2.5` | default: 4-30s, 480p-1080p, first/last frame, audio |
| `seedance_2_0` | `bytedance/seedance-2.0` | native 4K, 4-15s |
| Seedance drafts | `bytedance/seedance-2.0-fast`, `bytedance/seedance-2.5-flash`, `bytedance/seedance-2.0-mini` | cheaper tiers |
| `veo3_1` | `google/veo-3.1` | 4/6/8s, 720p/1080p/4K, audio, first+last frame |
| Veo 3.1 Lite | `google/veo-3.1-lite` | cheapest Google option |
| Veo 3.1 Fast | `google/veo-3.1-fast` | 4K option |
| `kling3_0` / `kling3_0_turbo` | no direct id | use `minimax/hailuo-3` or `alibaba/wan-3.0` |
| `cinematic_studio_video_4_0` | `minimax/hailuo-3` (2K) or `runway/gen-4.5` | cinematic look |
| `grok_video_v15` | `x-ai/grok-imagine-video-1.5` | 1-15s, 480p-1080p, first frame |
| Grok lite | `x-ai/grok-imagine-video-1.5-lite` | cheapest per second |
| `gemini_omni_flash_1_1` | `google/gemini-omni-1.1-flash` | 3-10s, audio |
| (no Higgsfield id) | `google/gemini-omni-1.2-flash` | newer, 3-15s, 4K option |
| (no Higgsfield id) | `alibaba/wan-3.0`, `alibaba/wan-3.0-prime` | 2-30s, first+last frame |
| (no Higgsfield id) | `black-forest-labs/flux-3-video` | 5-20s, up to 4K, continuation |
| (no Higgsfield id) | `runway/aleph-2` | video-to-video edit |
| `marketing_studio_video` / `_image` | no equivalent | write the ad prompt directly; `heygen/heygen-video-1` for presenter ads |
| `brain_activity` (Virality Predictor) | no equivalent | no scoring endpoint |

## Audio (TTS)

| Higgsfield | OpenRouter | Notes |
|---|---|---|
| `seed_audio` (speech) | `bytedance-seed/seed-audio-1-0` | prompt-driven; 120s cap, 3000 chars |
| `elevenlabs_v4` / voice presets | `elevenlabs/eleven-v3` or `-v4` | voices are model-specific ids, not Higgsfield presets |
| `seed_audio` (SFX / ambience) | `bytedance-seed/seed-audio-1-0` non-speech prompt | works well for rain, room tone, impacts |
| `sonilo_music` / `mirelo_text_to_audio` | `google/lyria-3-pro-preview` (preview) or Seed Audio ambience | verify call shape and price before promising music |
| `voice_change` workflow | none | regenerate the clip with the target voice, or use `heygen/heygen-video-1` |
| voice cloning | `fish-audio/s2.1-pro`, `bytedance-seed/seed-audio-1-0`, `heygen/heygen-voice-1` | stateless: pass a 1-3 clip sample in `input_references` |

Details: `references/audio-api.md`.

## Workflows that become local or disappear

| Higgsfield workflow | OpenRouter equivalent |
|---|---|
| `draw_to_video` (sketch/timestamp edit) | `black-forest-labs/flux-video-edit` |
| `reframe` (aspect change) | no model - ffmpeg crop/pad the source, or regenerate with `aspect_ratio` |
| Video upscale | `black-forest-labs/flux-video-upscale`, source as `video_url` in `input_references` |
| Video extension | `previous_job_id` on models that advertise continuation |
| `multi_image_to_3d` (GLB) | none - no 3D output |
| Soul training (`higgsfield-soul-id`) | none - identity is passed as `input_references` per request |
| Marketing Studio (avatars, hooks, settings, DTC ads) | none - write the prompt directly |

When a request lands in the right column, say what is missing in one line and offer
the nearest substitute. Do not pretend the feature exists.
