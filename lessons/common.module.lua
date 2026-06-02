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
		- 게임 오브젝트 이름: 누적 공성전 월드에서는 역할 이름을 우선하고, 최초 추가 회차를 구분해야 할 때만 숫자 접미사를 사용
	* enum 기반 객체 호출 선언: local fldBattlefield = ..., local partRock = ...처럼 소문자 축약타입 + 카멜케이스로 작성

	2) 접두사 레퍼런스 표 (Prefix Reference Table)
	* 게임 오브젝트 타입 (타입명을 3~5글자로 축약, 원래 5글자 이하는 그대로)
		- svc           : game:GetService()로 가져오는 엔진 싱글턴 서비스 객체 (예: svcWorkspace)
		- fld           : Folder 인스턴스 (예: fldBattlefield)
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

	SIEGE_WORLD           = "SiegeWorld",              -- [의미/의도] 누적 공성전 월드 루트 ➔ 모든 회차에서 같은 전장을 이어 쓰기 위함
	BATTLEFIELD           = "Battlefield",             -- [의미/의도] 전투 공간 폴더 ➔ 바닥, 엄폐물, 라운드 버튼, 스폰 지점을 한 전장 안에서 관리하기 위함
	BATTLEFIELD_BASE      = "BattlefieldBase",         -- [의미/의도] 전장 바닥 Part ➔ 첫 회차부터 마지막 회차까지 플레이 가능한 공통 바닥을 유지하기 위함
	BUILD_AREA            = "BuildArea",               -- [의미/의도] 건설/방벽 영역 폴더 ➔ 버튼, 방벽 소환 위치, 학생 건축물을 누적 관리하기 위함
	TARGET_AREA           = "TargetArea",              -- [의미/의도] 연습 타겟 영역 폴더 ➔ 더미와 과녁을 같은 전장 안에서 누적 관리하기 위함
	CASTLE                = "Castle",                  -- [의미/의도] 성 구조물 폴더 ➔ 성문과 석조 성벽을 공통 성 영역에서 관리하기 위함
	GATE                  = "Gate",                    -- [의미/의도] 성문 모델 이름 ➔ 공성 공격의 핵심 목표물을 식별하기 위함
	STONE_WALL            = "StoneWall",               -- [의미/의도] 석조 성벽 모델 이름 ➔ 성문 주변의 부분 파괴 가능한 벽을 식별하기 위함
	SIEGE_ENGINE          = "SiegeEngine",             -- [의미/의도] 공성 병기 폴더 ➔ 발사 버튼과 탄환 발사 기준점을 한곳에서 관리하기 위함

	PRACTICE_DUMMY_PREFIX = "PracticeDummy_",          -- [의미/의도] 기본 연습 더미 접두사 ➔ 전장 타격 대상을 번호로 구분하기 위함
	COOLDOWN_DUMMY_PREFIX = "CooldownDummy_",          -- [의미/의도] 쿨타임 연습 더미 접두사 ➔ 무기 밸런스 실험 대상을 구분하기 위함
	MAGIC_DUMMY_PREFIX    = "MagicDummy_",             -- [의미/의도] 마법 연습 더미 접두사 ➔ 광역 스킬 실험 대상을 구분하기 위함
	TARGET_PREFIX         = "Target_",                 -- [의미/의도] 과녁 접두사 ➔ 투사체 명중 피드백 대상을 구분하기 위함

	PRACTICE_ROCK         = "PracticeRock",            -- [의미/의도] 연습용 돌 도구 이름 ➔ 첫 플레이 가능한 기본 공격 도구를 식별하기 위함
	BALANCE_SWORD         = "BalanceSword",            -- [의미/의도] 밸런스 검 도구 이름 ➔ 쿨타임과 데미지 조정 실험 무기를 식별하기 위함
	TRAINING_BOW          = "TrainingBow",             -- [의미/의도] 훈련용 활 도구 이름 ➔ 원거리 투사체 무기를 식별하기 위함
	PRACTICE_SHIELD       = "PracticeShield",          -- [의미/의도] 연습용 방패 도구 이름 ➔ 방어 장비를 식별하기 위함
	HEAVY_ARMOR           = "HeavyArmor",              -- [의미/의도] 무거운 갑옷 도구 이름 ➔ 이동 패널티 장비를 식별하기 위함
	MAGIC_STAFF           = "MagicStaff",              -- [의미/의도] 마법 지팡이 도구 이름 ➔ RemoteEvent 기반 스킬 입력 장비를 식별하기 위함

	THROWN_PRACTICE_ROCK  = "ThrownPracticeRock",      -- [의미/의도] 던져진 돌 투사체 이름 ➔ 충돌 판정에서 기본 투사체를 구분하기 위함
	PROJECTILE_ALL        = "Projectile",              -- [의미/의도] 공통 투사체 이름 ➔ 방어/충돌 규칙에서 넓게 투사체를 구분하기 위함
	PROJECTILE_ARROW      = "Arrow",                   -- [의미/의도] 화살 이름 ➔ 화살 계열 투사체를 구분하기 위함
	PROJECTILE_ARROW_TRAINING = "TrainingArrow",       -- [의미/의도] 훈련 화살 이름 ➔ 원거리 무기 수업의 서버 생성 화살을 구분하기 위함
	SIEGE_STONE           = "SiegeStone",              -- [의미/의도] 공성 돌 탄환 이름 ➔ 성문/성벽 피해를 주는 공성 탄환을 구분하기 위함

	COVER_MARKER_PREFIX   = "CoverMarker_",            -- [의미/의도] 엄폐물 배치 마커 접두사 ➔ 학생 건축 위치 힌트를 번호로 구분하기 위함
	COVER_BLOCK_PREFIX    = "CoverBlock_",             -- [의미/의도] 엄폐 블록 접두사 ➔ 엄폐물 모델 내부 블록을 층별로 구분하기 위함
	COVER_STUDENT_PREFIX  = "StudentCover_",           -- [의미/의도] 학생 엄폐물 접두사 ➔ 학생이 만든 엄폐 모델을 구분하기 위함
	BUILD_BUTTON          = "BuildButton",             -- [의미/의도] 건설 버튼 이름 ➔ 자원 기반 방벽 생성 입력 장치를 식별하기 위함
	WALL_SPAWN            = "WallSpawn",               -- [의미/의도] 방벽 생성 위치 이름 ➔ 방벽이 실제로 생길 기준 좌표를 식별하기 위함
	WALL_BLOCK_SUFFIX     = "_WallBlock",              -- [의미/의도] 방벽 블록 접미사 ➔ 플레이어가 만든 방벽 블록을 추적하기 위함
	WOOD                  = "Wood",                    -- [의미/의도] 나무 자원 이름 ➔ leaderstats에 표시되는 건설 자원 수량을 식별하기 위함

	ARMOR_AURA            = "ArmorAura",               -- [의미/의도] 갑옷 오라 이름 ➔ 장착 이펙트를 찾아 제거하거나 관리하기 위함
	GATE_PLANK_PREFIX     = "GatePlank_",              -- [의미/의도] 성문 판자 접두사 ➔ 성문을 이루는 개별 판자를 번호로 구분하기 위함
	WALL_SECTION_PREFIX   = "WallSection_",            -- [의미/의도] 성벽 구역 접두사 ➔ 부분 파괴되는 성벽 구역을 번호로 구분하기 위함
	STONE_BLOCK_PREFIX    = "StoneBlock_",             -- [의미/의도] 석조 블록 접두사 ➔ 성벽 섹션 내부 블록을 층별로 구분하기 위함
	LAUNCH_BUTTON         = "LaunchButton",            -- [의미/의도] 공성 병기 발사 버튼 이름 ➔ 원격 발사 입력 장치를 식별하기 위함
	LAUNCH_POINT          = "LaunchPoint",             -- [의미/의도] 공성 탄환 발사 지점 이름 ➔ 탄환 생성 시작 좌표를 식별하기 위함
	TARGET_POINT          = "TargetPoint",             -- [의미/의도] 공성 탄환 목표 지점 이름 ➔ 탄환이 향할 기준 좌표를 식별하기 위함
	CAST_MAGIC            = "CastMagic",               -- [의미/의도] 마법 시전 RemoteEvent 이름 ➔ 클라이언트 입력과 서버 판정을 연결하기 위함

	TEAM_BLUE             = "Blue",                    -- [의미/의도] 청팀 이름 ➔ 공성전 팀 구분에 사용하기 위함
	TEAM_RED              = "Red",                     -- [의미/의도] 홍팀 이름 ➔ 공성전 팀 구분에 사용하기 위함
	ROUND_START_BUTTON    = "RoundStartButton",        -- [의미/의도] 라운드 시작 버튼 이름 ➔ 최종 공성전 시작 입력 장치를 식별하기 위함
	SPAWN_POINT_PREFIX    = "SpawnPoint_",             -- [의미/의도] 스폰 지점 접두사 ➔ 팀별 스폰 패드를 번호로 구분하기 위함
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

