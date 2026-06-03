--[[
	Roblox Studio 수업 공통 모듈 (ModuleScript)
	역할: 수업용 헬퍼 함수와 공통 이넘 상수를 제공하는 실제 참조용 공통 스크립트입니다.
	붙여넣기 위치: ReplicatedStorage > ModuleScript 이름 Common (또는 Rojo 동기화)
	사용 방법: local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

	--------------------------------------------------------------------------------
	[1. 교육용 네이밍 컨벤션 (Naming Convention)]
	어린 학생들과 초보자들이 변수의 타입과 역할을 직관적으로 이해하고 오타를 최소화할 수 있도록
	"타입 소문자 + 대문자 시작" 네이밍 컨벤션을 강제 적용합니다.

	1) 기본 규칙
	* 게임 오브젝트(Instance): 타입명을 3~5글자로 축약(원래 5글자 이하면 축약 없이 그대로)한 소문자 접두어 + 고유이름 대문자 시작 (예: svcWorkspace, eventCastMagic)
	* 로직 타입 (Luau 기본 데이터 타입): C++ 표준 약어형 소문자(str, int, float, tbl, bool)를 접두사로 사용
	* 고유이름: 타입명 바로 뒤에 붙이며, 첫 글자를 대문자로 시작하여 이어 씀
	* 일차(Day) 표시:
		- 학생 파일명: 정렬 편의를 위해 숫자를 접두사로 배치 (예: 01_student_answer.module.lua)
		- 게임 오브젝트 이름: 누적 전초기지 공방전 월드에서는 역할 이름을 우선하고, 최초 추가 회차를 구분해야 할 때만 숫자 접미사를 사용
	* enum 기반 객체 호출 선언: local fldBattlefield = ..., local partRock = ...처럼 소문자 축약타입 + 카멜케이스로 작성

	2) 접두사 레퍼런스 표 (Prefix Reference Table)
	* 게임 오브젝트 타입 (타입명을 3~5글자로 축약, 원래 5글자 이하는 그대로)
		- svc           : game:GetService()로 가져오는 엔진 싱글턴 서비스 객체 (예: svcWorkspace)
		- fld           : Folder 인스턴스 (예: fldBattlefield)
		- part          : Part 인스턴스 (예: partBattlefieldBase)
		- model         : Model 인스턴스 (예: modelOutpostCore)
		- tool          : Tool 인스턴스 (예: toolThrowingStone)
		- team          : Team 인스턴스 (예: teamInstance)
		- expl          : Explosion 인스턴스 (예: explMagic)
		- hum           : Humanoid 인스턴스 (예: humOutpostCore)
		- ival          : IntValue 인스턴스 (예: ivalWood)
		- click         : ClickDetector 인스턴스 (예: clickButton)
		- event         : RemoteEvent 인스턴스 (예: eventCastMagic)
		- emit          : ParticleEmitter 인스턴스 (예: emitArmorAura)
	* 로직 기본 타입 (C++ 약어형)
		- bool          : Boolean (참/거짓) (예: boolIsTouched)
		- tbl           : Table (배열/사전) (예: tblDummies)
		- int           : Integer (정수형) (예: intDamage)
		- float         : Float/Double (실수형) (예: floatCooldown)
		- str           : String (문자열) (예: strPlayerName)

	[2. 엔진 타입과 논리 이름의 두 축 (Physical Type vs Logical Type)]
	한 Instance는 엔진 물리 타입과 개발자 논리 이름 축을 동시에 가집니다.
	* eEnginePhysicalType : 엔진이 강제하는 물리(명목) 타입 = .ClassName (예: Part, Humanoid). Instance.new/IsA에 사용.
	* eEngineLogicalType  : 개발자가 .Name으로 표현하는 논리 타입(도메인 종류) (예: Handle, Gate). .ClassName으로 구분 안 되는 종류를 .Name으로 나눔.
	  - RESERVED_ 접두사: 로블록스 엔진이 의미를 고정한 불변 예약 이름(예: Handle, HumanoidRootPart, leaderstats). 값을 바꾸면 엔진 기능이 죽으므로 절대 수정 금지.
	--------------------------------------------------------------------------------
]]

local common = {} -- [의미/의도] 공통 모듈 테이블 정의 ➔ 헬퍼 함수와 상수를 담아 반환하기 위함
local intAutoRockDesignId = 0

-- --------------------------------------------------------------------------------

common.eEngineServiceSingleton = { -- [의미/의도] 엔진 서비스 싱글턴 이넘 정의 ➔ 오타 방지 및 로블록스 서비스 객체 접근 이름을 안전하게 통합 관리하기 위함
	WORKSPACE          = "Workspace",         -- [의미/의도] Workspace 서비스 키 ➔ 게임 월드(파트·폴더) 공간에 접근하기 위함
	PLAYERS            = "Players",           -- [의미/의도] Players 서비스 키 ➔ 접속 플레이어와 leaderstats를 관리하기 위함
	REPLICATED_STORAGE = "ReplicatedStorage", -- [의미/의도] ReplicatedStorage 서비스 키 ➔ 서버·클라이언트 공유 저장소에 접근하기 위함
	SERVER_SCRIPT_SERVICE = "ServerScriptService",
	DEBRIS             = "Debris",            -- [의미/의도] Debris 서비스 키 ➔ 생성물을 일정 시간 후 자동 삭제하기 위함
	TEAMS              = "Teams",             -- [의미/의도] Teams 서비스 키 ➔ 진영(팀)을 등록·관리하기 위함
}

-- --------------------------------------------------------------------------------

common.eEnginePhysicalType = { -- [의미/의도] 물리(명목) 타입 이넘 정의 ➔ 엔진이 강제하는 .ClassName(실체 타입)을 한곳에서 안전하게 관리하기 위함(Instance.new/IsA에 사용)
	PART             = "Part",            -- [의미/의도] Part 클래스명 ➔ 기본 물리 블록 인스턴스를 만들거나 IsA로 검사하기 위함
	BASE_PART        = "BasePart",        -- [의미/의도] BasePart 클래스명 ➔ 물리 파트 계열을 포괄적으로 IsA 검사하기 위함
	MODEL            = "Model",           -- [의미/의도] Model 클래스명 ➔ 여러 파트를 묶는 모델 인스턴스를 만들거나 검사하기 위함
	HUMANOID         = "Humanoid",        -- [의미/의도] Humanoid 클래스명 ➔ 체력·피해 기능을 가진 생명체 컴포넌트를 만들기 위함
	FOLDER           = "Folder",          -- [의미/의도] Folder 클래스명 ➔ 오브젝트를 분류·정리하는 폴더 인스턴스를 만들기 위함
	MODULE_SCRIPT    = "ModuleScript",
	SURFACE_GUI      = "SurfaceGui",
	TEXT_LABEL       = "TextLabel",
	WELD_CONSTRAINT  = "WeldConstraint",
	TOOL             = "Tool",            -- [의미/의도] Tool 클래스명 ➔ 플레이어가 장착하는 도구 인스턴스를 만들기 위함
	INT_VALUE        = "IntValue",        -- [의미/의도] IntValue 클래스명 ➔ 정수 값을 저장하는 인스턴스를 만들기 위함
	CLICK_DETECTOR   = "ClickDetector",   -- [의미/의도] ClickDetector 클래스명 ➔ 마우스 클릭 감지 컴포넌트를 만들기 위함
	REMOTE_EVENT     = "RemoteEvent",     -- [의미/의도] RemoteEvent 클래스명 ➔ 서버·클라이언트 통신 채널 인스턴스를 만들기 위함
	PARTICLE_EMITTER = "ParticleEmitter", -- [의미/의도] ParticleEmitter 클래스명 ➔ 입자 이펙트 컴포넌트를 만들기 위함
	EXPLOSION        = "Explosion",       -- [의미/의도] Explosion 클래스명 ➔ 폭발 이펙트 인스턴스를 만들기 위함
	TEAM             = "Team",            -- [의미/의도] Team 클래스명 ➔ 진영(팀) 인스턴스를 만들기 위함
}

-- --------------------------------------------------------------------------------

common.eEngineLogicalType = { -- [의미/의도] 논리 타입 이넘 정의 ➔ .ClassName으로 구분 안 되는 도메인 종류를 .Name으로 표현(RESERVED_는 엔진이 강제하는 불변 예약 이름이라 값 수정 금지)
	RESERVED_HANDLE             = "Handle",           -- [의미/의도] Handle 예약 이름 ➔ 도구 손잡이 파트로 엔진이 자동 인식하게 하기 위함(수정 금지)
	RESERVED_HUMANOID_ROOT_PART = "HumanoidRootPart", -- [의미/의도] HumanoidRootPart 예약 이름 ➔ 캐릭터 중심 파트로 엔진이 인식하게 하기 위함(수정 금지)
	RESERVED_LEADERSTATS        = "leaderstats",      -- [의미/의도] leaderstats 예약 이름 ➔ 리더보드 통계 폴더로 엔진이 인식하게 하기 위함(수정 금지)

	OUTPOST_BATTLE_WORLD  = "OutpostBattleWorld", -- [의미/의도] 누적 전초기지 공방전 루트 ➔ 1회차부터 같은 5v5 목표전 맵을 이어 쓰기 위함
	BATTLEFIELD           = "Battlefield",        -- [의미/의도] 전투 공간 폴더 ➔ 바닥, 엄폐물, 라운드 버튼, 스폰 지점을 한 전장 안에서 관리하기 위함
	BATTLEFIELD_BASE      = "BattlefieldBase",    -- [의미/의도] 전장 바닥 Part ➔ 첫 회차부터 마지막 회차까지 플레이 가능한 공통 바닥을 유지하기 위함
	BUILD_AREA            = "BuildArea",          -- [의미/의도] 건설/방벽 영역 폴더 ➔ 버튼, 방벽 소환 위치, 학생 건축물을 누적 관리하기 위함
	OBJECTIVE_AREA        = "ObjectiveArea",      -- [의미/의도] 목표물 영역 폴더 ➔ 전초기지 코어, 가드, 표적을 같은 전장 목표 영역에서 관리하기 위함
	ITEM_SPAWN_AREA       = "ItemSpawns",         -- [의미/의도] 파밍 아이템 영역 폴더 ➔ 학생 튜닝 장비를 전장 곳곳에 흩뿌려 관리하기 위함
	OUTPOST_ASSETS        = "OutpostAssets",
	ROCK_LOOKS            = "RockLooks",
	STUDENT_ROCK_VALIDATION_BOARD = "StudentRockValidationBoard",
	STUDENT_ROCK_VALIDATION_GUI = "StudentRockValidationGui",
	STUDENT_ROCK_VALIDATION_TEXT = "StudentRockValidationText",
	STUDENT_ROCK_DESIGNS  = "StudentRockDesigns",
	STUDENT_LESSON_CONFIGS = "StudentLessonConfigs",
	FORTIFICATION         = "Fortification",      -- [의미/의도] 기지 방어 구조물 폴더 ➔ 문/벽을 양 팀 전초기지 방어 시설로 관리하기 위함
	GATE                  = "Gate",               -- [의미/의도] 문 모델 이름 ➔ 기지 방어선의 파괴 가능한 진입 목표물을 식별하기 위함
	STONE_WALL            = "StoneWall",          -- [의미/의도] 석조 벽 모델 이름 ➔ 기지 주변의 부분 파괴 가능한 벽을 식별하기 위함
	SIEGE_ENGINE          = "SiegeEngine",        -- [의미/의도] 중장비 폴더 ➔ 발사 버튼과 탄환 발사 기준점을 한곳에서 관리하기 위함

	OUTPOST_CORE_PREFIX   = "OutpostCore_",  -- [의미/의도] 전초기지 코어 접두사 ➔ 양 팀이 지키고 공격할 핵심 목표를 구분하기 위함
	OUTPOST_GUARD_PREFIX  = "OutpostGuard_", -- [의미/의도] 전초기지 가드 접두사 ➔ 초반 전투 목표를 번호로 구분하기 위함
	DUEL_GUARD_PREFIX     = "DuelGuard_",    -- [의미/의도] 근접 교전 가드 접두사 ➔ 무기 쿨타임 실험 대상을 구분하기 위함
	ARCANE_GUARD_PREFIX   = "ArcaneGuard_",  -- [의미/의도] 마법 교전 가드 접두사 ➔ 광역 스킬 실험 대상을 구분하기 위함
	RANGE_TARGET_PREFIX   = "RangeTarget_",  -- [의미/의도] 원거리 표적 접두사 ➔ 활 명중 피드백 대상을 구분하기 위함

	ITEM_SPAWN_PREFIX     = "ItemSpawn_",    -- [의미/의도] 아이템 스폰 마커 접두사 ➔ 어떤 장비가 어느 위치에 나타나는지 구분하기 위함
	FIELD_ITEM_PREFIX     = "FieldItem_",    -- [의미/의도] 전장 파밍 Tool 접두사 ➔ 월드에 놓인 학생 튜닝 장비를 번호로 구분하기 위함

	THROWING_STONE        = "ThrowingStone", -- [의미/의도] 투척 돌 도구 이름 ➔ 1회차부터 파밍해 쓰는 기본 공격 장비를 식별하기 위함
	FIELD_SWORD           = "FieldSword",    -- [의미/의도] 전장 검 도구 이름 ➔ 쿨타임과 데미지 조정 실험 무기를 식별하기 위함
	FIELD_BOW             = "FieldBow",      -- [의미/의도] 전장 활 도구 이름 ➔ 원거리 투사체 무기를 식별하기 위함
	FIELD_SHIELD          = "FieldShield",   -- [의미/의도] 전장 방패 도구 이름 ➔ 방어 장비를 식별하기 위함
	FIELD_ARMOR           = "FieldArmor",    -- [의미/의도] 전장 갑옷 도구 이름 ➔ 이동 패널티 장비를 식별하기 위함
	MAGIC_STAFF           = "MagicStaff",    -- [의미/의도] 마법 지팡이 도구 이름 ➔ RemoteEvent 기반 스킬 입력 장비를 식별하기 위함

	THROWN_STONE          = "ThrownStone", -- [의미/의도] 던져진 돌 투사체 이름 ➔ 충돌 판정에서 기본 투사체를 구분하기 위함
	PARTICLE_EFFECT       = "ParticleEffect",
	THROWING_STONE_LOOK   = "ThrowingStoneLook",
	PROJECTILE_ALL        = "Projectile",  -- [의미/의도] 공통 투사체 이름 ➔ 방어/충돌 규칙에서 넓게 투사체를 구분하기 위함
	PROJECTILE_ARROW      = "Arrow",       -- [의미/의도] 화살 이름 ➔ 화살 계열 투사체를 구분하기 위함
	PROJECTILE_ARROW_FIELD = "FieldArrow", -- [의미/의도] 전장 화살 이름 ➔ 원거리 무기 수업의 서버 생성 화살을 구분하기 위함
	SIEGE_STONE           = "SiegeStone",   -- [의미/의도] 중장비 탄환 이름 ➔ 문/벽 피해를 주는 무거운 탄환을 구분하기 위함

	COVER_MARKER_PREFIX   = "CoverMarker_",  -- [의미/의도] 엄폐물 배치 마커 접두사 ➔ 학생 건축 위치 힌트를 번호로 구분하기 위함
	COVER_BLOCK_PREFIX    = "CoverBlock_",   -- [의미/의도] 엄폐 블록 접두사 ➔ 엄폐물 모델 내부 블록을 층별로 구분하기 위함
	COVER_STUDENT_PREFIX  = "StudentCover_", -- [의미/의도] 학생 엄폐물 접두사 ➔ 학생이 만든 엄폐 모델을 구분하기 위함
	BUILD_BUTTON          = "BuildButton",   -- [의미/의도] 건설 버튼 이름 ➔ 자원 기반 방벽 생성 입력 장치를 식별하기 위함
	WALL_SPAWN            = "WallSpawn",     -- [의미/의도] 방벽 생성 위치 이름 ➔ 방벽이 실제로 생길 기준 좌표를 식별하기 위함
	WALL_BLOCK_SUFFIX     = "_WallBlock",    -- [의미/의도] 방벽 블록 접미사 ➔ 플레이어가 만든 방벽 블록을 추적하기 위함
	WOOD                  = "Wood",          -- [의미/의도] 나무 자원 이름 ➔ leaderstats에 표시되는 건설 자원 수량을 식별하기 위함

	ARMOR_AURA            = "ArmorAura",    -- [의미/의도] 갑옷 오라 이름 ➔ 장착 이펙트를 찾아 제거하거나 관리하기 위함
	GATE_PLANK_PREFIX     = "GatePlank_",   -- [의미/의도] 문 판자 접두사 ➔ 문을 이루는 개별 판자를 번호로 구분하기 위함
	WALL_SECTION_PREFIX   = "WallSection_", -- [의미/의도] 벽 구역 접두사 ➔ 부분 파괴되는 벽 구역을 번호로 구분하기 위함
	STONE_BLOCK_PREFIX    = "StoneBlock_",  -- [의미/의도] 석조 블록 접두사 ➔ 벽 섹션 내부 블록을 층별로 구분하기 위함
	LAUNCH_BUTTON         = "LaunchButton", -- [의미/의도] 중장비 발사 버튼 이름 ➔ 원격 발사 입력 장치를 식별하기 위함
	LAUNCH_POINT          = "LaunchPoint",  -- [의미/의도] 중장비 탄환 발사 지점 이름 ➔ 탄환 생성 시작 좌표를 식별하기 위함
	TARGET_POINT          = "TargetPoint",  -- [의미/의도] 중장비 탄환 목표 지점 이름 ➔ 탄환이 향할 기준 좌표를 식별하기 위함
	CAST_MAGIC            = "CastMagic",    -- [의미/의도] 마법 시전 RemoteEvent 이름 ➔ 클라이언트 입력과 서버 판정을 연결하기 위함

	TEAM_BLUE             = "Blue",             -- [의미/의도] 청팀 이름 ➔ 전초기지 공방전 팀 구분에 사용하기 위함
	TEAM_RED              = "Red",              -- [의미/의도] 홍팀 이름 ➔ 전초기지 공방전 팀 구분에 사용하기 위함
	ROUND_START_BUTTON    = "RoundStartButton", -- [의미/의도] 라운드 시작 버튼 이름 ➔ 최종 목표전 시작 입력 장치를 식별하기 위함
	SPAWN_POINT_PREFIX    = "SpawnPoint_",      -- [의미/의도] 스폰 지점 접두사 ➔ 팀별 스폰 패드를 이름으로 구분하기 위함
}

-- --------------------------------------------------------------------------------

