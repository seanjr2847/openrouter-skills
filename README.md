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


