# 원문 대비 변경 내역

원문: https://github.com/higgsfield-ai/skills (main, v0.14.0, 2026-11-25 수신본)
원문 라이선스: MIT. 원문의 문장·구조는 최대한 유지하고 호출 계층만 교체했습니다.

## 공통

| 원문 | 이 패키지 |
|---|---|
| `higgsfield` CLI 설치 + `higgsfield auth login` | `OPENROUTER_API_KEY` 환경변수 |
| `higgsfield generate create <jst> ... --wait --json` | `POST /api/v1/images` (동기) / `POST /api/v1/videos` + 폴링 (비동기) |
| `higgsfield model get <jst> --json` | `GET /api/v1/images/models`, `GET /api/v1/videos/models` |
| `higgsfield upload create <path>` | 로컬 파일을 base64 data URL로 인라인 (업로드 단계 없음) |
| `--image` / `--start-image` / `--end-image` | `input_references` / `frame_images[first_frame]` / `frame_images[last_frame]` |
| job id로 결과 참조 | 로컬 파일 경로로 참조 (signed URL은 24시간 만료) |

## 신규

- `openrouter-media/SKILL.md` — 생성 계층 진입 문서, 모델 라우팅 기본값, 비용 규칙
- `openrouter-media/references/image-api.md` — 이미지 요청/응답/과금
- `openrouter-media/references/video-api.md` — 영상 제출·폴링·다운로드·웹훅
- `openrouter-media/references/model-map.md` — Higgsfield 모델 id → OpenRouter id, 대응 없는 기능 목록
- `openrouter-media/references/pricing.md` — 2026-11-25 단가 스냅샷
- `openrouter-media/references/troubleshooting.md` — 400/402/403, 만료 잡, 다운로드 실패
- `openrouter-media/scripts/or-media.sh` — `models` / `price` / `image` / `video` / `poll`
- `openrouter-product-photoshoot/references/mode-prompts.md` — 백엔드 인핸서 대체 로컬 템플릿(10모드)
- `openrouter-marketplace-cards/references/asset-templates.md` — 마켓 자산 템플릿 13종 + 체크리스트

## 수정

### `openrouter-generate`
- `SKILL.md` 전면 재작성: Higgsfield job_set_type(`gpt_image_2_6`, `seedance_2_5`,
  `nano_banana_*`, `soul_*`, `marketing_studio_*`) 라우팅 → OpenRouter 모델 id 라우팅.
  Marketing Studio / Virality Predictor / 3D / 오디오 섹션 삭제.
- `references/model-catalog.md` 재작성: 원문 카탈로그의 job_set_type 표를
  OpenRouter 실측 카탈로그(영상 30종·이미지 71종)로 교체.
- `references/media-inputs.md` 재작성: `--image`/`--start-image`/`--end-image`/
  `--video`/`--audio` → `input_references`, `frame_images`. 오디오 레퍼런스는 없음.
- `references/workflows.md` 재작성: `draw_to_video`→`flux-video-edit`,
  `reframe`→ffmpeg 또는 재생성, 업스케일→`flux-video-upscale`, 확장→`previous_job_id`.
- `references/troubleshooting.md` 재작성(OpenRouter 오류 코드 기준).
- `references/prompt-engineering.md` 유지, 호출 표기만 교체(`--image`→`input_references`,
  `--start-image`→`frame_images`, 모델 확인 명령).

### `openrouter-websites`
- `SKILL.md` 전면 재작성: `higgsfield website create/deploy/publish`(Cloudflare Worker
  플랫폼) → 로컬 프로젝트 + OpenRouter 미디어 + Vercel/Pages 배포. `--type app/game`,
  서브도메인, 커뮤니티 피드 publish 규칙 삭제.
- 문장 그대로 유지: `design-taste-frontend.md`, `image-to-code.md`.
- 명령/URL만 변환: `asset-system.md`(생성 배치), `reference-boards.md`, `wow-maker.md`,
  `seo.md`(`*.higgsfield.app` → `*.vercel.app`, 피드·Cloudflare Edge 문단 교체),
  `security.md`(`website secrets set` → `vercel env add`, frame-ancestors 예시 정리),
  `review-rubric.md`(플랫폼 브랜딩 규칙 제거), `design-recipe.md`, `wow-catalog.md`.