common.eEngineAttributeKey = { -- [의미/의도] 엔진 Attribute 키 이넘 정의 ➔ 서버/클라이언트가 문자열 키를 공유할 때 오타 없이 같은 계약을 사용하기 위함
	ROUND_STARTER_PLAYER_NAME_RUNTIME = "RoundStarter", -- [의미/의도] RoundStarter 속성 키 ➔ 라운드를 시작한 플레이어 이름을 런타임에 공유하기 위함
	ROUND_STATE           = "RoundState",               -- [의미/의도] RoundState 속성 키 ➔ 라운드 진행 상태를 서버·클라이언트가 공유하기 위함
	TIME_LEFT_RUNTIME      = "TimeLeft",                -- [의미/의도] TimeLeft 속성 키 ➔ 남은 시간을 런타임에 공유하기 위함
	ROUND_WINNER_RUNTIME   = "RoundWinner",
	ROUND_END_REASON_RUNTIME = "RoundEndReason",
	ROUND_BLUE_PLAYER_COUNT_RUNTIME = "BluePlayerCount",
	ROUND_RED_PLAYER_COUNT_RUNTIME = "RedPlayerCount",
	FIELD_ITEM_TYPE        = "FieldItemType",           -- [의미/의도] 파밍 아이템 종류 키 ➔ Tool 이름이 학생 DisplayName으로 바뀌어도 장비 종류를 식별하기 위함
	FIELD_ITEM_DISPLAY_NAME = "FieldItemDisplayName",   -- [의미/의도] 파밍 아이템 표시 이름 키 ➔ 학생이 지은 장비 이름을 런타임에 공유하기 위함
	FIELD_ITEM_HOME_NAME   = "FieldItemHomeName",
	FIELD_ITEM_HOME_POSITION = "FieldItemHomePosition",
}

-- --------------------------------------------------------------------------------

common.eRoundStateValue = { -- [의미/의도] 라운드 상태값 이넘 정의 ➔ ROUND_STATE Attribute에 저장되는 진행 상태 문자열을 한곳에서 안전하게 관리하기 위함
	PREPARING = "Preparing", -- [의미/의도] Preparing 상태 ➔ 라운드 준비 중 단계를 나타내기 위함
	PLAYING   = "Playing",   -- [의미/의도] Playing 상태 ➔ 라운드 진행 중 단계를 나타내기 위함
	FINISHED  = "Finished",  -- [의미/의도] Finished 상태 ➔ 라운드 종료 단계를 나타내기 위함
}

-- --------------------------------------------------------------------------------

common.eStudentLessonConfigKey = {
	COVER_DESIGN  = "CoverDesign",
	RESOURCE_WALL = "ResourceWall",
	SWORD         = "Sword",
	BOW           = "Bow",
	SHIELD        = "Shield",
	ARMOR         = "Armor",
	GATE          = "Gate",
	STONE_WALL    = "StoneWall",
	SIEGE_ENGINE  = "SiegeEngine",
	STAFF         = "Staff",
	MAGIC         = "Magic",
	FINAL_BATTLE  = "FinalBattle",
}

-- --------------------------------------------------------------------------------

function common.hasEngineLogicalNamePrefix(strName, strPrefix) -- [의미/의도] 엔진 논리 이름이 지정된 enum 접두사로 시작하는지 검사 ➔ 부분 문자열 검색이 다른 logical type 경계를 침범하지 않도록 접두사 기준으로만 판정하기 위함
	return strName:sub(1, #strPrefix) == strPrefix -- [의미/의도] 이름 앞부분이 접두사와 정확히 일치하는지 반환 ➔ "TargetPoint"처럼 접두사 경계가 다른 이름을 오인하지 않도록 하기 위함
end

-- --------------------------------------------------------------------------------

function common.applyInstanceProperties(instanceTarget, tblProperties) -- [의미/의도] 인스턴스 속성 묶음 적용 함수 정의 ➔ Size/Position/Material 같은 반복 속성 대입을 한곳에서 처리하기 위함
	if tblProperties then -- [의미/의도] 속성 테이블이 전달된 경우만 처리 ➔ 설정할 속성이 없는 호출도 안전하게 허용하기 위함
		for strPropertyName, valueProperty in pairs(tblProperties) do -- [의미/의도] 속성 이름과 값을 순회 ➔ 테이블에 담긴 설정을 인스턴스에 일괄 반영하기 위함
			instanceTarget[strPropertyName] = valueProperty -- [의미/의도] 대상 인스턴스 속성에 값을 대입 ➔ Roblox Properties 창에서 수동 설정하던 값을 코드로 적용하기 위함
		end
	end

	return instanceTarget -- [의미/의도] 설정된 인스턴스를 반환 ➔ 호출자가 이어서 추가 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.resetNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 삭제 후 재생성 함수 정의 ➔ 수업장을 깨끗하게 초기화해야 하는 예외 상황에 사용하기 위함
	local instanceOld = instanceParent:FindFirstChild(strName) -- [의미/의도] 부모 아래에서 같은 이름의 기존 객체를 검색 ➔ 재생성 전에 이전 객체를 지우기 위함
	if instanceOld then -- [의미/의도] 기존 객체가 있다면 ➔ 이전 수업 실행 흔적을 제거하기 위함
		instanceOld:Destroy() -- [의미/의도] 기존 객체 삭제 ➔ 오래된 파트나 스크립트가 새 설정과 충돌하지 않게 하기 위함
	end

	local instanceNew = Instance.new(strClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성 ➔ 수업 오브젝트를 코드로 만들기 위함
	instanceNew.Name = strName -- [의미/의도] 인스턴스 이름을 지정 ➔ 학생 코드와 Explorer에서 같은 이름으로 찾을 수 있게 하기 위함
	common.applyInstanceProperties(instanceNew, tblProperties) -- [의미/의도] 전달된 속성 묶음을 적용 ➔ 생성 직후 필요한 설정을 한 번에 반영하기 위함
	instanceNew.Parent = instanceParent -- [의미/의도] 인스턴스 부모를 지정 ➔ 올바른 폴더/모델/서비스 아래에 배치하기 위함
	return instanceNew -- [의미/의도] 새 인스턴스 반환 ➔ 호출한 setup 코드에서 변수로 보관할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createOrReplaceInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 기존 인스턴스 대체 생성 호환 함수 정의 ➔ 삭제 재생성이 필요한 경우 기존 호출명을 계속 사용할 수 있게 하기 위함
	return common.resetNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] resetNamedInstance에 위임 ➔ 삭제 재생성 정책을 한곳에서 관리하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 보장 함수 정의 ➔ 누적형 전초기지 월드에서 기존 오브젝트를 지우지 않고 재사용하기 위함
	local instanceTarget = instanceParent:FindFirstChild(strName) -- [의미/의도] 부모 아래에서 같은 이름의 객체 검색 ➔ 이미 만든 콘텐츠를 다음 회차에서도 유지하기 위함
	if instanceTarget and not instanceTarget:IsA(strClassName) then -- [의미/의도] 같은 이름이지만 타입이 다르다면 ➔ 잘못된 오브젝트가 학생 코드 참조를 막지 않게 하기 위함
		instanceTarget:Destroy() -- [의미/의도] 잘못된 타입 객체 삭제 ➔ 올바른 타입으로 다시 보장하기 위함
		instanceTarget = nil -- [의미/의도] 재생성 필요 상태로 초기화 ➔ 아래 생성 분기가 실행되게 하기 위함
	end

	if not instanceTarget then -- [의미/의도] 대상 객체가 없으면 ➔ 새로 필요한 수업 오브젝트를 만들기 위함
		instanceTarget = Instance.new(strClassName) -- [의미/의도] 요청한 타입의 인스턴스 생성 ➔ 누락된 오브젝트를 보강하기 위함
		instanceTarget.Name = strName          -- [의미/의도] 이름 지정 ➔ 학생/시스템 코드가 같은 이름으로 찾을 수 있게 하기 위함
		instanceTarget.Parent = instanceParent -- [의미/의도] 부모 지정 ➔ 누적 전초기지 월드의 올바른 계층에 배치하기 위함
	end

	common.applyInstanceProperties(instanceTarget, tblProperties) -- [의미/의도] 속성 보정 ➔ 기존 객체를 유지하되 크기/위치/재질 같은 기준값은 수업 표준으로 맞추기 위함
	return instanceTarget -- [의미/의도] 보장된 인스턴스 반환 ➔ 호출부에서 이어서 사용할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 보장 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] ensureNamedInstance에 위임 ➔ 삭제 없이 기존 콘텐츠를 재사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] 고정 Part 보장 함수 정의 ➔ 바닥/버튼/마커가 회차마다 삭제되지 않고 누적 유지되도록 하기 위함
	local tblPartProperties = tblProperties or {} -- [의미/의도] 속성 테이블 기본값 준비 ➔ 호출자가 속성을 생략해도 안전하게 처리하기 위함
	tblPartProperties.Anchored = tblPartProperties.Anchored ~= false -- [의미/의도] 기본 Anchored=true 설정 ➔ 명시적으로 false를 준 경우를 제외하고 setup 오브젝트를 고정하기 위함
	return common.ensureNamedInstance(common.eEnginePhysicalType.PART, strName, instanceParent, tblPartProperties) -- [의미/의도] Part 보장 실행 ➔ 기존 Part는 유지하고 필요한 속성만 보정하기 위함
end

-- --------------------------------------------------------------------------------

function common.createStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] 고정 Part 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] ensureStaticPart에 위임 ➔ 같은 이름의 Part가 중복 생성되지 않게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ClickDetector 보장 함수 정의 ➔ 버튼 setup 재실행 시 감지기가 중복 생성되지 않게 하기 위함
	local clickDetector = partParent:FindFirstChildOfClass(common.eEnginePhysicalType.CLICK_DETECTOR) -- [의미/의도] 기존 ClickDetector 검색 ➔ 이미 연결된 클릭 컴포넌트를 재사용하기 위함
	if not clickDetector then -- [의미/의도] 클릭 감지기가 없다면 ➔ 버튼 기능을 새로 추가하기 위함
		clickDetector = Instance.new(common.eEnginePhysicalType.CLICK_DETECTOR) -- [의미/의도] 새 ClickDetector 생성 ➔ Part를 마우스로 클릭 가능한 버튼으로 만들기 위함
		clickDetector.Parent = partParent -- [의미/의도] 클릭 감지기를 대상 Part 아래에 배치 ➔ 해당 Part 클릭 이벤트가 활성화되게 하기 위함
	end

	clickDetector.MaxActivationDistance = intMaxActivationDistance -- [의미/의도] 클릭 가능 거리 보정 ➔ 회차별 버튼 사용 거리 기준을 유지하기 위함
	return clickDetector -- [의미/의도] 보장된 ClickDetector 반환 ➔ 필요하면 호출부에서 추가 설정할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ClickDetector 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ensureClickDetector에 위임 ➔ 감지기 중복 생성을 막기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] Tool과 Handle 보장 함수 정의 ➔ 학생 스크립트나 커스터마이즈가 붙은 Tool을 삭제하지 않고 규격만 보정하기 위함
	local toolTarget = common.ensureNamedInstance(common.eEnginePhysicalType.TOOL, strToolName, instanceParent) -- [의미/의도] Tool 보장 ➔ 기존 장비와 내부 Script를 유지하면서 없으면 생성하기 위함
	toolTarget.RequiresHandle = true -- [의미/의도] Handle 필요 설정 ➔ Roblox 장착 규칙에 맞게 손잡이 파트를 사용하기 위함
	toolTarget.ToolTip = strToolTip  -- [의미/의도] Tool 설명 문구 보정 ➔ 플레이어가 장비 기능을 툴팁으로 확인할 수 있게 하기 위함

	local partHandle = common.ensureNamedInstance(common.eEnginePhysicalType.PART, common.eEngineLogicalType.RESERVED_HANDLE, toolTarget, tblHandleProperties) -- [의미/의도] Handle Part 보장 ➔ Tool이 캐릭터 손에 부착될 기준 파트를 유지 또는 생성하기 위함

	return toolTarget, partHandle -- [의미/의도] Tool과 Handle 반환 ➔ 호출부가 필요한 경우 두 객체를 추가 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] Tool과 Handle 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] ensureToolWithHandle에 위임 ➔ Tool 내부 콘텐츠 삭제를 피하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureHumanoidTarget(strName, instanceParent, tblRootPartProperties, tblHumanoidProperties) -- [의미/의도] Humanoid 목표물 보장 함수 정의 ➔ 전초기지 코어/가드가 회차 재실행 때 삭제되지 않고 기준만 보정되게 하기 위함
	local modelTarget = common.ensureNamedInstance(common.eEnginePhysicalType.MODEL, strName, instanceParent) -- [의미/의도] 목표물 Model 보장 ➔ 몸통 파트와 Humanoid를 하나의 피해 가능 오브젝트로 묶기 위함
	local partHumanoidRoot = common.ensureStaticPart(common.eEngineLogicalType.RESERVED_HUMANOID_ROOT_PART, modelTarget, tblRootPartProperties) -- [의미/의도] HumanoidRootPart 보장 ➔ 데미지 판정과 위치 기준이 되는 중심 파트를 유지 또는 생성하기 위함
	local humTarget = common.ensureNamedInstance(common.eEnginePhysicalType.HUMANOID, common.eEnginePhysicalType.HUMANOID, modelTarget, tblHumanoidProperties) -- [의미/의도] Humanoid 보장 ➔ 목표물이 체력과 피해 처리를 갖게 하기 위함

	return modelTarget, partHumanoidRoot, humTarget -- [의미/의도] 목표물 구성 객체 반환 ➔ 호출부에서 필요 시 세부 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 월드 보장 함수 정의 ➔ 어떤 회차부터 실행해도 같은 5v5 목표전 전장 구조가 유지되게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType

	local fldOutpostBattleWorld = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_BATTLE_WORLD, svcWorkspace) -- [의미/의도] 전초기지 공방전 루트 보장 ➔ 모든 회차 콘텐츠를 하나의 월드 아래에 누적하기 위함
	local fldBattlefield = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.BATTLEFIELD, fldOutpostBattleWorld) -- [의미/의도] 전투 공간 폴더 보장 ➔ 플레이 가능한 중심 전장을 유지하기 위함
	local fldBuildArea = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.BUILD_AREA, fldOutpostBattleWorld) -- [의미/의도] 건설 영역 폴더 보장 ➔ 방벽과 학생 건축물을 누적하기 위함
	local fldObjectiveArea = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.OBJECTIVE_AREA, fldOutpostBattleWorld) -- [의미/의도] 목표물 영역 폴더 보장 ➔ 코어/가드/표적을 누적하기 위함
	local fldItemSpawnArea = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.ITEM_SPAWN_AREA, fldOutpostBattleWorld) -- [의미/의도] 아이템 스폰 영역 보장 ➔ 파밍 장비를 전장 곳곳에 유지하기 위함
	local fldFortification = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.FORTIFICATION, fldOutpostBattleWorld) -- [의미/의도] 방어 구조물 영역 보장 ➔ 문과 벽을 기지 방어 구조로 관리하기 위함
	local fldSiegeEngine = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.SIEGE_ENGINE, fldOutpostBattleWorld) -- [의미/의도] 중장비 폴더 보장 ➔ 발사 버튼과 기준점을 누적 관리하기 위함
	local partBattlefieldBase = common.ensureStaticPart(eLogical.BATTLEFIELD_BASE, fldBattlefield, { -- [의미/의도] 공통 전장 바닥 보장 ➔ 1회차부터 12회차까지 같은 플레이 공간을 유지하기 위함
		Size = Vector3.new(110, 1, 90),
		Position = Vector3.new(0, -0.5, 0),
		Material = Enum.Material.Grass,
	})

	return {
		fldOutpostBattleWorld = fldOutpostBattleWorld,
		fldBattlefield = fldBattlefield,
		fldBuildArea = fldBuildArea,
		fldObjectiveArea = fldObjectiveArea,
		fldItemSpawnArea = fldItemSpawnArea,
		fldFortification = fldFortification,
		fldSiegeEngine = fldSiegeEngine,
		partBattlefieldBase = partBattlefieldBase,
	}
end

-- --------------------------------------------------------------------------------

function common.waitForOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 월드 대기 함수 정의 ➔ 학생/시스템 스크립트가 선생님 setup이 만든 공통 구조를 안전하게 참조하기 위함
	local eLogical = common.eEngineLogicalType
	local fldOutpostBattleWorld = svcWorkspace:WaitForChild(eLogical.OUTPOST_BATTLE_WORLD) -- [의미/의도] 전초기지 공방전 루트 대기 ➔ 누적 전장 구조가 준비된 뒤 진행하기 위함
	local fldBattlefield = fldOutpostBattleWorld:WaitForChild(eLogical.BATTLEFIELD) -- [의미/의도] 전투 공간 폴더 대기 ➔ 바닥/엄폐/스폰/라운드 버튼 참조를 안전하게 하기 위함
	local partBattlefieldBase = fldBattlefield:WaitForChild(eLogical.BATTLEFIELD_BASE) -- [의미/의도] 공통 바닥 Part 대기 ➔ 어떤 회차에서도 같은 플레이 바닥이 준비된 뒤 진행하기 위함
	local fldBuildArea = fldOutpostBattleWorld:WaitForChild(eLogical.BUILD_AREA) -- [의미/의도] 건설 영역 폴더 대기 ➔ 방벽 버튼과 생성 위치를 안전하게 찾기 위함
	local fldObjectiveArea = fldOutpostBattleWorld:WaitForChild(eLogical.OBJECTIVE_AREA) -- [의미/의도] 목표물 영역 폴더 대기 ➔ 코어/가드/표적 참조를 안전하게 하기 위함
	local fldItemSpawnArea = fldOutpostBattleWorld:WaitForChild(eLogical.ITEM_SPAWN_AREA) -- [의미/의도] 아이템 스폰 영역 대기 ➔ 파밍 장비 배치를 안전하게 하기 위함
	local fldFortification = fldOutpostBattleWorld:WaitForChild(eLogical.FORTIFICATION) -- [의미/의도] 방어 구조물 영역 대기 ➔ 문/벽 참조를 안전하게 하기 위함
	local fldSiegeEngine = fldOutpostBattleWorld:WaitForChild(eLogical.SIEGE_ENGINE) -- [의미/의도] 중장비 폴더 대기 ➔ 발사 버튼과 기준점 참조를 안전하게 하기 위함

	return {
		fldOutpostBattleWorld = fldOutpostBattleWorld,
		fldBattlefield = fldBattlefield,
		partBattlefieldBase = partBattlefieldBase,
		fldBuildArea = fldBuildArea,
		fldObjectiveArea = fldObjectiveArea,
		fldItemSpawnArea = fldItemSpawnArea,
		fldFortification = fldFortification,
		fldSiegeEngine = fldSiegeEngine,
	}
end

-- --------------------------------------------------------------------------------

