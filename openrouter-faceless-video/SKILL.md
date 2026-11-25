---
name: openrouter-faceless-video
description: |
  Create a finished faceless explainer, documentary, illustrated story, or children's
  music video, or edit a previously created faceless video - narration, background
  clips, music bed, captions and final assembly - through OpenRouter's video and
  text-to-speech APIs. Use when: "make a faceless video", "create a narrated
  explainer", "make a children's song video", "edit this faceless video".
  NOT for: a single silent clip (use openrouter-generate), ads or UGC (openrouter-generate),
  unrelated footage edits, or script-only requests.
argument-hint: "[topic or source] [duration] [language] [aspect ratio]"
allowed-tools: Bash
---

# Faceless video (OpenRouter)

One finished video: consistent visual style, narration, optional music bed, optional
captions. Preserve anything the user supplies (assets, voice preference, script).

Pick the mode before generating: illustrated explainers use `references/production.md`;
fast-cut channel motion `references/channel-motion.md`; stills and picture stories
`references/picture-story.md`; a sung children's music video `references/song.md`;
explicit talking characters `references/talking-characters.md`; a presenter overlay
`references/presenter.md`; edits to an existing video `references/editing.md`.
Background music alone is not a song request. Never infer a presenter from a photo.

When the brief supplies `animation_mode`, treat `fully_animated` as motion and
`scene_based` as stills without asking again. Keep the production mode when
continuing or editing an existing video.

## Before spending credits

Resolve the missing pieces one question at a time: topic, approximate duration,
aspect ratio, language, visual style, voice, music, subtitles. Never invent a voice
or a preset. List what is actually available:

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models speech
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" voices qwen/qwen3-tts-1.7b
```

Honor the requested duration exactly; never silently round it up. Confirm photo
roles before using reference images.

Set `SKILL_DIR` to this skill's installed directory and keep every working file in a
persistent session directory, never inside the skill. Verify `ffmpeg`, `ffprobe`,
`python3`, `awk` before starting, and check the models you plan to use:

```bash
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models video
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" voices <tts-model>
```

If a stage, model, dependency or requested feature is unavailable, say so and stop
before paid work.

## The four generation calls

| Stage | Call |
|---|---|
| Narration (TTS) | `or-media.sh speech --model <tts> --voice <v> --input "<line>" --instructions "<delivery>" --format mp3 --out work/` |
| Background clip (per block) | `or-media.sh video --model minimax/hailuo-3 --prompt "<visual, no spoken words>" --duration 10 --ratio 16:9 --ref <style-key.png> --out work/` |
| Stills / style key | `or-media.sh image --model openai/gpt-image-2.6-sunburst --prompt "<style>" --out work/` |
| Music bed / ambience | `or-media.sh speech --model bytedance-seed/seed-audio-1-0 --input "<instrumental description, no voices>" --format mp3 --out work/` (max 120s per call) |

Voice notes: the higgsfield voice preset library does not exist here. Pick a model
that covers your language, then a voice id from `voices <model>`:
`elevenlabs/eleven-v3` and `google/gemini-3.8-flash-tts` are multilingual with
`instructions` support; `qwen/qwen3-tts-1.7b` lists Korean-capable voices;
`heygen/heygen-voice-1` accepts inline audio tags like `[sighs]`; `fish-audio/s2.1-pro`
and `bytedance-seed/seed-audio-1-0` support stateless voice cloning from a short
sample (`--ref sample.wav`). Keep one voice id for the whole video.

`seed-audio-1-0` treats the input as a prompt, so it can also produce non-speech
audio (rain, room tone, footsteps). It is not a licensed music library - for a real
music bed, check `google/lyria-3-*` on the models page before use, and say so if you
skip it.

There is no hosted upload endpoint. Deliver the local file (or hand it to whatever
host the user already uses); do not claim a hosted URL exists.

## Procedure

Read `references/production.md` for the full generation, timing gate, assembly, QC
and delivery sequence. For subtitles read `references/captions.md` (local Whisper for
word timing; authored text is what gets burned in). `references/creative.md` covers
style, assets and long-form planning, `references/styles.md` style guidance,
`references/prompts.md` scene-plan prompting. `scripts/assemble_blocks.sh` joins
ordered clip/voice pairs without changing speech speed; the other scripts in
`scripts/` (assembly, captions, motion validation, song-prompt validation) are the
original deterministic tooling and need no changes.

Never speed up narration to fit a window. If a take overruns, rewrite and regenerate
it, at most three attempts per line, then report the timing failure instead of
claiming a finished video.
