# Roblox Luau 12일 수업 스크립트 운영 가이드

이 폴더는 12회차 동안 하나의 5v5 전초기지 공방전 게임을 누적해서 완성하는 Roblox Luau 코드 팩입니다. 1회차부터 `Workspace/OutpostBattleWorld` 아래의 같은 전장을 사용하고, 각 회차는 이전 회차 오브젝트를 지우지 않은 채 새 개념과 장치를 보강합니다.

핵심 루프는 “장비를 직접 지급받기”가 아니라 “맵에 흩어진 학생 튜닝 장비를 찾아 줍고, 상대 목표물을 공격하거나 우리 목표물을 지키기”입니다.

Blue/Red는 공수 고정이 없는 대칭 팀입니다. 접속한 모든 플레이어를 두 팀으로 계속 나누고, 홀수 인원일 때 생기는 추가 1명은 라운드마다 Blue/Red가 번갈아 받습니다. 팀에 배정된 플레이어는 상대 플레이어와 상대 코어를 공격할 수 있습니다.

## 1. 핵심 구조

- `lessons/Common.lua` + `lessons/Common/`: `ReplicatedStorage > ModuleScript` 이름 `Common`과 그 하위 ModuleScript들로 두는 공통 상수/헬퍼와 서버 권한 게임 시스템입니다.
- `lessons/teacher_setup.server.lua`: 선생님 전용 단일 준비 코드입니다. 공통 전장, 목표물, 아이템 스폰 마커, 버튼, 방어 구조물, 팀 같은 기준 오브젝트를 `ensure*` 방식으로 한 번에 보장합니다.
- `lessons/01_student_answer.module.lua` ~ `lessons/12_student_answer.module.lua`: 일자별 학생용 설정 ModuleScript입니다. 허용된 데이터 값만 수정하고, 실제 아이템 생성, 획득, 데미지, 자원, 쿨타임, 라운드 판정은 `Common`이 처리합니다.
- `lessons/11_student_answer.client.lua`: 11일차 클라이언트 입력 코드입니다. 클라이언트는 입력과 요청만 담당하고 데미지, 자원, 라운드 상태는 서버가 판정합니다.

`Common`이 커지면 날짜별 파일이 아니라 개념별 ModuleScript로 나눕니다. 분리 기준은 `docs/ARCH_공통모듈_개념별분리.md`를 따릅니다.

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

학생 스크립트 파일명은 정렬을 위해 `01_student_answer.module.lua`, `02_student_answer.module.lua`처럼 숫자를 붙입니다. 게임 오브젝트 이름은 회차별 이름으로 나누지 않고 `Battlefield`, `ObjectiveArea`, `ItemSpawns`, `Fortification`처럼 도메인 역할을 우선합니다. 번호는 `OutpostGuard_1`, `WallSection_1`처럼 같은 종류를 구분할 때만 씁니다.

## 3. 네이밍 규칙

스크립트 변수는 `타입 축약 접두사 + 고유이름`을 사용합니다. 문자열 이름, 클래스명, Attribute 키는 `Common/CoreEnums.lua`의 enum 테이블에서 관리합니다.

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
2. `ReplicatedStorage`에 `lessons/Common.lua`와 `lessons/Common/` 구조를 배치합니다. (Roblox Studio 내에서는 `Common` ModuleScript 하위에 자식 ModuleScript들로 구성되며, Studio `Script Sync` 등을 활용해 동기화할 수 있습니다.)
3. `ServerScriptService`에 `lessons/teacher_setup.server.lua`를 붙여넣고 이름을 `TeacherSetup`으로 둡니다.
4. Explorer에서 `Workspace/OutpostBattleWorld`, `Teams`, `ReplicatedStorage` 생성물을 확인합니다.
5. `TeacherSetup`은 매일 같은 파일을 사용합니다. Play마다 다시 실행되어도 기존 오브젝트를 지우지 않고 누락된 기준 구조만 보강합니다.
6. 1회차 학생 답안은 `StudentRockDesigns`에, 2~12회차 학생 답안은 `StudentLessonConfigs`에 ModuleScript로 넣고, 수업에서 허용한 데이터 값만 바꿔 Play로 검증합니다.