function common.readConfigNumber(tblConfig, strKey, numberDefault, numberMin, numberMax) -- [의미/의도] 학생 설정 숫자 읽기 함수 정의 ➔ 학생이 바꾼 수치를 서버 기준 범위 안으로 제한하기 위함
	local numberValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 값 조회 ➔ 없는 값은 기본값으로 처리하기 위함
	if type(numberValue) ~= "number" then -- [의미/의도] 숫자가 아니면 ➔ 잘못된 설정으로 서버 로직이 깨지지 않게 하기 위함
		return numberDefault
	end

	if numberMin and numberValue < numberMin then -- [의미/의도] 최솟값보다 작으면 ➔ 너무 약하거나 음수인 값으로 규칙이 망가지지 않게 하기 위함
		return numberMin
	end

	if numberMax and numberValue > numberMax then -- [의미/의도] 최댓값보다 크면 ➔ 학생 설정이 게임 밸런스를 벗어나지 않게 하기 위함
		return numberMax
	end

	return numberValue -- [의미/의도] 검증된 숫자 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigInteger(tblConfig, strKey, intDefault, intMin, intMax) -- [의미/의도] 학생 설정 정수 읽기 함수 정의 ➔ 반복 횟수와 개수 설정을 안전한 정수로 제한하기 위함
	return math.floor(common.readConfigNumber(tblConfig, strKey, intDefault, intMin, intMax)) -- [의미/의도] 숫자 설정을 정수로 보정 ➔ for 반복문에 안전하게 넣기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigString(tblConfig, strKey, strDefault) -- [의미/의도] 학생 설정 문자열 읽기 함수 정의 ➔ 이름/색상 같은 문자열 설정을 기본값과 함께 다루기 위함
	local strValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 문자열 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if type(strValue) ~= "string" or strValue == "" then -- [의미/의도] 문자열이 아니거나 비어 있다면 ➔ 잘못된 설정으로 이름이 깨지는 것을 막기 위함
		return strDefault
	end

	return strValue -- [의미/의도] 검증된 문자열 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigVector3(tblConfig, strKey, vectorDefault, vectorMin, vectorMax) -- [의미/의도] 학생 설정 Vector3 읽기 함수 정의 ➔ 위치와 크기 설정을 안전하게 받기 위함
	local vectorValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 Vector3 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if typeof(vectorValue) ~= "Vector3" then -- [의미/의도] Vector3가 아니라면 ➔ 잘못된 값으로 Part 위치/크기 설정이 실패하지 않게 하기 위함
		vectorValue = vectorDefault
	end

	if vectorMin then -- [의미/의도] 최솟값 제한이 있으면 ➔ 음수 크기나 과도하게 낮은 위치를 방지하기 위함
		vectorValue = Vector3.new(
			math.max(vectorValue.X, vectorMin.X),
			math.max(vectorValue.Y, vectorMin.Y),
			math.max(vectorValue.Z, vectorMin.Z)
		)
	end

	if vectorMax then -- [의미/의도] 최댓값 제한이 있으면 ➔ 너무 큰 파트나 맵 밖 배치로 수업장이 깨지는 것을 막기 위함
		vectorValue = Vector3.new(
			math.min(vectorValue.X, vectorMax.X),
			math.min(vectorValue.Y, vectorMax.Y),
			math.min(vectorValue.Z, vectorMax.Z)
		)
	end

	return vectorValue -- [의미/의도] 검증된 Vector3 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigEnumItem(tblConfig, strKey, enumDefault) -- [의미/의도] 학생 설정 EnumItem 읽기 함수 정의 ➔ Material/Shape 같은 엔진 enum 설정을 안전하게 받기 위함
	local enumValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 EnumItem 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if typeof(enumValue) ~= "EnumItem" then -- [의미/의도] EnumItem이 아니라면 ➔ 잘못된 설정으로 속성 대입이 실패하지 않게 하기 위함
		return enumDefault
	end

	local boolValueEnumTypeOk, enumValueType = pcall(function()
		return enumValue.EnumType
	end)
	local boolDefaultEnumTypeOk, enumDefaultType = pcall(function()
		return enumDefault.EnumType
	end)
	if not boolValueEnumTypeOk or not boolDefaultEnumTypeOk or enumValueType ~= enumDefaultType then -- [의미/의도] 기본값과 다른 enum 종류라면 ➔ Material 자리에 PartType 같은 값이 들어가 오류 나는 것을 막기 위함
		return enumDefault
	end

	return enumValue -- [의미/의도] 검증된 EnumItem 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigBrickColor(tblConfig, strKey, strDefaultColor) -- [의미/의도] 학생 설정 BrickColor 읽기 함수 정의 ➔ BrickColor 값 또는 색상 이름을 안전하게 받기 위함
	local valueColor = tblConfig and tblConfig[strKey]
	if typeof(valueColor) == "BrickColor" then
		return valueColor
	end

	local strColorName = common.readConfigString(tblConfig, strKey, strDefaultColor) -- [의미/의도] 색상 이름 읽기 ➔ 비어 있거나 잘못된 문자열을 기본값으로 대체하기 위함
	local boolSuccess, brickColor = pcall(function()
		return BrickColor.new(strColorName)
	end)

	if not boolSuccess then -- [의미/의도] 색상 변환 실패 시 ➔ 색상 오타가 서버 스크립트 오류가 되지 않게 하기 위함
		return BrickColor.new(strDefaultColor)
	end

	return brickColor -- [의미/의도] 검증된 BrickColor 반환 ➔ Part 색상 설정에 사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.readConfigColor3(tblConfig, strKey, colorDefault, tblValidationMessages, strSourceName)
	local valueColor = tblConfig and tblConfig[strKey]
	if valueColor == nil then
		return colorDefault
	end

	if typeof(valueColor) == "Color3" then
		return valueColor
	end

	if typeof(valueColor) == "BrickColor" then
		return valueColor.Color
	end

	if type(valueColor) == "string" then
		local boolSuccess, brickColor = pcall(function()
			return BrickColor.new(valueColor)
		end)
		if boolSuccess then
			return brickColor.Color
		end
	end

	common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Color3.fromRGB(...), BrickColor.new(...), 또는 색상 이름 문자열이어야 해서 기본색으로 보정했습니다.")
	return colorDefault
end

-- --------------------------------------------------------------------------------

function common.createBrickColorFromColor3(colorValue, strDefaultColor)
	local boolSuccess, brickColor = pcall(function()
		return BrickColor.new(colorValue)
	end)
	if boolSuccess then
		return brickColor
	end

	return BrickColor.new(strDefaultColor or "Dark stone grey")
end

-- --------------------------------------------------------------------------------

function common.markRuntimeInstalled(instanceTarget, strAttributeKey) -- [의미/의도] 런타임 시스템 중복 설치 방지 함수 정의 ➔ 같은 버튼/Tool에 이벤트가 여러 번 연결되는 것을 막기 위함
	if instanceTarget:GetAttribute(strAttributeKey) then -- [의미/의도] 이미 설치 표시가 있으면 ➔ 중복 이벤트 연결을 차단하기 위함
		return false
	end

	instanceTarget:SetAttribute(strAttributeKey, true) -- [의미/의도] 설치 완료 표시 저장 ➔ 이후 같은 시스템이 다시 연결되지 않게 하기 위함
	return true -- [의미/의도] 이번 호출에서 설치 가능함을 반환 ➔ 호출부가 이벤트를 연결하게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.clampNumber(numberValue, numberMin, numberMax)
	return math.min(math.max(numberValue, numberMin), numberMax)
end

-- --------------------------------------------------------------------------------

common.tblEquipmentSizeRule = {
	ThrowingStone = {
		Default = Vector3.new(1.2, 1.2, 1.2),
		Min = Vector3.new(0.5, 0.5, 0.5),
		Max = Vector3.new(2.6, 2.6, 2.6),
	},
	SiegeStone = {
		Default = Vector3.new(4, 4, 4),
		Min = Vector3.new(1.5, 1.5, 1.5),
		Max = Vector3.new(10, 10, 10),
	},
}

-- --------------------------------------------------------------------------------

common.tblThrowingStoneMaterialBlockList = {
	Enum.Material.Air,
	Enum.Material.Water,
	Enum.Material.ForceField,
}

-- --------------------------------------------------------------------------------

common.eParticleTexture = {
	EXPLOSION01_CORE_MAIN = "rbxasset://textures/particles/explosion01_core_main.dds",
	EXPLOSION01_IMPLOSION_MAIN = "rbxasset://textures/particles/explosion01_implosion_main.dds",
	EXPLOSION01_SHOCKWAVE_MAIN = "rbxasset://textures/particles/explosion01_shockwave_main.dds",
	EXPLOSION01_SMOKE_MAIN = "rbxasset://textures/particles/explosion01_smoke_main.dds",
	FIRE_MAIN = "rbxasset://textures/particles/fire_main.dds",
	FIRE_SPARKS_MAIN = "rbxasset://textures/particles/fire_sparks_main.dds",
	FORCEFIELD_GLOW_MAIN = "rbxasset://textures/particles/forcefield_glow_main.dds",
	FORCEFIELD_VORTEX_MAIN = "rbxasset://textures/particles/forcefield_vortex_main.dds",
	SMOKE_MAIN = "rbxasset://textures/particles/smoke_main.dds",
	SPARKLES_MAIN = "rbxasset://textures/particles/sparkles_main.dds",
	SQUARE_PARTICLE = "rbxasset://textures/particles/SquareParticle.png",

	SPARKLES = "rbxasset://textures/particles/sparkles_main.dds",
	FIRE = "rbxasset://textures/particles/fire_main.dds",
	SMOKE = "rbxasset://textures/particles/smoke_main.dds",
}

-- --------------------------------------------------------------------------------

function common.isThrowingStoneMaterialBlocked(enumMaterial)
	for _, enumBlockedMaterial in ipairs(common.tblThrowingStoneMaterialBlockList) do
		if enumMaterial == enumBlockedMaterial then
			return true
		end
	end

	return false
end

-- --------------------------------------------------------------------------------

function common.addValidationMessage(tblValidationMessages, strSourceName, strMessage)
	if not tblValidationMessages then
		return
	end

	local strSafeSourceName = strSourceName or "Unknown"
	table.insert(tblValidationMessages, strSafeSourceName .. ": " .. strMessage)
end

-- --------------------------------------------------------------------------------

function common.readConfigTable(tblConfig, strKey, tblDefault, tblValidationMessages, strSourceName)
	local valueTable = tblConfig and tblConfig[strKey]
	if valueTable == nil then
		return tblDefault
	end

	if type(valueTable) ~= "table" then
		common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 table이어야 해서 기본 설정을 사용합니다.")
		return tblDefault
	end

	return valueTable
end

-- --------------------------------------------------------------------------------

function common.mergeConfigTables(tblBase, tblOverride)
	local tblMerged = {}
	if type(tblBase) == "table" then
		for keyConfig, valueConfig in pairs(tblBase) do
			tblMerged[keyConfig] = valueConfig
		end
	end

	if type(tblOverride) == "table" then
		for keyConfig, valueConfig in pairs(tblOverride) do
			tblMerged[keyConfig] = valueConfig
		end
	end

	return tblMerged
end

-- --------------------------------------------------------------------------------

function common.isVector3OutsideRange(vectorValue, vectorMin, vectorMax)
	return vectorValue.X < vectorMin.X or vectorValue.Y < vectorMin.Y or vectorValue.Z < vectorMin.Z
		or vectorValue.X > vectorMax.X or vectorValue.Y > vectorMax.Y or vectorValue.Z > vectorMax.Z
end

-- --------------------------------------------------------------------------------

function common.readThrowingStoneMaterial(tblConfig, strKey, enumDefault, tblValidationMessages, strSourceName)
	local valueMaterial = tblConfig and tblConfig[strKey]
	if valueMaterial ~= nil and typeof(valueMaterial) ~= "EnumItem" then
		common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Enum.Material 값을 써야 해서 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	local enumMaterial = common.readConfigEnumItem(tblConfig, strKey, enumDefault)
	if valueMaterial ~= nil and enumMaterial == enumDefault and valueMaterial ~= enumDefault then
		common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Material 종류가 아니라 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	if common.isThrowingStoneMaterialBlocked(enumMaterial) then
		common.addValidationMessage(tblValidationMessages, strSourceName, tostring(enumMaterial) .. "는 돌 Part에 쓰지 않도록 막아서 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	return enumMaterial
end

-- --------------------------------------------------------------------------------

function common.readEffectNumber(tblEffectConfig, strKey, numberDefault, numberMin, numberMax, tblValidationMessages, strSourceName)
	local numberRaw = tblEffectConfig and tblEffectConfig[strKey]
	if numberRaw ~= nil and type(numberRaw) ~= "number" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 숫자여야 해서 기본값으로 보정했습니다.")
		return numberDefault
	end

	if type(numberRaw) == "number" and (numberRaw < numberMin or numberRaw > numberMax) then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
	end

	return common.readConfigNumber(tblEffectConfig, strKey, numberDefault, numberMin, numberMax)
end

-- --------------------------------------------------------------------------------

function common.readEffectColor(tblEffectConfig, strKey, colorDefault, tblValidationMessages, strSourceName)
	local valueColor = tblEffectConfig and tblEffectConfig[strKey]
	if valueColor == nil then
		return colorDefault
	end

	if typeof(valueColor) == "ColorSequence" then
		return valueColor
	end

	if typeof(valueColor) == "Color3" then
		return ColorSequence.new(valueColor)
	end

	common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 ColorSequence.new(...) 또는 Color3.fromRGB(...) 값이어야 해서 기본색으로 보정했습니다.")
	return colorDefault
end

-- --------------------------------------------------------------------------------

function common.isAllowedParticleTexture(strTexture)
	for _, strAllowedTexture in pairs(common.eParticleTexture) do
		if strTexture == strAllowedTexture then
			return true
		end
	end

	return false
end

-- --------------------------------------------------------------------------------

function common.readEffectTexture(tblEffectConfig, strKey, strDefaultTexture, tblValidationMessages, strSourceName)
	local strTexture = common.readConfigString(tblEffectConfig, strKey, strDefaultTexture)
	if common.isAllowedParticleTexture(strTexture) then
		return strTexture
	end

	common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 common.eParticleTexture 값만 사용할 수 있어 기본 Sparkles로 보정했습니다.")
	return strDefaultTexture
end

-- --------------------------------------------------------------------------------

function common.readEffectBoolean(tblEffectConfig, strKey, boolDefault, tblValidationMessages, strSourceName)
	local boolRaw = tblEffectConfig and tblEffectConfig[strKey]
	if boolRaw == nil then
		return boolDefault
	end

	if type(boolRaw) ~= "boolean" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 true/false 값이어야 해서 기본값으로 보정했습니다.")
		return boolDefault
	end

	return boolRaw
end

-- --------------------------------------------------------------------------------

function common.readEffectEnumItem(tblEffectConfig, strKey, enumDefault, tblValidationMessages, strSourceName)
	local enumRaw = tblEffectConfig and tblEffectConfig[strKey]
	if enumRaw == nil then
		return enumDefault
	end

	local enumValue = common.readConfigEnumItem(tblEffectConfig, strKey, enumDefault)
	if enumValue == enumDefault and enumRaw ~= enumDefault then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 올바른 Roblox Enum 값이어야 해서 기본값으로 보정했습니다.")
	end

	return enumValue
end

-- --------------------------------------------------------------------------------

function common.readEffectVector2(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax, tblValidationMessages, strSourceName)
	local vectorRaw = tblEffectConfig and tblEffectConfig[strKey]
	if vectorRaw == nil then
		return vectorDefault
	end

	if typeof(vectorRaw) ~= "Vector2" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 Vector2.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return vectorDefault
	end

	if vectorMin and (vectorRaw.X < vectorMin.X or vectorRaw.Y < vectorMin.Y) then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 허용 범위 안으로 보정했습니다.")
	end
	if vectorMax and (vectorRaw.X > vectorMax.X or vectorRaw.Y > vectorMax.Y) then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 허용 범위 안으로 보정했습니다.")
	end

	return Vector2.new(
		common.clampNumber(vectorRaw.X, vectorMin and vectorMin.X, vectorMax and vectorMax.X),
		common.clampNumber(vectorRaw.Y, vectorMin and vectorMin.Y, vectorMax and vectorMax.Y)
	)
end

-- --------------------------------------------------------------------------------

function common.readEffectVector3(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax, tblValidationMessages, strSourceName)
	local vectorRaw = tblEffectConfig and tblEffectConfig[strKey]
	if vectorRaw ~= nil and typeof(vectorRaw) ~= "Vector3" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 Vector3.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return vectorDefault
	end

	return common.readConfigVector3(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax)
end

-- --------------------------------------------------------------------------------

function common.createOrderedNumberRange(numberMin, numberMax, strLabel, tblValidationMessages, strSourceName)
	if numberMin <= numberMax then
		return NumberRange.new(numberMin, numberMax)
	end

	common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strLabel .. "Min이 Max보다 커서 두 값을 서로 바꿨습니다.")
	return NumberRange.new(numberMax, numberMin)
end

-- --------------------------------------------------------------------------------

function common.readEffectNumberRange(tblEffectConfig, strKey, strMinKey, strMaxKey, numberDefaultMin, numberDefaultMax, numberMin, numberMax, tblValidationMessages, strSourceName)
	local rangeRaw = tblEffectConfig and tblEffectConfig[strKey]
	if rangeRaw ~= nil then
		if typeof(rangeRaw) ~= "NumberRange" then
			common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 NumberRange.new(...) 값이어야 해서 기본값으로 보정했습니다.")
			return NumberRange.new(numberDefaultMin, numberDefaultMax)
		end

		if rangeRaw.Min < numberMin or rangeRaw.Max > numberMax then
			common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
		end

		return common.createOrderedNumberRange(
			common.clampNumber(rangeRaw.Min, numberMin, numberMax),
			common.clampNumber(rangeRaw.Max, numberMin, numberMax),
			strKey,
			tblValidationMessages,
			strSourceName
		)
	end

	local numberRangeMin = common.readEffectNumber(tblEffectConfig, strMinKey, numberDefaultMin, numberMin, numberMax, tblValidationMessages, strSourceName)
	local numberRangeMax = common.readEffectNumber(tblEffectConfig, strMaxKey, numberDefaultMax, numberMin, numberMax, tblValidationMessages, strSourceName)
	return common.createOrderedNumberRange(numberRangeMin, numberRangeMax, strKey, tblValidationMessages, strSourceName)
end

-- --------------------------------------------------------------------------------

function common.readEffectNumberSequence(tblEffectConfig, strKey, numberDefault, numberMin, numberMax, tblValidationMessages, strSourceName)
	local sequenceRaw = tblEffectConfig and tblEffectConfig[strKey]
	if sequenceRaw == nil then
		return NumberSequence.new(numberDefault)
	end

	if typeof(sequenceRaw) == "NumberSequence" then
		local tblKeypoints = {}
		local boolWasClamped = false
		for _, keypoint in ipairs(sequenceRaw.Keypoints) do
			local numberValue = common.clampNumber(keypoint.Value, numberMin, numberMax)
			local numberMaxEnvelope = math.max(0, math.min(numberValue - numberMin, numberMax - numberValue))
			local numberEnvelope = common.clampNumber(keypoint.Envelope, 0, numberMaxEnvelope)
			if numberValue ~= keypoint.Value or numberEnvelope ~= keypoint.Envelope then
				boolWasClamped = true
			end
			table.insert(tblKeypoints, NumberSequenceKeypoint.new(keypoint.Time, numberValue, numberEnvelope))
		end
		if boolWasClamped then
			common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. " 내부 숫자는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
		end
		return NumberSequence.new(tblKeypoints)
	end

	if type(sequenceRaw) ~= "number" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 숫자 또는 NumberSequence.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return NumberSequence.new(numberDefault)
	end

	if sequenceRaw < numberMin or sequenceRaw > numberMax then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
	end

	return NumberSequence.new(common.clampNumber(sequenceRaw, numberMin, numberMax))
