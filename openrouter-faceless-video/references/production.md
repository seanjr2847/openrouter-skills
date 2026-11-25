# Production workflow

Path prefix in the commands below: `OR="$HOME/.claude/skills/openrouter-media/scripts/or-media.sh"`.

1. **Research and plan.** For factual topics, research reliable sources and keep a
   short source list; for personal stories use only supplied facts. Plan one
   illustrated scene and one narration line per 10-second block; use a shorter final
   block when the duration is not a multiple of 10. Never cut a sentence across
   blocks. For a visual-only tail of at most three seconds, create silent audio and
   pass `--last-visual-only` to the assembler.

2. **Style key.** Generate one style image and reuse it as the reference for every
   clip so the look holds together:

   ```bash
   bash "$OR" image --model openai/gpt-image-2.6-sunburst \
     --prompt "<style formula: medium, palette, light, texture>" \
     --ratio 16:9 --out work/
   ```

   A selected preset does not exist here - translate a reference look into a written
   style formula instead. Check the first rendered clip before submitting the rest,
   and inspect each result for drift in identity and palette.

3. **Narration, block by block.** Pick one model and one voice, and keep both for the
   whole video. About 26-30 spoken words fits a 10-second block in English; treat that
   as a starting point, not a guarantee.

   ```bash
   bash "$OR" speech --model elevenlabs/eleven-v3 --voice sarah \
     --input "<spoken line, no timing cue>" \
     --instructions "warm, clear, lively conversational delivery, starts immediately" \
     --format mp3 --out work/
   ```

   Delivery direction goes in `--instructions` (supported by ElevenLabs, Gemini TTS
   and Fish Audio; ignored elsewhere). Never leave the cue inside the text you burn
   into captions. For other providers check `bash "$OR" voices <model>` first.

   Timing gate: every take must end inside [window-2.0s, window-0.2s] for its block:

   ```bash
   bash "$SKILL_DIR/scripts/check_voice.sh" work/voice01.mp3 10
   ```

   A failing line gets rewritten and regenerated - never sped up. Three attempts per
   line, then report the timing failure instead of calling the video finished.

4. **Background clips, block by block.** 10 seconds each, matching aspect ratio, with
   the style key as a reference:

   ```bash
   bash "$OR" video --model minimax/hailuo-3 \
     --prompt "<scene description, no spoken words, motion only>" \
     --duration 10 --resolution 2K --ratio 16:9 \
     --ref work/style.png --out work/
   ```

   `minimax/hailuo-3` is the direct replacement for the original `minimax_h3` (2K,
   5-15s). Cheaper alternatives: `bytedance/seedance-2.5` (480p-1080p, 4-30s) or
   `google/veo-3.1-lite` (4/6/8s - only if the block is 8s). Check the supported
   `duration` values for the model you pick; a 10s block needs a model that accepts
   `10`.

   State the price before the batch: 10 clips x 10s of `hailuo-3` at $0.13/s is
   about $13. Draft on `seedance-2.5-flash` or `veo-3.1-lite` first when the user has
   not seen the style yet.

5. **Download and name.** Save as `clip01.mp4`, `voice01.mp3`, ... in block order,
   confirm every file is non-empty and decodable, then assemble:

   ```bash
   bash "$SKILL_DIR/scripts/assemble_blocks.sh" --out work/final.mp4 \
     --last-seconds 5 work/clip01.mp4 work/voice01.mp3 work/clip02.mp4 work/voice02.mp3
   ```

   The script validates speech timing, duration, audio and decoding, and writes an
   assembly receipt. Omit `--last-seconds` for full-length blocks.

   Music bed (optional, only if requested):

   ```bash
   bash "$OR" speech --model bytedance-seed/seed-audio-1-0 \
     --input "warm minimal instrumental bed, soft piano and air, no voices, loops cleanly" \
     --format mp3 --out work/
   ```

   Pass it with `--music work/speech-<ts>.mp3`. `seed-audio-1-0` caps output at 120
   seconds per call and is ambience-grade, not a licensed track - loop or trim it with
   ffmpeg and tell the user what it is.

   If a gate fails, fix the input and rerun; never bypass it or hand back loose clips
   as a finished video.

6. **Captions (if requested).** Follow `references/captions.md`: local Whisper gives
   word timing, the authored lines supply the text that is actually burned in.

7. **Delivery.** There is no hosted upload step. Report the local file path, the real
   duration, aspect ratio, language, subtitle status and the source list. If the user
   needs a URL, ask which host they want to use rather than inventing one.

Resume from saved completed outputs. A video job you already started can be polled
with `bash "$OR" poll <job_id>`; do not submit duplicates while a job is running.
Respect generation failures and refusals.

