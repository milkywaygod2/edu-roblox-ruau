# Roblox Luau 12일 수업 스크립트 운영 가이드

이 폴더는 `docs/curriculum_12_weeks.md`와 `docs/roblox_luau_lecture_guide.md`를 실제 Roblox Studio 수업에서 바로 사용할 수 있도록 구체화한 코드 팩입니다.

## 1. 교육용 네이밍 컨벤션 (Naming Convention)

어린 학생들과 초보자들이 변수의 타입과 역할을 직관적으로 이해하고 오타를 최소화할 수 있도록 아래의 **타입 소문자 + 대문자 시작 (접미사 숫자)** 네이밍 컨벤션을 스크립트 작성 시 강제 적용합니다.

### 1) 기본 규칙
*   **접두사(타입명)**: 로블록스의 클래스명 또는 데이터 타입을 **약어와 언더바(_) 없이 100% 소문자**로 붙여 씁니다. (`localscript`, `remoteevent` 등 하나의 단어로 취급)
*   **고유이름**: 타입명 바로 뒤에 붙이며, **첫 글자를 대문자**로 시작하여 이어 씁니다.
*   **접미사(일차 표시)**: 일차 정보를 표시할 때는 접두사 `DayXX`를 쓰지 않고, 변수명/오브젝트명의 **맨 뒤에 숫자만 접미사(예: 01, 12)**로 붙입니다. (폴더명이나 파일 경로는 스네이크케이스 규칙에 따라 끝에 `_XX`를 붙임)

### 2) 접두사 사전 (Prefix Reference Table)

| 접두사 (소문자 100%) | 대상 개념 (Roblox Class / Type) | 예시 변수명 | 설명 |
| :--- | :--- | :--- | :--- |
| `service` | game:GetService()로 가져오는 서비스들 | `serviceWorkspace`, `servicePlayers` | 로블록스 핵심 서비스 객체 |
| `folder` | Folder 인스턴스 | `folderArena01`, `folderDummies04` | 오브젝트를 그룹화하는 폴더 |
| `part` | Part (블록, 구체, 실린더 등 물리 파트) | `partPracticeBase`, `partWall03` | 게임 내 배치된 물리 단일 파트 |
| `model` | Model 인스턴스 | `modelPracticeDummy`, `modelSiege10` | 여러 파트가 조립된 모델(캐릭터, 차량 등) |
| `tool` | Tool 인스턴스 | `toolPracticeRock`, `toolSword04` | 플레이어가 장착할 수 있는 도구/무기 |
| `script` | Script (서버측 작동 코드) | `scriptStudentAnswer01` | 서버에서 돌아가는 일반 스크립트 |
| `localscript` | LocalScript (클라이언트측 코드) | `localscriptInput11` | 플레이어 기기에서 작동하는 로컬 스크립트 |
| `remoteevent` | RemoteEvent | `remoteeventCastMagic11` | 서버-클라이언트 간 통신 이벤트 |
| `clickdetector`| ClickDetector | `clickdetectorButton03` | 클릭 입력을 감지하는 객체 |
| `humanoid` | Humanoid | `humanoidPractice`, `humanoidBoss12` | 캐릭터의 생명력, 움직임을 관리하는 객체 |
| `intvalue` | IntegerValue | `intvalueWood03` | 정수형 데이터 보관 객체 |
| `stringvalue` | StringValue | `stringvalueRoundState12` | 문자열형 데이터 보관 객체 |
| `boolvalue` | BoolValue | `boolvalueReady12` | 참/거짓형 데이터 보관 객체 |
| `bool` | Boolean (Luau 기본 데이터 타입) | `boolIsTouched`, `boolIsCooldown` | 스크립트 내 참/거짓 변수 |
| `table` | Table (Luau 테이블/배열/사전) | `tableDummies`, `tableSpawnPoints` | 여러 데이터를 담는 배열 또는 테이블 변수 |
| `number` | Number (Luau 소수/정수형 변수) | `numberDamage`, `numberCooldown` | 숫자형 일반 변수 |
| `string` | String (Luau 문자열 변수) | `stringPlayerName`, `stringError` | 문자열형 일반 변수 |

---

## 2. 폴더 구조