function common.applyInstanceProperties(instanceTarget, tblProperties) -- [의미/의도] 인스턴스 속성 묶음 적용 함수 정의 ➔ Size/Position/Material 같은 반복 속성 대입을 한곳에서 처리하기 위함
	if tblProperties then                                            -- [의미/의도] 속성 테이블이 전달된 경우만 처리 ➔ 설정할 속성이 없는 호출도 안전하게 허용하기 위함
		for strPropertyName, valueProperty in pairs(tblProperties) do -- [의미/의도] 속성 이름과 값을 순회 ➔ 테이블에 담긴 설정을 인스턴스에 일괄 반영하기 위함
			instanceTarget[strPropertyName] = valueProperty                -- [의미/의도] 대상 인스턴스 속성에 값을 대입 ➔ Roblox Properties 창에서 수동 설정하던 값을 코드로 적용하기 위함
		end                                                            -- [의미/의도] 속성 순회 반복문 종료 ➔ 모든 속성 적용을 마침
	end                                                               -- [의미/의도] 속성 테이블 존재 조건문 종료 ➔ 반환 단계로 이동하기 위함

	return instanceTarget                                             -- [의미/의도] 설정된 인스턴스를 반환 ➔ 호출자가 이어서 추가 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.resetNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 삭제 후 재생성 함수 정의 ➔ 수업장을 깨끗하게 초기화해야 하는 예외 상황에 사용하기 위함
	local instanceOld = instanceParent:FindFirstChild(strName)                           -- [의미/의도] 부모 아래에서 같은 이름의 기존 객체를 검색 ➔ 재생성 전에 이전 객체를 지우기 위함
	if instanceOld then                                                                  -- [의미/의도] 기존 객체가 있다면 ➔ 이전 수업 실행 흔적을 제거하기 위함
		instanceOld:Destroy()                                                               -- [의미/의도] 기존 객체 삭제 ➔ 오래된 파트나 스크립트가 새 설정과 충돌하지 않게 하기 위함
	end                                                                                  -- [의미/의도] 기존 객체 삭제 조건문 종료 ➔ 새 객체 생성 단계로 이동하기 위함

	local instanceNew = Instance.new(strClassName)                         -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성 ➔ 수업 오브젝트를 코드로 만들기 위함
	instanceNew.Name = strName                                             -- [의미/의도] 인스턴스 이름을 지정 ➔ 학생 코드와 Explorer에서 같은 이름으로 찾을 수 있게 하기 위함
	common.applyInstanceProperties(instanceNew, tblProperties)             -- [의미/의도] 전달된 속성 묶음을 적용 ➔ 생성 직후 필요한 설정을 한 번에 반영하기 위함
	instanceNew.Parent = instanceParent                                    -- [의미/의도] 인스턴스 부모를 지정 ➔ 올바른 폴더/모델/서비스 아래에 배치하기 위함
	return instanceNew                                                     -- [의미/의도] 새 인스턴스 반환 ➔ 호출한 setup 코드에서 변수로 보관할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createOrReplaceInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 기존 인스턴스 대체 생성 호환 함수 정의 ➔ 삭제 재생성이 필요한 경우 기존 호출명을 계속 사용할 수 있게 하기 위함
	return common.resetNamedInstance(strClassName, strName, instanceParent, tblProperties)    -- [의미/의도] resetNamedInstance에 위임 ➔ 삭제 재생성 정책을 한곳에서 관리하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 보장 함수 정의 ➔ 누적형 공성전 월드에서 기존 오브젝트를 지우지 않고 재사용하기 위함
	local instanceTarget = instanceParent:FindFirstChild(strName)                   -- [의미/의도] 부모 아래에서 같은 이름의 객체 검색 ➔ 이미 만든 콘텐츠를 다음 회차에서도 유지하기 위함
	if instanceTarget and not instanceTarget:IsA(strClassName) then                 -- [의미/의도] 같은 이름이지만 타입이 다르다면 ➔ 잘못된 오브젝트가 학생 코드 참조를 막지 않게 하기 위함
		instanceTarget:Destroy()                                                       -- [의미/의도] 잘못된 타입 객체 삭제 ➔ 올바른 타입으로 다시 보장하기 위함
		instanceTarget = nil                                                           -- [의미/의도] 재생성 필요 상태로 초기화 ➔ 아래 생성 분기가 실행되게 하기 위함
	end                                                                              -- [의미/의도] 타입 점검 조건문 종료 ➔ 재사용 또는 생성 단계로 이동하기 위함

	if not instanceTarget then                                                       -- [의미/의도] 대상 객체가 없으면 ➔ 새로 필요한 수업 오브젝트를 만들기 위함
		instanceTarget = Instance.new(strClassName)                                      -- [의미/의도] 요청한 타입의 인스턴스 생성 ➔ 누락된 오브젝트를 보강하기 위함
		instanceTarget.Name = strName                                                    -- [의미/의도] 이름 지정 ➔ 학생/시스템 코드가 같은 이름으로 찾을 수 있게 하기 위함
		instanceTarget.Parent = instanceParent                                           -- [의미/의도] 부모 지정 ➔ 누적 공성전 월드의 올바른 계층에 배치하기 위함
	end                                                                              -- [의미/의도] 생성 조건문 종료 ➔ 속성 보정 단계로 이동하기 위함

	common.applyInstanceProperties(instanceTarget, tblProperties)                    -- [의미/의도] 속성 보정 ➔ 기존 객체를 유지하되 크기/위치/재질 같은 기준값은 수업 표준으로 맞추기 위함
	return instanceTarget                                                           -- [의미/의도] 보장된 인스턴스 반환 ➔ 호출부에서 이어서 사용할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 보장 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] ensureNamedInstance에 위임 ➔ 삭제 없이 기존 콘텐츠를 재사용하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] 고정 Part 보장 함수 정의 ➔ 바닥/버튼/마커가 회차마다 삭제되지 않고 누적 유지되도록 하기 위함
	local tblPartProperties = tblProperties or {}                       -- [의미/의도] 속성 테이블 기본값 준비 ➔ 호출자가 속성을 생략해도 안전하게 처리하기 위함
	tblPartProperties.Anchored = tblPartProperties.Anchored ~= false    -- [의미/의도] 기본 Anchored=true 설정 ➔ 명시적으로 false를 준 경우를 제외하고 setup 오브젝트를 고정하기 위함
	return common.ensureNamedInstance(common.eEnginePhysicalType.PART, strName, instanceParent, tblPartProperties) -- [의미/의도] Part 보장 실행 ➔ 기존 Part는 유지하고 필요한 속성만 보정하기 위함
