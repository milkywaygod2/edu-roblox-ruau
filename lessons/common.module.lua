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
		- 폴더명(디렉토리): 정렬 편의를 위해 숫자를 접두사로 배치 (예: 01_rock_tool)
		- 변수명 / 인스턴스명: 코드 단순화를 위해 숫자를 접미사로 배치 (예: fldArena01, Arena01)
	* enum 기반 객체 호출 선언: local fldArena01 = ..., local partRock = ...처럼 소문자 축약타입 + 카멜케이스로 작성

	2) 접두사 레퍼런스 표 (Prefix Reference Table)
	* 게임 오브젝트 타입 (타입명을 3~5글자로 축약, 원래 5글자 이하는 그대로)
		- svc           : game:GetService()로 가져오는 엔진 싱글턴 서비스 객체 (예: svcWorkspace)
		- fld           : Folder 인스턴스 (예: fldArena01)
		- part          : Part 인스턴스 (예: partPracticeBase)
		- model         : Model 인스턴스 (예: modelPracticeDummy)
		- tool          : Tool 인스턴스 (예: toolPracticeRock)
		- team          : Team 인스턴스 (예: teamInstance)
		- expl          : Explosion 인스턴스 (예: explMagic)
		- hum           : Humanoid 인스턴스 (예: humPractice)
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

-- --------------------------------------------------------------------------------

common.eEngineServiceSingleton = { -- [의미/의도] 엔진 서비스 싱글턴 이넘 정의 ➔ 오타 방지 및 로블록스 서비스 객체 접근 이름을 안전하게 통합 관리하기 위함
	WORKSPACE          = "Workspace",
	PLAYERS            = "Players",
	REPLICATED_STORAGE = "ReplicatedStorage",
	STARTER_PACK       = "StarterPack",
	DEBRIS             = "Debris",
	TEAMS              = "Teams",
}

-- --------------------------------------------------------------------------------

common.eEnginePhysicalType = { -- [의미/의도] 물리(명목) 타입 이넘 정의 ➔ 엔진이 강제하는 .ClassName(실체 타입)을 한곳에서 안전하게 관리하기 위함(Instance.new/IsA에 사용)
	PART             = "Part",
	BASE_PART        = "BasePart",
	MODEL            = "Model",
	HUMANOID         = "Humanoid",
	FOLDER           = "Folder",
	TOOL             = "Tool",
	INT_VALUE        = "IntValue",
	CLICK_DETECTOR   = "ClickDetector",
	REMOTE_EVENT     = "RemoteEvent",
	PARTICLE_EMITTER = "ParticleEmitter",
	EXPLOSION        = "Explosion",
	TEAM             = "Team",
}

-- --------------------------------------------------------------------------------

common.eEngineLogicalType = { -- [의미/의도] 논리 타입 이넘 정의 ➔ .ClassName으로 구분 안 되는 도메인 종류를 .Name으로 표현(RESERVED_는 엔진이 강제하는 불변 예약 이름이라 값 수정 금지)
	RESERVED_HANDLE             = "Handle",
	RESERVED_HUMANOID_ROOT_PART = "HumanoidRootPart",
	RESERVED_LEADERSTATS        = "leaderstats",

	-- 01 rock_tool
	ARENA01               = "Arena01",
	PRACTICE_BASE         = "PracticeBase",
	PRACTICE_DUMMY_PREFIX = "PracticeDummy_",
	PRACTICE_ROCK         = "PracticeRock",
	THROWN_PRACTICE_ROCK  = "ThrownPracticeRock",
	-- 02 cover_design
	COVER_FIELD02         = "CoverField02",
	GRID_BASE             = "GridBase",
	COVER_MARKER_PREFIX   = "CoverMarker_",
	COVER_BLOCK_PREFIX    = "CoverBlock_",
	COVER_STUDENT_PREFIX  = "StudentCover_",
	-- 03 resource_wall
	RESOURCE_WALL03       = "ResourceWall03",
	BUILD_BUTTON          = "BuildButton",
	WALL_SPAWN            = "WallSpawn",
	WALL_BLOCK_SUFFIX     = "_WallBlock",
	WOOD                  = "Wood",
	-- 04 melee_weapon
	BALANCE_SWORD         = "BalanceSword",
	DUMMIES04             = "Dummies04",
	COOLDOWN_DUMMY_PREFIX = "CooldownDummy_",
	-- 05 ranged_weapon
	TARGET_RANGE05            = "TargetRange05",
	TRAINING_BOW              = "TrainingBow",
	PROJECTILE_ALL            = "Projectile",
	PROJECTILE_ARROW          = "Arrow",
	PROJECTILE_ARROW_TRAINING = "TrainingArrow",
	TARGET_PREFIX             = "Target_",
	-- 06 shield_design
	PRACTICE_SHIELD       = "PracticeShield",
	-- 07 armor_design
	HEAVY_ARMOR           = "HeavyArmor",
	ARMOR_AURA            = "ArmorAura",
	-- 08 building_gate
	CASTLE08              = "Castle08",
	GATE                  = "Gate",
	GATE_PLANK_PREFIX     = "GatePlank_",
	-- 09 stone_wall
	STONE_WALL09          = "StoneWall09",
	WALL_SECTION_PREFIX   = "WallSection_",
	STONE_BLOCK           = "StoneBlock",
	-- 10 siege_engine
	SIEGE_ENGINE10        = "SiegeEngine10",
	LAUNCH_BUTTON         = "LaunchButton",
	LAUNCH_POINT          = "LaunchPoint",
	TARGET_POINT          = "TargetPoint",
	SIEGE_STONE           = "SiegeStone",
	-- 11 magic_skill
	CAST_MAGIC            = "CastMagic",
	MAGIC_STAFF           = "MagicStaff",
	MAGIC_ARENA11         = "MagicArena11",
	MAGIC_DUMMY_PREFIX    = "MagicDummy_",
	-- 12 final_battle
	TEAM_BLUE             = "Blue",
	TEAM_RED              = "Red",
	FINAL_BATTLE12        = "FinalBattle12",
	ROUND_START_BUTTON    = "RoundStartButton",
	SPAWN_POINT_PREFIX    = "SpawnPoint_",
}

