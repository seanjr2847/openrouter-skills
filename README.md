# OpenRouter skills (Higgsfield 스킬의 OpenRouter 판)

원문: https://github.com/higgsfield-ai/skills (v0.14.0, 2026-11-25 수신)
원문 라이선스: MIT. 이 패키지는 원문의 스킬 문서·디자인 레퍼런스를 유지하고,
**생성 계층(Higgsfield CLI/플랫폼)만 OpenRouter API로 교체**한 포크입니다.

Claude Code에서 Higgsfield 구독/크레딧 없이, OpenRouter API 키만으로 같은 작업을
돌리기 위한 것입니다.

## 무엇이 들어 있나

| 스킬 | 대체하는 원문 | 역할 |
|---|---|---|
| `openrouter-media` | `higgsfield` CLI 전체 | 이미지/영상 생성 API 계층 + `scripts/or-media.sh` |
| `openrouter-generate` | `higgsfield-generate` | 범용 이미지/영상 생성, 모델 선택, 레퍼런스·프레임 입력 |
| `openrouter-websites` | `higgsfield-websites` | 사이트 구축(디자인 브리프→빌드→QA→배포), 스크롤 스크럽 사이트 포함 |
| `openrouter-product-photoshoot` | `higgsfield-product-photoshoot` | 제품 화보 10개 모드 + 로컬 프롬프트 템플릿 |
| `openrouter-marketplace-cards` | `higgsfield-marketplace-cards` | 마켓 리스팅 이미지 세트 + 자산별 컴플라이언스 체크리스트 |
| `openrouter-youtube-thumbnail` | `higgsfield-youtube-thumbnail` | 썸네일/커버 이미지, 텍스트 오버레이 베이크 |
| `openrouter-brandkit` | `higgsfield-brandkit` | 브랜드 시스템(로고·팔레트·목업·브랜드북), 결정형 로컬 툴 유지 |
| `openrouter-faceless-video` | `higgsfield-faceless-video` | 내레이션(TTS)·배경클립·음악·자막·최종 조립 |

## 빠른 시작

```bash
export OPENROUTER_API_KEY="sk-or-..."          # PowerShell: $env:OPENROUTER_API_KEY="..."

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" models video   # 쓸 수 있는 영상 모델/단가
bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" price google/veo-3.1

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" image \
  --model openai/gpt-image-2.6-sunburst --prompt "neon city at dusk" --ratio 16:9 --out ./out

bash "$HOME/.claude/skills/openrouter-media/scripts/or-media.sh" video \
  --model bytedance/seedance-2.5 --prompt "camera dollies in" --duration 8 --out ./out
```

의존성: `python3`(필수, 표준 라이브러리만 사용), `ffmpeg`(영상 조립·스크롤 사이트),
`node`/`bun`(웹사이트 빌드). `jq`·`curl`은 필요 없습니다(`or-media-jq.sh` 폴백을 쓸 때만).

## 원문에서 바뀐 핵심 3가지

1. **호출 계층**: `higgsfield generate create <job_set_type> --wait` → OpenRouter REST.
   이미지는 동기 `POST /api/v1/images`, 영상은 비동기 `POST /api/v1/videos` +
   폴링 + `content` 다운로드.
2. **프롬프트 인핸서**: Higgsfield 백엔드가 대신 조립하던 제품 화보/마켓 카드
   프롬프트를 **로컬 템플릿**으로 옮겼습니다
   (`openrouter-product-photoshoot/references/mode-prompts.md`,
   `openrouter-marketplace-cards/references/asset-templates.md`).
3. **호스팅**: `higgsfield website create/deploy`(Workers 플랫폼) → 로컬 프로젝트
   빌드 후 Vercel/Cloudflare Pages 배포. 커뮤니티 피드 publish 단계는 없습니다.

## OpenRouter에 없는 것 (대체 없음)

- 정식 음악 라이브러리(`google/lyria-3` 프리뷰 제외), `voice_change` 워크플로.
- `higgsfield-video-explainer`는 포팅하지 않았습니다(슬라이드·프리셋 체계가 Higgsfield 전용).
  내레이션·조립이 필요한 경우는 `openrouter-faceless-video`가 커버합니다.
- Soul 캐릭터 학습 → 요청마다 `input_references`로 얼굴을 넣는 방식으로 대체.
- Marketing Studio(아바타·훅·설정·DTC 광고), Virality Predictor, 3D/GLB,
  Higgsfield 플랫폼 앱(`fnf` SDK)·멀티플레이 게임 템플릿.

모델 id 대응표와 "없는 기능" 목록: `openrouter-media/references/model-map.md`

## 비용 주의

영상은 초당 과금입니다. 8초 클립 기준 대략 `veo-3.1-lite` 720p 오디오 포함 $0.40,
`veo-3.1` 오디오 포함 $3.20. 초안은 저해상도/저가 모델로 먼저 뽑고 승인된 컷만
최종 모델로 재생성하세요. 실제 청구액은 응답의 `usage.cost`에 찍힙니다.
단가표: `openrouter-media/references/pricing.md`

## 문서