end

-- --------------------------------------------------------------------------------

function common.createStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] 고정 Part 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] ensureStaticPart에 위임 ➔ 같은 이름의 Part가 중복 생성되지 않게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ClickDetector 보장 함수 정의 ➔ 버튼 setup 재실행 시 감지기가 중복 생성되지 않게 하기 위함
	local clickDetector = partParent:FindFirstChildOfClass(common.eEnginePhysicalType.CLICK_DETECTOR) -- [의미/의도] 기존 ClickDetector 검색 ➔ 이미 연결된 클릭 컴포넌트를 재사용하기 위함
	if not clickDetector then                                                                         -- [의미/의도] 클릭 감지기가 없다면 ➔ 버튼 기능을 새로 추가하기 위함
		clickDetector = Instance.new(common.eEnginePhysicalType.CLICK_DETECTOR)                           -- [의미/의도] 새 ClickDetector 생성 ➔ Part를 마우스로 클릭 가능한 버튼으로 만들기 위함
		clickDetector.Parent = partParent                                                                 -- [의미/의도] 클릭 감지기를 대상 Part 아래에 배치 ➔ 해당 Part 클릭 이벤트가 활성화되게 하기 위함
	end                                                                                               -- [의미/의도] 생성 조건문 종료 ➔ 거리 보정 단계로 이동하기 위함

	clickDetector.MaxActivationDistance = intMaxActivationDistance                                    -- [의미/의도] 클릭 가능 거리 보정 ➔ 회차별 버튼 사용 거리 기준을 유지하기 위함
	return clickDetector                                                                              -- [의미/의도] 보장된 ClickDetector 반환 ➔ 필요하면 호출부에서 추가 설정할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ClickDetector 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ensureClickDetector에 위임 ➔ 감지기 중복 생성을 막기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] Tool과 Handle 보장 함수 정의 ➔ 학생 스크립트나 커스터마이즈가 붙은 Tool을 삭제하지 않고 규격만 보정하기 위함
	local toolTarget = common.ensureNamedInstance(common.eEnginePhysicalType.TOOL, strToolName, instanceParent) -- [의미/의도] Tool 보장 ➔ 기존 장비와 내부 Script를 유지하면서 없으면 생성하기 위함
	toolTarget.RequiresHandle = true                                                                            -- [의미/의도] Handle 필요 설정 ➔ Roblox 장착 규칙에 맞게 손잡이 파트를 사용하기 위함
	toolTarget.ToolTip = strToolTip                                                                             -- [의미/의도] Tool 설명 문구 보정 ➔ 플레이어가 장비 기능을 툴팁으로 확인할 수 있게 하기 위함

	local partHandle = common.ensureNamedInstance(common.eEnginePhysicalType.PART, common.eEngineLogicalType.RESERVED_HANDLE, toolTarget, tblHandleProperties) -- [의미/의도] Handle Part 보장 ➔ Tool이 캐릭터 손에 부착될 기준 파트를 유지 또는 생성하기 위함

	return toolTarget, partHandle                                                                               -- [의미/의도] Tool과 Handle 반환 ➔ 호출부가 필요한 경우 두 객체를 추가 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] Tool과 Handle 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] ensureToolWithHandle에 위임 ➔ Tool 내부 콘텐츠 삭제를 피하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureHumanoidDummy(strName, instanceParent, tblRootPartProperties, tblHumanoidProperties) -- [의미/의도] 연습용 Humanoid 더미 보장 함수 정의 ➔ 더미가 회차 재실행 때 삭제되지 않고 위치/체력 기준만 보정되게 하기 위함
	local modelDummy = common.ensureNamedInstance(common.eEnginePhysicalType.MODEL, strName, instanceParent) -- [의미/의도] 더미 Model 보장 ➔ 몸통 파트와 Humanoid를 하나의 생명체 모델로 묶기 위함
	local partHumanoidRoot = common.ensureStaticPart(common.eEngineLogicalType.RESERVED_HUMANOID_ROOT_PART, modelDummy, tblRootPartProperties) -- [의미/의도] HumanoidRootPart 보장 ➔ 데미지 판정과 위치 기준이 되는 중심 파트를 유지 또는 생성하기 위함
	local humDummy = common.ensureNamedInstance(common.eEnginePhysicalType.HUMANOID, common.eEnginePhysicalType.HUMANOID, modelDummy, tblHumanoidProperties) -- [의미/의도] Humanoid 보장 ➔ 더미가 체력과 피해 처리를 가진 타겟이 되게 하기 위함

	return modelDummy, partHumanoidRoot, humDummy                                                              -- [의미/의도] 더미 구성 객체 반환 ➔ 호출부에서 필요 시 세부 조작할 수 있게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.createHumanoidDummy(strName, instanceParent, tblRootPartProperties, tblHumanoidProperties) -- [의미/의도] 연습용 Humanoid 더미 생성 호환 함수 정의 ➔ 기존 helper 호출을 누적형 ensure 정책으로 연결하기 위함
	return common.ensureHumanoidDummy(strName, instanceParent, tblRootPartProperties, tblHumanoidProperties) -- [의미/의도] ensureHumanoidDummy에 위임 ➔ 더미 중복 생성을 막고 기존 타겟을 유지하기 위함