초기화가 꼭 필요한 예외 상황에서는 `common.resetNamedInstance()`를 사용할 수 있지만, 기본 수업 운영은 누적 유지입니다.

## 5. 학생 튜닝 장비 규칙

01, 04, 05, 06, 07, 11회차의 장비는 `StarterPack`으로 직접 지급하지 않습니다. `Common`이 `ItemSpawns`에 `FieldItem_*` Tool을 만들고, 플레이어가 클릭해서 줍습니다.

1회차 돌멩이는 `ServerScriptService > StudentRockDesigns` 폴더 안의 학생 ModuleScript가 데이터 table만 `return`합니다. `VariantId`, 생성, 배치, 획득, 데미지 판정은 `Common`이 처리합니다. 학생 ModuleScript 하나가 오타로 실패해도 `pcall(require)`로 격리하고, 그 학생 돌만 기본 돌멩이로 대체합니다. 오류와 보정 내용은 Output과 전장 안 `StudentRockValidationBoard`에 표시됩니다.

```lua
local rock = {}
local appearance = {}

appearance.BrickColor = BrickColor.new("Bright red")
appearance.Material = Enum.Material.Slate
appearance.Size = Vector3.new(1.2, 1.2, 1.2)
appearance.CollisionShape = Enum.PartType.Ball
appearance.LookShape = ""

rock.DisplayName = "불타는 돌"
rock.Appearance = appearance
rock.Trait = "Heavy"
rock.SpawnCount = 3

return rock
```

2~12회차는 `ServerScriptService > StudentLessonConfigs` 폴더 안의 ModuleScript가 설정 table만 `return`합니다. `Common`은 `02_student_answer` 또는 `StudentAnswer02`처럼 ModuleScript 이름의 앞/뒤 숫자로 회차를 판단합니다. 학생 파일은 `require(Common)`이나 `common.install*`을 호출하지 않고, `TeacherSetup`이 Play 시점에 이 ModuleScript들을 읽어 설치합니다.

`Appearance`는 돌의 모양 묶음입니다. `Size`는 실제 게임 기준 크기이자 `LookShape`가 들어갈 최대 크기입니다. `CollisionShape`는 기본 충돌 Part 모양이고, `LookShape`는 그 크기 안에 맞춰 붙는 겉모습 모델입니다. `BrickColor` 대신 `Color = Color3.fromRGB(...)`를 써도 됩니다.

`Damage`, `Speed`, `Cooldown`, `Knockback` 같은 결과값은 학생 코드에 넣지 않습니다. `Common`이 돌의 크기, 재질, 성격을 읽고 서버에서 계산합니다. `SpawnCount`는 1~10으로 제한되며, 스폰 위치는 선생님이 놓은 기준점 주변에 자동 분산됩니다. 학생 코드에는 `SpawnOffset`을 넣지 않습니다.

수업 설명에서는 `1 stud ~= 30cm` 정도로 잡습니다. Roblox 캐릭터는 대략 5~6 studs 높이이므로 `1.8`은 사람보다 큰 바위가 아니라 “꽤 큰 손바위”에 가깝습니다.

| 값 | 수업용 느낌 |
| --- | --- |
| `Vector3.new(0.7, 0.7, 0.7)` | 조약돌 |
| `Vector3.new(1.2, 1.2, 1.2)` | 손에 드는 돌 |
| `Vector3.new(1.8, 1.8, 1.8)` | 큰 손바위 |
| `Vector3.new(2.4, 2.4, 2.4)` | 느리고 무거운 바위 |

