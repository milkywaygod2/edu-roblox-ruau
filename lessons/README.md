# Roblox Luau 12일 수업 스크립트 운영 가이드

이 폴더는 12회차 동안 하나의 5v5 전초기지 공방전 게임을 누적해서 완성하는 Roblox Luau 코드 팩입니다. 1회차부터 `Workspace/OutpostBattleWorld` 아래의 같은 전장을 사용하고, 각 회차는 이전 회차 오브젝트를 지우지 않은 채 새 개념과 장치를 보강합니다.

핵심 루프는 “장비를 직접 지급받기”가 아니라 “맵에 흩어진 학생 튜닝 장비를 찾아 줍고, 상대 목표물을 공격하거나 우리 목표물을 지키기”입니다.

## 1. 핵심 구조

- `lessons/common.module.lua`: `ReplicatedStorage > ModuleScript` 이름 `Common`으로 두는 공통 상수/헬퍼와 서버 권한 게임 시스템입니다.
- `teacher_setup.server.lua`: 선생님 전용 준비 코드입니다. 공통 전장, 목표물, 아이템 스폰 마커, 버튼, 방어 구조물, 팀 같은 기준 오브젝트를 `ensure*` 방식으로 보장합니다.
- `student_answer.server.lua`: 학생용 설정 코드입니다. `tbl...Config` 값만 수정하고, 실제 아이템 생성, 획득, 데미지, 자원, 쿨타임, 라운드 판정은 `Common`의 `install...` 함수가 처리합니다.
- `student_answer.client.lua`: 클라이언트 입력이 필요한 경우에만 사용합니다. 클라이언트는 입력과 요청만 담당하고 데미지, 자원, 라운드 상태는 서버가 판정합니다.

## 2. 누적 월드 구조

```text
Workspace
  OutpostBattleWorld
    Battlefield
      BattlefieldBase
      CoverMarker_*
      RoundStartButton
      SpawnPoint_Blue
      SpawnPoint_Red
    ObjectiveArea
      OutpostCore_*
      OutpostGuard_*
      DuelGuard_*
      RangeTarget_*
      ArcaneGuard_*
    ItemSpawns
      ItemSpawn_ThrowingStone_*
      ItemSpawn_FieldSword_*
      ItemSpawn_FieldBow_*
      ItemSpawn_FieldShield_*
      ItemSpawn_FieldArmor_*
      ItemSpawn_MagicStaff_*
      FieldItem_*
    BuildArea
      BuildButton
      WallSpawn
      *_WallBlock
    Fortification
      Gate
      StoneWall
    SiegeEngine
      LaunchButton
      LaunchPoint
      TargetPoint
```

회차 폴더명은 정렬을 위해 `01_rock_tool`처럼 숫자를 붙입니다. 게임 오브젝트 이름은 회차별 폴더명으로 나누지 않고 `Battlefield`, `ObjectiveArea`, `ItemSpawns`, `Fortification`처럼 도메인 역할을 우선합니다. 번호는 `OutpostGuard_1`, `WallSection_1`처럼 같은 종류를 구분할 때만 씁니다.

## 3. 네이밍 규칙

스크립트 변수는 `타입 축약 접두사 + 고유이름`을 사용합니다. 문자열 이름, 클래스명, Attribute 키는 `common.module.lua`의 enum 테이블에서 관리합니다.

| 접두사 | 대상 | 예시 |
| --- | --- | --- |
| `svc` | `game:GetService()` 서비스 | `svcWorkspace` |
| `fld` | `Folder` | `fldBattlefield` |
| `part` | `Part` 또는 `BasePart` | `partBuildButton` |
| `model` | `Model` | `modelGate` |
| `tool` | `Tool` | `toolThrowingStone` |
| `hum` | `Humanoid` | `humOutpostCore` |
| `ival` | `IntValue` | `ivalWood` |
| `click` | `ClickDetector` | `clickDetector` |
| `event` | `RemoteEvent` | `eventCastMagic` |
| `emit` | `ParticleEmitter` | `emitArmorAura` |
| `tbl` | table | `tblOutpostWorld` |
| `bool` | boolean | `boolReady` |
| `int` | integer | `intTimeLeft` |
| `str` | string | `strPlayerName` |