end

-- --------------------------------------------------------------------------------

function common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 보장 함수 정의 ➔ 어떤 회차부터 실행해도 같은 기본 전장 구조가 유지되게 하기 위함
	local ePhysical = common.eEnginePhysicalType -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ Folder/Part 생성 타입을 간단히 쓰기 위함
	local eLogical = common.eEngineLogicalType   -- [의미/의도] 논리 이름 이넘 단축 참조 ➔ 공성전 월드의 표준 이름을 간단히 쓰기 위함

	local fldSiegeWorld = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.SIEGE_WORLD, svcWorkspace)          -- [의미/의도] 공성전 월드 루트 보장 ➔ 모든 회차 콘텐츠를 하나의 월드 아래에 누적하기 위함
	local fldBattlefield = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.BATTLEFIELD, fldSiegeWorld)        -- [의미/의도] 전투 공간 폴더 보장 ➔ 플레이 가능한 중심 전장을 유지하기 위함
	local fldBuildArea = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.BUILD_AREA, fldSiegeWorld)           -- [의미/의도] 건설 영역 폴더 보장 ➔ 방벽과 학생 건축물을 누적하기 위함
	local fldTargetArea = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.TARGET_AREA, fldSiegeWorld)         -- [의미/의도] 타겟 영역 폴더 보장 ➔ 더미와 과녁을 누적하기 위함
	local fldCastle = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.CASTLE, fldSiegeWorld)                  -- [의미/의도] 성 영역 폴더 보장 ➔ 성문과 성벽을 같은 성 구조로 관리하기 위함
	local fldSiegeEngine = common.ensureNamedInstance(ePhysical.FOLDER, eLogical.SIEGE_ENGINE, fldSiegeWorld)       -- [의미/의도] 공성 병기 폴더 보장 ➔ 발사 버튼과 기준점을 누적 관리하기 위함
	local partBattlefieldBase = common.ensureStaticPart(eLogical.BATTLEFIELD_BASE, fldBattlefield, {                -- [의미/의도] 공통 전장 바닥 보장 ➔ 1회차부터 12회차까지 같은 플레이 공간을 유지하기 위함
		Size = Vector3.new(110, 1, 90),
		Position = Vector3.new(0, -0.5, 0),
		Material = Enum.Material.Grass,
	})

	return {
		fldSiegeWorld = fldSiegeWorld,
		fldBattlefield = fldBattlefield,
		fldBuildArea = fldBuildArea,
		fldTargetArea = fldTargetArea,
		fldCastle = fldCastle,
		fldSiegeEngine = fldSiegeEngine,
		partBattlefieldBase = partBattlefieldBase,
	}