- `INSTALL.md` — Claude Code 설치 절차
- `CHANGES.md` — 원문 대비 파일별 변경 내역
- `openrouter-media/references/` — 이미지/영상 API, 모델 매핑, 단가, 트러블슈팅



## 미결사항 / Open items

2026-11-25 기준입니다. "검증 필요"는 제가 아직 실제로 확인하지 못한 것, "구조적 공백"은
OpenRouter에 대응 자체가 없는 것, "대체 구현"은 제가 로컬로 흉내낸 것이라 품질 동등성이
확인되지 않은 것입니다.

### 검증 필요

| # | 항목 | 내용 | 다음 행동 |
|---|---|---|---|
| 1 | 실제 API 호출 | 키가 없어 라이브 생성 1회도 돌리지 못했습니다. 페이로드는 `--dry-run`으로만 확인 | 키 넣고 `image` 1회 → `video` 4초 1회 순서로 확인 |
| 2 | 모델별 파라미터 400 | 카탈로그 기준으로 맞췄지만, provider별로 실제 허용값이 더 좁을 수 있음 | 첫 실행에서 400 나면 해당 모델 `endpoints` 재확인 |
| 3 | `or-media-jq.sh` 폴백 | jq가 없는 이 PC에서 실행 검증 불가 (Python 경로만 확인) | jq 있는 환경에서 1회 확인 |
| 4 | Windows 네이티브 실행 | 문서는 `bash "$HOME/.claude/skills/..."` 기준. Git Bash가 없는 환경이면 호출 실패 | 필요 시 PowerShell 래퍼 추가 |
| 5 | 플러그인 설치 경로 | `claude plugin marketplace add`로 설치되는지는 미확인(수동 복사만 검증) | 실제 설치 1회 확인 |
| 6 | 단가·카탈로그 스냅샷 | 2026-11-25 조회값. 모델·가격은 수시로 바뀜 | `pricing.md` 날짜 갱신, `models`로 재확인 |
| 7 | TTS 요금 계산 | 모델별 문자/초 단가를 문서에 확정하지 않음(읽고 계산하도록 안내) | 자주 쓰는 모델 2~3개는 실측 단가 기록 |
| 8 | 썸네일 해상도 | `gemini-3-pro-image` 4K는 카탈로그 표기 기준, 실제 출력 해상도 미확인 | 4K 요청 1회 후 `naturalWidth` 실측 |
| 9 | faceless 스크립트 테스트 | 원문 pytest 6종을 실행해보지 않음 | `pytest openrouter-faceless-video/scripts/tests` 1회 |
| 10 | 다중화자 TTS | Gemini·Fish만 지원한다고 문서화. ElevenLabs 우회는 개별 호출 | 실제 2인 대화 샘플 1회 확인 |

### 대체 구현 (품질 동등성 미확인)

| # | 항목 | 내용 |
|---|---|---|
| 11 | 제품 화보 프롬프트 | Higgsfield 백엔드 인핸서 대신 로컬 템플릿 10종. 결과물 품질 비교 안 됨 |
| 12 | 마켓 카드 컴플라이언스 | 백엔드 규칙 대신 자체 템플릿 13종. 마켓 정책 최신성은 사용자 확인 필요 |
| 13 | 웹사이트 스킬 경로 | 레퍼런스가 `app/src`·`app/public` 전제(TanStack 기준). SKILL.md에 매핑 안내만 넣음 |
| 14 | 음악 | `sonilo_music` 대응 없음. `seed-audio-1-0`(앰비언스, 120초)·`lyria-3`(프리뷰)는 호출 형태·가격 미검증 |

### 구조적 공백 (대응 없음)

| # | 항목 | 영향 |
|---|---|---|
| 15 | Soul 캐릭터 학습 (`higgsfield-soul-id`) | 인물 일관성이 참조 이미지 수준. 원하면 이 스킬만 원문 유지하는 하이브리드 |
| 16 | Marketing Studio (아바타·훅·설정·DTC 광고) | 광고는 프롬프트 직접 작성, 프레젠터는 `heygen-video-1`로 근사 |
| 17 | Virality Predictor | 광고 소재 점수화 불가 |
| 18 | 3D/GLB (`multi_image_to_3d`, meshy) | 3D 자산·게임 파이프라인 제외 |
| 19 | `voice_change` 워크플로 | 완성 영상의 목소리만 교체 불가 → 클립 재생성 |
| 20 | 호스팅 업로드 (`upload create`) | 결과 URL 공유하려면 사용자가 직접 호스팅 |
| 21 | 잡 이력 조회 (video job list) | 재현·재시작은 로컬 기록에 의존 |
| 22 | Higgsfield 플랫폼 (Workers 배포·피드·게임·fnf SDK) | 사이트는 로컬 빌드 + Vercel/Pages 직접 배포 |

### 정해둔 것 (참고)

- 라이선스: 원문 MIT 유지. 파생물 고지 문구(NOTICE)는 아직 별도 파일로 만들지 않았습니다.
- 스킬 이름은 `openrouter-*`로 분리해 기존 `higgsfield-*` 설치본과 충돌하지 않게 했습니다.
