# Roblox Luau 12일 수업 스크립트 운영 가이드

이 폴더는 `docs/curriculum_12_weeks.md`와 `docs/roblox_luau_lecture_guide.md`를 실제 Roblox Studio 수업에서 바로 사용할 수 있도록 구체화한 코드 팩입니다.

## 1. 폴더 구조

```text
lessons/
  day01_rock_tool/
    teacher_setup.server.lua
    student_answer.server.lua
  ...
  day12_final_battle/
    teacher_setup.server.lua
    student_answer.server.lua
```

- `teacher_setup.server.lua`: 선생님이 Roblox Studio에서 수업 맵, Tool, 버튼, 팀, 연습용 더미를 자동 생성하는 준비 코드입니다.
- `student_answer.server.lua`: 학생용 완성 모범답안입니다. 빈칸 채우기나 임시 스캐폴드가 아니라 완성된 정답 코드입니다.
- 파일명에 `.server.lua`를 붙인 이유는 대부분 서버 권한에서 오브젝트 생성, 데미지, 점수, 라운드 상태를 처리하기 때문입니다.

## 2. 공통 실행 환경

- 프로그램: Roblox Studio
- 기본 화면: View > Explorer, Properties, Output을 켜 둡니다.
- 권장 테스트: Home > Play 또는 Test 탭의 Play
- 권장 저장: 수업 전 `.rbxl` 또는 Team Create publish 백업
- 보안 원칙: Toolbox 무료 모델은 최소화하고, 가져온 모델에 숨어 있는 Script가 있는지 Explorer에서 확인합니다.

## 3. 공통 실행 순서

1. Roblox Studio에서 수업용 place를 엽니다.
2. `ServerScriptService`에 Script를 만들고 해당 일차의 `teacher_setup.server.lua` 전체를 붙여넣습니다.
3. Play를 눌러 setup 코드가 Workspace/StarterPack/Teams 등에 필요한 오브젝트를 생성하는지 확인합니다.
4. Stop을 누른 뒤 setup Script는 비활성화하거나 삭제합니다. 반복 실행하면 기존 오브젝트를 지우고 다시 만들 수 있습니다.
5. 학생 답안 파일 상단의 `Paste path`를 확인합니다.
6. `ServerScriptService` 또는 `StarterPack > Tool > Script`에 학생 답안 코드를 붙여넣습니다.
7. Play로 기능을 테스트하고 Output 창의 오류를 확인합니다.

## 4. Paste path 규칙

| 유형 | 붙여넣기 위치 | 대상 일차 |
| --- | --- | --- |
| 맵/버튼/라운드 서버 코드 | `ServerScriptService > Script` | 02, 03, 08, 09, 10, 12 |
| Tool 동작 코드 | `StarterPack > Tool > Script` | 01, 04, 05, 06, 07, 11 |
| 준비 코드 | `ServerScriptService > Script` | 모든 teacher_setup |

Tool 동작 코드를 `ServerScriptService`에 넣으면 실제 플레이어 Backpack으로 복제된 Tool에 이벤트가 연결되지 않을 수 있습니다. Tool 계열 답안은 반드시 해당 Tool 내부 Script에 넣습니다.

## 5. 일차별 생성/실행 대상

| 일차 | 주제 | teacher_setup 생성물 | student_answer 위치 |
| --- | --- | --- | --- |
| 01 | 돌멩이 기초 무기 | `Workspace/Day01_Arena`, `StarterPack/PracticeRock` | `StarterPack > PracticeRock > Script` |
| 02 | 기초 엄폐물 | `Workspace/Day02_CoverField` | `ServerScriptService > Script` |
| 03 | 자원 기반 방벽 | `Workspace/Day03_ResourceWall/BuildButton` | `ServerScriptService > Script` |
| 04 | 일반 무기/디바운스 | `StarterPack/BalanceSword`, `Workspace/Day04_Dummies` | `StarterPack > BalanceSword > Script` |
| 05 | 원거리 무기 | `StarterPack/TrainingBow`, `Workspace/Day05_TargetRange` | `StarterPack > TrainingBow > Script` |
| 06 | 방패 | `StarterPack/PracticeShield` | `StarterPack > PracticeShield > Script` |
| 07 | 갑옷 | `StarterPack/HeavyArmor` | `StarterPack > HeavyArmor > Script` |
| 08 | 파괴되는 성문 | `Workspace/Day08_Castle/Gate` | `ServerScriptService > Script` |
| 09 | 부분 파괴 성벽 | `Workspace/Day09_StoneWall` | `ServerScriptService > Script` |
| 10 | 공성 병기 | `Workspace/Day10_SiegeEngine` | `ServerScriptService > Script` |
| 11 | 마법 스킬 | `StarterPack/MagicStaff`, `Workspace/Day11_MagicArena` | `StarterPack > MagicStaff > Script` |
| 12 | 최종 대전 | `Workspace/Day12_FinalBattle`, `Teams/Blue`, `Teams/Red` | `ServerScriptService > Script` |

## 6. 검증 체크리스트

- teacher setup 실행 후 Explorer에 위 표의 생성물이 보이는가?
- Tool 계열 수업은 Play 후 플레이어 Backpack/캐릭터에 Tool이 들어왔는가?
- Output 창에 빨간 오류가 없는가?
- 버튼 수업은 ClickDetector의 MaxActivationDistance 안에서 클릭했는가?
- 데미지 수업은 대상 Model 안에 Humanoid와 HumanoidRootPart가 있는가?
- 라운드 수업은 Workspace Attribute `RoundState`, `TimeLeft`가 바뀌는가?

## 7. 문제 해결

- Tool 클릭이 반응하지 않음: 학생 답안 Script가 `StarterPack > Tool` 내부에 있는지 확인합니다.
- `WaitForChild`에서 멈춤: teacher setup을 먼저 실행했는지, 오브젝트 이름이 주석의 경로와 같은지 확인합니다.
- 데미지가 안 들어감: 대상에 Humanoid가 있어야 하며, 자기 캐릭터는 데미지 대상에서 제외됩니다.
- 버튼이 안 눌림: ClickDetector가 버튼 Part 안에 있는지, Play 모드에서 거리가 충분히 가까운지 확인합니다.
- 여러 번 실행되어 오브젝트가 중복됨: teacher setup은 기존 DayXX 폴더/Tool을 지우고 다시 만들도록 작성했지만, 수업 중에는 Stop 후 setup Script를 비활성화합니다.
- Team Create 충돌: 공통 시스템은 선생님만 수정하고, 학생별 실험은 각자 폴더에서 진행합니다.

## 8. 원본 문서 보존

`docs/curriculum_12_weeks.md`는 원본 12주 계획 문서입니다. 이 파일은 기준 문서로 고정하고, 실제 실행 코드와 보완 운영 설명은 `lessons/`와 강의 가이드 문서에서 관리합니다.