돌멩이 크기는 `Common.tblEquipmentSizeRule.ThrowingStone` 기준으로 `0.5`~`2.6` studs 안에서 보정됩니다. 투석기 탄환처럼 큰 물체는 별도 규칙(`SiegeStone`)을 둬서 `10` studs까지 허용할 수 있습니다.

돌멩이 `Material`은 자유도를 유지하기 위해 blacklist 방식으로 처리합니다. `Enum.Material.Air`, `Enum.Material.Water`, `Enum.Material.ForceField`처럼 돌 Part에 맞지 않거나 특수 효과성인 재질만 `Enum.Material.Slate`로 되돌리고, 나머지 Material은 가능한 한 그대로 반영합니다.

Creator Store 모델은 `ReplicatedStorage > OutpostAssets > RockLooks` 폴더 안에 넣고 이름으로 참조합니다.

```lua
appearance.LookShape = "Meteor"
```

`Common`은 `RockLooks/Meteor`를 찾아 Handle과 투사체에 겉모습으로 붙입니다. `LookShape` 모델은 `Size` 안으로 맞춰지고, 내부 Script/ModuleScript/LocalScript는 제거됩니다. 충돌과 데미지 판정은 계속 안전한 기본 Part가 맡습니다.

최종전 라운드를 다시 시작하면 플레이어가 들고 있던 `FieldItem_*` 장비는 원래 스폰 위치로 돌아갑니다. 따라서 12회차 플레이테스트에서도 각 팀은 자기 스폰에서 시작한 뒤 맵에 놓인 학생 장비를 다시 파밍해야 합니다.

### 물리 실물 자산 및 가상 신용 화폐 규칙

이 프로젝트는 3D 월드의 물리적 상호작용 극대화를 위해 **실물 자원 수송**을 기본 뼈대로 삼습니다.

* **실물 자원 (Wood, Stone, Gold)**:
  * 맵에서 채굴하거나 적의 성벽을 파괴해서 드랍되는 자원 조각들은 가상 숫자가 아닙니다.
  * 플레이어가 직접 접근해 **등에 물리적으로 짊어지고(Carry)** 운반해야만 소지할 수 있으며, 이 짊어진 벽돌을 소모해 원하는 위치에 직접 엄폐물(`CoreBlock`)을 건축할 수 있습니다.
* **가상 신용 화폐 (Credit)**:
  * 플레이어 계정 리더보드(`leaderstats`)에 표시되는 `Credit` 수치는 물리 자원 블록과는 철저히 독립된 **문서상/신용 화폐**입니다.
  * 3일차 버튼식 성벽 자동 빌드 등 추상적 자원 거래나 추후 상점 기능에 활용됩니다.


11회차 마법 이펙트는 Roblox `ParticleEmitter` 일부 속성을 직접 조합하는 table입니다. 별도 프리셋을 고르지 않고 `Shape`, `ShapeStyle`, `ShapeInOut`, `EmissionDirection`, `Orientation` 같은 Roblox 기본 Enum을 그대로 씁니다.

```lua
local effect = {}
local magic = {}

effect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
effect.Rate = 24
effect.Color = Color3.fromRGB(255, 112, 36)
effect.Lifetime = NumberRange.new(0.25, 0.7)
effect.Speed = NumberRange.new(0.5, 2)
effect.Size = NumberSequence.new(0.35)
effect.Shape = Enum.ParticleEmitterShape.Sphere
effect.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
effect.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
effect.EmissionDirection = Enum.NormalId.Top
effect.Orientation = Enum.ParticleOrientation.FacingCamera

magic.Effect = effect

return magic
```

