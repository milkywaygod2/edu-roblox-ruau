# Roblox Luau 12일 수업 스크립트 운영 가이드

이 폴더는 12회차 동안 하나의 5v5 전초기지 공방전 게임을 누적해서 완성하는 Roblox Luau 코드 팩입니다. 1회차부터 `Workspace/OutpostBattleWorld` 아래의 같은 전장을 사용하고, 각 회차는 이전 회차 오브젝트를 지우지 않은 채 새 개념과 장치를 보강합니다.

핵심 루프는 “장비를 직접 지급받기”가 아니라 “맵에 흩어진 학생 튜닝 장비를 찾아 줍고, 상대 목표물을 공격하거나 우리 목표물을 지키기”입니다.

Blue/Red는 공수 고정이 없는 대칭 팀입니다. 접속한 모든 플레이어를 두 팀으로 계속 나누고, 홀수 인원일 때 생기는 추가 1명은 라운드마다 Blue/Red가 번갈아 받습니다. 팀에 배정된 플레이어는 상대 플레이어와 상대 코어를 공격할 수 있습니다.

## 1. 핵심 구조

- `lessons/ReplicatedStorage/Common/init.luau` + `lessons/ReplicatedStorage/Common/*.luau`: `ReplicatedStorage > Common` ModuleScript와 그 하위 ModuleScript들로 두는 공통 상수/헬퍼, 클라이언트 입력 런타임, 서버 권한 게임 시스템입니다.
- `lessons/ServerScriptService/TeacherSetup.server.luau`: 선생님 전용 단일 준비 코드입니다. 공통 전장, 목표물, 아이템 스폰 마커, 버튼, 방어 구조물, 팀 같은 기준 오브젝트를 `ensure*` 방식으로 한 번에 보장합니다.
- `lessons/ServerScriptService/StudentRockDesigns/01_student_answer.luau`와 `lessons/ServerScriptService/StudentLessonConfigs/02_student_answer.luau` ~ `12_student_answer.luau`: 일자별 학생용 설정 ModuleScript입니다. 허용된 데이터 값만 수정하고, 실제 아이템 생성, 획득, 데미지, 자원, 쿨타임, 라운드 판정은 `Common`이 처리합니다.
- `lessons/StarterPlayerScripts/StudentSetup.local.luau`: 학생 클라이언트에서 `Common/PlayerCombatClient` 기본 조준, 빈손 주먹 공격, 돌멩이 충전 투척 입력 런타임을 켜는 부트스트랩입니다.
- `lessons/StarterPlayerScripts/11_student_answer.local.luau`: 11일차 마법 클라이언트 입력 코드입니다. 클라이언트는 입력과 요청만 담당하고 데미지, 자원, 라운드 상태는 서버가 판정합니다.

`Common`이 커지면 날짜별 파일이 아니라 개념별 ModuleScript로 나눕니다. 분리 기준은 `docs/ARCH_공통모듈_개념별분리.md`를 따릅니다.

## 2. 누적 월드 구조

