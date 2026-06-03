# ARCH: Common 모듈 개념별 분리 계획

## 목적

`lessons/ReplicatedStorage/Common`은 현재 수업용 게임 엔진, 설정 검증, 외형 처리, 이펙트, 파밍 장비, 전투 규칙, 최종전 운영까지 담고 있다. 1일차 기준으로도 Common은 단순 helper가 아니라 수업 프레임워크가 되었으므로, 날짜가 아니라 큰 기능과 개념 단위로 분리한다.

## 현재 판단

일자별 `teacher_setup`은 제거했고, 선생님 준비 코드는 `lessons/ServerScriptService/TeacherSetup.server.luau` 하나로 정리했다. 따라서 다음 분리 기준도 날짜가 아니라 아래와 같은 도메인 책임이어야 한다.

- 엔진 이름과 상수
- 인스턴스 보장/생성
- 학생 설정 ModuleScript 로딩과 검증
- 외형과 Appearance
- 파티클 Effect
- 전장 파밍 Tool
- 1일차 돌멩이
- 전투 규칙
- 회차별 시스템
- 전체 커리큘럼 setup

## 목표 구조

Roblox Studio에서는 `ReplicatedStorage > Common` ModuleScript를 Facade로 유지한다. 학생/선생 코드의 외부 API는 계속 아래 형태를 유지한다.

```lua
local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))
```

내부만 `Common` ModuleScript의 자식 ModuleScript로 분리한다.

```text
ReplicatedStorage
  Common
    CoreEnums
    EngineEnsure
    StudentConfig
    Appearance
    Effect
    FieldItem
    ThrowingStone
    CombatRules
    BuildSystems
    WeaponSystems
    Fortification
    SiegeEngine
    MagicSystem
    CurriculumSetup
    FinalBattle
```

## Facade 패턴

각 하위 ModuleScript는 독립 table을 반환하기보다 `install(common)` 함수로 Common Facade에 자기 API를 주입한다. 이렇게 하면 학생 코드의 `common.installThrowingStonePickups(...)` 같은 호출을 유지하면서 내부 파일만 나눌 수 있다.

```lua
-- Common
local common = {}

require(script:WaitForChild("CoreEnums")).install(common)
require(script:WaitForChild("StudentConfig")).install(common)
require(script:WaitForChild("Effect")).install(common)

return common
```

```lua
-- Effect
local module = {}

function module.install(common)
    common.eParticleTexture = {
        SPARKLES = "rbxasset://textures/particles/sparkles_main.dds",
    }

    function common.readParticleEffectConfig(tblConfig, strKey, tblValidationMessages, strSourceName)
        -- 구현
    end
end

return module
```

이 방식은 GoF 관점에서 Facade + Builder/Installer 조합이다. 외부에는 단일 Common API를 제공하고, 내부 구현은 개념별 ModuleScript가 담당한다.

## 모듈 경계

| 모듈 | 책임 | 주요 API 예시 |
| --- | --- | --- |
| `CoreEnums` | Roblox 서비스명, ClassName, 논리 이름, Attribute, 라운드 상태 enum | `eEngineServiceSingleton`, `eEnginePhysicalType`, `eEngineLogicalType`, `eEngineAttributeKey` |
| `EngineEnsure` | Instance 생성/보장, 공통 월드 폴더 보장 | `ensureNamedInstance`, `ensureStaticPart`, `ensureClickDetector`, `ensureOutpostBattleWorld` |
| `StudentConfig` | 학생 ModuleScript 로딩, 파일명 기반 회차 라우팅, 설정값 타입 검증, validation message | `readConfigNumber`, `readStudentLessonConfigModule`, `installStudentLessonConfigs`, `addValidationMessage` |
| `Appearance` | 장비 외형, Handle 스타일, RockLooks 모델 fit, LookShape 적용 | `applyToolHandleStudentStyle`, `findRockLookTemplate`, `applyRockLook` |
| `Effect` | ParticleEmitter 설정 읽기, 텍스처 enum, 이펙트 적용 | `eParticleTexture`, `readParticleEffectConfig`, `applyParticleEffect` |
| `FieldItem` | 전장 파밍 Tool 생성, 스폰 마커, 라운드 시작 시 Tool 복귀 | `ensureFieldItemSpawnMarkers`, `installFieldToolPickups`, `resetFieldToolPickupsToWorld` |
| `ThrowingStone` | 1일차 돌멩이 디자인, 스탯 계산, 학생 ModuleScript 로딩, 투척 시스템 | `resolveThrowingStoneDesign`, `installStudentThrowingStoneDesigns`, `installThrowingStoneTool` |
| `CombatRules` | 투사체 판별, 팀/코어 피해 가능 여부 | `isCombatProjectileName`, `canPlayerDamageModel`, `getOutpostObjectiveTeamName` |
| `BuildSystems` | 엄폐물, 자원 방벽 | `installStudentCoverDesign`, `installResourceWallSystem` |
| `WeaponSystems` | 검, 활, 방패, 갑옷 | `installFieldSwordTool`, `installFieldBowTool`, `installFieldShieldTool`, `installFieldArmorTool` |
| `Fortification` | 문, 석벽 체력과 피해 처리 | `installGateDamageSystem`, `installStoneWallDamageSystem` |
| `SiegeEngine` | 투석기 버튼, 탄환 생성, 중장비 쿨타임 | `installSiegeEngineSystem` |
| `MagicSystem` | 지팡이 Tool, `CastMagic`, 마법 서버 판정 | `installMagicStaffTool`, `installMagicServerSystem` |
| `CurriculumSetup` | 1~12일차 전체 기준 오브젝트 보장 | `setupCurriculumWorld`, `ensureCurriculum*` |
| `FinalBattle` | 팀 배정, 라운드 시작/종료, 코어 체력, 승패 판정 | `installFinalBattleSystem` |