수업용 텍스처 후보는 Studio 기본 `content/textures/particles` 중 단독 사용하기 좋은 완성형 파츠 11개만 `common.eParticleTexture`에 모아 관리합니다. 불필요한 레이어나 접미사(`_MAIN`)를 제거하고 직관적인 이름으로 제공합니다. Roblox API는 `Texture`를 enum 목록이 아니라 ContentId로 받기 때문에, 수업에서는 검증 가능한 목록을 Common에서 관리합니다. 이펙트 숫자값은 전부 Common에서 보정합니다. `Rate` 0~60, `LightEmission/LightInfluence` 0~1, `Brightness` 0~10, `Lifetime` 0.05~3, `Speed` 0~20, `Size` 0.05~3, `SpreadAngle` 0~180, `Acceleration` -50~50, `Drag` 0~20, `Rotation/RotSpeed` -360~360, `VelocityInheritance` 0~1, `ZOffset` -5~5, `TimeScale` 0~2, `ShapePartial` 0~1, `EffectLifetime` 0.5~6 안으로 제한됩니다.

## 6. Paste Path

| 유형 | 붙여넣기 위치 | 대상 회차 |
| --- | --- | --- |
| 준비 코드 | `ServerScriptService > Script` 이름 `TeacherSetup` | `lessons/teacher_setup.server.lua` 하나 |
| 1회차 학생 돌멩이 데이터 | `ServerScriptService > StudentRockDesigns > ModuleScript` | `01_student_answer.module.lua` |
| 2~12회차 학생 설정 데이터 | `ServerScriptService > StudentLessonConfigs > ModuleScript` | `02_student_answer.module.lua` ~ `12_student_answer.module.lua` |
| RemoteEvent 입력 코드 | `StarterPlayer > StarterPlayerScripts > LocalScript` | `11_student_answer.client.lua` |

Tool 계열 답안도 이제 Tool 내부에 넣지 않습니다. 장비의 생성, 클릭 획득, Backpack 이동은 `Common`이 처리하고, 학생은 설정값만 수정합니다.

## 7. 회차별 생성/보장 대상

| 회차 | 주제 | 공통 setup 보장 대상 | 학생 파일 |
| --- | --- | --- | --- |
| 01 | 돌 투척/첫 파밍 | `OutpostBattleWorld/Battlefield`, `ObjectiveArea/OutpostCore_*`, `ItemSpawn_ThrowingStone_*`, `ServerScriptService/StudentRockDesigns` | `01_student_answer.module.lua` |
| 02 | 전초기지 엄폐물 | `OutpostBattleWorld/Battlefield/CoverMarker_*`, `ServerScriptService/StudentLessonConfigs` | `02_student_answer.module.lua` |
| 03 | 자원 기반 방벽 | `OutpostBattleWorld/BuildArea/BuildButton`, `WallSpawn`, `ServerScriptService/StudentLessonConfigs` | `03_student_answer.module.lua` |
| 04 | 근접 무기/디바운스 | `ObjectiveArea/DuelGuard_*`, `ItemSpawn_FieldSword_*`, `ServerScriptService/StudentLessonConfigs` | `04_student_answer.module.lua` |
| 05 | 원거리 무기 | `ObjectiveArea/RangeTarget_*`, `ItemSpawn_FieldBow_*`, `ServerScriptService/StudentLessonConfigs` | `05_student_answer.module.lua` |
| 06 | 방패 | `ItemSpawn_FieldShield_*`, `ServerScriptService/StudentLessonConfigs` | `06_student_answer.module.lua` |
| 07 | 갑옷 | `ItemSpawn_FieldArmor_*`, `ServerScriptService/StudentLessonConfigs` | `07_student_answer.module.lua` |
| 08 | 파괴되는 문 | `OutpostBattleWorld/Fortification/Gate`, `ServerScriptService/StudentLessonConfigs` | `08_student_answer.module.lua` |
| 09 | 부분 파괴 석벽 | `OutpostBattleWorld/Fortification/StoneWall`, `ServerScriptService/StudentLessonConfigs` | `09_student_answer.module.lua` |
| 10 | 중장비 | `OutpostBattleWorld/SiegeEngine/LaunchButton`, `LaunchPoint`, `TargetPoint`, `ServerScriptService/StudentLessonConfigs` | `10_student_answer.module.lua` |
| 11 | 마법 스킬 | `ItemSpawn_MagicStaff_*`, `ObjectiveArea/ArcaneGuard_*`, `ReplicatedStorage/CastMagic`, `ServerScriptService/StudentLessonConfigs` | `11_student_answer.module.lua`, `11_student_answer.client.lua` |
| 12 | 최종 5v5 공방전 | `Battlefield/RoundStartButton`, `SpawnPoint_Blue`, `SpawnPoint_Red`, `Teams/Blue`, `Teams/Red`, `ServerScriptService/StudentLessonConfigs` | `12_student_answer.module.lua` |