- `scroll-scrub.md`, `scroll-scrub-asset-react.md`, `scroll-scrub-asset-css.md`,
  `scroll-scrub-asset-video.md`: 2026-11-25 오후 세션에서 이미 OpenRouter판으로
  변환한 4개 파일을 그대로 가져왔습니다(별도 zip `openrouter-scroll-website.zip` 참조).
- 미포팅: `quanta-design.md`(fnf SDK 전용 디자인 시스템), `containers.md`(플랫폼 컨테이너 토큰),
  `cover-animator.md`(피드 카드 커버 영상), `runtime-and-infra.md`(Worker 배포 전제),
  `website-flow.md`, `app-flow.md`, `app-cover.md`, `app-quickstart.md`,
  `app-layouts.md`, `auth.md`, `fnf-sdk.md`, `fnf-react.md`, `contest.md`,
  `game-*.md` — Higgsfield 플랫폼(Worker 런타임·fnf SDK·realtime 룸·meshy 3D)
  전용이라 OpenRouter에서 의미가 없습니다.

### `openrouter-product-photoshoot`
- `SKILL.md` 재작성: `higgsfield product-photoshoot create --mode ...` → 모드 표·면접
  질문은 유지하고, 생성 단계를 "로컬 템플릿 조립 → 이미지 API 1콜"로 교체.
  `n` 대신 변형별 개별 호출 규칙 추가.

### `openrouter-marketplace-cards`
- `SKILL.md` 재작성: `--scope`/`--asset` 의미 유지, 백엔드 컴플라이언스 템플릿을
  자체 템플릿 파일로 대체. 마켓 정책 보증 문구는 "정책은 사용자가 최종 확인" 으로 수정.

### `openrouter-youtube-thumbnail`
- 원문 본문 유지. 부트스트랩(CLI 설치/로그인/모델 확인)을 키·모델 확인으로 교체,
  생성 명령 3종을 `or-media.sh image` 로 교체(`nano_banana_pro`→`gemini-3-pro-image`,
  `seedream_v5_pro`→`seedream-5-0-pro`, `gpt_image_2`→`gpt-image-2.6-sunburst`).
  `references/` 2개와 `agents/openai.yaml` 은 원문 그대로.

### `openrouter-brandkit`
- `SKILL.md`: 부트스트랩(CLI 설치/로그인/모델 확인) 교체, `CLI mapping` 표 →
  `Generation mapping` 표, Recraft 벡터 로고 명령을 `or-media.sh image
  --model recraft/recraft-v4.1-vector --format svg` 로 교체(색상·배경은 프롬프트로 이동).
  나머지 워크플로·상태 관리·브랜드북 규칙은 원문 유지.
- `references/prerequisites.md`: 도구 매트릭스·확인 루프·네트워크 요구사항을
  OpenRouter 기준으로 수정.
- `references/{asset-analysis,concept-boards,logo,mockups,social-templates}.md`:
  명령만 변환(모델 id·플래그). 문장 구조는 원문 유지, 변환 표기 안내 1줄 추가.
- `scripts/*.py` 3개: 원문 그대로(생성 호출 없음, 결정형 로컬 툴).

### `openrouter-faceless-video`
- `SKILL.md` 재작성: Higgsfield 프리셋/보이스 목록 → OpenRouter TTS 모델·보이스 조회,
  `seed_audio` → `POST /api/v1/audio/speech`, `minimax_h3` → `minimax/hailuo-3`,
  `sonilo_music` → `bytedance-seed/seed-audio-1-0`(앰비언스) 또는 `lyria-3` 후보,
  `higgsfield upload create`(호스팅) → 로컬 파일 전달.
- `references/production.md` 재작성: 위 호출로 교체. `check_voice.sh` 타이밍 게이트,
  `assemble_blocks.sh` 조립, QC 순서는 원문 유지.