end

-- --------------------------------------------------------------------------------

function common.readParticleEffectConfig(tblConfig, strKey, tblValidationMessages, strSourceName)
	local valueEffect = tblConfig and tblConfig[strKey]
	if valueEffect == nil or valueEffect == false then
		return nil
	end

	if type(valueEffect) ~= "table" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "Effect는 table이어야 해서 효과를 끕니다.")
		return nil
	end

	return {
		Texture = common.readEffectTexture(valueEffect, "Texture", common.eParticleTexture.SPARKLES, tblValidationMessages, strSourceName),
		Rate = common.readEffectNumber(valueEffect, "Rate", 24, 0, 60, tblValidationMessages, strSourceName),
		LightEmission = common.readEffectNumber(valueEffect, "LightEmission", 0.4, 0, 1, tblValidationMessages, strSourceName),
		LightInfluence = common.readEffectNumber(valueEffect, "LightInfluence", 0, 0, 1, tblValidationMessages, strSourceName),
		Brightness = common.readEffectNumber(valueEffect, "Brightness", 1, 0, 10, tblValidationMessages, strSourceName),
		Color = common.readEffectColor(valueEffect, "Color", ColorSequence.new(Color3.fromRGB(255, 112, 36)), tblValidationMessages, strSourceName),
		Transparency = common.readEffectNumberSequence(valueEffect, "Transparency", 0, 0, 1, tblValidationMessages, strSourceName),
		Lifetime = common.readEffectNumberRange(valueEffect, "Lifetime", "LifetimeMin", "LifetimeMax", 0.25, 0.7, 0.05, 3, tblValidationMessages, strSourceName),
		Speed = common.readEffectNumberRange(valueEffect, "Speed", "SpeedMin", "SpeedMax", 0.5, 2, 0, 20, tblValidationMessages, strSourceName),
		Size = common.readEffectNumberSequence(valueEffect, "Size", 0.35, 0.05, 3, tblValidationMessages, strSourceName),
		SpreadAngle = common.readEffectVector2(valueEffect, "SpreadAngle", Vector2.new(
			common.readEffectNumber(valueEffect, "SpreadX", 20, 0, 180, tblValidationMessages, strSourceName),
			common.readEffectNumber(valueEffect, "SpreadY", 20, 0, 180, tblValidationMessages, strSourceName)
		), Vector2.new(0, 0), Vector2.new(180, 180), tblValidationMessages, strSourceName),
		Acceleration = common.readEffectVector3(valueEffect, "Acceleration", Vector3.new(0, 0, 0), Vector3.new(-50, -50, -50), Vector3.new(50, 50, 50), tblValidationMessages, strSourceName),
		Drag = common.readEffectNumber(valueEffect, "Drag", 0, 0, 20, tblValidationMessages, strSourceName),
		Rotation = common.readEffectNumberRange(valueEffect, "Rotation", "RotationMin", "RotationMax", 0, 0, -360, 360, tblValidationMessages, strSourceName),
		RotSpeed = common.readEffectNumberRange(valueEffect, "RotSpeed", "RotSpeedMin", "RotSpeedMax", 0, 0, -360, 360, tblValidationMessages, strSourceName),
		VelocityInheritance = common.readEffectNumber(valueEffect, "VelocityInheritance", 0, 0, 1, tblValidationMessages, strSourceName),
		ZOffset = common.readEffectNumber(valueEffect, "ZOffset", 0, -5, 5, tblValidationMessages, strSourceName),
		TimeScale = common.readEffectNumber(valueEffect, "TimeScale", 1, 0, 2, tblValidationMessages, strSourceName),
		Shape = common.readEffectEnumItem(valueEffect, "Shape", Enum.ParticleEmitterShape.Sphere, tblValidationMessages, strSourceName),
		ShapeStyle = common.readEffectEnumItem(valueEffect, "ShapeStyle", Enum.ParticleEmitterShapeStyle.Surface, tblValidationMessages, strSourceName),
		ShapeInOut = common.readEffectEnumItem(valueEffect, "ShapeInOut", Enum.ParticleEmitterShapeInOut.Outward, tblValidationMessages, strSourceName),
		ShapePartial = common.readEffectNumber(valueEffect, "ShapePartial", 1, 0, 1, tblValidationMessages, strSourceName),
		EmissionDirection = common.readEffectEnumItem(valueEffect, "EmissionDirection", Enum.NormalId.Top, tblValidationMessages, strSourceName),
		Orientation = common.readEffectEnumItem(valueEffect, "Orientation", Enum.ParticleOrientation.FacingCamera, tblValidationMessages, strSourceName),
		LockedToPart = common.readEffectBoolean(valueEffect, "LockedToPart", false, tblValidationMessages, strSourceName),
	}
end

-- --------------------------------------------------------------------------------

function common.readEquipmentSize(tblConfig, strKey, strEquipmentRuleName, tblValidationMessages, strSourceName)
	local tblSizeRule = common.tblEquipmentSizeRule[strEquipmentRuleName]
	local vectorDefault = tblSizeRule.Default
	local vectorMin = tblSizeRule.Min
	local vectorMax = tblSizeRule.Max
	local valueSize = tblConfig and tblConfig[strKey]

	if valueSize ~= nil and typeof(valueSize) ~= "Vector3" then
		common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Vector3.new(...) 값이어야 해서 기본 크기로 보정했습니다.")
		return vectorDefault
	end

	if typeof(valueSize) == "Vector3" and common.isVector3OutsideRange(valueSize, vectorMin, vectorMax) then
		common.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 장비 기준 범위를 벗어나 " .. tostring(vectorMin) .. " ~ " .. tostring(vectorMax) .. " 안으로 보정했습니다.")
	end

	return common.readConfigVector3(tblConfig, strKey, vectorDefault, vectorMin, vectorMax)
end

-- --------------------------------------------------------------------------------

function common.hashTextToInteger(strText)
	local intHash = 0
	for index = 1, #strText do
		intHash = (intHash * 31 + string.byte(strText, index)) % 2147483647
	end

	return intHash
end

-- --------------------------------------------------------------------------------

function common.createFlatSpawnJitter(strSeedText, intIndex, numberRadius)
	if numberRadius <= 0 then
		return Vector3.new(0, 0, 0)
	end

	local randomJitter = Random.new(common.hashTextToInteger(strSeedText .. "_" .. intIndex))
	local numberDistance = math.sqrt(randomJitter:NextNumber()) * numberRadius
	local numberAngle = randomJitter:NextNumber() * math.pi * 2
	return Vector3.new(math.cos(numberAngle) * numberDistance, 0, math.sin(numberAngle) * numberDistance)
end

-- --------------------------------------------------------------------------------

function common.createAutoRockVariantId()
	intAutoRockDesignId += 1
	return "RockAuto_" .. intAutoRockDesignId
end

-- --------------------------------------------------------------------------------

function common.createRockDesign(strDisplayName) -- [의미/의도] 학생용 돌멩이 디자인 객체 생성 함수 정의 ➔ 학생마다 독립된 table을 받아 = 대입으로 외형과 컨셉만 바꾸게 하기 위함
	local strSafeDisplayName = common.readConfigString({DisplayName = strDisplayName}, "DisplayName", "전장 돌멩이")
	return {
		DesignKind = "ThrowingStone",
		VariantId = common.createAutoRockVariantId(),
		DisplayName = strSafeDisplayName,
		SpawnCount = 3,
		SpawnRadius = 4,
		Appearance = {
			BrickColor = BrickColor.new("Dark stone grey"),
			Material = Enum.Material.Slate,
			Size = Vector3.new(1.2, 1.2, 1.2),
			CollisionShape = Enum.PartType.Ball,
			LookShape = "",
		},
		Trait = "Balanced",
	}
end

-- --------------------------------------------------------------------------------

function common.getThrowingStoneMaterialProfile(enumMaterial)
	if enumMaterial == Enum.Material.Metal then
		return {Mass = 1.45, Hardness = 1.2}
	elseif enumMaterial == Enum.Material.Wood then
		return {Mass = 0.7, Hardness = 0.75}
	elseif enumMaterial == Enum.Material.Neon then
		return {Mass = 0.85, Hardness = 0.8}
	elseif enumMaterial == Enum.Material.Ice then
		return {Mass = 0.8, Hardness = 1}
	elseif enumMaterial == Enum.Material.Concrete then
		return {Mass = 1.25, Hardness = 1.05}
	end

	return {Mass = 1, Hardness = 1}
end

-- --------------------------------------------------------------------------------

function common.getThrowingStoneTraitProfile(strTrait)
	if strTrait == "Heavy" then
		return {Mass = 1.35, Hardness = 1.1, Speed = 0.82, Cooldown = 1.18, Knockback = 1.25}
	elseif strTrait == "Light" then
		return {Mass = 0.75, Hardness = 0.9, Speed = 1.18, Cooldown = 0.88, Knockback = 0.8}
	elseif strTrait == "Bouncy" then
		return {Mass = 0.95, Hardness = 0.85, Speed = 1, Cooldown = 1, Knockback = 1.35}
	elseif strTrait == "Sharp" then
		return {Mass = 1, Hardness = 1.25, Speed = 0.95, Cooldown = 1.12, Knockback = 0.95}
	end

	return {Mass = 1, Hardness = 1, Speed = 1, Cooldown = 1, Knockback = 1}
end

-- --------------------------------------------------------------------------------

function common.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)
	local tblMaterialProfile = common.getThrowingStoneMaterialProfile(enumMaterial)
	local tblTraitProfile = common.getThrowingStoneTraitProfile(strTrait)
	local numberVolume = vectorSize.X * vectorSize.Y * vectorSize.Z
	local numberSizeMass = common.clampNumber(numberVolume / 1.728, 0.25, 5)
	local numberMass = numberSizeMass * tblMaterialProfile.Mass * tblTraitProfile.Mass
	local numberHardness = tblMaterialProfile.Hardness * tblTraitProfile.Hardness

	return {
		Damage = common.clampNumber(9 + numberMass * numberHardness * 5.5, 8, 30),
		Cooldown = common.clampNumber((0.55 + numberMass * 0.22) * tblTraitProfile.Cooldown, 0.45, 2.4),
		Speed = common.clampNumber((105 / math.sqrt(numberMass)) * tblTraitProfile.Speed, 45, 135),
		Arc = common.clampNumber(18 - numberMass * 1.8, 5, 35),
		KnockbackForward = common.clampNumber((28 + numberMass * 10) * tblTraitProfile.Knockback, 18, 80),
		KnockbackUp = common.clampNumber(12 + numberMass * 3, 8, 35),
		Lifetime = common.clampNumber(4 + numberMass * 0.35, 3, 8),
	}
end

-- --------------------------------------------------------------------------------

function common.resolveThrowingStoneDesign(tblConfig, tblValidationMessages, strSourceName)
	local strVariantId = tblConfig and tblConfig.VariantId
	if type(strVariantId) ~= "string" or strVariantId == "" then
		strVariantId = common.createAutoRockVariantId()
	end

	local tblAppearance = common.readConfigTable(tblConfig, "Appearance", nil, tblValidationMessages, strSourceName)
	local tblAppearanceConfig = common.mergeConfigTables(tblConfig, tblAppearance)
	local vectorSize = common.readEquipmentSize(tblAppearanceConfig, "Size", "ThrowingStone", tblValidationMessages, strSourceName)
	if tblAppearanceConfig and tblAppearanceConfig.Size == nil and tblAppearanceConfig.CollisionSize ~= nil then
		vectorSize = common.readEquipmentSize(tblAppearanceConfig, "CollisionSize", "ThrowingStone", tblValidationMessages, strSourceName)
	end
	local enumMaterial = common.readThrowingStoneMaterial(tblAppearanceConfig, "Material", Enum.Material.Slate, tblValidationMessages, strSourceName)
	local enumShape = common.readConfigEnumItem(tblAppearanceConfig, "CollisionShape", Enum.PartType.Ball)
	local valueShape = tblAppearanceConfig and tblAppearanceConfig.CollisionShape
	if tblAppearanceConfig and tblAppearanceConfig.CollisionShape == nil and tblAppearanceConfig.Shape ~= nil then
		enumShape = common.readConfigEnumItem(tblAppearanceConfig, "Shape", Enum.PartType.Ball)
		valueShape = tblAppearanceConfig.Shape
	end
	if valueShape ~= nil and enumShape == Enum.PartType.Ball and valueShape ~= Enum.PartType.Ball then
		common.addValidationMessage(tblValidationMessages, strSourceName, "CollisionShape는 Enum.PartType 값을 써야 해서 Ball로 보정했습니다.")
	end
	local brickColor = common.readConfigBrickColor(tblAppearanceConfig, "BrickColor", "Dark stone grey")
	local colorProjectile = brickColor.Color
	if tblAppearanceConfig and tblAppearanceConfig.Color ~= nil then
		colorProjectile = common.readConfigColor3(tblAppearanceConfig, "Color", colorProjectile, tblValidationMessages, strSourceName)
		brickColor = common.createBrickColorFromColor3(colorProjectile)
	end
	local strTrait = common.readConfigString(tblConfig, "Trait", "Balanced")
	local strLookShape = common.readConfigString(tblAppearanceConfig, "LookShape", "")
	if strLookShape == "" then
		strLookShape = common.readConfigString(tblAppearanceConfig, "Look", "")
	end
	if strLookShape ~= "" and not common.findRockLookTemplate(strLookShape) then
		common.addValidationMessage(tblValidationMessages, strSourceName, "LookShape '" .. strLookShape .. "'를 ReplicatedStorage/OutpostAssets/RockLooks에서 찾지 못해 기본 모양을 사용합니다.")
	end
	local valueSpawnCount = tblConfig and tblConfig.SpawnCount
	if type(valueSpawnCount) == "number" and (valueSpawnCount < 1 or valueSpawnCount > 10) then
		common.addValidationMessage(tblValidationMessages, strSourceName, "SpawnCount는 1~10 범위로 보정했습니다.")
	elseif valueSpawnCount ~= nil and type(valueSpawnCount) ~= "number" then
		common.addValidationMessage(tblValidationMessages, strSourceName, "SpawnCount는 숫자여야 해서 기본 3으로 보정했습니다.")
	end
	local tblStats = common.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)

	return {
		VariantId = strVariantId,
		DisplayName = common.readConfigString(tblConfig, "DisplayName", "전장 돌멩이"),
		SpawnCount = common.readConfigInteger(tblConfig, "SpawnCount", 3, 1, 10),
		SpawnOffset = common.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8)),
		SpawnRadius = common.readConfigNumber(tblConfig, "SpawnRadius", 4, 0, 8),
		Damage = tblStats.Damage,
		Cooldown = tblStats.Cooldown,
		Speed = tblStats.Speed,
		Arc = tblStats.Arc,
		KnockbackForward = tblStats.KnockbackForward,
		KnockbackUp = tblStats.KnockbackUp,
		Lifetime = tblStats.Lifetime,
		LookShape = strLookShape,
		Look = strLookShape,
		ProjectileSize = vectorSize,
		ProjectileMaterial = enumMaterial,
		ProjectileBrickColor = brickColor,
		ProjectileColor = colorProjectile,
		ProjectileShape = enumShape,
		Handle = {
			Size = vectorSize,
			Material = enumMaterial,
			BrickColor = brickColor,
			Color = colorProjectile,
			Shape = enumShape,
		},
	}
end

-- --------------------------------------------------------------------------------

function common.applyToolHandleStudentStyle(toolTarget, tblConfig) -- [의미/의도] Tool Handle 학생 스타일 적용 함수 정의 ➔ 학생이 외형만 바꿀 수 있게 크기/재질/색을 제한적으로 반영하기 위함
	local tblHandleConfig = tblConfig and tblConfig.Handle or {} -- [의미/의도] Handle 설정 테이블 준비 ➔ 학생이 생략한 값은 기존 기본값을 쓰기 위함
	local partHandle = common.ensureNamedInstance(common.eEnginePhysicalType.PART, common.eEngineLogicalType.RESERVED_HANDLE, toolTarget)
	partHandle.Size = common.readConfigVector3(tblHandleConfig, "Size", partHandle.Size, Vector3.new(0.2, 0.2, 0.2), Vector3.new(8, 8, 8))
	partHandle.Material = common.readConfigEnumItem(tblHandleConfig, "Material", partHandle.Material)
	local brickHandleColor = common.readConfigBrickColor(tblHandleConfig, "BrickColor", partHandle.BrickColor.Name)
	local colorHandle = brickHandleColor.Color
	if tblHandleConfig.Color ~= nil then
		colorHandle = common.readConfigColor3(tblHandleConfig, "Color", colorHandle)
		brickHandleColor = common.createBrickColorFromColor3(colorHandle, partHandle.BrickColor.Name)
	end

	partHandle.BrickColor = brickHandleColor
	partHandle.Color = colorHandle
	partHandle.Shape = common.readConfigEnumItem(tblHandleConfig, "Shape", partHandle.Shape)
	return partHandle
end

-- --------------------------------------------------------------------------------

function common.findRockLookTemplate(strLook)
	if type(strLook) ~= "string" or strLook == "" then
		return nil
	end

	local eLogical = common.eEngineLogicalType
	local svcReplicatedStorage = game:GetService(common.eEngineServiceSingleton.REPLICATED_STORAGE)
	local fldOutpostAssets = svcReplicatedStorage:FindFirstChild(eLogical.OUTPOST_ASSETS)
	local fldRockLooks = fldOutpostAssets and fldOutpostAssets:FindFirstChild(eLogical.ROCK_LOOKS)
	if not fldRockLooks then
		return nil
	end

	return fldRockLooks:FindFirstChild(strLook)
end

-- --------------------------------------------------------------------------------

function common.removeLuaSourceDescendants(instanceTarget)
	for _, instanceDescendant in ipairs(instanceTarget:GetDescendants()) do
		if instanceDescendant:IsA("LuaSourceContainer") then
			instanceDescendant:Destroy()
		end
	end
end

-- --------------------------------------------------------------------------------

function common.calculateFitScaleWithinBounds(vectorSourceSize, vectorTargetSize)
	if vectorSourceSize.X <= 0 or vectorSourceSize.Y <= 0 or vectorSourceSize.Z <= 0 then
		return 1
	end

	return math.min(
		vectorTargetSize.X / vectorSourceSize.X,
		vectorTargetSize.Y / vectorSourceSize.Y,
		vectorTargetSize.Z / vectorSourceSize.Z
	)
end

-- --------------------------------------------------------------------------------