```text
lessons/
  01_rock_tool/
    teacher_setup.server.lua
    student_answer.server.lua
  11_magic_skill/
    teacher_setup.server.lua
    student_answer.server.lua
    student_answer.client.lua
  ...
  12_final_battle/
    teacher_setup.server.lua
    student_answer.server.lua
```

- `teacher_setup.server.lua`: 선생님이 Roblox Studio에서 수업 맵, Tool, 버튼, 팀, 연습용 더미를 자동 생성하는 준비 코드입니다.
- `student_answer.server.lua`: 학생용 완성 모범답안입니다. 빈칸 채우기나 임시 스캐폴드가 아니라 완성된 정답 코드입니다.
- `student_answer.client.lua`: 클라이언트 입력이 필요한 RemoteEvent 수업에서 Tool 안 LocalScript로 붙여넣는 코드입니다.
- 파일명에 `.server.lua`를 붙인 이유는 대부분 서버 권한에서 오브젝트 생성, 데미지, 점수, 라운드 상태를 처리하기 때문입니다.

## 3. 공통 실행 환경

- 프로그램: Roblox Studio
- 기본 화면: 로블록스 스튜디오의 버전이나 언어 설정에 따라 상단 메뉴의 **보기(View)** 또는 **창(Window)** 메뉴에서 아래 3가지 필수 창을 항상 활성화해 둡니다.
  1. **탐색기 (Explorer) [단축키: `Ctrl + Shift + X` 또는 `Ctrl + Alt + I`]**: 게임 내 존재하는 모든 오브젝트(폴더, 파트, 스크립트, 팀 등)의 계층 구조를 트리 형태로 나열하고 관리하는 창입니다.
  2. **속성 (Properties) [단축키: `Ctrl + Shift + P`]**: 선택한 오브젝트의 이름, 색상, 재질, 크기, 활성화 상태 등 세부적인 속성을 확인하고 편집하는 창입니다.
  3. **출력 (Output)**: 스크립트의 `print()` 출력값이나 시스템 작동 로그, 그리고 실행 도중 발생한 에러 메시지(빨간색 코드 에러)를 실시간으로 띄워 디버깅을 돕는 창입니다.
- 권장 테스트: Home > Play 또는 Test 탭의 Play
- 권장 저장: 수업 전 `.rbxl` 또는 Team Create publish 백업
- 보안 원칙: Toolbox 무료 모델은 최소화하고, 가져온 모델에 숨어 있는 Script가 있는지 탐색기(Explorer)에서 확인합니다.

## 4. 공통 실행 순서

1. Roblox Studio에서 수업용 place를 엽니다.
2. `ServerScriptService`에 Script를 만들고 해당 일차의 `teacher_setup.server.lua` 전체를 붙여넣습니다.
3. Play를 눌러 setup 코드가 Workspace/StarterPack/Teams 등에 필요한 오브젝트를 생성하는지 확인합니다.
4. Stop을 누른 뒤 setup Script는 비활성화하거나 삭제합니다. 반복 실행하면 기존 오브젝트를 지우고 다시 만들 수 있습니다.
5. 학생 답안 파일 상단의 `Paste path`를 확인합니다.
6. 학생 답안 파일 상단의 붙여넣기 위치에 맞춰 `ServerScriptService`, `StarterPack > Tool > Script`, `StarterPack > Tool > LocalScript`에 코드를 붙여넣습니다.
7. Play로 기능을 테스트하고 Output(출력) 창의 오류를 확인합니다.

## 5. Paste path 규칙

| 유형 | 붙여넣기 위치 | 대상 일차 |
| --- | --- | --- |
| 맵/버튼/라운드 서버 코드 | `ServerScriptService > Script` | 02, 03, 08, 09, 10, 12 |
| Tool 동작 코드 | `StarterPack > Tool > Script` | 01, 04, 05, 06, 07 |
| RemoteEvent 서버 판정 코드 | `ServerScriptService > Script` | 11 |
| RemoteEvent 입력 코드 | `StarterPack > Tool > LocalScript` | 11 |
| 준비 코드 | `ServerScriptService > Script` | 모든 teacher_setup |