## 4. 실행 순서

1. Roblox Studio에서 수업용 place를 엽니다.
2. `ReplicatedStorage`에 `ModuleScript`를 만들고 `lessons/common.module.lua`를 붙여넣은 뒤 이름을 `Common`으로 설정합니다.
3. `ServerScriptService`에 해당 회차의 `teacher_setup.server.lua`를 붙여넣고 Play로 실행합니다.
4. Explorer에서 `Workspace/OutpostBattleWorld`, `Teams`, `ReplicatedStorage` 생성물을 확인합니다.
5. Stop 후 setup Script는 비활성화합니다. 다시 실행해도 기본 정책은 삭제 재생성이 아니라 누락 오브젝트 보장입니다.
6. 학생 답안 파일의 붙여넣기 위치에 맞춰 `student_answer` 코드를 넣고, 수업에서 허용한 `tbl...Config` 값만 바꿔 Play로 검증합니다.

초기화가 꼭 필요한 예외 상황에서는 `common.resetNamedInstance()` 또는 `createOrReplaceInstance()`를 사용할 수 있지만, 기본 수업 운영은 누적 유지입니다.

## 5. 학생 튜닝 장비 규칙

01, 04, 05, 06, 07, 11회차의 장비는 `StarterPack`으로 직접 지급하지 않습니다. 학생 설정 스크립트가 `ServerScriptService`에서 실행되면 `Common`이 `ItemSpawns`에 `FieldItem_*` Tool을 만들고, 플레이어가 클릭해서 줍습니다.

학생별 버전을 여러 개 놓고 싶으면 설정에서 아래 값을 바꿉니다.

```lua
VariantId = "MyStone01"
DisplayName = "불타는 돌"
SpawnOffset = Vector3.new(2, 0, 0)
SpawnCount = 3
```

`VariantId`가 같으면 같은 위치의 기존 장비를 보정하고, 다르면 새 학생 버전이 별도 `FieldItem_*`으로 생깁니다.

최종전 라운드를 다시 시작하면 플레이어가 들고 있던 `FieldItem_*` 장비는 원래 스폰 위치로 돌아갑니다. 따라서 12회차 플레이테스트에서도 각 팀은 자기 스폰에서 시작한 뒤 맵에 놓인 학생 장비를 다시 파밍해야 합니다.

## 6. Paste Path

| 유형 | 붙여넣기 위치 | 대상 회차 |
| --- | --- | --- |
| 준비 코드 | `ServerScriptService > Script` | 모든 `teacher_setup` |
| 학생 서버 설정 코드 | `ServerScriptService > Script` | 모든 `student_answer.server.lua` |
| RemoteEvent 입력 코드 | `StarterPlayer > StarterPlayerScripts > LocalScript` | 11 |

Tool 계열 답안도 이제 Tool 내부에 넣지 않습니다. 장비의 생성, 클릭 획득, Backpack 이동은 `Common`이 처리하고, 학생은 설정값만 수정합니다.

## 7. 회차별 생성/보장 대상