function common.fitBasePartWithinBounds(partVisual, vectorTargetSize)
	local numberScale = common.calculateFitScaleWithinBounds(partVisual.Size, vectorTargetSize)
	if numberScale <= 0 then
		return false
	end

	partVisual.Size = partVisual.Size * numberScale
	return true
end

-- --------------------------------------------------------------------------------

function common.fitModelWithinBounds(modelVisual, vectorTargetSize)
	local _, vectorBoundsSize = modelVisual:GetBoundingBox()
	local numberScale = common.calculateFitScaleWithinBounds(vectorBoundsSize, vectorTargetSize)
	if numberScale <= 0 then
		return false
	end

	local boolSuccess = pcall(function()
		modelVisual:ScaleTo(modelVisual:GetScale() * numberScale)
	end)
	if not boolSuccess then
		return false
	end

	return true
end

-- --------------------------------------------------------------------------------

function common.pivotModelBoundsToTarget(modelVisual, cframeTarget)
	local cframePivot = modelVisual:GetPivot()
	local cframeBounds = modelVisual:GetBoundingBox()
	local cframeBoundsFromPivot = cframePivot:ToObjectSpace(cframeBounds)
	modelVisual:PivotTo(cframeTarget * cframeBoundsFromPivot:Inverse())
end

-- --------------------------------------------------------------------------------

function common.prepareRockLookPart(partVisual, partTarget, boolKeepCurrentCFrame)
	partVisual.Anchored = false
	partVisual.CanCollide = false
	partVisual.CanTouch = false
	partVisual.CanQuery = false
	partVisual.Massless = true
	if not boolKeepCurrentCFrame then
		partVisual.CFrame = partTarget.CFrame
	end

	local weldVisual = Instance.new(common.eEnginePhysicalType.WELD_CONSTRAINT)
	weldVisual.Part0 = partTarget
	weldVisual.Part1 = partVisual
	weldVisual.Parent = partVisual
end

-- --------------------------------------------------------------------------------

function common.clearRockLook(partTarget)
	local instanceOldLook = partTarget:FindFirstChild(common.eEngineLogicalType.THROWING_STONE_LOOK)
	if instanceOldLook then
		instanceOldLook:Destroy()
	end
end

-- --------------------------------------------------------------------------------

function common.applyRockLook(partTarget, strLookShape)
	common.clearRockLook(partTarget)

	local instanceTemplate = common.findRockLookTemplate(strLookShape)
	if not instanceTemplate then
		partTarget.Transparency = 0
		return
	end

	local instanceLook = instanceTemplate:Clone()
	instanceLook.Name = common.eEngineLogicalType.THROWING_STONE_LOOK
	common.removeLuaSourceDescendants(instanceLook)
	instanceLook.Parent = partTarget
	partTarget.Transparency = 1

	if instanceLook:IsA(common.eEnginePhysicalType.BASE_PART) then
		if not common.fitBasePartWithinBounds(instanceLook, partTarget.Size) then
			instanceLook:Destroy()
			partTarget.Transparency = 0
			return
		end
		common.prepareRockLookPart(instanceLook, partTarget)
		return
	end

	if instanceLook:IsA(common.eEnginePhysicalType.MODEL) then
		if not common.fitModelWithinBounds(instanceLook, partTarget.Size) then
			instanceLook:Destroy()
			partTarget.Transparency = 0
			return
		end
		common.pivotModelBoundsToTarget(instanceLook, partTarget.CFrame)
		for _, instanceDescendant in ipairs(instanceLook:GetDescendants()) do
			if instanceDescendant:IsA(common.eEnginePhysicalType.BASE_PART) then
				common.prepareRockLookPart(instanceDescendant, partTarget, true)
			end
		end
		return
	end

	instanceLook:Destroy()
	partTarget.Transparency = 0
end

-- --------------------------------------------------------------------------------

function common.applyParticleEffect(partTarget, tblEffectConfig)
	local emitEffect = partTarget:FindFirstChild(common.eEngineLogicalType.PARTICLE_EFFECT)
	if not tblEffectConfig then
		if emitEffect then
			emitEffect:Destroy()
		end
		return
	end

	emitEffect = common.ensureNamedInstance(common.eEnginePhysicalType.PARTICLE_EMITTER, common.eEngineLogicalType.PARTICLE_EFFECT, partTarget)
	emitEffect.Enabled = true
	emitEffect.Texture = tblEffectConfig.Texture
	emitEffect.LockedToPart = tblEffectConfig.LockedToPart
	emitEffect.SpreadAngle = tblEffectConfig.SpreadAngle
	emitEffect.Lifetime = tblEffectConfig.Lifetime
	emitEffect.Speed = tblEffectConfig.Speed
	emitEffect.Size = tblEffectConfig.Size
	emitEffect.Transparency = tblEffectConfig.Transparency
	emitEffect.Rate = tblEffectConfig.Rate
	emitEffect.LightEmission = tblEffectConfig.LightEmission
	emitEffect.LightInfluence = tblEffectConfig.LightInfluence
	emitEffect.Brightness = tblEffectConfig.Brightness
	emitEffect.Color = tblEffectConfig.Color
	emitEffect.Acceleration = tblEffectConfig.Acceleration
	emitEffect.Drag = tblEffectConfig.Drag
	emitEffect.Rotation = tblEffectConfig.Rotation
	emitEffect.RotSpeed = tblEffectConfig.RotSpeed
	emitEffect.VelocityInheritance = tblEffectConfig.VelocityInheritance
	emitEffect.ZOffset = tblEffectConfig.ZOffset
	emitEffect.TimeScale = tblEffectConfig.TimeScale
	emitEffect.Shape = tblEffectConfig.Shape
	emitEffect.ShapeStyle = tblEffectConfig.ShapeStyle
	emitEffect.ShapeInOut = tblEffectConfig.ShapeInOut
	emitEffect.ShapePartial = tblEffectConfig.ShapePartial
	emitEffect.EmissionDirection = tblEffectConfig.EmissionDirection
	emitEffect.Orientation = tblEffectConfig.Orientation
end

-- --------------------------------------------------------------------------------

function common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, strToolName, tblSpawnPositions, strColorName) -- [의미/의도] 전장 아이템 스폰 마커 보장 함수 정의 ➔ 학생 튜닝 장비가 어디에 나타날지 선생 코드에서 지도처럼 배치하기 위함
	local eLogical = common.eEngineLogicalType
	local brickColor = BrickColor.new(strColorName or "Bright yellow")

	for index, vectorPosition in ipairs(tblSpawnPositions) do
		common.ensureStaticPart(eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_" .. index, fldItemSpawnArea, {
			Size = Vector3.new(2, 0.2, 2),
			Position = vectorPosition,
			Transparency = 0.35,
			BrickColor = brickColor,
		})
	end
end

-- --------------------------------------------------------------------------------

function common.formatStudentRockValidationText(tblValidationMessages)
	if #tblValidationMessages == 0 then
		return "돌멩이 설정 검사 완료\n오류나 보정 항목이 없습니다."
	end

	local tblLines = {"돌멩이 설정 검사 결과"}
	for index, strMessage in ipairs(tblValidationMessages) do
		if index <= 10 then
			table.insert(tblLines, index .. ". " .. strMessage)
		end
	end
	if #tblValidationMessages > 10 then
		table.insert(tblLines, "...외 " .. (#tblValidationMessages - 10) .. "건은 Output 창을 확인하세요.")
	end

	return table.concat(tblLines, "\n")
end

-- --------------------------------------------------------------------------------

function common.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local partBoard = common.ensureStaticPart(eLogical.STUDENT_ROCK_VALIDATION_BOARD, tblOutpostWorld.fldBattlefield, {
		Size = Vector3.new(36, 12, 1),
		Position = Vector3.new(0, 9, -46),
		CanCollide = false,
		Material = Enum.Material.SmoothPlastic,
		BrickColor = BrickColor.new(#tblValidationMessages == 0 and "Lime green" or "Bright yellow"),
	})

	local guiBoard = common.ensureNamedInstance(ePhysical.SURFACE_GUI, eLogical.STUDENT_ROCK_VALIDATION_GUI, partBoard, {
		Face = Enum.NormalId.Front,
		CanvasSize = Vector2.new(1200, 420),
	})
	local labelBoard = common.ensureNamedInstance(ePhysical.TEXT_LABEL, eLogical.STUDENT_ROCK_VALIDATION_TEXT, guiBoard, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.15,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 24,
		Font = Enum.Font.Gotham,
	})
	labelBoard.Text = common.formatStudentRockValidationText(tblValidationMessages)

	for _, strMessage in ipairs(tblValidationMessages) do
		warn("학생 돌멩이 설정 검사: " .. strMessage)
	end
end

-- --------------------------------------------------------------------------------

function common.getFieldItemSpawnPositions(fldItemSpawnArea, strToolName, tblDefaultSpawnPositions) -- [의미/의도] 전장 아이템 스폰 위치 조회 함수 정의 ➔ 선생 setup 마커가 있으면 그 위치를 쓰고 없으면 기본 위치를 사용하기 위함
	local eLogical = common.eEngineLogicalType
	local tblSpawnPositions = {}

	for index, vectorDefaultPosition in ipairs(tblDefaultSpawnPositions) do
		local partSpawnMarker = fldItemSpawnArea:FindFirstChild(eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_" .. index)
		table.insert(tblSpawnPositions, partSpawnMarker and partSpawnMarker.Position or vectorDefaultPosition)
	end

	return tblSpawnPositions
end

-- --------------------------------------------------------------------------------

function common.installFieldToolPickups(svcWorkspace, strToolName, strToolTip, tblConfig, tblDefaultSpawnPositions, tblDefaultHandleProperties, fnInstallToolSystem) -- [의미/의도] 파밍 Tool 묶음 설치 함수 정의 ➔ 직접 지급하지 않고 맵에 놓인 장비를 플레이어가 찾아서 줍게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local eAttrKey = common.eEngineAttributeKey
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local tblSpawnPositions = common.getFieldItemSpawnPositions(fldItemSpawnArea, strToolName, tblDefaultSpawnPositions)
	local intSpawnCount = common.readConfigInteger(tblConfig, "SpawnCount", #tblSpawnPositions, 1, 12)
	local strDisplayName = common.readConfigString(tblConfig, "DisplayName", strToolName)
	local strVariantId = common.readConfigString(tblConfig, "VariantId", strToolName)
	local vectorSpawnOffset = common.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8))
	local numberSpawnRadius = common.readConfigNumber(tblConfig, "SpawnRadius", 0, 0, 12)

	for index = 1, intSpawnCount do
		local vectorSpawnJitter = common.createFlatSpawnJitter(strVariantId, index, numberSpawnRadius)
		local vectorSpawnPosition = tblSpawnPositions[((index - 1) % #tblSpawnPositions) + 1] + vectorSpawnOffset + vectorSpawnJitter
		local toolPickup = common.ensureToolWithHandle(eLogical.FIELD_ITEM_PREFIX .. strToolName .. "_" .. strVariantId .. "_" .. index, strToolTip, fldItemSpawnArea, tblDefaultHandleProperties)
		toolPickup.ToolTip = strDisplayName .. " - 클릭해서 줍기"
		toolPickup.CanBeDropped = true
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_TYPE, strToolName)
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_DISPLAY_NAME, strDisplayName)
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME, toolPickup.Name)

		local partHandle = common.applyToolHandleStudentStyle(toolPickup, tblConfig)
		partHandle.Position = vectorSpawnPosition + Vector3.new(0, math.max(1.5, partHandle.Size.Y / 2 + 0.5), 0)
		partHandle.Anchored = true
		partHandle.CanCollide = false
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, partHandle.Position)

		if fnInstallToolSystem then
			fnInstallToolSystem(toolPickup, tblConfig)
		end

		local clickPickup = common.ensureClickDetector(partHandle, 18)
		if common.markRuntimeInstalled(toolPickup, "RuntimeInstalled_FieldPickup") then
			clickPickup.MouseClick:Connect(function(player)
				local backpackPlayer = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
				if not backpackPlayer or toolPickup.Parent ~= fldItemSpawnArea then return end

				partHandle.Anchored = false
				partHandle.CanCollide = false
				toolPickup.Name = strDisplayName
				toolPickup.Parent = backpackPlayer
			end)
		end
	end
end

-- --------------------------------------------------------------------------------

function common.resetFieldToolPickupsToWorld(svcPlayers, fldItemSpawnArea) -- [의미/의도] 플레이어가 들고 있는 파밍 Tool을 전장 스폰 위치로 되돌리는 함수 정의 ➔ 새 라운드가 시작될 때 다시 찾아 줍는 흐름을 유지하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local eAttrKey = common.eEngineAttributeKey

	local function reset_tool(toolPickup)
		if not toolPickup:IsA(ePhysical.TOOL) or not toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) then return end

		local strHomeName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME)
		local vectorHomePosition = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION)
		if typeof(strHomeName) ~= "string" or typeof(vectorHomePosition) ~= "Vector3" then return end

		toolPickup.Name = strHomeName
		toolPickup.Parent = fldItemSpawnArea

		local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
		if partHandle and partHandle:IsA(ePhysical.BASE_PART) then
			partHandle.Position = vectorHomePosition
			partHandle.Anchored = true
			partHandle.CanCollide = false
			common.ensureClickDetector(partHandle, 18)
		end
	end

	local function scan_container(instanceContainer)
		if not instanceContainer then return end

		for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
			reset_tool(instanceChild)
		end
	end

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		scan_container(playerPlayer:FindFirstChild("Backpack"))
		scan_container(playerPlayer.Character)
	end
end

-- --------------------------------------------------------------------------------

function common.installThrowingStonePickups(svcWorkspace, tblConfig) -- [의미/의도] 투척 돌 파밍 설치 함수 정의 ➔ 1회차 기본 무기를 맵에서 찾아 줍는 루프로 제공하기 위함
	local eLogical = common.eEngineLogicalType
	local tblThrowingStoneConfig = tblConfig
	local boolAlreadyResolved = tblConfig and tblConfig.ProjectileSize ~= nil and tblConfig.ProjectileMaterial ~= nil
	local boolLooksLikeStudentDesign = tblConfig and (
		tblConfig.DesignKind == "ThrowingStone"
		or tblConfig.Appearance
		or tblConfig.CollisionSize
		or tblConfig.CollisionShape
		or tblConfig.LookShape
		or tblConfig.Size
		or tblConfig.Material
		or tblConfig.BrickColor
		or tblConfig.Color
		or tblConfig.Shape
		or tblConfig.Trait
	)
	if boolLooksLikeStudentDesign and not boolAlreadyResolved then
		tblThrowingStoneConfig = common.resolveThrowingStoneDesign(tblConfig)
	end

	return common.installFieldToolPickups(svcWorkspace, eLogical.THROWING_STONE, "클릭해서 주운 뒤 전초기지 목표에 던집니다", tblThrowingStoneConfig, {
		Vector3.new(-24, 0.1, 8),
		Vector3.new(0, 0.1, 4),
		Vector3.new(24, 0.1, 8),
	}, {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.Slate,
		BrickColor = BrickColor.new("Dark stone grey"),
	}, common.installThrowingStoneTool)
end

-- --------------------------------------------------------------------------------

function common.createFallbackRockDesign(strSourceName)
	local tblRockDesign = common.createRockDesign(strSourceName .. " 기본 돌")
	tblRockDesign.Appearance.BrickColor = BrickColor.new("Medium stone grey")
	tblRockDesign.Appearance.Material = Enum.Material.Slate
	tblRockDesign.Appearance.Size = Vector3.new(1.1, 1.1, 1.1)
	tblRockDesign.Appearance.CollisionShape = Enum.PartType.Ball
	tblRockDesign.Trait = "Balanced"
	return tblRockDesign
end

-- --------------------------------------------------------------------------------

function common.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
	if not moduleRockDesign:IsA(common.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblRockDesign = pcall(require, moduleRockDesign)
	if not boolSuccess then
		common.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "코드 실행 오류가 있어 기본 돌로 대체했습니다. " .. tostring(tblRockDesign))
		return common.createFallbackRockDesign(moduleRockDesign.Name)
	end

	if type(tblRockDesign) ~= "table" then
		common.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "마지막 줄에서 table을 return해야 해서 기본 돌로 대체했습니다.")
		return common.createFallbackRockDesign(moduleRockDesign.Name)
	end

	return tblRockDesign
end

-- --------------------------------------------------------------------------------

function common.installStudentThrowingStoneDesigns(svcWorkspace, fldStudentRockDesigns)
	local tblModules = {}
	local tblValidationMessages = {}
	if fldStudentRockDesigns then
		for _, instanceChild in ipairs(fldStudentRockDesigns:GetChildren()) do
			if instanceChild:IsA(common.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	if #tblModules == 0 then
		common.addValidationMessage(tblValidationMessages, "StudentRockDesigns", "학생 ModuleScript가 없어 전장 기본 돌을 설치했습니다.")
		common.installThrowingStonePickups(svcWorkspace, common.resolveThrowingStoneDesign(common.createFallbackRockDesign("전장"), tblValidationMessages, "전장"))
		common.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
		return 1
	end

	for _, moduleRockDesign in ipairs(tblModules) do
		local tblRockDesign = common.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
		if tblRockDesign then
			common.installThrowingStonePickups(svcWorkspace, common.resolveThrowingStoneDesign(tblRockDesign, tblValidationMessages, moduleRockDesign.Name))
		end
	end

	common.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
	return #tblModules
end

-- --------------------------------------------------------------------------------

function common.readStudentLessonConfigModule(moduleLessonConfig, tblValidationMessages)
	if not moduleLessonConfig:IsA(common.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblLessonConfig = pcall(require, moduleLessonConfig)
	if not boolSuccess then
		common.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "코드 실행 오류가 있어 이 설정을 건너뜁니다. " .. tostring(tblLessonConfig))
		return nil
	end

	if type(tblLessonConfig) ~= "table" then
		common.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "마지막 줄에서 table을 return해야 해서 이 설정을 건너뜁니다.")
		return nil
	end

	return tblLessonConfig
end

-- --------------------------------------------------------------------------------

function common.readStudentLessonConfigDayNumber(moduleLessonConfig, tblValidationMessages)
	local strModuleName = moduleLessonConfig.Name
	local valueDayNumber = tonumber(strModuleName:match("^(%d+)") or strModuleName:match("(%d+)$"))
	if type(valueDayNumber) ~= "number" then
		common.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "파일명 앞이나 뒤에 회차 숫자가 없어 건너뜁니다. 예: 02_student_answer 또는 StudentAnswer02")
		return nil
	end

	return math.floor(valueDayNumber)
end

-- --------------------------------------------------------------------------------

function common.readStudentLessonConceptConfig(tblLessonConfig, strConceptKey)
	local tblConceptConfig = tblLessonConfig[strConceptKey]
	if type(tblConceptConfig) == "table" then
		return tblConceptConfig
	end

	return tblLessonConfig
end

-- --------------------------------------------------------------------------------

