# Prompt Engineering

## Basics

OpenRouter image and video models reward concrete, sensory prompts.

- **Subject + setting + style**: "a red fox curled in a snowy pine forest, golden hour, cinematic"
- **Camera**: lens (35mm, 85mm), angle (low, overhead), motion (dolly in, tracking shot)
- **Lighting**: rim light, neon glow, moody backlight
- **Style/medium**: oil painting, watercolor, photograph, anime, 3D render

Keep it under ~200 tokens. Models distort with very long prompts.

## Image-to-image

When passing `input_references`, the prompt should describe what changes, not redescribe the input.

Bad: "a man with brown hair in a leather jacket holding coffee, made into anime"
Good: "transform into anime style, vibrant colors, soft cel shading"

## Image-to-video

`frame_images` with `frame_type: "first_frame"` anchors the first frame. The prompt describes motion.

- Verbs: zooms in, dollies left, sweeping pan, slow push, fast whip
- Subject motion: "the dancer spins", "smoke rises slowly"
- Don't redescribe the static frame — model already has it.

## Negative phrasing

Most models don't expose a `negative_prompt`. Phrase positively:
- Instead of "no blur" → "tack sharp"
- Instead of "no people" → "uninhabited landscape"

## Aspect ratio guidance

- `16:9` — landscape, cinematic
- `9:16` — vertical, social
- `1:1` — square, profile / icon
- `4:3`, `3:4`, `21:9` — model-dependent, check the model in `GET /api/v1/videos/models` or `GET /api/v1/images/models`

## Safety

Providers reject prompts that trip safety filters; the job ends as `failed` with the reason in `error`. Avoid:
- Real public figures
- Sexual content
- Trademarks / branded characters