## 8. 검증 체크리스트

- `Common` ModuleScript가 `ReplicatedStorage`에 있는가?
- teacher setup 실행 후 `Workspace/OutpostBattleWorld` 아래에 누적 전장 구조가 보이는가?
- Tool 계열 수업은 Play 후 `ItemSpawns/FieldItem_*`가 보이고, 클릭하면 Backpack으로 들어오는가?
- 버튼 수업은 ClickDetector 거리 안에서 클릭했는가?
- 데미지 수업은 대상 Model 안에 Humanoid와 HumanoidRootPart가 있는가?
- 라운드 수업은 Workspace Attribute `RoundState`, `TimeLeft`, `RoundWinner`, `RoundEndReason`, `BluePlayerCount`, `RedPlayerCount`가 바뀌는가?
- Output 창에 빨간 오류가 없는가?

## 9. 실전 실습 및 운영 가이드 (1일차 기준)

이 가이드는 로블록스 스튜디오에서 1일차 수업(돌 투척 및 물리 자원 획득)을 세팅하고 검증하는 단계별 실전 가이드입니다.

### 1단계. 필수 뷰(View) 패널 및 개발 환경 준비
1. 스튜디오 상단 **View** 탭을 클릭합니다.
2. **Explorer**, **Properties**, **Output** 창을 활성화하여 화면에 배치합니다.
> [!NOTE]
> **Output(출력) 창**은 Luau 컴파일 오류, 린팅 정보, 학생 코드 밸리데이션 로그를 실시간으로 모니터링하는 핵심 디버깅 도구이므로 항상 열어두어야 합니다.

### 2단계. 1일차 교사용 월드 세팅 (Teacher Setup)
1. **스크립트 생성**:
   - 스튜디오의 **Explorer** 창에서 `ServerScriptService`를 마우스 우클릭하고 **Insert Object > Script**를 생성합니다.
   - 스크립트 이름을 `TeacherSetup`으로 변경합니다.