function common.installStudentLessonConfigByDayNumber(svcWorkspace, svcPlayers, svcReplicatedStorage, intDayNumber, tblLessonConfig, tblValidationMessages, strSourceName)
	local eConfigKey = common.eStudentLessonConfigKey

	if intDayNumber == 2 then
		common.installStudentCoverDesign(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.COVER_DESIGN))
	elseif intDayNumber == 3 then
		common.installResourceWallSystem(svcWorkspace, svcPlayers, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.RESOURCE_WALL))
	elseif intDayNumber == 4 then
		common.installFieldSwordPickups(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SWORD))
	elseif intDayNumber == 5 then
		common.installFieldBowPickups(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.BOW))
	elseif intDayNumber == 6 then
		common.installFieldShieldPickups(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SHIELD))
	elseif intDayNumber == 7 then
		common.installFieldArmorPickups(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.ARMOR))
	elseif intDayNumber == 8 then
		common.installGateDamageSystem(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.GATE))
	elseif intDayNumber == 9 then
		common.installStoneWallDamageSystem(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.STONE_WALL))
	elseif intDayNumber == 10 then
		common.installSiegeEngineSystem(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SIEGE_ENGINE))
	elseif intDayNumber == 11 then
		common.installMagicStaffPickups(svcWorkspace, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.STAFF))
		common.installMagicServerSystem(svcReplicatedStorage, svcPlayers, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.MAGIC))
	elseif intDayNumber == 12 then
		common.installFinalBattleSystem(svcWorkspace, svcPlayers, common.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.FINAL_BATTLE))
	else
		common.addValidationMessage(tblValidationMessages, strSourceName, "지원하지 않는 " .. tostring(intDayNumber) .. "회차 설정이라 건너뜁니다.")
		return false
	end

	return true
end

-- --------------------------------------------------------------------------------

function common.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages)
	local tblLessonConfig = common.readStudentLessonConfigModule(moduleLessonConfig, tblValidationMessages)
	if not tblLessonConfig then
		return false
	end

	local intDayNumber = common.readStudentLessonConfigDayNumber(moduleLessonConfig, tblValidationMessages)
	if not intDayNumber then
		return false
	end

	return common.installStudentLessonConfigByDayNumber(svcWorkspace, svcPlayers, svcReplicatedStorage, intDayNumber, tblLessonConfig, tblValidationMessages, moduleLessonConfig.Name)
end

-- --------------------------------------------------------------------------------

function common.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, fldStudentLessonConfigs)
	local tblModules = {}
	local tblValidationMessages = {}
	if fldStudentLessonConfigs then
		for _, instanceChild in ipairs(fldStudentLessonConfigs:GetChildren()) do
			if instanceChild:IsA(common.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	local intInstalledCount = 0
	for _, moduleLessonConfig in ipairs(tblModules) do
		if common.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages) then
			intInstalledCount += 1
		end
	end

	for _, strMessage in ipairs(tblValidationMessages) do
		warn("학생 수업 설정 검사: " .. strMessage)
	end

	return intInstalledCount
end

-- --------------------------------------------------------------------------------

function common.installFieldSwordPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 검 파밍 설치 함수 정의 ➔ 근접 무기를 직접 지급하지 않고 중앙 교전 지역에서 획득하게 하기 위함
	local eLogical = common.eEngineLogicalType
	return common.installFieldToolPickups(svcWorkspace, eLogical.FIELD_SWORD, "클릭해서 주운 뒤 근접 교전에 사용합니다", tblConfig, {
		Vector3.new(-18, 0.1, -2),
		Vector3.new(18, 0.1, -2),
	}, {
		Size = Vector3.new(1, 5, 1),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Medium stone grey"),
	}, common.installFieldSwordTool)
end

-- --------------------------------------------------------------------------------

function common.installFieldBowPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 활 파밍 설치 함수 정의 ➔ 원거리 무기를 전장 측면에서 찾아 쓰게 하기 위함
	local eLogical = common.eEngineLogicalType
	return common.installFieldToolPickups(svcWorkspace, eLogical.FIELD_BOW, "클릭해서 주운 뒤 원거리 견제에 사용합니다", tblConfig, {
		Vector3.new(-34, 0.1, -6),
		Vector3.new(34, 0.1, -6),
	}, {
		Size = Vector3.new(1, 4, 1),
		Material = Enum.Material.Wood,
		BrickColor = BrickColor.new("Reddish brown"),
	}, common.installFieldBowTool)
end

-- --------------------------------------------------------------------------------

function common.installFieldShieldPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 방패 파밍 설치 함수 정의 ➔ 방어 장비를 목표물 주변에서 찾아 선택하게 하기 위함
	local eLogical = common.eEngineLogicalType
	return common.installFieldToolPickups(svcWorkspace, eLogical.FIELD_SHIELD, "클릭해서 주운 뒤 투사체를 막습니다", tblConfig, {
		Vector3.new(-12, 0.1, 18),
		Vector3.new(12, 0.1, -18),
	}, {
		Size = Vector3.new(4, 5, 0.6),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Dark stone grey"),
	}, common.installFieldShieldTool)
end

-- --------------------------------------------------------------------------------

function common.installFieldArmorPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 갑옷 파밍 설치 함수 정의 ➔ 강한 방어 장비를 느린 이동이라는 선택지와 함께 맵에 배치하기 위함
	local eLogical = common.eEngineLogicalType
	return common.installFieldToolPickups(svcWorkspace, eLogical.FIELD_ARMOR, "클릭해서 주운 뒤 장착 능력치를 적용합니다", tblConfig, {
		Vector3.new(-30, 0.1, 22),
		Vector3.new(30, 0.1, -22),
	}, {
		Size = Vector3.new(2, 2, 1),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Really black"),
	}, common.installFieldArmorTool)
end

-- --------------------------------------------------------------------------------

function common.installMagicStaffPickups(svcWorkspace, tblConfig) -- [의미/의도] 마법 지팡이 파밍 설치 함수 정의 ➔ 클라이언트 입력 장비도 직접 지급하지 않고 전장에서 획득하게 하기 위함
	local eLogical = common.eEngineLogicalType
	return common.installFieldToolPickups(svcWorkspace, eLogical.MAGIC_STAFF, "클릭해서 주운 뒤 조준 지점에 마법을 시전합니다", tblConfig, {
		Vector3.new(-8, 0.1, -30),
		Vector3.new(8, 0.1, -30),
	}, {
		Size = Vector3.new(0.6, 5, 0.6),
		Material = Enum.Material.Neon,
		BrickColor = BrickColor.new("Royal purple"),
	}, common.installMagicStaffTool)
end

-- --------------------------------------------------------------------------------

function common.isCombatProjectileName(strName) -- [의미/의도] 전투 투사체 이름 판별 함수 정의 ➔ 문/벽/방패가 받을 수 있는 공격 투사체를 공통으로 구분하기 위함
	local eLogical = common.eEngineLogicalType
	return strName == eLogical.THROWN_STONE
		or strName == eLogical.PROJECTILE_ARROW_FIELD
		or strName == eLogical.PROJECTILE_ALL
		or strName == eLogical.SIEGE_STONE
end

-- --------------------------------------------------------------------------------

function common.getOutpostObjectiveTeamName(modelTarget)
	if not modelTarget then return nil end

	local strPrefix = common.eEngineLogicalType.OUTPOST_CORE_PREFIX
	if common.hasEngineLogicalNamePrefix(modelTarget.Name, strPrefix) then
		return modelTarget.Name:sub(#strPrefix + 1)
	end

	return nil
end

-- --------------------------------------------------------------------------------

function common.canPlayerDamageModel(playerAttacker, modelTarget)
	if not modelTarget then return false end
	if not playerAttacker then return true end
	if not playerAttacker.Team then return false end

	local svcPlayers = game:GetService(common.eEngineServiceSingleton.PLAYERS)
	local playerTarget = svcPlayers:GetPlayerFromCharacter(modelTarget)
	if playerTarget and playerTarget.Team == playerAttacker.Team then
		return false
	end

	local strObjectiveTeamName = common.getOutpostObjectiveTeamName(modelTarget)
	if strObjectiveTeamName and strObjectiveTeamName == playerAttacker.Team.Name then
		return false
	end

	return true
end

-- --------------------------------------------------------------------------------

function common.installThrowingStoneTool(toolThrowingStone, tblConfig) -- [의미/의도] 투척 돌 서버 시스템 설치 함수 정의 ➔ 학생 파일에는 외형/수치 설정만 남기고 실제 공격 규칙은 서버 공통 코드가 처리하기 위함
	if not common.markRuntimeInstalled(toolThrowingStone, "RuntimeInstalled_ThrowingStone") then
		return
	end

	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcPlayers = game:GetService(eService.PLAYERS)
	local partHandle = common.applyToolHandleStudentStyle(toolThrowingStone, tblConfig)

	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 15, 1, 30)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 0.8, 0.2, 3)
	local numberSpeed = common.readConfigNumber(tblConfig, "Speed", 90, 20, 140)
	local numberArc = common.readConfigNumber(tblConfig, "Arc", 12, 0, 60)
	local numberKnockbackForward = common.readConfigNumber(tblConfig, "KnockbackForward", 45, 0, 80)
	local numberKnockbackUp = common.readConfigNumber(tblConfig, "KnockbackUp", 18, 0, 60)
	local numberLifetime = common.readConfigNumber(tblConfig, "Lifetime", 5, 1, 12)
	local vectorProjectileSize = common.readConfigVector3(tblConfig, "ProjectileSize", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0.3, 0.3, 0.3), Vector3.new(4, 4, 4))
	local enumProjectileMaterial = common.readThrowingStoneMaterial(tblConfig, "ProjectileMaterial", Enum.Material.Slate)
	local colorProjectile = common.readConfigColor3(tblConfig, "ProjectileColor", BrickColor.new("Dark stone grey").Color)
	local enumProjectileShape = common.readConfigEnumItem(tblConfig, "ProjectileShape", Enum.PartType.Ball)
	local strLookShape = common.readConfigString(tblConfig, "LookShape", common.readConfigString(tblConfig, "Look", ""))
	local boolReady = true
	common.applyRockLook(partHandle, strLookShape)

	toolThrowingStone.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolThrowingStone.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local playerAttacker = svcPlayers:GetPlayerFromCharacter(modelCharacter)
		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partRock = Instance.new(ePhysical.PART)
		partRock.Name = eLogical.THROWN_STONE
		partRock.Shape = enumProjectileShape
		partRock.Size = vectorProjectileSize
		partRock.Material = enumProjectileMaterial
		partRock.Color = colorProjectile
		partRock.Position = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0)
		partRock.Parent = workspace
		common.applyRockLook(partRock, strLookShape)
		partRock.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberSpeed + Vector3.new(0, numberArc, 0)
		svcDebris:AddItem(partRock, numberLifetime)

		local boolHitOnce = false
		partRock.Touched:Connect(function(partHit)
			if boolHitOnce then return end

			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
			if not humTarget or modelTarget == modelCharacter then return end
			if not common.canPlayerDamageModel(playerAttacker, modelTarget) then return end

			boolHitOnce = true
			humTarget:TakeDamage(numberDamage)
			if partTargetRoot then
				partTargetRoot.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberKnockbackForward + Vector3.new(0, numberKnockbackUp, 0)
			end
			partRock:Destroy()
		end)

		task.wait(numberCooldown)
		boolReady = true
	end)
end

-- --------------------------------------------------------------------------------

function common.installStudentCoverDesign(svcWorkspace, tblConfig) -- [의미/의도] 학생 엄폐물 디자인 적용 함수 정의 ➔ 학생은 위치/재질/색 같은 에셋 설정만 바꾸고 생성 방식은 공통 코드가 관리하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local tblCovers = tblConfig and tblConfig.Covers or {}

	if #tblCovers == 0 then
		tblCovers = {
			{Origin = Vector3.new(-14, 1, 8), Material = Enum.Material.WoodPlanks, Color = "Reddish brown"},
			{Origin = Vector3.new(0, 1, 8), Material = Enum.Material.Slate, Color = "Dark stone grey"},
			{Origin = Vector3.new(14, 1, 8), Material = Enum.Material.Metal, Color = "Medium blue"},
		}
	end

	for index, tblCoverConfig in ipairs(tblCovers) do
		local intLevels = common.readConfigInteger(tblCoverConfig, "Levels", 3, 1, 5)
		local vectorOrigin = common.readConfigVector3(tblCoverConfig, "Origin", Vector3.new(index * 14 - 28, 1, 8), Vector3.new(-50, 0, -50), Vector3.new(50, 15, 50))
		local enumMaterial = common.readConfigEnumItem(tblCoverConfig, "Material", Enum.Material.WoodPlanks)
		local brickColor = common.readConfigBrickColor(tblCoverConfig, "Color", "Reddish brown")
		local modelCover = common.ensureNamedInstance(ePhysical.MODEL, eLogical.COVER_STUDENT_PREFIX .. index, fldBattlefield)

		for level = 1, intLevels do
			common.ensureStaticPart(eLogical.COVER_BLOCK_PREFIX .. level, modelCover, {
				Size = Vector3.new(math.max(3, 8 - level), 2, 2),
				Position = vectorOrigin + Vector3.new(0, level, 0),
				CanCollide = true,
				Material = enumMaterial,
				BrickColor = brickColor,
			})
		end
	end
end

-- --------------------------------------------------------------------------------

function common.installResourceWallSystem(svcWorkspace, svcPlayers, tblConfig) -- [의미/의도] 자원 방벽 서버 시스템 설치 함수 정의 ➔ 자원 지급/차감/방벽 생성 규칙을 학생 코드 밖의 공통 서버 코드로 관리하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local fldBuildArea = tblOutpostWorld.fldBuildArea
	local partBuildButton = fldBuildArea:WaitForChild(eLogical.BUILD_BUTTON)
	local partWallSpawn = fldBuildArea:WaitForChild(eLogical.WALL_SPAWN)
	local intStartWood = common.readConfigInteger(tblConfig, "StartWood", 30, 0, 200)
	local intWallCost = common.readConfigInteger(tblConfig, "WallCost", 10, 1, 100)
	local intBlockCount = common.readConfigInteger(tblConfig, "BlockCount", 8, 2, 12)
	local vectorBlockSize = common.readConfigVector3(tblConfig, "BlockSize", Vector3.new(4, 6, 1), Vector3.new(1, 2, 0.5), Vector3.new(8, 12, 4))
	local enumMaterial = common.readConfigEnumItem(tblConfig, "BlockMaterial", Enum.Material.WoodPlanks)
	local brickColor = common.readConfigBrickColor(tblConfig, "BlockColor", "Reddish brown")
	local intNextRow = 0

	local function setup_stats(player)
		local fldLeaderstats = player:FindFirstChild(eLogical.RESERVED_LEADERSTATS)
		if not fldLeaderstats then
			fldLeaderstats = Instance.new(ePhysical.FOLDER)
			fldLeaderstats.Name = eLogical.RESERVED_LEADERSTATS
			fldLeaderstats.Parent = player
		end

		local ivalWood = fldLeaderstats:FindFirstChild(eLogical.WOOD)
		if not ivalWood then
			ivalWood = Instance.new(ePhysical.INT_VALUE)
			ivalWood.Name = eLogical.WOOD
			ivalWood.Value = intStartWood
			ivalWood.Parent = fldLeaderstats
		end
	end

	local function build_wall(player)
		local fldLeaderstats = player:FindFirstChild(eLogical.RESERVED_LEADERSTATS)
		local ivalWood = fldLeaderstats and fldLeaderstats:FindFirstChild(eLogical.WOOD)
		if not ivalWood or ivalWood.Value < intWallCost then return end

		ivalWood.Value -= intWallCost
		intNextRow += 1

		for index = 1, intBlockCount do
			local partWallBlock = Instance.new(ePhysical.PART)
			partWallBlock.Name = player.Name .. eLogical.WALL_BLOCK_SUFFIX .. "_" .. intNextRow .. "_" .. index
			partWallBlock.Size = vectorBlockSize
			partWallBlock.Position = partWallSpawn.Position + Vector3.new((index - (intBlockCount + 1) / 2) * vectorBlockSize.X, vectorBlockSize.Y / 2, intNextRow * 3)
			partWallBlock.Anchored = true
			partWallBlock.Material = enumMaterial
			partWallBlock.BrickColor = brickColor
			partWallBlock.Parent = fldBuildArea
		end
	end

	if not common.markRuntimeInstalled(partBuildButton, "RuntimeInstalled_ResourceWall") then
		return
	end

	for _, player in ipairs(svcPlayers:GetPlayers()) do setup_stats(player) end
	svcPlayers.PlayerAdded:Connect(setup_stats)

	common.ensureClickDetector(partBuildButton, 24).MouseClick:Connect(build_wall)
end

-- --------------------------------------------------------------------------------

function common.installFieldSwordTool(toolFieldSword, tblConfig) -- [의미/의도] 전장 검 서버 시스템 설치 함수 정의 ➔ 근접 타격 판정과 쿨타임을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolFieldSword, "RuntimeInstalled_FieldSword") then
		return
	end

	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local svcPlayers = game:GetService(eService.PLAYERS)
	local partHandle = common.applyToolHandleStudentStyle(toolFieldSword, tblConfig)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 20, 1, 45)
	local numberActiveTime = common.readConfigNumber(tblConfig, "ActiveTime", 0.25, 0.05, 1)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 1.2, 0.2, 5)
	local brickActiveColor = common.readConfigBrickColor(tblConfig, "ActiveColor", "Really red")
	local brickIdleColor = common.readConfigBrickColor(tblConfig, "IdleColor", "Medium stone grey")
	local boolCanAttack = true

	toolFieldSword.Activated:Connect(function()
		if not boolCanAttack then return end

		boolCanAttack = false
		local tableAlreadyHit = {}
		partHandle.BrickColor = brickActiveColor

		local connectionTouched = partHandle.Touched:Connect(function(partHit)
			local playerAttacker = svcPlayers:GetPlayerFromCharacter(toolFieldSword.Parent)
			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			if not humTarget or modelTarget == toolFieldSword.Parent or tableAlreadyHit[humTarget] then return end
			if not common.canPlayerDamageModel(playerAttacker, modelTarget) then return end

			tableAlreadyHit[humTarget] = true
			humTarget:TakeDamage(numberDamage)
		end)

		task.wait(numberActiveTime)
		connectionTouched:Disconnect()
		partHandle.BrickColor = brickIdleColor
		task.wait(numberCooldown)
		boolCanAttack = true
	end)
end

-- --------------------------------------------------------------------------------

