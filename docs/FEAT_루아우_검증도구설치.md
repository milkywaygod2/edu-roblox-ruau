# FEAT: Luau 로컬 검증 도구 설치 메모

## 목적

Roblox Studio와 VSCode/Antigravity 환경에서 수업용 Luau 파일을 편집할 때, Codex가 로컬 터미널에서 최소한의 문법/정적 검증을 실행할 수 있게 하는 도구 설치 기준을 정리한다.

## 결론

VSCode 확장만으로도 사람이 편집할 때 자동완성, 빨간줄, Roblox API 힌트를 보는 데는 충분하다. 하지만 Codex가 작업 후 `luau`, `luau-analyze`, `stylua`, `selene` 같은 명령을 직접 실행하려면 CLI 도구가 로컬 `PATH`에서 잡혀야 한다.

Roblox 실제 런타임 검증은 여전히 Studio Play가 최종 기준이다. 독립 Luau CLI는 `game`, `Enum`, `Vector3`, `Instance` 같은 Roblox DataModel 런타임을 완전히 실행하는 도구가 아니다.

## winget 확인 결과

2026-06-03 기준 이 컴퓨터에서 `winget search`로 확인한 결과는 다음과 같다.

| 도구 | winget 결과 | 판단 |
| --- | --- | --- |
| 공식 `luau` / `luau-analyze` | 패키지 못 찾음 | GitHub Releases 직접 다운로드 필요 |
| `Lune` | `Lune.Lune` 확인 | winget 설치 가능 |
| `Rokit` | `Rojo.Rokit` 1.2.0 확인 | winget 설치 가능 |
| `StyLua` | 패키지 못 찾음 | Rokit 또는 직접 다운로드 권장 |
| `Selene` | 패키지 못 찾음 | Rokit 또는 직접 다운로드 권장 |

## 권장 설치 순서

1. Rokit 설치

```powershell
winget install --id Rojo.Rokit -e
```

2. 공식 Luau CLI 설치

공식 `luau.exe`, `luau-analyze.exe`는 winget에서 확인되지 않았다. `luau-lang/luau` GitHub Releases의 Windows 바이너리를 받아 PATH에 넣는다.

3. 선택 도구 설치

포맷/린트까지 필요하면 Rokit으로 `StyLua`, `Selene`을 관리한다. 팀 단위로 버전을 고정하려면 프로젝트 루트에 `rokit.toml`을 두고 `rokit install`로 설치한다.

## 용도 구분

| 용도 | 도구 |
| --- | --- |
| 에디터 자동완성/Roblox API 힌트 | Luau LSP 계열 VSCode 확장 |
| Luau 문법 실행/간단 실행 | `luau` |
| 타입 체크/정적 분석 | `luau-analyze` |
| 포맷 | `StyLua` |
| 린트 | `Selene` |
| Roblox 도구 버전 관리 | `Rokit` |
| Studio 실제 동작 검증 | Roblox Studio Play |

## 참고 링크

- Luau 공식 repo: https://github.com/luau-lang/luau
- Rokit repo: https://github.com/rojo-rbx/rokit
- Roblox Script Sync 문서: https://create.roblox.com/docs/scripting/sync