2. **코드 복사**:
   - [teacher_setup.server.lua](file:///E:/_Develop/edu/edu-roblox-ruau/lessons/teacher_setup.server.lua)의 내용 전체를 복사하여 `TeacherSetup` 스크립트에 붙여넣습니다.
3. **월드 자동 생성 검증**:
   - 스튜디오 상단의 **Play** 버튼을 누릅니다.
   - **Output** 창에 `수업 월드 준비 완료` 문구가 출력되는지 확인합니다.
   - 다음 생성물을 확인합니다:
     - `Workspace` 아래에 누적 경기장 구조물인 `OutpostBattleWorld`와 바닥(`BattlefieldBase`), 그리고 연습용 더미(`OutpostGuard_1` ~ `OutpostGuard_4`)가 정상 스폰되는지 확인합니다.
     - 중앙 경기장 바닥 근처에 돌멩이 획득용 `FieldItem_ThrowingStone_*` 도구가 스폰되어 바닥에 놓여 있는지 확인합니다.
   - 확인이 끝나면 **Stop**을 눌러 테스트를 종료합니다.
   > [!TIP]
   > 리팩토링된 `TeacherSetup`은 `ensure` 방식(안전 무결성 보장)으로 구현되어 있어, 매번 삭제하거나 `Disabled`하지 않고 **그대로 켜두고 수업에 활용하셔도 안전합니다.**

### 3단계. 학생 모범답안 적용 및 물리 루프 검증 (Student Answer)
1. **학생 모듈 배치**:
   - `ServerScriptService > StudentRockDesigns` 폴더로 이동합니다. (없는 경우 `TeacherSetup`을 실행하면 자동 생성됩니다.)
   - 폴더 안에 **Insert Object > ModuleScript**를 생성하고 이름을 `01_student_answer`로 설정합니다.
   - [01_student_answer.module.lua](file:///E:/_Develop/edu/edu-roblox-ruau/lessons/01_student_answer.module.lua)에 작성된 학생 돌 디자인 설정 테이블 코드를 복사하여 붙여넣습니다.
2. **플레이 및 3D 물리 피드백 검증**:
   - **Play** 버튼을 누릅니다.
   - **필드 파밍 검증**:
     - 바닥에 스폰된 돌멩이 도구에 접근하여 `ProximityPrompt`("등에 메기") 단축키를 누르거나 클릭합니다.
     - 돌멩이가 플레이어의 등(`Torso`) 뒤에 **WeldConstraint로 착 달라붙으며 차곡차곡 물리적으로 쌓이는지** 확인합니다.
   - **물리 투사체 및 넉백 검증**:
     - 등에 자원을 멘 상태에서 마우스 좌클릭을 하여 돌멩이를 전방으로 던집니다.
     - 던져진 돌멩이가 `OutpostGuard` 더미를 맞췄을 때, **더미가 뒤로 강하게 튕겨 나가고(넉백)** 더미의 `Health`가 정상적으로 깎이는지 확인합니다.
   - **파편 드랍 검증**:
     - 돌멩이가 벽이나 더미에 닿아 부서질 때, 그 자리에 **작은 돌멩이 자원 파편 조각들이 툭툭 튕겨 나오며 드롭되는지** 확인합니다.
     - 이 조각들을 플레이어가 지나가며 다시 주워 등에 쌓을 수 있는지 체크합니다.

## 10. 문제 해결

- Tool 클릭이 반응하지 않음: `TeacherSetup`으로 `ItemSpawn_*` 마커가 만들어졌고, 해당 회차 ModuleScript가 `StudentLessonConfigs`에 들어 있는지 확인합니다. 1회차 돌멩이는 `StudentRockDesigns` ModuleScript를 `TeacherSetup`이 읽어 설치합니다.
- 같은 학생 장비가 겹침: 1회차 돌멩이는 `StudentRockDesigns` 안에 학생별 ModuleScript가 있는지 확인합니다. 다른 Tool 회차는 학생별 `VariantId` 또는 `SpawnOffset`을 다르게 설정합니다.
- `WaitForChild`에서 멈춤: `Common`과 단일 `TeacherSetup`을 먼저 실행했는지 확인합니다.
- 오브젝트가 중복됨: teacher setup과 학생 설정 코드는 기본적으로 보장 방식입니다. 전투 중 생긴 투사체/방벽 같은 런타임 생성물은 Stop 후 다시 시작하거나 필요한 경우에만 reset helper로 정리합니다.
- 클라이언트 요청이 이상함: 클라이언트 값은 신뢰하지 말고 서버 코드에서 거리, 쿨타임, 소유자, 타입을 검사합니다.
- Team Create 충돌: 공통 시스템은 선생님만 수정하고, 학생별 실험은 정해진 설정 테이블과 학생용 모델 범위에서 진행합니다.

## 11. 원본 문서

`docs/curriculum_12_weeks.md`는 12주 계획 문서입니다. 실제 실행 코드와 운영 설명은 `lessons/`와 강의 가이드에서 관리합니다.