function common.installFieldBowTool(toolFieldBow, tblConfig) -- [의미/의도] 전장 활 서버 시스템 설치 함수 정의 ➔ 발사체 생성/피해/자동 삭제를 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolFieldBow, "RuntimeInstalled_FieldBow") then
		return
	end

	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcPlayers = game:GetService(eService.PLAYERS)
	common.applyToolHandleStudentStyle(toolFieldBow, tblConfig)

	local numberSpeed = common.readConfigNumber(tblConfig, "Speed", 110, 30, 160)
	local numberArc = common.readConfigNumber(tblConfig, "Arc", 28, 0, 80)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 18, 1, 35)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 0.9, 0.2, 4)
	local numberLifetime = common.readConfigNumber(tblConfig, "Lifetime", 6, 1, 12)
	local vectorArrowSize = common.readConfigVector3(tblConfig, "ArrowSize", Vector3.new(0.4, 0.4, 3), Vector3.new(0.2, 0.2, 1), Vector3.new(2, 2, 6))
	local enumArrowMaterial = common.readConfigEnumItem(tblConfig, "ArrowMaterial", Enum.Material.Wood)
	local brickTargetHitColor = common.readConfigBrickColor(tblConfig, "TargetHitColor", "Lime green")
	local boolReady = true

	toolFieldBow.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolFieldBow.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local playerAttacker = svcPlayers:GetPlayerFromCharacter(modelCharacter)
		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partArrow = Instance.new(ePhysical.PART)
		partArrow.Name = eLogical.PROJECTILE_ARROW_FIELD
		partArrow.Size = vectorArrowSize
		partArrow.Material = enumArrowMaterial
		partArrow.CFrame = partHumanoidRoot.CFrame * CFrame.new(0, 1.5, -4)
		partArrow.Parent = workspace
		partArrow.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberSpeed + Vector3.new(0, numberArc, 0)
		svcDebris:AddItem(partArrow, numberLifetime)

		partArrow.Touched:Connect(function(partHit)
			if partHit:IsDescendantOf(modelCharacter) then return end

			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			if humTarget and common.canPlayerDamageModel(playerAttacker, modelTarget) then humTarget:TakeDamage(numberDamage) end
			if common.hasEngineLogicalNamePrefix(partHit.Name, eLogical.RANGE_TARGET_PREFIX) then
				partHit.BrickColor = brickTargetHitColor
			end
			partArrow:Destroy()
		end)

		task.wait(numberCooldown)
		boolReady = true
	end)
end

-- --------------------------------------------------------------------------------

function common.installFieldShieldTool(toolFieldShield, tblConfig) -- [의미/의도] 전장 방패 서버 시스템 설치 함수 정의 ➔ 방어 스탯과 투사체 차단 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolFieldShield, "RuntimeInstalled_FieldShield") then
		return
	end

	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local partHandle = common.applyToolHandleStudentStyle(toolFieldShield, tblConfig)
	local numberBonusHealth = common.readConfigNumber(tblConfig, "BonusHealth", 60, 0, 100)
	local numberBlockHeal = common.readConfigNumber(tblConfig, "BlockHeal", 5, 0, 20)
	local numberWalkSpeedPenalty = common.readConfigNumber(tblConfig, "WalkSpeedPenalty", 2, 0, 8)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolFieldShield.Equipped:Connect(function()
		modelEquippedCharacter = toolFieldShield.Parent
		if not modelEquippedCharacter or not modelEquippedCharacter:IsA(ePhysical.MODEL) then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humPlayer then return end

		tableSavedStats = {MaxHealth = humPlayer.MaxHealth, WalkSpeed = humPlayer.WalkSpeed}
		humPlayer.MaxHealth += numberBonusHealth
		humPlayer.Health = math.min(humPlayer.Health + numberBonusHealth, humPlayer.MaxHealth)
		humPlayer.WalkSpeed = math.max(4, humPlayer.WalkSpeed - numberWalkSpeedPenalty)
	end)

	toolFieldShield.Unequipped:Connect(function()
		if not modelEquippedCharacter or not tableSavedStats then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humPlayer then
			humPlayer.MaxHealth = tableSavedStats.MaxHealth
			humPlayer.Health = math.min(humPlayer.Health, tableSavedStats.MaxHealth)
			humPlayer.WalkSpeed = tableSavedStats.WalkSpeed
		end

		modelEquippedCharacter = nil
		tableSavedStats = nil
	end)

	partHandle.Touched:Connect(function(partHit)
		if partHit.Name ~= eLogical.PROJECTILE_ARROW_FIELD and partHit.Name ~= eLogical.PROJECTILE_ALL then return end
		if not modelEquippedCharacter then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humPlayer then
			humPlayer.Health = math.min(humPlayer.Health + numberBlockHeal, humPlayer.MaxHealth)
		end
		partHit:Destroy()
	end)
end

-- --------------------------------------------------------------------------------

function common.installFieldArmorTool(toolFieldArmor, tblConfig) -- [의미/의도] 전장 갑옷 서버 시스템 설치 함수 정의 ➔ 장착 스탯과 장식 이펙트 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolFieldArmor, "RuntimeInstalled_FieldArmor") then
		return
	end

	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	common.applyToolHandleStudentStyle(toolFieldArmor, tblConfig)

	local numberMaxHealth = common.readConfigNumber(tblConfig, "MaxHealth", 180, 100, 240)
	local numberHealOnEquip = common.readConfigNumber(tblConfig, "HealOnEquip", 80, 0, 120)
	local numberWalkSpeed = common.readConfigNumber(tblConfig, "WalkSpeed", 10, 4, 20)
	local numberJumpPower = common.readConfigNumber(tblConfig, "JumpPower", 32, 10, 80)
	local numberAuraRate = common.readConfigNumber(tblConfig, "AuraRate", 20, 0, 80)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolFieldArmor.Equipped:Connect(function()
		modelEquippedCharacter = toolFieldArmor.Parent
		if not modelEquippedCharacter or not modelEquippedCharacter:IsA(ePhysical.MODEL) then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		local partHumanoidRoot = modelEquippedCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not humPlayer or not partHumanoidRoot then return end

		tableSavedStats = {MaxHealth = humPlayer.MaxHealth, WalkSpeed = humPlayer.WalkSpeed, JumpPower = humPlayer.JumpPower}
		humPlayer.MaxHealth = numberMaxHealth
		humPlayer.Health = math.min(humPlayer.Health + numberHealOnEquip, humPlayer.MaxHealth)
		humPlayer.WalkSpeed = numberWalkSpeed
		humPlayer.JumpPower = numberJumpPower

		local emitOldArmorAura = partHumanoidRoot:FindFirstChild(eLogical.ARMOR_AURA)
		if emitOldArmorAura then emitOldArmorAura:Destroy() end

		local emitArmorAura = Instance.new(ePhysical.PARTICLE_EMITTER)
		emitArmorAura.Name = eLogical.ARMOR_AURA
		emitArmorAura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitArmorAura.Rate = numberAuraRate
		emitArmorAura.Lifetime = NumberRange.new(0.5, 1.2)
		emitArmorAura.Speed = NumberRange.new(1, 3)
		emitArmorAura.Parent = partHumanoidRoot
	end)

	toolFieldArmor.Unequipped:Connect(function()
		if not modelEquippedCharacter or not tableSavedStats then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		local partHumanoidRoot = modelEquippedCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if humPlayer then
			humPlayer.MaxHealth = tableSavedStats.MaxHealth
			humPlayer.Health = math.min(humPlayer.Health, tableSavedStats.MaxHealth)
			humPlayer.WalkSpeed = tableSavedStats.WalkSpeed
			humPlayer.JumpPower = tableSavedStats.JumpPower
		end

		local emitArmorAura = partHumanoidRoot and partHumanoidRoot:FindFirstChild(eLogical.ARMOR_AURA)
		if emitArmorAura then emitArmorAura:Destroy() end

		modelEquippedCharacter = nil
		tableSavedStats = nil
	end)
end

-- --------------------------------------------------------------------------------

function common.installMagicStaffTool(toolMagicStaff, tblConfig) -- [의미/의도] 마법 지팡이 Tool 외형 설치 함수 정의 ➔ 입력/피해 판정은 클라이언트 요청과 서버 시스템에 맡기고 장비 외형만 제한적으로 반영하기 위함
	if not common.markRuntimeInstalled(toolMagicStaff, "RuntimeInstalled_MagicStaffTool") then
		return
	end

	common.applyToolHandleStudentStyle(toolMagicStaff, tblConfig)
end

-- --------------------------------------------------------------------------------

function common.installGateDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 전초기지 문 피해 서버 시스템 설치 함수 정의 ➔ 문 체력/피격/붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local modelGate = tblOutpostWorld.fldFortification:WaitForChild(eLogical.GATE)
	if not common.markRuntimeInstalled(modelGate, "RuntimeInstalled_GateDamage") then
		return
	end

	local numberHealth = common.readConfigNumber(tblConfig, "Health", 120, 30, 300)
	local numberDamagePerHit = common.readConfigNumber(tblConfig, "DamagePerHit", 30, 5, 80)
	local numberWarningHealth = common.readConfigNumber(tblConfig, "WarningHealth", numberHealth / 2, 0, numberHealth)
	local brickWarningColor = common.readConfigBrickColor(tblConfig, "WarningColor", "Bright orange")
	local boolBroken = false

	local function set_gate_color(brickColor)
		for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
			if partGatePlank:IsA(ePhysical.BASE_PART) then
				partGatePlank.BrickColor = brickColor
			end
		end
	end

	local function break_gate()
		boolBroken = true
		for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
			if partGatePlank:IsA(ePhysical.BASE_PART) then
				partGatePlank.Anchored = false
				partGatePlank.AssemblyLinearVelocity = Vector3.new(math.random(-25, 25), 35, math.random(-20, 20))
			end
		end
	end

	local function damage_gate(numberAmount)
		if boolBroken then return end

		numberHealth -= numberAmount
		if numberHealth <= numberWarningHealth then set_gate_color(brickWarningColor) end
		if numberHealth <= 0 then break_gate() end
	end

	for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
		if partGatePlank:IsA(ePhysical.BASE_PART) then
			partGatePlank.Touched:Connect(function(partHit)
				if not common.isCombatProjectileName(partHit.Name) then return end

				partHit:Destroy()
				damage_gate(numberDamagePerHit)
			end)
		end
	end
end

-- --------------------------------------------------------------------------------

function common.installStoneWallDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 석조 벽 피해 서버 시스템 설치 함수 정의 ➔ 구역별 체력/부분 붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local modelStoneWall = tblOutpostWorld.fldFortification:WaitForChild(eLogical.STONE_WALL)
	if not common.markRuntimeInstalled(modelStoneWall, "RuntimeInstalled_StoneWallDamage") then
		return
	end

	local numberSectionHealth = common.readConfigNumber(tblConfig, "SectionHealth", 90, 30, 240)
	local numberDamagePerHit = common.readConfigNumber(tblConfig, "DamagePerHit", 30, 5, 80)
	local brickDamagedColor = common.readConfigBrickColor(tblConfig, "DamagedColor", "Dark stone grey")
	local tableSectionHealth = {}
	local tableCollapsed = {}

	local function collapse_section(modelSection)
		if tableCollapsed[modelSection] then return end

		tableCollapsed[modelSection] = true
		for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do
			if partStoneBlock:IsA(ePhysical.BASE_PART) then
				partStoneBlock.Anchored = false
				partStoneBlock.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-10, 10))
			end
		end
	end

	local function register_section(modelSection)
		tableSectionHealth[modelSection] = numberSectionHealth
		for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do
			if partStoneBlock:IsA(ePhysical.BASE_PART) then
				partStoneBlock.Touched:Connect(function(partHit)
					if not common.isCombatProjectileName(partHit.Name) then return end

					partHit:Destroy()
					tableSectionHealth[modelSection] -= numberDamagePerHit
					partStoneBlock.BrickColor = brickDamagedColor
					if tableSectionHealth[modelSection] <= 0 then
						collapse_section(modelSection)
					end
				end)
			end
		end
	end

	for _, modelSection in ipairs(modelStoneWall:GetChildren()) do
		if modelSection:IsA(ePhysical.MODEL) then
			register_section(modelSection)
		end
	end
end

-- --------------------------------------------------------------------------------

function common.installSiegeEngineSystem(svcWorkspace, tblConfig) -- [의미/의도] 중장비 서버 시스템 설치 함수 정의 ➔ 발사 버튼/무거운 탄환/쿨타임 규칙을 공통 서버 코드가 책임지게 하기 위함
	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local fldSiegeEngine = tblOutpostWorld.fldSiegeEngine
	local partLaunchButton = fldSiegeEngine:WaitForChild(eLogical.LAUNCH_BUTTON)
	local partLaunchPoint = fldSiegeEngine:WaitForChild(eLogical.LAUNCH_POINT)
	local partTargetPoint = fldSiegeEngine:WaitForChild(eLogical.TARGET_POINT)
	if not common.markRuntimeInstalled(partLaunchButton, "RuntimeInstalled_SiegeEngine") then
		return
	end

	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 2.5, 0.5, 8)
	local numberForwardSpeed = common.readConfigNumber(tblConfig, "ForwardSpeed", 95, 30, 160)
	local numberUpSpeed = common.readConfigNumber(tblConfig, "UpSpeed", 45, 0, 100)
	local numberLifetime = common.readConfigNumber(tblConfig, "Lifetime", 8, 2, 20)
	local vectorStoneSize = common.readConfigVector3(tblConfig, "StoneSize", Vector3.new(3, 3, 3), Vector3.new(1, 1, 1), Vector3.new(6, 6, 6))
	local enumStoneMaterial = common.readConfigEnumItem(tblConfig, "StoneMaterial", Enum.Material.Slate)
	local boolReady = true

	local function launch_stone()
		if not boolReady then return end

		local vectorOffset = partTargetPoint.Position - partLaunchPoint.Position
		if vectorOffset.Magnitude <= 0 then return end

		boolReady = false

		local partSiegeStone = Instance.new(ePhysical.PART)
		partSiegeStone.Name = eLogical.SIEGE_STONE
		partSiegeStone.Shape = Enum.PartType.Ball
		partSiegeStone.Size = vectorStoneSize
		partSiegeStone.Material = enumStoneMaterial
		partSiegeStone.Position = partLaunchPoint.Position
		partSiegeStone.Parent = workspace
		partSiegeStone.AssemblyLinearVelocity = vectorOffset.Unit * numberForwardSpeed + Vector3.new(0, numberUpSpeed, 0)
		svcDebris:AddItem(partSiegeStone, numberLifetime)

		task.wait(numberCooldown)
		boolReady = true
	end

	common.ensureClickDetector(partLaunchButton, 24).MouseClick:Connect(launch_stone)
end

-- --------------------------------------------------------------------------------