```text
Workspace
  OutpostBattleWorld
    Battlefield
      BattlefieldBase
      CoverMarker_*
      SpawnPoint_Blue
      SpawnPoint_Red
      RoundStartButton
    ObjectiveArea
      OutpostCore_*
      TeamSymbol_*
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

학생 스크립트 파일명은 정렬과 회차 판별을 위해 `01_student_answer.luau`, `02_student_answer.luau`처럼 숫자를 붙입니다. 게임 오브젝트 이름은 회차별 이름으로 나누지 않고 `Battlefield`, `ObjectiveArea`, `ItemSpawns`, `Fortification`처럼 도메인 역할을 우선합니다. 번호는 `OutpostGuard_1`, `WallSection_1`처럼 같은 종류를 구분할 때만 씁니다.

## 3. 네이밍 규칙

스크립트 변수는 `타입 축약 접두사 + 고유이름`을 사용합니다. 문자열 이름, 클래스명, Attribute 키는 `ReplicatedStorage/Common/CoreEnums.luau`의 enum 테이블에서 관리합니다.

| 접두사 | 대상 | 예시 |
| --- | --- | --- |
| `svc` | `game:GetService()` 서비스 | `svcWorkspace` |
| `fld` | `Folder` | `fldBattlefield` |
| `part` | `Part`, `SpawnLocation` 또는 `BasePart` | `partBuildButton` |
| `model` | `Model` | `modelGate` |
| `tool` | `Tool` | `toolThrowingStone` |
| `hum` | `Humanoid` | `humOutpostCore` |
| `ival` | `IntValue` | `ivalWood` |
| `click` | `ClickDetector` | `clickDetector` |
| `event` | `RemoteEvent` | `eventFistAttack` |
| `emit` | `ParticleEmitter` | `emitArmorAura` |
| `tbl` | table | `tblOutpostWorld` |
| `bool` | boolean | `boolReady` |
| `int` | integer | `intTimeLeft` |
| `str` | string | `strPlayerName` |

## 4. 실행 순서

1. Roblox Studio에서 수업용 place를 엽니다.
2. Studio Script Sync를 켜고 `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer > StarterPlayerScripts`를 동기화 대상으로 잡습니다.
3. `Script Sync > Sync with Directory`에서 repo의 `lessons` 폴더를 지정합니다. 루트 이름이 디스크에 한 번 포함되므로 `ReplicatedStorage`를 `lessons/ReplicatedStorage`에 연결하지 않습니다.
4. 이미 `lessons/ReplicatedStorage/ReplicatedStorage` 같은 중첩 폴더가 생겼다면 Studio에서 해당 sync를 끊고 `lessons`를 다시 지정합니다.
5. Explorer에서 `ReplicatedStorage/Common`, `ServerScriptService/TeacherSetup`, `StudentRockDesigns`, `StudentLessonConfigs`가 만들어졌는지 확인합니다.
6. `TeacherSetup`은 매일 같은 파일을 사용합니다. Play마다 `Workspace/OutpostBattleWorld`를 새로 만들고, 설정한 회차까지의 기준 구조를 누적 생성합니다.
7. 학생 답안은 연결된 로컬 `.luau` 파일을 수정하고, 수업에서 허용한 데이터 값만 바꿔 Play로 검증합니다.

예를 들어 `3`을 넣으면 월드를 비운 뒤 1~3일차 구조만 다시 만들고, `10`을 넣으면 1~10일차 구조를 다시 만듭니다. 높은 회차를 실행한 뒤 낮은 회차로 내려가도 학생이 월드 안에 만든 오브젝트까지 함께 정리됩니다.

### 진도 조절

일자별로 누적 실행하려면 `lessons/ServerScriptService/TeacherSetup.server.luau` 상단 숫자만 바꿉니다.

```lua
local ACTIVE_LESSON_DAY = 3
```

| 값 | 적용 범위 |
| --- | --- |
| `1` | 1일차 돌멩이 파밍까지 |
| `2` | 1~2일차 |
| `3` | 1~3일차 |
| `12` | 전체 최종전까지 |

`ACTIVE_LESSON_DAY`는 1~12 사이로 보정됩니다. 예를 들어 `12`에서 `3`으로 낮춰도 `OutpostBattleWorld`를 새로 만든 뒤 1~3일차 구조만 생성하므로 수동 삭제가 필요 없습니다.

## 5. 학생 튜닝 장비 규칙

01, 04, 05, 06, 07, 11회차의 장비는 `StarterPack`으로 직접 지급하지 않습니다. `Common`이 `ItemSpawns`에 `FieldItem_*` Tool을 만들고, 플레이어가 클릭해서 줍습니다.

1회차 돌멩이는 `ServerScriptService > StudentRockDesigns` 폴더 안의 학생 ModuleScript가 데이터 table만 `return`합니다. `VariantId`, 생성, 배치, 획득, 데미지 판정은 `Common`이 처리합니다. 학생 ModuleScript 하나가 오타로 실패해도 `pcall(require)`로 격리하고, 그 학생 돌만 기본 돌멩이로 대체합니다. 오류와 보정 내용은 Output과 전장 안 `StudentRockValidationBoard`에 표시됩니다.

```lua
local CM = 1 / 30 -- 1 stud = 30cm 물리 스케일 기준 (센티미터 단위를 Roblox stud 크기로 변환)

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.Slate
appearance.Size = Vector3.new(30, 30, 30) * CM -- 센티미터 단위 입력 (가로 30cm, 세로 30cm, 높이 30cm -> 1.0 stud)
appearance.CollisionShape = Enum.PartType.Ball
appearance.LookShape = "" -- 공식 에셋 팩 링크: https://create.roblox.com/store/asset/17354921094

