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
	WORKSPACE          = "Workspace",          -- [의미/의도] Workspace 서비스 키 ➔ 게임 월드(파트·폴더) 공간에 접근하기 위함
	PLAYERS            = "Players",            -- [의미/의도] Players 서비스 키 ➔ 접속 플레이어와 leaderstats를 관리하기 위함
	REPLICATED_STORAGE = "ReplicatedStorage",  -- [의미/의도] ReplicatedStorage 서비스 키 ➔ 서버·클라이언트 공유 저장소에 접근하기 위함
	STARTER_PACK       = "StarterPack",        -- [의미/의도] StarterPack 서비스 키 ➔ 시작 시 지급할 도구를 넣어두기 위함
	DEBRIS             = "Debris",             -- [의미/의도] Debris 서비스 키 ➔ 생성물을 일정 시간 후 자동 삭제하기 위함
	TEAMS              = "Teams",              -- [의미/의도] Teams 서비스 키 ➔ 진영(팀)을 등록·관리하기 위함
}

-- --------------------------------------------------------------------------------

common.eEnginePhysicalType = { -- [의미/의도] 물리(명목) 타입 이넘 정의 ➔ 엔진이 강제하는 .ClassName(실체 타입)을 한곳에서 안전하게 관리하기 위함(Instance.new/IsA에 사용)
	PART             = "Part",             -- [의미/의도] Part 클래스명 ➔ 기본 물리 블록 인스턴스를 만들거나 IsA로 검사하기 위함
	BASE_PART        = "BasePart",         -- [의미/의도] BasePart 클래스명 ➔ 물리 파트 계열을 포괄적으로 IsA 검사하기 위함
	MODEL            = "Model",            -- [의미/의도] Model 클래스명 ➔ 여러 파트를 묶는 모델 인스턴스를 만들거나 검사하기 위함
	HUMANOID         = "Humanoid",         -- [의미/의도] Humanoid 클래스명 ➔ 체력·피해 기능을 가진 생명체 컴포넌트를 만들기 위함
	FOLDER           = "Folder",           -- [의미/의도] Folder 클래스명 ➔ 오브젝트를 분류·정리하는 폴더 인스턴스를 만들기 위함
	TOOL             = "Tool",             -- [의미/의도] Tool 클래스명 ➔ 플레이어가 장착하는 도구 인스턴스를 만들기 위함
	INT_VALUE        = "IntValue",         -- [의미/의도] IntValue 클래스명 ➔ 정수 값을 저장하는 인스턴스를 만들기 위함
	CLICK_DETECTOR   = "ClickDetector",    -- [의미/의도] ClickDetector 클래스명 ➔ 마우스 클릭 감지 컴포넌트를 만들기 위함
	REMOTE_EVENT     = "RemoteEvent",      -- [의미/의도] RemoteEvent 클래스명 ➔ 서버·클라이언트 통신 채널 인스턴스를 만들기 위함
	PARTICLE_EMITTER = "ParticleEmitter",  -- [의미/의도] ParticleEmitter 클래스명 ➔ 입자 이펙트 컴포넌트를 만들기 위함
	EXPLOSION        = "Explosion",        -- [의미/의도] Explosion 클래스명 ➔ 폭발 이펙트 인스턴스를 만들기 위함
	TEAM             = "Team",             -- [의미/의도] Team 클래스명 ➔ 진영(팀) 인스턴스를 만들기 위함
}

-- --------------------------------------------------------------------------------