function common.installMagicServerSystem(svcReplicatedStorage, svcPlayers, tblConfig) -- [의미/의도] 마법 서버 시스템 설치 함수 정의 ➔ 클라이언트 입력은 요청으로만 받고 거리/쿨타임/피해는 서버가 판정하기 위함
	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcWorkspace = game:GetService(eService.WORKSPACE)
	local eventCastMagic = svcReplicatedStorage:WaitForChild(eLogical.CAST_MAGIC)
	if not common.markRuntimeInstalled(eventCastMagic, "RuntimeInstalled_MagicServer") then
		return
	end

	local numberMaxDistance = common.readConfigNumber(tblConfig, "MaxDistance", 80, 10, 160)
	local numberRadius = common.readConfigNumber(tblConfig, "Radius", 12, 2, 30)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 25, 1, 60)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 1.8, 0.3, 8)
	local numberEffectLifetime = common.readConfigNumber(tblConfig, "EffectLifetime", 2, 0.5, 6)
	local tblEffectValidationMessages = {}
	local tblEffectConfig = common.readParticleEffectConfig(tblConfig, "Effect", tblEffectValidationMessages, "MagicEffect")
	local tableLastCastByPlayer = {}

	for _, strMessage in ipairs(tblEffectValidationMessages) do
		warn("마법 이펙트 설정 검사: " .. strMessage)
	end

	local function spawn_magic_effect(vectorPosition)
		if not tblEffectConfig then
			return
		end

		local partEffectAnchor = Instance.new(ePhysical.PART)
		partEffectAnchor.Name = eLogical.PARTICLE_EFFECT
		partEffectAnchor.Anchored = true
		partEffectAnchor.CanCollide = false
		partEffectAnchor.CanTouch = false
		partEffectAnchor.CanQuery = false
		partEffectAnchor.Transparency = 1
		partEffectAnchor.Size = Vector3.new(1, 1, 1)
		partEffectAnchor.Position = vectorPosition
		partEffectAnchor.Parent = svcWorkspace
		common.applyParticleEffect(partEffectAnchor, tblEffectConfig)
		svcDebris:AddItem(partEffectAnchor, numberEffectLifetime)
	end

	local function cast_magic(player, targetPosition)
		if typeof(targetPosition) ~= "Vector3" then return end

		local numberNow = os.clock()
		local numberLastCast = tableLastCastByPlayer[player] or -numberCooldown
		if numberNow - numberLastCast < numberCooldown then return end

		local modelCharacter = player.Character
		local partHumanoidRoot = modelCharacter and modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		if (targetPosition - partHumanoidRoot.Position).Magnitude > numberMaxDistance then return end

		tableLastCastByPlayer[player] = numberNow

		local explMagic = Instance.new(ePhysical.EXPLOSION)
		explMagic.Position = targetPosition
		explMagic.BlastRadius = numberRadius
		explMagic.BlastPressure = 0
		explMagic.DestroyJointRadiusPercent = 0
		explMagic.Parent = svcWorkspace
		spawn_magic_effect(targetPosition)

		for _, object in ipairs(svcWorkspace:GetDescendants()) do
			if object:IsA(ePhysical.HUMANOID) then
				local humanoidTarget = object
				local modelTarget = humanoidTarget.Parent
				local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
				if partTargetRoot
					and (partTargetRoot.Position - targetPosition).Magnitude <= numberRadius
					and modelTarget ~= modelCharacter
					and common.canPlayerDamageModel(player, modelTarget)
				then
					humanoidTarget:TakeDamage(numberDamage)
				end
			end
		end
	end

	eventCastMagic.OnServerEvent:Connect(cast_magic)
	svcPlayers.PlayerRemoving:Connect(function(player)
		tableLastCastByPlayer[player] = nil
	end)
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType

	local fldOutpostAssets = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_ASSETS, svcReplicatedStorage)
	local fldRockLooks = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.ROCK_LOOKS, fldOutpostAssets)
	local fldStudentRockDesigns = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_ROCK_DESIGNS, svcServerScriptService)
	local fldStudentLessonConfigs = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_LESSON_CONFIGS, svcServerScriptService)

	return {
		fldOutpostAssets = fldOutpostAssets,
		fldRockLooks = fldRockLooks,
		fldStudentRockDesigns = fldStudentRockDesigns,
		fldStudentLessonConfigs = fldStudentLessonConfigs,
	}
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumCoreTargets(fldObjectiveArea)
	local eLogical = common.eEngineLogicalType

	for _, tblCoreConfig in ipairs({
		{Name = eLogical.TEAM_BLUE, Position = Vector3.new(0, 3, 32), Color = "Bright blue"},
		{Name = eLogical.TEAM_RED, Position = Vector3.new(0, 3, -32), Color = "Bright red"},
	}) do
		common.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. tblCoreConfig.Name, fldObjectiveArea, {
			Size = Vector3.new(6, 6, 4),
			Position = tblCoreConfig.Position,
			BrickColor = BrickColor.new(tblCoreConfig.Color),
		}, {
			MaxHealth = 160,
			Health = 160,
		})
	end
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumPracticeTargets(fldObjectiveArea)
	local eLogical = common.eEngineLogicalType

	for index, vectorPosition in ipairs({
		Vector3.new(-16, 2.5, 24),
		Vector3.new(16, 2.5, 24),
		Vector3.new(-16, 2.5, -24),
		Vector3.new(16, 2.5, -24),
	}) do
		common.ensureHumanoidTarget(eLogical.OUTPOST_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new(index <= 2 and "Bright blue" or "Bright red"),
		}, {
			MaxHealth = 100,
			Health = 100,
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-18, 2.5, -8),
		Vector3.new(-9, 2.5, -8),
		Vector3.new(0, 2.5, -8),
		Vector3.new(9, 2.5, -8),
		Vector3.new(18, 2.5, -8),
	}) do
		common.ensureHumanoidTarget(eLogical.DUEL_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright orange"),
		}, {
			MaxHealth = 120,
			Health = 120,
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-32, 3, -30),
		Vector3.new(-20, 3, -34),
		Vector3.new(-8, 3, -38),
		Vector3.new(8, 3, -38),
		Vector3.new(20, 3, -34),
		Vector3.new(32, 3, -30),
	}) do
		common.ensureStaticPart(eLogical.RANGE_TARGET_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(4, 6, 1),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright red"),
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-21, 2.5, -26),
		Vector3.new(-14, 2.5, -30),
		Vector3.new(-7, 2.5, -34),
		Vector3.new(7, 2.5, -34),
		Vector3.new(14, 2.5, -30),
		Vector3.new(21, 2.5, -26),
	}) do
		common.ensureHumanoidTarget(eLogical.ARCANE_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Royal purple"),
		}, {
			MaxHealth = 100,
			Health = 100,
		})
	end
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumBattlefieldMarkers(fldBattlefield)
	local eLogical = common.eEngineLogicalType

	for index, vectorPosition in ipairs({
		Vector3.new(-28, 0.1, 0),
		Vector3.new(-14, 0.1, -4),
		Vector3.new(0, 0.1, 0),
		Vector3.new(14, 0.1, 4),
		Vector3.new(28, 0.1, 0),
	}) do
		common.ensureStaticPart(eLogical.COVER_MARKER_PREFIX .. index, fldBattlefield, {
			Size = Vector3.new(2, 0.2, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright yellow"),
		})
	end

	local partRoundStartButton = common.ensureStaticPart(eLogical.ROUND_START_BUTTON, fldBattlefield, {
		Size = Vector3.new(8, 1, 8),
		Position = Vector3.new(0, 0.5, 0),
		BrickColor = BrickColor.new("Lime green"),
	})
	common.ensureClickDetector(partRoundStartButton, 30)

	for _, tblSpawnConfig in ipairs({
		{Team = eLogical.TEAM_BLUE, Position = Vector3.new(0, 0.5, 38), Color = "Bright blue"},
		{Team = eLogical.TEAM_RED, Position = Vector3.new(0, 0.5, -38), Color = "Bright red"},
	}) do
		common.ensureStaticPart(eLogical.SPAWN_POINT_PREFIX .. tblSpawnConfig.Team, fldBattlefield, {
			Size = Vector3.new(8, 1, 8),
			Position = tblSpawnConfig.Position,
			BrickColor = BrickColor.new(tblSpawnConfig.Color),
			Material = Enum.Material.Neon,
		})
	end
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumBuildArea(fldBuildArea)
	local eLogical = common.eEngineLogicalType

	local partBuildButton = common.ensureStaticPart(eLogical.BUILD_BUTTON, fldBuildArea, {
		Size = Vector3.new(6, 1, 6),
		Position = Vector3.new(0, 0.5, 18),
		BrickColor = BrickColor.new("Bright green"),
	})
	common.ensureClickDetector(partBuildButton, 24)

	common.ensureStaticPart(eLogical.WALL_SPAWN, fldBuildArea, {
		Size = Vector3.new(2, 0.2, 2),
		Position = Vector3.new(0, 0.1, 24),
		Transparency = 0.35,
		BrickColor = BrickColor.new("Bright yellow"),
	})
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumItemSpawnMarkers(fldItemSpawnArea)
	local eLogical = common.eEngineLogicalType

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.THROWING_STONE, {
		Vector3.new(-24, 0.1, 8),
		Vector3.new(0, 0.1, 4),
		Vector3.new(24, 0.1, 8),
	}, "Bright yellow")

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SWORD, {
		Vector3.new(-18, 0.1, -2),
		Vector3.new(18, 0.1, -2),
	}, "Really red")

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_BOW, {
		Vector3.new(-34, 0.1, -6),
		Vector3.new(34, 0.1, -6),
	}, "Bright blue")

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SHIELD, {
		Vector3.new(-12, 0.1, 18),
		Vector3.new(12, 0.1, -18),
	}, "Dark stone grey")

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_ARMOR, {
		Vector3.new(-30, 0.1, 22),
		Vector3.new(30, 0.1, -22),
	}, "Really black")

	common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.MAGIC_STAFF, {
		Vector3.new(-8, 0.1, -30),
		Vector3.new(8, 0.1, -30),
	}, "Royal purple")
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumFortification(fldFortification)
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local modelGate = common.ensureNamedInstance(ePhysical.MODEL, eLogical.GATE, fldFortification)

	for index = 1, 5 do
		common.ensureStaticPart(eLogical.GATE_PLANK_PREFIX .. index, modelGate, {
			Size = Vector3.new(2, 10, 1),
			Position = Vector3.new((index - 3) * 2, 5, -26),
			Material = Enum.Material.WoodPlanks,
			BrickColor = BrickColor.new("Reddish brown"),
		})
	end

	local modelStoneWall = common.ensureNamedInstance(ePhysical.MODEL, eLogical.STONE_WALL, fldFortification)
	for section = 1, 5 do
		local modelWallSection = common.ensureNamedInstance(ePhysical.MODEL, eLogical.WALL_SECTION_PREFIX .. section, modelStoneWall)
		for height = 1, 4 do
			common.ensureStaticPart(eLogical.STONE_BLOCK_PREFIX .. height, modelWallSection, {
				Size = Vector3.new(6, 2, 2),
				Position = Vector3.new((section - 3) * 6, height * 2 - 1, -30),
				Material = Enum.Material.Slate,
				BrickColor = BrickColor.new("Dark stone grey"),
			})
		end
	end
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumSiegeEngine(fldSiegeEngine)
	local eLogical = common.eEngineLogicalType

	local partLaunchButton = common.ensureStaticPart(eLogical.LAUNCH_BUTTON, fldSiegeEngine, {
		Size = Vector3.new(6, 1, 6),
		Position = Vector3.new(0, 0.5, 12),
		BrickColor = BrickColor.new("Bright blue"),
	})
	common.ensureClickDetector(partLaunchButton, 24)

	common.ensureStaticPart(eLogical.LAUNCH_POINT, fldSiegeEngine, {
		Size = Vector3.new(2, 2, 2),
		Position = Vector3.new(0, 4, 4),
		Transparency = 0.4,
	})

	common.ensureStaticPart(eLogical.TARGET_POINT, fldSiegeEngine, {
		Size = Vector3.new(4, 4, 4),
		Position = Vector3.new(0, 4, -34),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Bright red"),
	})
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	common.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage)
end

-- --------------------------------------------------------------------------------

function common.ensureCurriculumTeams(svcTeams)
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType

	for _, tblTeamConfig in ipairs({
		{Name = eLogical.TEAM_BLUE, Color = "Bright blue"},
		{Name = eLogical.TEAM_RED, Color = "Bright red"},
	}) do
		common.ensureNamedInstance(ePhysical.TEAM, tblTeamConfig.Name, svcTeams, {
			TeamColor = BrickColor.new(tblTeamConfig.Color),
			AutoAssignable = false,
		})
	end
end

-- --------------------------------------------------------------------------------

function common.setupCurriculumWorld(gameRoot, tblConfig)
	local eService = common.eEngineServiceSingleton
	local dataModel = gameRoot or game
	local svcWorkspace = dataModel:GetService(eService.WORKSPACE)
	local svcPlayers = dataModel:GetService(eService.PLAYERS)
	local svcReplicatedStorage = dataModel:GetService(eService.REPLICATED_STORAGE)
	local svcServerScriptService = dataModel:GetService(eService.SERVER_SCRIPT_SERVICE)
	local svcTeams = dataModel:GetService(eService.TEAMS)
	local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace)
	local tblSharedAssets = common.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local boolInstallStudentThrowingStones = tblConfig == nil or tblConfig.InstallStudentThrowingStones ~= false
	local boolInstallStudentLessonConfigs = tblConfig == nil or tblConfig.InstallStudentLessonConfigs ~= false

	common.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	common.ensureCurriculumTeams(svcTeams)
	common.ensureCurriculumCoreTargets(tblOutpostWorld.fldObjectiveArea)
	common.ensureCurriculumPracticeTargets(tblOutpostWorld.fldObjectiveArea)
	common.ensureCurriculumBattlefieldMarkers(tblOutpostWorld.fldBattlefield)
	common.ensureCurriculumBuildArea(tblOutpostWorld.fldBuildArea)
	common.ensureCurriculumItemSpawnMarkers(tblOutpostWorld.fldItemSpawnArea)
	common.ensureCurriculumFortification(tblOutpostWorld.fldFortification)
	common.ensureCurriculumSiegeEngine(tblOutpostWorld.fldSiegeEngine)

	if boolInstallStudentThrowingStones then
		common.installStudentThrowingStoneDesigns(svcWorkspace, tblSharedAssets.fldStudentRockDesigns)
	end

	if boolInstallStudentLessonConfigs then
		common.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, tblSharedAssets.fldStudentLessonConfigs)
	end

	print("수업 월드 준비 완료")
	return {
		tblOutpostWorld = tblOutpostWorld,
		tblSharedAssets = tblSharedAssets,
	}
end

-- --------------------------------------------------------------------------------

function common.installFinalBattleSystem(svcWorkspace, svcPlayers, tblConfig) -- [의미/의도] 최종 라운드 서버 시스템 설치 함수 정의 ➔ 팀 스폰/라운드 타이머/상태 Attribute를 공통 서버 코드가 책임지게 하기 위함
	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local eAttrKey = common.eEngineAttributeKey
	local eRoundState = common.eRoundStateValue
	local svcTeams = game:GetService(eService.TEAMS)
	local tblOutpostWorld = common.waitForOutpostBattleWorld(svcWorkspace)
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local partRoundStartButton = fldBattlefield:WaitForChild(eLogical.ROUND_START_BUTTON)
	if not common.markRuntimeInstalled(partRoundStartButton, "RuntimeInstalled_FinalBattle") then
		return
	end

	local intRoundTime = common.readConfigInteger(tblConfig, "RoundTime", 180, 30, 600)
	local numberRespawnHeight = common.readConfigNumber(tblConfig, "RespawnHeight", 4, 1, 12)
	local numberCoreHealth = common.readConfigNumber(tblConfig, "CoreHealth", 160, 50, 500)
	local boolRoundRunning = false

	local function ensure_team(strTeamName, strColorName)
		local teamInstance = svcTeams:FindFirstChild(strTeamName) or Instance.new(ePhysical.TEAM)
		teamInstance.Name = strTeamName
		teamInstance.TeamColor = BrickColor.new(strColorName)
		teamInstance.AutoAssignable = false
		teamInstance.Parent = svcTeams
		return teamInstance
	end

	local function ensure_team_spawn(strTeamName, vectorPosition, strColorName)
		return common.ensureStaticPart(eLogical.SPAWN_POINT_PREFIX .. strTeamName, fldBattlefield, {
			Size = Vector3.new(8, 1, 8),
			Position = vectorPosition,
			BrickColor = BrickColor.new(strColorName),
			Material = Enum.Material.Neon,
		})
	end

	local function ensure_team_core(strTeamName, vectorPosition, strColorName)
		local modelCore, partCoreRoot, humCore = common.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. strTeamName, fldObjectiveArea, {
			Size = Vector3.new(6, 6, 4),
			Position = vectorPosition,
			BrickColor = BrickColor.new(strColorName),
		}, {
			MaxHealth = numberCoreHealth,
			Health = numberCoreHealth,
		})

		if humCore.Health <= 0 then
			humCore:Destroy()
			humCore = common.ensureNamedInstance(ePhysical.HUMANOID, ePhysical.HUMANOID, modelCore, {
				MaxHealth = numberCoreHealth,
				Health = numberCoreHealth,
			})
		end

		partCoreRoot.BrickColor = BrickColor.new(strColorName)
		humCore.MaxHealth = numberCoreHealth
		humCore.Health = numberCoreHealth
		return humCore
	end

	local teamBlue = ensure_team(eLogical.TEAM_BLUE, "Bright blue")
	local teamRed = ensure_team(eLogical.TEAM_RED, "Bright red")
	local partSpawnBlue = ensure_team_spawn(eLogical.TEAM_BLUE, Vector3.new(0, 0.5, 38), "Bright blue")
	local partSpawnRed = ensure_team_spawn(eLogical.TEAM_RED, Vector3.new(0, 0.5, -38), "Bright red")
	local boolPreferBlueForOddRound = true

	local function count_team_players(teamTarget)
		local intCount = 0
		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			if playerPlayer.Team == teamTarget then
				intCount += 1
			end
		end
		return intCount
	end

	local function pick_open_team(intBlueCount, intRedCount, boolPreferBlue)
		if intBlueCount < intRedCount then return teamBlue end
		if intRedCount < intBlueCount then return teamRed end
		if boolPreferBlue then return teamBlue end
		return teamRed
	end

	local function apply_player_team(playerPlayer, teamTarget)
		playerPlayer.Neutral = false
		playerPlayer.Team = teamTarget
	end

	local function assign_player_to_open_team(playerPlayer)
		local teamTarget = pick_open_team(count_team_players(teamBlue), count_team_players(teamRed), boolPreferBlueForOddRound)
		apply_player_team(playerPlayer, teamTarget)
	end

	local function assign_round_teams()
		local intBlueCount = 0
		local intRedCount = 0

		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			local teamTarget = pick_open_team(intBlueCount, intRedCount, boolPreferBlueForOddRound)
			apply_player_team(playerPlayer, teamTarget)
			if teamTarget == teamBlue then
				intBlueCount += 1
			elseif teamTarget == teamRed then
				intRedCount += 1
			end
		end

		svcWorkspace:SetAttribute(eAttrKey.ROUND_BLUE_PLAYER_COUNT_RUNTIME, intBlueCount)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_RED_PLAYER_COUNT_RUNTIME, intRedCount)
		if (intBlueCount + intRedCount) % 2 == 1 then
			boolPreferBlueForOddRound = not boolPreferBlueForOddRound
		end
	end

	local function get_spawn_for_player(playerPlayer)
		if playerPlayer.Team == teamBlue then return partSpawnBlue end
		if playerPlayer.Team == teamRed then return partSpawnRed end
		return nil
	end

	local function move_player_to_team_spawn(playerPlayer)
		local partSpawn = get_spawn_for_player(playerPlayer)
		if not partSpawn then return end

		playerPlayer:LoadCharacter()
		local modelCharacter = playerPlayer.Character or playerPlayer.CharacterAdded:Wait()
		local partHumanoidRoot = modelCharacter:WaitForChild(eLogical.RESERVED_HUMANOID_ROOT_PART, 5)
		if partHumanoidRoot then
			partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, numberRespawnHeight, 0))
		end
	end

	local function move_players_to_team_spawns()
		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			move_player_to_team_spawn(playerPlayer)
		end
	end

	local function get_core_health(strTeamName)
		local modelCore = fldObjectiveArea:FindFirstChild(eLogical.OUTPOST_CORE_PREFIX .. strTeamName)
		local humCore = modelCore and modelCore:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humCore then return 0 end
		return humCore.Health
	end

	local function get_destroyed_core_winner()
		local numberBlueHealth = get_core_health(eLogical.TEAM_BLUE)
		local numberRedHealth = get_core_health(eLogical.TEAM_RED)

		if numberBlueHealth <= 0 and numberRedHealth <= 0 then return "Draw", "BothCoresDestroyed" end
		if numberBlueHealth <= 0 then return eLogical.TEAM_RED, "BlueCoreDestroyed" end
		if numberRedHealth <= 0 then return eLogical.TEAM_BLUE, "RedCoreDestroyed" end
		return nil, nil
	end

	local function get_time_limit_winner()
		local numberBlueHealth = get_core_health(eLogical.TEAM_BLUE)
		local numberRedHealth = get_core_health(eLogical.TEAM_RED)

		if numberBlueHealth > numberRedHealth then return eLogical.TEAM_BLUE, "TimeLimitCoreHealth" end
		if numberRedHealth > numberBlueHealth then return eLogical.TEAM_RED, "TimeLimitCoreHealth" end
		return "Draw", "TimeLimitDraw"
	end

	local function finish_round(strWinner, strReason)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_WINNER_RUNTIME, strWinner)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_END_REASON_RUNTIME, strReason)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.FINISHED)
		boolRoundRunning = false
	end

	local function start_round(playerPlayer)
		if boolRoundRunning then return end

		boolRoundRunning = true
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STARTER_PLAYER_NAME_RUNTIME, playerPlayer.Name)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PREPARING)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_WINNER_RUNTIME, "None")
		svcWorkspace:SetAttribute(eAttrKey.ROUND_END_REASON_RUNTIME, "None")
		ensure_team_core(eLogical.TEAM_BLUE, Vector3.new(0, 3, 32), "Bright blue")
		ensure_team_core(eLogical.TEAM_RED, Vector3.new(0, 3, -32), "Bright red")
		common.resetFieldToolPickupsToWorld(svcPlayers, fldItemSpawnArea)
		assign_round_teams()
		move_players_to_team_spawns()

		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PLAYING)
		for intTimeLeft = intRoundTime, 0, -1 do
			svcWorkspace:SetAttribute(eAttrKey.TIME_LEFT_RUNTIME, intTimeLeft)
			local strWinner, strReason = get_destroyed_core_winner()
			if strWinner then
				finish_round(strWinner, strReason)
				return
			end

			task.wait(1)
		end

		local strWinner, strReason = get_time_limit_winner()
		finish_round(strWinner, strReason)
	end

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		assign_player_to_open_team(playerPlayer)
	end

	svcPlayers.PlayerAdded:Connect(function(playerPlayer)
		assign_player_to_open_team(playerPlayer)
		if boolRoundRunning then
			task.defer(move_player_to_team_spawn, playerPlayer)
		end
	end)

	common.ensureClickDetector(partRoundStartButton, 30).MouseClick:Connect(start_round)
end

-- --------------------------------------------------------------------------------

return common -- [의미/의도] 공통 모듈 반환 ➔ 외부 스크립트에서 require()로 이 모듈을 로드하여 사용하도록 하기 위함