end

-- --------------------------------------------------------------------------------

function common.waitForSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 대기 함수 정의 ➔ 학생/시스템 스크립트가 선생님 setup이 만든 공통 구조를 안전하게 참조하기 위함
	local eLogical = common.eEngineLogicalType   -- [의미/의도] 논리 이름 이넘 단축 참조 ➔ WaitForChild 이름을 간단히 쓰기 위함
	local fldSiegeWorld = svcWorkspace:WaitForChild(eLogical.SIEGE_WORLD)       -- [의미/의도] 공성전 월드 루트 대기 ➔ 누적 전장 구조가 준비된 뒤 진행하기 위함
	local fldBattlefield = fldSiegeWorld:WaitForChild(eLogical.BATTLEFIELD)     -- [의미/의도] 전투 공간 폴더 대기 ➔ 바닥/엄폐/스폰/라운드 버튼 참조를 안전하게 하기 위함
	local partBattlefieldBase = fldBattlefield:WaitForChild(eLogical.BATTLEFIELD_BASE) -- [의미/의도] 공통 바닥 Part 대기 ➔ 어떤 회차에서도 같은 플레이 바닥이 준비된 뒤 진행하기 위함
	local fldBuildArea = fldSiegeWorld:WaitForChild(eLogical.BUILD_AREA)        -- [의미/의도] 건설 영역 폴더 대기 ➔ 방벽 버튼과 생성 위치를 안전하게 찾기 위함
	local fldTargetArea = fldSiegeWorld:WaitForChild(eLogical.TARGET_AREA)      -- [의미/의도] 타겟 영역 폴더 대기 ➔ 더미/과녁 참조를 안전하게 하기 위함
	local fldCastle = fldSiegeWorld:WaitForChild(eLogical.CASTLE)               -- [의미/의도] 성 영역 폴더 대기 ➔ 성문/성벽 참조를 안전하게 하기 위함
	local fldSiegeEngine = fldSiegeWorld:WaitForChild(eLogical.SIEGE_ENGINE)    -- [의미/의도] 공성 병기 폴더 대기 ➔ 발사 버튼과 기준점 참조를 안전하게 하기 위함

	return {
		fldSiegeWorld = fldSiegeWorld,
		fldBattlefield = fldBattlefield,
		partBattlefieldBase = partBattlefieldBase,
		fldBuildArea = fldBuildArea,
		fldTargetArea = fldTargetArea,
		fldCastle = fldCastle,
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

function common.readConfigBrickColor(tblConfig, strKey, strDefaultColor) -- [의미/의도] 학생 설정 BrickColor 읽기 함수 정의 ➔ 색상 이름을 안전한 BrickColor 값으로 변환하기 위함
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

function common.markRuntimeInstalled(instanceTarget, strAttributeKey) -- [의미/의도] 런타임 시스템 중복 설치 방지 함수 정의 ➔ 같은 버튼/Tool에 이벤트가 여러 번 연결되는 것을 막기 위함
	if instanceTarget:GetAttribute(strAttributeKey) then -- [의미/의도] 이미 설치 표시가 있으면 ➔ 중복 이벤트 연결을 차단하기 위함
		return false
	end

	instanceTarget:SetAttribute(strAttributeKey, true) -- [의미/의도] 설치 완료 표시 저장 ➔ 이후 같은 시스템이 다시 연결되지 않게 하기 위함
	return true -- [의미/의도] 이번 호출에서 설치 가능함을 반환 ➔ 호출부가 이벤트를 연결하게 하기 위함
end

-- --------------------------------------------------------------------------------

function common.applyToolHandleStudentStyle(toolTarget, tblConfig) -- [의미/의도] Tool Handle 학생 스타일 적용 함수 정의 ➔ 학생이 외형만 바꿀 수 있게 크기/재질/색을 제한적으로 반영하기 위함
	local tblHandleConfig = tblConfig and tblConfig.Handle or {} -- [의미/의도] Handle 설정 테이블 준비 ➔ 학생이 생략한 값은 기존 기본값을 쓰기 위함
	local partHandle = common.ensureNamedInstance(common.eEnginePhysicalType.PART, common.eEngineLogicalType.RESERVED_HANDLE, toolTarget)
	partHandle.Size = common.readConfigVector3(tblHandleConfig, "Size", partHandle.Size, Vector3.new(0.2, 0.2, 0.2), Vector3.new(8, 8, 8))
	partHandle.Material = common.readConfigEnumItem(tblHandleConfig, "Material", partHandle.Material)
	partHandle.BrickColor = common.readConfigBrickColor(tblHandleConfig, "Color", partHandle.BrickColor.Name)
	return partHandle
end

-- --------------------------------------------------------------------------------

function common.isCombatProjectileName(strName) -- [의미/의도] 전투 투사체 이름 판별 함수 정의 ➔ 성문/성벽/방패가 받을 수 있는 공격 투사체를 공통으로 구분하기 위함
	local eLogical = common.eEngineLogicalType
	return strName == eLogical.THROWN_PRACTICE_ROCK
		or strName == eLogical.PROJECTILE_ARROW_TRAINING
		or strName == eLogical.PROJECTILE_ALL
		or strName == eLogical.SIEGE_STONE
end

-- --------------------------------------------------------------------------------

function common.installPracticeRockTool(toolPracticeRock, tblConfig) -- [의미/의도] 연습 돌멩이 서버 시스템 설치 함수 정의 ➔ 학생 파일에는 외형/수치 설정만 남기고 실제 공격 규칙은 서버 공통 코드가 처리하기 위함
	if not common.markRuntimeInstalled(toolPracticeRock, "RuntimeInstalled_PracticeRock") then
		return
	end

	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	common.applyToolHandleStudentStyle(toolPracticeRock, tblConfig)

	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 15, 1, 30)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 0.8, 0.2, 3)
	local numberSpeed = common.readConfigNumber(tblConfig, "Speed", 90, 20, 140)
	local numberArc = common.readConfigNumber(tblConfig, "Arc", 12, 0, 60)
	local numberKnockbackForward = common.readConfigNumber(tblConfig, "KnockbackForward", 45, 0, 80)
	local numberKnockbackUp = common.readConfigNumber(tblConfig, "KnockbackUp", 18, 0, 60)
	local numberLifetime = common.readConfigNumber(tblConfig, "Lifetime", 5, 1, 12)
	local vectorProjectileSize = common.readConfigVector3(tblConfig, "ProjectileSize", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0.3, 0.3, 0.3), Vector3.new(4, 4, 4))
	local enumProjectileMaterial = common.readConfigEnumItem(tblConfig, "ProjectileMaterial", Enum.Material.Slate)
	local brickProjectileColor = common.readConfigBrickColor(tblConfig, "ProjectileColor", "Dark stone grey")
	local boolReady = true

	toolPracticeRock.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolPracticeRock.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partRock = Instance.new(ePhysical.PART)
		partRock.Name = eLogical.THROWN_PRACTICE_ROCK
		partRock.Shape = Enum.PartType.Ball
		partRock.Size = vectorProjectileSize
		partRock.Material = enumProjectileMaterial
		partRock.BrickColor = brickProjectileColor
		partRock.Position = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0)
		partRock.Parent = workspace
		partRock.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberSpeed + Vector3.new(0, numberArc, 0)
		svcDebris:AddItem(partRock, numberLifetime)

		local boolHitOnce = false
		partRock.Touched:Connect(function(partHit)
			if boolHitOnce then return end

			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
			if not humTarget or modelTarget == modelCharacter then return end

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
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local fldBattlefield = tblSiegeWorld.fldBattlefield
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
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local fldBuildArea = tblSiegeWorld.fldBuildArea
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

function common.installBalanceSwordTool(toolBalanceSword, tblConfig) -- [의미/의도] 밸런스 검 서버 시스템 설치 함수 정의 ➔ 근접 타격 판정과 쿨타임을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolBalanceSword, "RuntimeInstalled_BalanceSword") then
		return
	end

	local ePhysical = common.eEnginePhysicalType
	local partHandle = common.applyToolHandleStudentStyle(toolBalanceSword, tblConfig)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 20, 1, 45)
	local numberActiveTime = common.readConfigNumber(tblConfig, "ActiveTime", 0.25, 0.05, 1)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 1.2, 0.2, 5)
	local brickActiveColor = common.readConfigBrickColor(tblConfig, "ActiveColor", "Really red")
	local brickIdleColor = common.readConfigBrickColor(tblConfig, "IdleColor", "Medium stone grey")
	local boolCanAttack = true

	toolBalanceSword.Activated:Connect(function()
		if not boolCanAttack then return end

		boolCanAttack = false
		local tableAlreadyHit = {}
		partHandle.BrickColor = brickActiveColor

		local connectionTouched = partHandle.Touched:Connect(function(partHit)
			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			if not humTarget or modelTarget == toolBalanceSword.Parent or tableAlreadyHit[humTarget] then return end

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

function common.installTrainingBowTool(toolTrainingBow, tblConfig) -- [의미/의도] 훈련 활 서버 시스템 설치 함수 정의 ➔ 발사체 생성/피해/자동 삭제를 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolTrainingBow, "RuntimeInstalled_TrainingBow") then
		return
	end

	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	common.applyToolHandleStudentStyle(toolTrainingBow, tblConfig)

	local numberSpeed = common.readConfigNumber(tblConfig, "Speed", 110, 30, 160)
	local numberArc = common.readConfigNumber(tblConfig, "Arc", 28, 0, 80)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 18, 1, 35)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 0.9, 0.2, 4)
	local numberLifetime = common.readConfigNumber(tblConfig, "Lifetime", 6, 1, 12)
	local vectorArrowSize = common.readConfigVector3(tblConfig, "ArrowSize", Vector3.new(0.4, 0.4, 3), Vector3.new(0.2, 0.2, 1), Vector3.new(2, 2, 6))
	local enumArrowMaterial = common.readConfigEnumItem(tblConfig, "ArrowMaterial", Enum.Material.Wood)
	local brickTargetHitColor = common.readConfigBrickColor(tblConfig, "TargetHitColor", "Lime green")
	local boolReady = true

	toolTrainingBow.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolTrainingBow.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partArrow = Instance.new(ePhysical.PART)
		partArrow.Name = eLogical.PROJECTILE_ARROW_TRAINING
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
			if humTarget then humTarget:TakeDamage(numberDamage) end
			if common.hasEngineLogicalNamePrefix(partHit.Name, eLogical.TARGET_PREFIX) then
				partHit.BrickColor = brickTargetHitColor
			end
			partArrow:Destroy()
		end)

		task.wait(numberCooldown)
		boolReady = true
	end)