Tool 동작 코드를 `ServerScriptService`에 넣으면 실제 플레이어 Backpack으로 복제된 Tool에 이벤트가 연결되지 않을 수 있습니다. Tool 계열 답안은 반드시 해당 Tool 내부 Script에 넣습니다. 11일차는 예외로 Tool of LocalScript가 입력을 보내고, ServerScriptService의 Script가 서버 판정을 처리합니다.

## 6. 일차별 생성/실행 대상

| 일차 | 주제 | teacher_setup 생성물 | student_answer 위치 |
| --- | --- | --- | --- |
| 01 | 돌멩이 기초 무기 | `Workspace/Arena01`, `StarterPack/PracticeRock` | `StarterPack > PracticeRock > Script` |
| 02 | 기초 엄폐물 | `Workspace/CoverField02` | `ServerScriptService > Script` |
| 03 | 자원 기반 방벽 | `Workspace/ResourceWall03/BuildButton` | `ServerScriptService > Script` |
| 04 | 일반 무기/디바운스 | `StarterPack/BalanceSword`, `Workspace/Dummies04` | `StarterPack > BalanceSword > Script` |
| 05 | 원거리 무기 | `StarterPack/TrainingBow`, `Workspace/TargetRange05` | `StarterPack > TrainingBow > Script` |
| 06 | 방패 | `StarterPack/PracticeShield` | `StarterPack > PracticeShield > Script` |
| 07 | 갑옷 | `StarterPack/HeavyArmor` | `StarterPack > HeavyArmor > Script` |
| 08 | 파괴되는 성문 | `Workspace/Castle08/Gate` | `ServerScriptService > Script` |
| 09 | 부분 파괴 성벽 | `Workspace/StoneWall09` | `ServerScriptService > Script` |
| 10 | 공성 병기 | `Workspace/SiegeEngine10` | `ServerScriptService > Script` |
| 11 | 마법 스킬 | `StarterPack/MagicStaff`, `Workspace/MagicArena11`, `ReplicatedStorage/CastMagic` | `ServerScriptService > Script`, `StarterPack > MagicStaff > LocalScript` |
| 12 | 최종 대전 | `Workspace/FinalBattle12`, `Teams/Blue`, `Teams/Red` | `ServerScriptService > Script` |

## 7. 검증 체크리스트

- teacher setup 실행 후 Explorer에 위 표의 생성물이 보이는가?
- Tool 계열 수업은 Play 후 플레이어 Backpack/캐릭터에 Tool이 들어왔는가?
- Output 창에 빨간 오류가 없는가?
- 버튼 수업은 ClickDetector of MaxActivationDistance 안에서 클릭했는가?
- 데미지 수업은 대상 Model 안에 Humanoid와 HumanoidRootPart가 있는가?
- 라운드 수업은 Workspace Attribute `RoundState`, `TimeLeft`가 바뀌는가?

## 8. 문제 해결

- Tool 클릭이 반응하지 않음: 학생 답안 Script가 `StarterPack > Tool` 내부에 있는지 확인합니다. 11일차는 `MagicStaff` 안 LocalScript와 `ServerScriptService`의 서버 Script가 둘 다 있어야 합니다.
- `WaitForChild`에서 멈춤: teacher setup을 먼저 실행했는지, 오브젝트 이름이 주석의 경로와 같은지 확인합니다.
- 데미지가 안 들어감: 대상에 Humanoid가 있어야 하며, 자기 캐릭터는 데미지 대상에서 제외됩니다.
- 버튼이 안 눌림: ClickDetector가 버튼 Part 안에 있는지, Play 모드에서 거리가 충분히 가까운지 확인합니다.
- 여러 번 실행되어 오브젝트가 중복됨: teacher setup은 기존 DayXX 폴더/Tool을 지우고 다시 만들도록 작성했지만, 수업 중에는 Stop 후 setup Script를 비활성화합니다.
- Team Create 충돌: 공통 시스템은 선생님만 수정하고, 학생별 실험은 각자 폴더에서 진행합니다.

## 9. 원본 문서 보존

`docs/curriculum_12_weeks.md`는 원본 12주 계획 문서입니다. 이 파일은 기준 문서로 고정하고, 실제 실행 코드와 보완 운영 설명은 `lessons/`와 강의 가이드 문서에서 관리합니다.