common.eEngineLogicalType = { -- [의미/의도] 논리 타입 이넘 정의 ➔ .ClassName으로 구분 안 되는 도메인 종류를 .Name으로 표현(RESERVED_는 엔진이 강제하는 불변 예약 이름이라 값 수정 금지)
	RESERVED_HANDLE             = "Handle",            -- [의미/의도] Handle 예약 이름 ➔ 도구 손잡이 파트로 엔진이 자동 인식하게 하기 위함(수정 금지)
	RESERVED_HUMANOID_ROOT_PART = "HumanoidRootPart",  -- [의미/의도] HumanoidRootPart 예약 이름 ➔ 캐릭터 중심 파트로 엔진이 인식하게 하기 위함(수정 금지)
	RESERVED_LEADERSTATS        = "leaderstats",       -- [의미/의도] leaderstats 예약 이름 ➔ 리더보드 통계 폴더로 엔진이 인식하게 하기 위함(수정 금지)

	-- 01 rock_tool
	ARENA01               = "Arena01",                 -- [의미/의도] Arena01 폴더 이름 ➔ 1일차 연습장 맵 폴더를 식별하기 위함
	PRACTICE_BASE         = "PracticeBase",            -- [의미/의도] PracticeBase 파트 이름 ➔ 1일차 연습장 바닥판을 식별하기 위함
	PRACTICE_DUMMY_PREFIX = "PracticeDummy_",          -- [의미/의도] PracticeDummy_ 접두사 ➔ 1일차 연습 더미 이름을 번호와 함께 짓기 위함
	PRACTICE_ROCK         = "PracticeRock",            -- [의미/의도] PracticeRock 도구 이름 ➔ 1일차 연습용 돌 도구를 식별하기 위함
	THROWN_PRACTICE_ROCK  = "ThrownPracticeRock",      -- [의미/의도] ThrownPracticeRock 파트 이름 ➔ 던져진 연습용 돌 투사체를 식별하기 위함
	-- 02 cover_design
	COVER_FIELD02         = "CoverField02",            -- [의미/의도] CoverField02 폴더 이름 ➔ 2일차 엄폐 연습장 폴더를 식별하기 위함
	GRID_BASE             = "GridBase",                -- [의미/의도] GridBase 파트 이름 ➔ 2일차 격자 바닥판을 식별하기 위함
	COVER_MARKER_PREFIX   = "CoverMarker_",            -- [의미/의도] CoverMarker_ 접두사 ➔ 2일차 엄폐물 배치 마커 이름을 짓기 위함
	COVER_BLOCK_PREFIX    = "CoverBlock_",             -- [의미/의도] CoverBlock_ 접두사 ➔ 2일차 엄폐 블록 이름을 짓기 위함
	COVER_STUDENT_PREFIX  = "StudentCover_",           -- [의미/의도] StudentCover_ 접두사 ➔ 2일차 학생이 만든 엄폐물 이름을 짓기 위함
	-- 03 resource_wall
	RESOURCE_WALL03       = "ResourceWall03",          -- [의미/의도] ResourceWall03 폴더 이름 ➔ 3일차 자원 벽 연습장 폴더를 식별하기 위함
	BUILD_BUTTON          = "BuildButton",             -- [의미/의도] BuildButton 파트 이름 ➔ 3일차 건설 버튼을 식별하기 위함
	WALL_SPAWN            = "WallSpawn",               -- [의미/의도] WallSpawn 파트 이름 ➔ 3일차 벽이 생성될 위치 파트를 식별하기 위함
	WALL_BLOCK_SUFFIX     = "_WallBlock",              -- [의미/의도] _WallBlock 접미사 ➔ 3일차 생성된 벽 블록 이름을 짓기 위함
	WOOD                  = "Wood",                    -- [의미/의도] Wood 통계 이름 ➔ 3일차 나무 자원 수량(leaderstats)을 식별하기 위함
	-- 04 melee_weapon
	BALANCE_SWORD         = "BalanceSword",            -- [의미/의도] BalanceSword 도구 이름 ➔ 4일차 밸런스 검 도구를 식별하기 위함
	DUMMIES04             = "Dummies04",               -- [의미/의도] Dummies04 폴더 이름 ➔ 4일차 연습 더미 그룹 폴더를 식별하기 위함
	COOLDOWN_DUMMY_PREFIX = "CooldownDummy_",          -- [의미/의도] CooldownDummy_ 접두사 ➔ 4일차 쿨타임 더미 이름을 번호와 함께 짓기 위함
	-- 05 ranged_weapon
	TARGET_RANGE05            = "TargetRange05",       -- [의미/의도] TargetRange05 폴더 이름 ➔ 5일차 과녁 연습장 폴더를 식별하기 위함
	TRAINING_BOW              = "TrainingBow",         -- [의미/의도] TrainingBow 도구 이름 ➔ 5일차 훈련용 활 도구를 식별하기 위함
	PROJECTILE_ALL            = "Projectile",          -- [의미/의도] Projectile 공통 이름 ➔ 모든 투사체를 포괄적으로 식별하기 위함
	PROJECTILE_ARROW          = "Arrow",               -- [의미/의도] Arrow 이름 ➔ 화살 투사체를 식별하기 위함
	PROJECTILE_ARROW_TRAINING = "TrainingArrow",       -- [의미/의도] TrainingArrow 이름 ➔ 5일차 훈련용 화살 투사체를 식별하기 위함
	TARGET_PREFIX             = "Target_",             -- [의미/의도] Target_ 접두사 ➔ 5일차 과녁 이름을 번호와 함께 짓기 위함
	-- 06 shield_design
	PRACTICE_SHIELD       = "PracticeShield",          -- [의미/의도] PracticeShield 도구 이름 ➔ 6일차 연습용 방패 도구를 식별하기 위함
	-- 07 armor_design
	HEAVY_ARMOR           = "HeavyArmor",              -- [의미/의도] HeavyArmor 도구 이름 ➔ 7일차 무거운 갑옷 도구를 식별하기 위함
	ARMOR_AURA            = "ArmorAura",               -- [의미/의도] ArmorAura 이름 ➔ 7일차 갑옷 오라 이펙트를 식별하기 위함
	-- 08 building_gate
	CASTLE08              = "Castle08",                -- [의미/의도] Castle08 폴더 이름 ➔ 8일차 성 구조물 폴더를 식별하기 위함
	GATE                  = "Gate",                    -- [의미/의도] Gate 모델 이름 ➔ 8일차 성문 모델을 식별하기 위함
	GATE_PLANK_PREFIX     = "GatePlank_",              -- [의미/의도] GatePlank_ 접두사 ➔ 8일차 성문 판자 파트 이름을 짓기 위함
	-- 09 stone_wall
	STONE_WALL09          = "StoneWall09",             -- [의미/의도] StoneWall09 폴더 이름 ➔ 9일차 석조 성벽 폴더를 식별하기 위함
	WALL_SECTION_PREFIX   = "WallSection_",            -- [의미/의도] WallSection_ 접두사 ➔ 9일차 성벽 구역 모델 이름을 짓기 위함
	STONE_BLOCK           = "StoneBlock",              -- [의미/의도] StoneBlock 파트 이름 ➔ 9일차 돌 블록 파트를 식별하기 위함
	-- 10 siege_engine
	SIEGE_ENGINE10        = "SiegeEngine10",           -- [의미/의도] SiegeEngine10 폴더 이름 ➔ 10일차 공성 병기 폴더를 식별하기 위함
	LAUNCH_BUTTON         = "LaunchButton",            -- [의미/의도] LaunchButton 파트 이름 ➔ 10일차 발사 버튼을 식별하기 위함
	LAUNCH_POINT          = "LaunchPoint",             -- [의미/의도] LaunchPoint 파트 이름 ➔ 10일차 발사 시작 지점을 식별하기 위함
	TARGET_POINT          = "TargetPoint",             -- [의미/의도] TargetPoint 파트 이름 ➔ 10일차 목표 지점을 식별하기 위함
	SIEGE_STONE           = "SiegeStone",              -- [의미/의도] SiegeStone 파트 이름 ➔ 10일차 공성 돌 탄환을 식별하기 위함
	-- 11 magic_skill
	CAST_MAGIC            = "CastMagic",               -- [의미/의도] CastMagic 이름 ➔ 11일차 마법 시전 리모트이벤트를 식별하기 위함
	MAGIC_STAFF           = "MagicStaff",              -- [의미/의도] MagicStaff 도구 이름 ➔ 11일차 마법 지팡이 도구를 식별하기 위함
	MAGIC_ARENA11         = "MagicArena11",            -- [의미/의도] MagicArena11 폴더 이름 ➔ 11일차 마법 아레나 폴더를 식별하기 위함
	MAGIC_DUMMY_PREFIX    = "MagicDummy_",             -- [의미/의도] MagicDummy_ 접두사 ➔ 11일차 마법 연습 더미 이름을 번호와 함께 짓기 위함
	-- 12 final_battle
	TEAM_BLUE             = "Blue",                    -- [의미/의도] Blue 팀 이름 ➔ 12일차 청팀 진영을 식별하기 위함
	TEAM_RED              = "Red",                     -- [의미/의도] Red 팀 이름 ➔ 12일차 홍팀 진영을 식별하기 위함
	FINAL_BATTLE12        = "FinalBattle12",           -- [의미/의도] FinalBattle12 폴더 이름 ➔ 12일차 최종 결전 폴더를 식별하기 위함
	ROUND_START_BUTTON    = "RoundStartButton",        -- [의미/의도] RoundStartButton 파트 이름 ➔ 12일차 라운드 시작 버튼을 식별하기 위함
	SPAWN_POINT_PREFIX    = "SpawnPoint_",             -- [의미/의도] SpawnPoint_ 접두사 ➔ 12일차 스폰 지점 이름을 번호와 함께 짓기 위함
}