end

-- --------------------------------------------------------------------------------

function common.installPracticeShieldTool(toolPracticeShield, tblConfig) -- [의미/의도] 연습 방패 서버 시스템 설치 함수 정의 ➔ 방어 스탯과 투사체 차단 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolPracticeShield, "RuntimeInstalled_PracticeShield") then
		return
	end

	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local partHandle = common.applyToolHandleStudentStyle(toolPracticeShield, tblConfig)
	local numberBonusHealth = common.readConfigNumber(tblConfig, "BonusHealth", 60, 0, 100)
	local numberBlockHeal = common.readConfigNumber(tblConfig, "BlockHeal", 5, 0, 20)
	local numberWalkSpeedPenalty = common.readConfigNumber(tblConfig, "WalkSpeedPenalty", 2, 0, 8)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolPracticeShield.Equipped:Connect(function()
		modelEquippedCharacter = toolPracticeShield.Parent
		if not modelEquippedCharacter or not modelEquippedCharacter:IsA(ePhysical.MODEL) then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humPlayer then return end

		tableSavedStats = {MaxHealth = humPlayer.MaxHealth, WalkSpeed = humPlayer.WalkSpeed}
		humPlayer.MaxHealth += numberBonusHealth
		humPlayer.Health = math.min(humPlayer.Health + numberBonusHealth, humPlayer.MaxHealth)
		humPlayer.WalkSpeed = math.max(4, humPlayer.WalkSpeed - numberWalkSpeedPenalty)
	end)

	toolPracticeShield.Unequipped:Connect(function()
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
		if partHit.Name ~= eLogical.PROJECTILE_ARROW_TRAINING and partHit.Name ~= eLogical.PROJECTILE_ALL then return end
		if not modelEquippedCharacter then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humPlayer then
			humPlayer.Health = math.min(humPlayer.Health + numberBlockHeal, humPlayer.MaxHealth)
		end
		partHit:Destroy()
	end)