rock.DisplayName = "불타는 돌"
rock.Appearance = appearance
rock.Trait = "Heavy"
rock.SpawnCount = 3

return rock
```

2~12회차는 `ServerScriptService > StudentLessonConfigs` 폴더 안의 ModuleScript가 설정 table만 `return`합니다. `Common`은 `02_student_answer` 또는 `StudentAnswer02`처럼 ModuleScript 이름의 앞/뒤 숫자로 회차를 판단합니다. 학생 파일은 `require(Common)`이나 `common.install*`을 호출하지 않고, `TeacherSetup`이 Play 시점에 이 ModuleScript들을 읽어 설치합니다.

`Appearance`는 돌의 모양 묶음입니다. `Size`는 실제 게임 기준 크기이자 `LookShape`가 들어갈 최대 크기입니다. `CollisionShape`는 기본 충돌 Part 모양이고, `LookShape`는 그 크기 안에 맞춰 붙는 겉모습 모델입니다. (학생들이 엉뚱한 색상을 임의로 지정해 비주얼을 해치지 못하도록, 서버 측에서 재질에 부합하는 고유 기본 색상이 자동으로 강제 적용됩니다.)

`Damage`, `Speed`, `Cooldown`, `Knockback` 같은 결과값은 학생 코드에 넣지 않습니다. `Common`이 돌의 크기, 재질, 성격을 읽고 서버에서 계산합니다. `SpawnCount`는 1~10으로 제한되며, 스폰 위치는 선생님이 놓은 기준점 주변에 자동 분산됩니다. 학생 코드에는 `SpawnOffset`을 넣지 않습니다.

수업 설명에서는 `1 stud ~= 30cm` 정도로 잡습니다. 학생들이 센티미터 단위를 사용해 직관적으로 크기를 상상할 수 있도록 `CM` 상수를 제공합니다. (돌멩이의 비정형성을 반영하여 부피 계산에 20%의 할인 보정이 적용되며, 일반 들기 한계는 **50kg**, 힘 특화 한계는 **70kg**으로 작동합니다.)

| 센티미터 입력 값 | Studs 크기 변환 | 수업용 느낌 (무게 예시 - Slate 재질) |
| --- | --- | --- |
| `Vector3.new(21, 21, 21) * CM` | `(0.7, 0.7, 0.7)` | 조약돌 (약 20.2kg - 일반 플레이어 들기 가능) |
| `Vector3.new(30, 30, 30) * CM` | `(1.0, 1.0, 1.0)` | 일반적인 돌멩이 (약 58.3kg - 힘 특화 시 들기 가능) |
| `Vector3.new(36, 36, 36) * CM` | `(1.2, 1.2, 1.2)` | 큰 손바위 (약 100.8kg - 너무 무거워서 들 수 없음) |

돌멩이 크기는 `Common.tblEquipmentSizeRule.ThrowingStone` 기준으로 `0.5`~`2.6` studs 안에서 보정됩니다. 투석기 탄환처럼 큰 물체는 별도 규칙(`SiegeStone`)을 둬서 `10` studs까지 허용할 수 있습니다.

돌멩이 `Material`은 자유도를 유지하기 위해 blacklist 방식으로 처리합니다. `Enum.Material.Air`, `Enum.Material.Water`, `Enum.Material.ForceField`처럼 돌 Part에 맞지 않거나 특수 효과성인 재질만 `Enum.Material.Slate`로 되돌리고, 나머지 Material은 가능한 한 그대로 반영합니다.

Roblox Creator Store(크리에이터 상점)에서 공식 무료 모델 팩을 다운받아 다양한 디자인을 테스트해 볼 수 있습니다.
* **공식 무료 모델 팩 다운로드 링크**: [[edu-roblox-ruau] Rock Looks 크리에이터 상점 링크](https://create.roblox.com/store/asset/17354921094)
* **에셋 팩 검색어**: `[edu-roblox-ruau] Rock Looks`
* **모델 Asset ID**: `17354921094`
* **적용 방법 (2가지 중 선택)**:
  1. **동적 자동 로드 (추천)**: 위 공식 에셋 팩 링크로 접속해 무료 **[획득(Get)]** 버튼을 눌러 내 인벤토리에 추가한 다음, 코드에서 `appearance.LookShape = "17354921094"` 처럼 에셋 ID를 직접 적습니다. 서버가 실행 시점에 자동으로 크리에이터 상점에서 모델을 다운로드합니다.
  2. **수동 폴더 임포트**: 다운로드한 모델 팩(Meteor, Skull, Spike, Star 등)을 `ReplicatedStorage > OutpostAssets > RockLooks` 폴더 안에 드래그하여 배치한 뒤, 코드에서 `appearance.LookShape = "Meteor"` 처럼 사용하고 싶은 모델명을 이름으로 참조합니다.

```lua
appearance.LookShape = "Meteor"
```

`Common`은 `RockLooks/Meteor`를 찾아 Handle과 투사체에 겉모습으로 붙입니다. `LookShape` 모델은 `Size` 안으로 맞춰지고, 내부 Script/ModuleScript/LocalScript는 제거됩니다. 충돌과 데미지 판정은 계속 안전한 기본 Part가 맡습니다.

최종전 라운드를 다시 시작하면 플레이어가 들고 있던 `FieldItem_*` 장비는 원래 스폰 위치로 돌아갑니다. 따라서 12회차 플레이테스트에서도 각 팀은 자기 스폰에서 시작한 뒤 맵에 놓인 학생 장비를 다시 파밍해야 합니다.

월드 밖으로 떨어진 파밍 장비는 자동으로 안전한 스폰 마커 중 하나로 돌아옵니다. 던져진 돌멩이도 전장 밖으로 벗어나거나 낙하하면 투척 상태를 정상 종료하고 다시 주울 수 있는 Tool 상태로 재스폰됩니다.

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

## 6. Script Sync Path

| 유형 | Studio sync 대상 | 로컬 경로 |
| --- | --- | --- |
| 공통 모듈 | `ReplicatedStorage` | `lessons/ReplicatedStorage` |
| 준비 코드 | `ServerScriptService` | `lessons/ServerScriptService/TeacherSetup.server.luau` |
| 1회차 학생 돌멩이 데이터 | `ServerScriptService` | `lessons/ServerScriptService/StudentRockDesigns/01_student_answer.luau` |
| 2~12회차 학생 설정 데이터 | `ServerScriptService` | `lessons/ServerScriptService/StudentLessonConfigs/02_student_answer.luau` ~ `12_student_answer.luau` |
| 학생 클라이언트 공통 입력 부트스트랩 | `StarterPlayer > StarterPlayerScripts` | `lessons/StarterPlayerScripts/StudentSetup.local.luau` |
| 마법 RemoteEvent 입력 코드 | `StarterPlayer > StarterPlayerScripts` | `lessons/StarterPlayerScripts/11_student_answer.local.luau` |

Tool 계열 답안도 이제 Tool 내부에 넣지 않습니다. 장비의 생성, 클릭 획득, Backpack 이동은 `Common`이 처리하고, 학생은 설정값만 수정합니다.

## 7. 회차별 생성/보장 대상

| 회차 | 주제 | 공통 setup 보장 대상 | 학생 파일 |
| --- | --- | --- | --- |
| 01 | 기본 조준/주먹/돌 투척/첫 파밍 | `OutpostBattleWorld/Battlefield`, `ObjectiveArea/OutpostCore_*`, `ObjectiveArea/TeamSymbol_*`, `ReplicatedStorage/FistAttack`, `ReplicatedStorage/ThrowingStoneAim`, `ItemSpawn_ThrowingStone_*`, `ServerScriptService/StudentRockDesigns`, `Common/PlayerCombatClient` | `StudentRockDesigns/01_student_answer.luau`, `StarterPlayerScripts/StudentSetup.local.luau` 부트스트랩 |
| 02 | 전초기지 엄폐물 | `OutpostBattleWorld/Battlefield/CoverMarker_*`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/02_student_answer.luau` |
| 03 | 자원 기반 방벽 | `OutpostBattleWorld/BuildArea/BuildButton`, `WallSpawn`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/03_student_answer.luau` |
| 04 | 근접 무기/디바운스 | `ObjectiveArea/DuelGuard_*`, `ItemSpawn_FieldSword_*`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/04_student_answer.luau` |
| 05 | 원거리 무기 | `ObjectiveArea/RangeTarget_*`, `ItemSpawn_FieldBow_*`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/05_student_answer.luau` |
| 06 | 방패 | `ItemSpawn_FieldShield_*`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/06_student_answer.luau` |
| 07 | 갑옷 | `ItemSpawn_FieldArmor_*`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/07_student_answer.luau` |
| 08 | 파괴되는 문 | `OutpostBattleWorld/Fortification/Gate`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/08_student_answer.luau` |
| 09 | 부분 파괴 석벽 | `OutpostBattleWorld/Fortification/StoneWall`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/09_student_answer.luau` |
| 10 | 중장비 | `OutpostBattleWorld/SiegeEngine/LaunchButton`, `LaunchPoint`, `TargetPoint`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/10_student_answer.luau` |
| 11 | 마법 스킬 | `ItemSpawn_MagicStaff_*`, `ObjectiveArea/ArcaneGuard_*`, `ReplicatedStorage/CastMagic`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/11_student_answer.luau`, `StarterPlayerScripts/11_student_answer.local.luau` |
| 12 | 최종 5v5 공방전 | `Battlefield/RoundStartButton`, `SpawnPoint_Blue`, `SpawnPoint_Red`, `Teams/Blue`, `Teams/Red`, `ServerScriptService/StudentLessonConfigs` | `StudentLessonConfigs/12_student_answer.luau` |

## 8. 검증 체크리스트

- `Common` ModuleScript가 `ReplicatedStorage`에 있는가?
- teacher setup 실행 후 `Workspace/OutpostBattleWorld` 아래에 누적 전장 구조가 보이는가?
- Play 시작 시 캐릭터가 배정된 팀의 `Battlefield/SpawnPoint_Blue` 또는 `Battlefield/SpawnPoint_Red`에서 시작하고, 버튼이나 목표물 안에 끼지 않는가?
- Tool 계열 수업은 Play 후 `ItemSpawns/FieldItem_*`가 보이고, 클릭하면 Backpack으로 들어오는가?
- Tool 또는 던져진 돌멩이가 바닥 밖으로 떨어졌을 때 `ItemSpawns` 아래 안전한 위치로 다시 나타나는가?
- 버튼 수업은 ClickDetector 거리 안에서 클릭했는가?
- 데미지 수업은 대상 Model 안에 Humanoid와 HumanoidRootPart가 있는가?
- 라운드 수업은 Workspace Attribute `RoundState`, `TimeLeft`, `RoundWinner`, `RoundEndReason`, `BluePlayerCount`, `RedPlayerCount`가 바뀌는가?
- Output 창에 빨간 오류가 없는가?

## 9. 실전 실습 및 운영 가이드 (1일차 기준)

이 가이드는 Studio Script Sync를 기준으로 `Common`, `TeacherSetup`, 학생 답안을 로컬 repo와 직접 연결해 검증하는 절차입니다.

### 1단계. 필수 뷰와 Script Sync 준비

1. Roblox Studio 상단 메뉴의 **View** 탭에서 **Explorer**, **Properties**, **Output**을 엽니다.
2. `File > Beta Features`에서 **Script Sync**를 켜고 Studio를 재시작합니다.
3. Explorer에서 `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer > StarterPlayerScripts`를 동기화 대상으로 선택합니다.
4. `Script Sync > Sync with Directory`로 repo의 `lessons` 폴더를 지정합니다.
5. `Script Sync > Reveal in Explorer`로 실제 연결 경로가 `lessons/ReplicatedStorage`, `lessons/ServerScriptService`, `lessons/StarterPlayerScripts`인지 확인합니다.

### 2단계. 동기화 결과 확인

```text
ReplicatedStorage
  Common
    Appearance
    BattlefieldLayout
    BuildSystems
    CombatRules
    CoreBlock
    CoreEnums
    CurriculumSetup
    Effect
    EngineEnsure
    FieldItem
    FinalBattle
    Fortification
    MagicSystem
    PlayerCombatClient
    SiegeEngine
    StudentConfig
    ThrowingStone
    WeaponSystems
