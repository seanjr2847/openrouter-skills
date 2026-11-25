# Text-to-speech reference (OpenRouter)

Endpoint: `POST https://openrouter.ai/api/v1/audio/speech` (OpenAI-compatible
`/audio/speech` shape). Discovery: `GET /api/v1/audio/speech/models`,
per-model voices: `GET /api/v1/audio/speech/models/{author}/{slug}`.

The response is **raw audio bytes**, not JSON. Write it to a file with `-o`
(curl) or `--output`; a non-200 reply returns a JSON error body instead.

## Request

| Field | Type | Notes |
|---|---|---|
| `model` | string | required, e.g. `elevenlabs/eleven-v3` |
| `input` | string or array | text to speak; an array of `{text, voice?, instructions?}` turns for multi-speaker models |
| `voice` | string | model-specific id from the models API; omit only if the provider has a default |
| `instructions` | string | delivery direction (tone, pacing) on ElevenLabs, Gemini TTS, Fish Audio; ignored elsewhere |
| `response_format` | string | `mp3` or `pcm` (default `pcm`). HeyGen and Gemini TTS return `pcm` only |
| `output_delivery` | string | `stream` (default) or `url` for a 24h signed download URL |
| `speed` | number | only where supported; unsupported models 400 on non-default values |
| `input_references` | array | stateless voice cloning: 1-3 `input_audio` parts (base64 or public URL), optional `text` transcript, optional one `image_url` for voice design |
| `provider` | object | `order`/`only`/`ignore`/`allow_fallbacks`, `zdr`, `data_collection` |
| `user`, `session_id` | string | tracking/log grouping |

Headers on success: `Content-Type: audio/mpeg | audio/pcm`, `X-Generation-Id`.

## Formats

- `mp3` - compressed, small, good default for video assembly.
- `pcm` - raw PCM (24 kHz mono for Azure; provider-dependent otherwise). Convert:
  `ffmpeg -f s16le -ar 24000 -ac 1 -i out.pcm out.wav`.

## Model notes

| Model | Good for | Limits / quirks |
|---|---|---|
| `elevenlabs/eleven-v3`, `-turbo`, `-v4` | natural narration, multilingual, `instructions` | single voice per request |
| `google/gemini-3.8-flash-tts`, `-lite-tts` | multilingual, multi-speaker `input` array, `instructions` | `pcm` only |
| `qwen/qwen3-tts-1.7b` | Korean/Japanese/Chinese voices | voice ids like `sohee`, `vivian` |
| `bytedance-seed/seed-audio-1-0` | prompt-driven speech, SFX, ambience, 3-clip voice switching via `@Audio1` | 3000 chars, 120 s per request, no `voice` + references together |
| `heygen/heygen-voice-1` / `-turbo` | inline tags `[sad]`, `[laughs]`, `[whispers]` | `pcm` only, 10k chars, `instructions` ignored |
| `fish-audio/s1`, `s2-pro`, `s2.1-pro`, `drama-3` | voice cloning, bracketed delivery tags, multi-speaker (except s1) | provider-specific reference handling |
| `microsoft/mai-voice-2.1` | Azure voice catalog | `voice` must be the full Azure id including the `:MAI-Voice-2.1` suffix |
| `mistralai/voxtral-mini-tts-*` | cheap English narration | voice ids like `en_paul_neutral` |
| `speechify/simba-3.5`, `deepgram/aura-2`, `assemblyai/assemblyai-tts-1`, `hexgrad/kokoro-82m` | fast/cheap drafts | check format support |

## Pricing shape

Most TTS models bill **per input character**; some audio models (Seed Audio 1.0) bill
**per second of generated audio** and report it under `pricing.completion`. Read the
model entry before quoting a total, and quote characters x rate rather than guessing.
A 10-second English block is roughly 26-30 words, about 150-180 characters.

## Failure modes

- `400` naming a voice - the id belongs to another model. Re-read `voices <model>`.
- `400` mentioning `input` - Seed Audio rejects prompts that would exceed 120 s.
- `400` on `response_format: mp3` - that model is `pcm` only (HeyGen, Gemini TTS).
- Empty file with status 200 - check `Content-Type`; with `output_delivery: url` the
  body is JSON containing `url`, not audio.
- Voice cloning rejected - the chosen endpoint does not advertise
  `supports_voice_cloning`; pick a model that does or drop the reference.