| 회차 | 주제 | teacher_setup 보장 대상 | student_answer 위치 |
| --- | --- | --- | --- |
| 01 | 돌 투척/첫 파밍 | `OutpostBattleWorld/Battlefield`, `ObjectiveArea/OutpostCore_*`, `ItemSpawn_ThrowingStone_*` | `ServerScriptService > Script` |
| 02 | 전초기지 엄폐물 | `OutpostBattleWorld/Battlefield/CoverMarker_*` | `ServerScriptService > Script` |
| 03 | 자원 기반 방벽 | `OutpostBattleWorld/BuildArea/BuildButton`, `WallSpawn` | `ServerScriptService > Script` |
| 04 | 근접 무기/디바운스 | `ObjectiveArea/DuelGuard_*`, `ItemSpawn_FieldSword_*` | `ServerScriptService > Script` |
| 05 | 원거리 무기 | `ObjectiveArea/RangeTarget_*`, `ItemSpawn_FieldBow_*` | `ServerScriptService > Script` |
| 06 | 방패 | `ItemSpawn_FieldShield_*` | `ServerScriptService > Script` |
| 07 | 갑옷 | `ItemSpawn_FieldArmor_*` | `ServerScriptService > Script` |
| 08 | 파괴되는 문 | `OutpostBattleWorld/Fortification/Gate` | `ServerScriptService > Script` |
| 09 | 부분 파괴 석벽 | `OutpostBattleWorld/Fortification/StoneWall` | `ServerScriptService > Script` |
| 10 | 중장비 | `OutpostBattleWorld/SiegeEngine/LaunchButton`, `LaunchPoint`, `TargetPoint` | `ServerScriptService > Script` |
| 11 | 마법 스킬 | `ItemSpawn_MagicStaff_*`, `ObjectiveArea/ArcaneGuard_*`, `ReplicatedStorage/CastMagic` | `ServerScriptService > Script`, `StarterPlayerScripts > LocalScript` |
| 12 | 최종 5v5 공방전 | `Battlefield/RoundStartButton`, `SpawnPoint_Blue`, `SpawnPoint_Red`, `Teams/Blue`, `Teams/Red` | `ServerScriptService > Script` |

## 8. 검증 체크리스트

- `Common` ModuleScript가 `ReplicatedStorage`에 있는가?
- teacher setup 실행 후 `Workspace/OutpostBattleWorld` 아래에 누적 전장 구조가 보이는가?
- Tool 계열 수업은 Play 후 `ItemSpawns/FieldItem_*`가 보이고, 클릭하면 Backpack으로 들어오는가?
- 버튼 수업은 ClickDetector 거리 안에서 클릭했는가?
- 데미지 수업은 대상 Model 안에 Humanoid와 HumanoidRootPart가 있는가?
- 라운드 수업은 Workspace Attribute `RoundState`, `TimeLeft`, `RoundWinner`, `RoundEndReason`, `BluePlayerCount`, `RedPlayerCount`가 바뀌는가?
- Output 창에 빨간 오류가 없는가?

## 9. 문제 해결

- Tool 클릭이 반응하지 않음: 학생 답안 Script가 `ServerScriptService`에 있고 teacher setup으로 `ItemSpawn_*` 마커가 먼저 만들어졌는지 확인합니다.
- 같은 학생 장비가 겹침: 학생별 `VariantId` 또는 `SpawnOffset`을 다르게 설정합니다.
- `WaitForChild`에서 멈춤: `Common`과 해당 회차 `teacher_setup`을 먼저 실행했는지 확인합니다.
- 오브젝트가 중복됨: teacher setup과 학생 설정 코드는 기본적으로 보장 방식입니다. 전투 중 생긴 투사체/방벽 같은 런타임 생성물은 Stop 후 다시 시작하거나 필요한 경우에만 reset helper로 정리합니다.
- 클라이언트 요청이 이상함: 클라이언트 값은 신뢰하지 말고 서버 코드에서 거리, 쿨타임, 소유자, 타입을 검사합니다.
- Team Create 충돌: 공통 시스템은 선생님만 수정하고, 학생별 실험은 정해진 설정 테이블과 학생용 모델 범위에서 진행합니다.

## 10. 원본 문서

`docs/curriculum_12_weeks.md`는 12주 계획 문서입니다. 실제 실행 코드와 운영 설명은 `lessons/`와 강의 가이드에서 관리합니다.