ServerScriptService
  TeacherSetup
  StudentRockDesigns
    01_student_answer
  StudentLessonConfigs
    02_student_answer
    ...
    12_student_answer
StarterPlayer
  StarterPlayerScripts
    StudentSetup
    11_student_answer
```

`Common/init.luau`는 Studio에서 `Common` ModuleScript 본문이 되고, 같은 폴더의 나머지 `.luau` 파일은 `Common`의 자식 ModuleScript가 됩니다. `TeacherSetup.server.luau`는 `TeacherSetup` Script, `StudentSetup.local.luau`와 `11_student_answer.local.luau`는 LocalScript로 동기화되어야 합니다.

### 3단계. 1일차 월드 생성 검증

1. Studio 상단의 **Play** 버튼을 누릅니다.
2. **Output** 창에 `수업 월드 준비 완료` 문구가 출력되는지 확인합니다.
3. `Workspace/OutpostBattleWorld`와 바닥(`BattlefieldBase`), 팀 스폰(`Battlefield/SpawnPoint_Blue`, `Battlefield/SpawnPoint_Red`), 코어(`OutpostCore_*`), 깃발(`TeamSymbol_*`)이 생성되는지 확인합니다.
4. Play 직후 캐릭터가 배정된 팀 스폰에서 시작하고, 빈손 좌클릭으로 상대 코어나 깃발 위 누적 피해 숫자가 올라가는지 확인합니다.
5. 전장 곳곳에 돌멩이 획득용 `FieldItem_ThrowingStone_*` 도구가 스폰되고, 획득과 충전 투척이 동작하는지 확인합니다.

## 10. 문제 해결

- Tool 클릭이 반응하지 않음: `TeacherSetup`으로 `ItemSpawn_*` 마커가 만들어졌고, 해당 회차 ModuleScript가 `StudentLessonConfigs`에 들어 있는지 확인합니다. 1회차 돌멩이는 `StudentRockDesigns` ModuleScript를 `TeacherSetup`이 읽어 설치합니다.
- 같은 학생 장비가 겹침: 1회차 돌멩이는 `StudentRockDesigns` 안에 학생별 ModuleScript가 있는지 확인합니다. 다른 Tool 회차는 학생별 `VariantId` 또는 `SpawnOffset`을 다르게 설정합니다.
- `WaitForChild`에서 멈춤: `Common`과 단일 `TeacherSetup`을 먼저 실행했는지 확인합니다.
- 오브젝트가 중복됨: teacher setup과 학생 설정 코드는 기본적으로 보장 방식입니다. 전투 중 생긴 투사체/방벽 같은 런타임 생성물은 Stop 후 다시 시작하거나 필요한 경우에만 reset helper로 정리합니다.
- 기본 Baseplate가 남아 있음: Studio 템플릿의 `Workspace/Baseplate`는 선생님 setup이 Play 시점에 제거합니다. 새 place에서 작업하거나 템플릿이 바뀌어도 수업용 `BattlefieldBase`만 남게 하려는 코드 안전장치입니다.
- 클라이언트 요청이 이상함: 클라이언트 값은 신뢰하지 말고 서버 코드에서 거리, 쿨타임, 소유자, 타입을 검사합니다.
- Team Create 충돌: 공통 시스템은 선생님만 수정하고, 학생별 실험은 정해진 설정 테이블과 학생용 모델 범위에서 진행합니다.

## 11. 원본 문서

`docs/curriculum_12_weeks.md`는 12주 계획 문서입니다. 실제 실행 코드와 운영 설명은 `lessons/`와 강의 가이드에서 관리합니다.
