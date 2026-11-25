# 설치 (Claude Code)

두 가지 방법 중 하나. **A안(폴더 복사)** 이 가장 확실합니다.

## 0. API 키

`OPENROUTER_API_KEY` 가 필요합니다. https://openrouter.ai/keys 에서 발급합니다.

Claude Code 전역 설정에 넣으려면 `~/.claude/settings.json` 에 추가합니다
(Windows: `C:\Users\<사용자>\.claude\settings.json`):

```json
{
  "env": {
    "OPENROUTER_API_KEY": "sk-or-..."
  }
}
```

또는 셸에서: `export OPENROUTER_API_KEY=...` /
PowerShell `$env:OPENROUTER_API_KEY="..."` / 영구 `setx OPENROUTER_API_KEY "..."`.

키는 채팅에 붙여넣지 말고 파일/환경변수로만 넣으세요.

## A. 스킬 폴더로 복사 (권장)

```bash
# macOS / Linux
cp -R openrouter-skills/openrouter-* ~/.claude/skills/

# Windows PowerShell
Copy-Item -Recurse .\openrouter-skills\openrouter-* $env:USERPROFILE\.claude\skills\
```

`~/.claude/skills/<스킬명>/SKILL.md` 구조가 되어야 합니다.
`openrouter-skills` 폴더 자체를 `skills` 아래에 넣으면 Claude Code가 스킬을 찾지
못합니다(한 단계 아래를 봅니다).

그다음 Claude Code를 재시작합니다. `/skills` 또는 대화에서
"openrouter-media 스킬 확인해줘" 로 인식 여부를 확인합니다.

## B. 플러그인 마켓플레이스로 설치

이 패키지를 GitHub 저장소로 올린 뒤:

```bash
claude plugin marketplace add <owner>/<repo>
claude plugin install openrouter-skills@openrouter
```

로컬 경로도 됩니다:

```bash
claude plugin marketplace add ./
claude plugin install openrouter-skills@openrouter
```

`marketplace.json` / `plugin.json` 은 `.claude-plugin/` 안에 들어 있습니다.

## 설치 확인

```bash
bash ~/.claude/skills/openrouter-media/scripts/or-media.sh models image | head
```

공개 엔드포인트라 키 없이도 목록이 나옵니다. 키까지 확인하려면 실제 생성 1회:

```bash
bash ~/.claude/skills/openrouter-media/scripts/or-media.sh image \
  --model google/gemini-3.1-flash-lite-image --prompt "test" --ratio 1:1 --out /tmp/or-test
```

## 기존 higgsfield-* 스킬과의 관계

이 패키지는 `openrouter-*` 라는 새 이름으로 설치되므로 기존
`~/.claude/skills/higgsfield-*`(2026-10-23 설치본)를 덮어쓰지 않습니다.
Higgsfield를 계속 쓰지 않는다면 그 폴더들을 지워서 스킬 목록이 중복되지 않게 하세요.

```powershell
Remove-Item -Recurse $env:USERPROFILE\.claude\skills\higgsfield-*
```

## 문제 해결

- 스킬이 안 보임 → `SKILL.md` 가 `~/.claude/skills/<name>/` 바로 아래에 있는지 확인
- `python3` 없음 → `winget install Python.Python.3.12` / `brew install python` / `apt install python3`
  (스크립트는 표준 라이브러리만 씁니다. jq는 필요 없습니다)
- `bash` 없음(Windows) → Git Bash 또는 WSL 사용
- 401 → 키가 Claude Code 프로세스 환경에 실제로 들어갔는지 확인