end

-- --------------------------------------------------------------------------------

function common.installHeavyArmorTool(toolHeavyArmor, tblConfig) -- [의미/의도] 무거운 갑옷 서버 시스템 설치 함수 정의 ➔ 장착 스탯과 장식 이펙트 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not common.markRuntimeInstalled(toolHeavyArmor, "RuntimeInstalled_HeavyArmor") then
		return
	end

	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	common.applyToolHandleStudentStyle(toolHeavyArmor, tblConfig)

	local numberMaxHealth = common.readConfigNumber(tblConfig, "MaxHealth", 180, 100, 240)
	local numberHealOnEquip = common.readConfigNumber(tblConfig, "HealOnEquip", 80, 0, 120)
	local numberWalkSpeed = common.readConfigNumber(tblConfig, "WalkSpeed", 10, 4, 20)
	local numberJumpPower = common.readConfigNumber(tblConfig, "JumpPower", 32, 10, 80)
	local numberAuraRate = common.readConfigNumber(tblConfig, "AuraRate", 20, 0, 80)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolHeavyArmor.Equipped:Connect(function()
		modelEquippedCharacter = toolHeavyArmor.Parent
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

	toolHeavyArmor.Unequipped:Connect(function()
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

function common.installGateDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 성문 피해 서버 시스템 설치 함수 정의 ➔ 성문 체력/피격/붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local modelGate = tblSiegeWorld.fldCastle:WaitForChild(eLogical.GATE)
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

function common.installStoneWallDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 석조 성벽 피해 서버 시스템 설치 함수 정의 ➔ 구역별 체력/부분 붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local modelStoneWall = tblSiegeWorld.fldCastle:WaitForChild(eLogical.STONE_WALL)
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

function common.installSiegeEngineSystem(svcWorkspace, tblConfig) -- [의미/의도] 공성 병기 서버 시스템 설치 함수 정의 ➔ 발사 버튼/공성 탄환/쿨타임 규칙을 공통 서버 코드가 책임지게 하기 위함
	local eService = common.eEngineServiceSingleton
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local fldSiegeEngine = tblSiegeWorld.fldSiegeEngine
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
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local eventCastMagic = svcReplicatedStorage:WaitForChild(eLogical.CAST_MAGIC)
	if not common.markRuntimeInstalled(eventCastMagic, "RuntimeInstalled_MagicServer") then
		return
	end

	local numberMaxDistance = common.readConfigNumber(tblConfig, "MaxDistance", 80, 10, 160)
	local numberRadius = common.readConfigNumber(tblConfig, "Radius", 12, 2, 30)
	local numberDamage = common.readConfigNumber(tblConfig, "Damage", 25, 1, 60)
	local numberCooldown = common.readConfigNumber(tblConfig, "Cooldown", 1.8, 0.3, 8)
	local tableLastCastByPlayer = {}

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
		explMagic.Parent = workspace

		for _, object in ipairs(workspace:GetDescendants()) do
			if object:IsA(ePhysical.HUMANOID) then
				local humanoidTarget = object
				local modelTarget = humanoidTarget.Parent
				local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
				if partTargetRoot and (partTargetRoot.Position - targetPosition).Magnitude <= numberRadius and modelTarget ~= modelCharacter then
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

function common.installFinalBattleSystem(svcWorkspace, svcPlayers, tblConfig) -- [의미/의도] 최종 라운드 서버 시스템 설치 함수 정의 ➔ 팀 스폰/라운드 타이머/상태 Attribute를 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = common.eEnginePhysicalType
	local eLogical = common.eEngineLogicalType
	local eAttrKey = common.eEngineAttributeKey
	local eRoundState = common.eRoundStateValue
	local tblSiegeWorld = common.waitForSiegeWorld(svcWorkspace)
	local fldBattlefield = tblSiegeWorld.fldBattlefield
	local partRoundStartButton = fldBattlefield:WaitForChild(eLogical.ROUND_START_BUTTON)
	if not common.markRuntimeInstalled(partRoundStartButton, "RuntimeInstalled_FinalBattle") then
		return
	end

	local intRoundTime = common.readConfigInteger(tblConfig, "RoundTime", 180, 30, 600)
	local numberRespawnHeight = common.readConfigNumber(tblConfig, "RespawnHeight", 4, 1, 12)
	local boolRoundRunning = false

	local function get_spawn_points()
		local tableSpawnPoints = {}
		for _, partChild in ipairs(fldBattlefield:GetChildren()) do
			if common.hasEngineLogicalNamePrefix(partChild.Name, eLogical.SPAWN_POINT_PREFIX) and partChild:IsA(ePhysical.BASE_PART) then
				table.insert(tableSpawnPoints, partChild)
			end
		end
		return tableSpawnPoints
	end

	local function move_players_to_spawns()
		local tableSpawns = get_spawn_points()
		if #tableSpawns == 0 then return end

		for index, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			local modelCharacter = playerPlayer.Character or playerPlayer.CharacterAdded:Wait()
			local partHumanoidRoot = modelCharacter:WaitForChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
			local partSpawn = tableSpawns[((index - 1) % #tableSpawns) + 1]
			partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, numberRespawnHeight, 0))
		end
	end

	local function start_round(playerPlayer)
		if boolRoundRunning then return end

		boolRoundRunning = true
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STARTER_PLAYER_NAME_RUNTIME, playerPlayer.Name)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PREPARING)
		move_players_to_spawns()

		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PLAYING)
		for intTimeLeft = intRoundTime, 0, -1 do
			svcWorkspace:SetAttribute(eAttrKey.TIME_LEFT_RUNTIME, intTimeLeft)
			task.wait(1)
		end

		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.FINISHED)
		boolRoundRunning = false
	end

	common.ensureClickDetector(partRoundStartButton, 30).MouseClick:Connect(start_round)
end

-- --------------------------------------------------------------------------------

return common -- [의미/의도] 공통 모듈 반환 ➔ 외부 스크립트에서 require()로 이 모듈을 로드하여 사용하도록 하기 위함