-- --------------------------------------------------------------------------------

common.eEngineAttributeKey = { -- [의미/의도] 엔진 Attribute 키 이넘 정의 ➔ 서버/클라이언트가 문자열 키를 공유할 때 오타 없이 같은 계약을 사용하기 위함
	ROUND_STARTER_PLAYER_NAME_RUNTIME = "RoundStarter",
	ROUND_STATE           = "RoundState",
	TIME_LEFT_RUNTIME      = "TimeLeft",
}

-- --------------------------------------------------------------------------------

common.eRoundStateValue = { -- [의미/의도] 라운드 상태값 이넘 정의 ➔ ROUND_STATE Attribute에 저장되는 진행 상태 문자열을 한곳에서 안전하게 관리하기 위함
	PREPARING = "Preparing",
	PLAYING   = "Playing",
	FINISHED  = "Finished",
}

-- --------------------------------------------------------------------------------

function common.hasEngineLogicalNamePrefix(strName, strPrefix) -- [의미/의도] 엔진 논리 이름이 지정된 enum 접두사로 시작하는지 검사 ➔ 부분 문자열 검색이 다른 logical type 경계를 침범하지 않도록 접두사 기준으로만 판정하기 위함
	return strName:sub(1, #strPrefix) == strPrefix    -- [의미/의도] 이름 앞부분이 접두사와 정확히 일치하는지 반환 ➔ "TargetPoint"처럼 접두사 경계가 다른 이름을 오인하지 않도록 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createOrReplaceInstance(strClassName, strName, instanceParent) -- [의미/의도] 기존 인스턴스 대체 생성 함수 정의 ➔ 중복 오브젝트를 자동 정리하고 새 오브젝트를 만들기 위함
	local instanceOld = instanceParent:FindFirstChild(strName)                    -- [의미/의도] 부모 아래에서 동일한 이름의 기존 객체를 검색함 ➔ 중복 생성을 방지하기 위함
	if instanceOld then                                                           -- [의미/의도] 기존 객체가 존재한다면 ➔ 구버전 찌꺼기가 충돌하지 않도록 처리하기 위함
		instanceOld:Destroy()                                                        -- [의미/의도] 기존 객체를 삭제함 ➔ 맵이 꼬이거나 이전 데이터가 남는 것을 막기 위함
	end                                                                           -- [의미/의도] 기존 객체 정리 조건문 종료 ➔ 다음 생성 단계로 진행하기 위함

	local instanceNew = Instance.new(strClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성함 ➔ 새 구성 요소를 만들기 위함
	instanceNew.Name = strName                     -- [의미/의도] 인스턴스의 이름을 지정함 ➔ 탐색기에서 구분 가능하도록 이름을 설정하기 위함
	instanceNew.Parent = instanceParent            -- [의미/의도] 인스턴스의 부모를 지정함 ➔ 게임 세상의 올바른 위치에 배치하기 위함
	return instanceNew                             -- [의미/의도] 새로 만들어진 인스턴스를 반환함 ➔ 호출한 곳에서 이어서 속성을 조작할 수 있도록 하기 위함
end

-- --------------------------------------------------------------------------------

return common -- [의미/의도] 공통 모듈 반환 ➔ 외부 스크립트에서 require()로 이 모듈을 로드하여 사용하도록 하기 위함