## 의존성 방향

하위 모듈은 아래 방향으로만 의존한다.

```text
CoreEnums
  -> EngineEnsure
  -> StudentConfig
  -> Appearance / Effect
  -> FieldItem / CombatRules
  -> ThrowingStone / BuildSystems / WeaponSystems / Fortification / SiegeEngine / MagicSystem
  -> CurriculumSetup / FinalBattle
```

금지한다.

- `CoreEnums`가 다른 모듈을 require
- `StudentConfig`가 특정 Tool/전투 구현 세부를 직접 소유
- `Effect`가 MagicSystem만을 위해 특수화
- `Appearance`가 ThrowingStone 전용 이름으로 굳어지는 것
- `CurriculumSetup`이 학생 답안 파일의 세부 구현을 직접 참조

## 1차 분리 범위

먼저 1일차와 11일차에서 이미 개념 경계가 선명한 모듈부터 분리한다.

1. `CoreEnums`
2. `StudentConfig`
3. `Effect`
4. `Appearance`
5. `FieldItem`
6. `ThrowingStone`
7. `CurriculumSetup`

이 순서가 안전한 이유는 1일차 돌멩이와 2~12일차 학생 설정 ModuleScript가 `StudentConfig`, `Appearance`, `FieldItem`, `ThrowingStone`, `CurriculumSetup`의 연결을 바로 검증해 주기 때문이다.

## 2차 분리 범위

1차 분리 후 다음 도메인을 차례로 옮긴다.

1. `CombatRules`
2. `BuildSystems`
3. `WeaponSystems`
4. `Fortification`
5. `SiegeEngine`
6. `MagicSystem`
7. `FinalBattle`

## Script Sync와 배치

Script Sync 기준으로 `ReplicatedStorage/Common` ModuleScript 아래 자식 ModuleScript도 함께 동기화 대상이 된다. 파일명은 Studio Script Sync 규칙에 맞춰 `.luau`로 둔다.

```text
lessons/ReplicatedStorage/
  Common/
    init.luau
    CoreEnums.luau
    EngineEnsure.luau
    StudentConfig.luau
    Appearance.luau
    Effect.luau
```

`Common/init.luau`는 Studio의 `ReplicatedStorage > Common` ModuleScript 본문이고, 같은 폴더의 나머지 `.luau` 파일은 그 자식 ModuleScript로 동기화된다.

```text
ReplicatedStorage
  Common
    CoreEnums
    EngineEnsure
    StudentConfig
    Appearance
    Effect
```

현재 repo는 붙여넣기 운영 대신 Studio Script Sync를 기준 구조로 삼는다.

## 완료 기준

1차 분리 완료 조건은 다음과 같다.

- 학생/선생 외부 API가 깨지지 않는다.
- `lessons/ServerScriptService/StudentRockDesigns/01_student_answer.luau`가 기존처럼 동작한다.
- `lessons/ServerScriptService/TeacherSetup.server.luau`가 기존처럼 `common.setupCurriculumWorld(game)` 하나만 호출한다.
- `common.eParticleTexture`, `Appearance`, `ThrowingStone` 책임이 서로 섞이지 않는다.
- `Common` Facade 파일은 초기화와 공개 API 결합만 담당한다.

## 보류 항목

- 바로 Rojo 프로젝트 구조로 전환할지 여부
- Script Sync 기준 파일명과 Studio 인스턴스명 확정
- 학생에게 노출할 API 목록 축소 여부
- `Common`을 수업용 public API와 내부 engine API로 나눌지 여부