-- --------------------------------------------------------------------------------

common.eEngineAttributeKey = { -- [의미/의도] 엔진 Attribute 키 이넘 정의 ➔ 서버/클라이언트가 문자열 키를 공유할 때 오타 없이 같은 계약을 사용하기 위함
	ROUND_STARTER_PLAYER_NAME_RUNTIME = "RoundStarter",  -- [의미/의도] RoundStarter 속성 키 ➔ 라운드를 시작한 플레이어 이름을 런타임에 공유하기 위함
	ROUND_STATE           = "RoundState",                -- [의미/의도] RoundState 속성 키 ➔ 라운드 진행 상태를 서버·클라이언트가 공유하기 위함
	TIME_LEFT_RUNTIME      = "TimeLeft",                 -- [의미/의도] TimeLeft 속성 키 ➔ 남은 시간을 런타임에 공유하기 위함
}

-- --------------------------------------------------------------------------------

common.eRoundStateValue = { -- [의미/의도] 라운드 상태값 이넘 정의 ➔ ROUND_STATE Attribute에 저장되는 진행 상태 문자열을 한곳에서 안전하게 관리하기 위함
	PREPARING = "Preparing",  -- [의미/의도] Preparing 상태 ➔ 라운드 준비 중 단계를 나타내기 위함
	PLAYING   = "Playing",    -- [의미/의도] Playing 상태 ➔ 라운드 진행 중 단계를 나타내기 위함
	FINISHED  = "Finished",   -- [의미/의도] Finished 상태 ➔ 라운드 종료 단계를 나타내기 위함
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