- `references/channel-motion.md`: `elevenlabs_v4 --dialogue` → `speech` 개별 호출
  (+ Gemini/Fish 다중화자 안내). `presenter.md`: 없는 `voice_change` 워크플로 명시.
  `song.md`: `seed_audio` 곡 생성 → `speech --model bytedance-seed/seed-audio-1-0`.
  `creative.md`: 프리셋 ID → 스타일 문장.
- `scripts/*` 21개와 `references/{captions,prompts,styles,picture-story,editing,talking-characters}.md`
  는 원문 그대로(ffmpeg·python 결정형 툴, Whisper 자막 타이밍).

### 정정: OpenRouter 오디오
처음 문서에 "오디오 출력 모델이 없다"고 적었는데 사실이 아닙니다.
`POST /api/v1/audio/speech`(TTS)에 38개 모델(ElevenLabs, Gemini TTS, Seed Audio 1.0,
Qwen3 TTS, HeyGen Voice, Fish Audio 등)이 있습니다. `openrouter-media`에 `speech` /
`voices` 서브커맨드와 `references/audio-api.md`를 추가했습니다.
## 자체 점검에서 찾아 고친 결함 (2026-11-25)

| # | 증상 | 원인 | 수정 |
|---|---|---|---|
| 1 | 스크립트가 이 PC에서 즉사 (`missing dependency: jq`) | bash+jq 구현이었고 이 PC에 jq가 없음 | 표준 라이브러리만 쓰는 `scripts/or_media.py` 추가, `or-media.sh`는 Python 우선 래퍼로 변경 (jq 버전은 `or-media-jq.sh`로 보존) |
| 2 | `--ref clip.mp4`가 image_url로 전송되어 업스케일·영상 편집이 400 | 영상 레퍼런스 타입 미판별 | mime/확장자로 판별해 `video_url` / `input_references` 로 전송 |
| 3 | `openai/gpt-image-*`에 `--resolution` 전달 (문서 3곳) | 이 모델은 resolution 필드가 없고 quality만 지원 | 예시·안내 수정, `references/image-api.md`에 모델별 지원 필드 표 추가 |
| 4 | `minimax/hailuo-3`에 `--resolution 1080p` | 이 모델은 2K만 지원 | 2K로 수정 |
| 5 | brandkit 문서에 `model get ... --json` 잔재 | 일괄 치환이 문장 속 명령을 놓침 | 실제 모델 목록 명령으로 교체 |
| 6 | media 스킬 서브커맨드 목록에 `speech`/`voices` 누락 | TTS 추가 후 목록 미갱신 | 목록·경로 수정 |
| 7 | generate 스킬이 "Seed Audio 미지원"이라고 서술 | TTS 추가 전 서술 | 목록에서 제거 |
| 8 | 썸네일 로고 패스에 gpt-image + `--resolution 4K` | 원문 플래그 이식 | `--quality high`로 교체, 낡은 `seedream_v4_5` id도 실재 id로 수정 |

검증: 문서 55개 명령 라인의 플래그를 스크립트 파서와 대조(불일치 0), 이미지/영상 모델 스펙과 예시 파라미터 대조(불일치 0),
스킬 내부 참조 파일 존재 확인(누락 0), `bash -n` 전 스크립트 통과, `or_media.py` 페이로드 dry-run 4종 확인.
## 포팅하지 않은 스킬

| 원문 | 이유 |
|---|---|
| `higgsfield-soul-id` | 캐릭터 학습(모델 파인튜닝) — OpenRouter에 없음. `input_references`로 대체 안내 |
| `higgsfield-video-explainer` | 슬라이드·프리셋 체계가 Higgsfield 전용 (내레이션은 TTS로 가능, `openrouter-faceless-video`가 커버) |
| `CLAUDE.md`, `COOKBOOK.md`, `INSTALL*.md`, `evals/`, `.github/`, `setup`, `scripts/update-check.sh` | 저장소 운영용(플러그인 배포·검증) 문서. 이 패키지에서는 `README.md`/`INSTALL.md`로 대체 |
| `.codex-plugin/`, `.cursor-plugin/` | Claude Code 대상이라 제외. 필요하면 플러그인 json만 복사해 확장 가능 |

