-- [Module] CoreEnums
local CoreEnums = {}

-- --------------------------------------------------------------------------------
CoreEnums.eEngineServiceSingleton = { -- [의미/의도] 엔진 서비스 싱글턴 이넘 정의 ➔ 오타 방지 및 로블록스 서비스 객체 접근 이름을 안전하게 통합 관리하기 위함
	WORKSPACE          = "Workspace",         -- [의미/의도] Workspace 서비스 키 ➔ 게임 월드(파트·폴더) 공간에 접근하기 위함
	PLAYERS            = "Players",           -- [의미/의도] Players 서비스 키 ➔ 접속 플레이어와 leaderstats를 관리하기 위함
	REPLICATED_STORAGE = "ReplicatedStorage", -- [의미/의도] ReplicatedStorage 서비스 키 ➔ 서버·클라이언트 공유 저장소에 접근하기 위함
	RUN_SERVICE        = "RunService",
	USER_INPUT_SERVICE = "UserInputService",
	PROXIMITY_PROMPT_SERVICE = "ProximityPromptService",
	SERVER_SCRIPT_SERVICE = "ServerScriptService",
	DEBRIS             = "Debris",            -- [의미/의도] Debris 서비스 키 ➔ 생성물을 일정 시간 후 자동 삭제하기 위함
	TEAMS              = "Teams",             -- [의미/의도] Teams 서비스 키 ➔ 진영(팀)을 등록·관리하기 위함
}


-- --------------------------------------------------------------------------------


CoreEnums.eEnginePhysicalType = { -- [의미/의도] 물리(명목) 타입 이넘 정의 ➔ 엔진이 강제하는 .ClassName(실체 타입)을 한곳에서 안전하게 관리하기 위함(Instance.new/IsA에 사용)
	PART             = "Part",            -- [의미/의도] Part 클래스명 ➔ 기본 물리 블록 인스턴스를 만들거나 IsA로 검사하기 위함
	MESH_PART        = "MeshPart",        -- [의미/의도] MeshPart 클래스명 ➔ 룩 에셋이 단일 메시 충돌 후보인지 검사하기 위함
	BASE_PART        = "BasePart",        -- [의미/의도] BasePart 클래스명 ➔ 물리 파트 계열을 포괄적으로 IsA 검사하기 위함
	SPAWN_LOCATION   = "SpawnLocation",   -- [의미/의도] SpawnLocation 클래스명 ➔ 플레이어 시작 위치를 Roblox 스폰 시스템과 직접 연결하기 위함
	MODEL            = "Model",           -- [의미/의도] Model 클래스명 ➔ 여러 파트를 묶는 모델 인스턴스를 만들거나 검사하기 위함
	HUMANOID         = "Humanoid",        -- [의미/의도] Humanoid 클래스명 ➔ 체력·피해 기능을 가진 생명체 컴포넌트를 만들기 위함
	FOLDER           = "Folder",          -- [의미/의도] Folder 클래스명 ➔ 오브젝트를 분류·정리하는 폴더 인스턴스를 만들기 위함
	MODULE_SCRIPT    = "ModuleScript",
	SURFACE_GUI      = "SurfaceGui",
	BILLBOARD_GUI    = "BillboardGui",
	TEXT_LABEL       = "TextLabel",
	SCREEN_GUI       = "ScreenGui",
	FRAME            = "Frame",
	WELD_CONSTRAINT  = "WeldConstraint",
	MOTOR_6D         = "Motor6D",
	TOOL             = "Tool",            -- [의미/의도] Tool 클래스명 ➔ 플레이어가 장착하는 도구 인스턴스를 만들기 위함
	INT_VALUE        = "IntValue",        -- [의미/의도] IntValue 클래스명 ➔ 정수 값을 저장하는 인스턴스를 만들기 위함
	CLICK_DETECTOR   = "ClickDetector",   -- [의미/의도] ClickDetector 클래스명 ➔ 마우스 클릭 감지 컴포넌트를 만들기 위함
	REMOTE_EVENT     = "RemoteEvent",     -- [의미/의도] RemoteEvent 클래스명 ➔ 서버·클라이언트 통신 채널 인스턴스를 만들기 위함
	PARTICLE_EMITTER = "ParticleEmitter", -- [의미/의도] ParticleEmitter 클래스명 ➔ 입자 이펙트 컴포넌트를 만들기 위함
	EXPLOSION        = "Explosion",       -- [의미/의도] Explosion 클래스명 ➔ 폭발 이펙트 인스턴스를 만들기 위함
	TEAM             = "Team",            -- [의미/의도] Team 클래스명 ➔ 진영(팀) 인스턴스를 만들기 위함
	ATTACHMENT       = "Attachment",      -- [의미/의도] Attachment 클래스명 ➔ 파티클 이펙트를 파트 위 특정 지점에 부착하기 위함
	PROXIMITY_PROMPT = "ProximityPrompt", -- [의미/의도] ProximityPrompt 클래스명 ➔ 근접 상호작용(등에 메기) 입력 컴포넌트를 만들기 위함
}


-- --------------------------------------------------------------------------------


CoreEnums.eEngineLogicalType = { -- [의미/의도] 논리 타입 이넘 정의 ➔ .ClassName으로 구분 안 되는 도메인 종류를 .Name으로 표현(RESERVED_는 엔진이 강제하는 불변 예약 이름이라 값 수정 금지)
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
	DEFAULT_SPAWN_LOCATION = "SpawnLocation", -- [의미/의도] Roblox 기본 스폰 이름 ➔ 템플릿 기본 스폰이 수업 전장 스폰과 충돌할 때 비활성화하기 위함
	DEFAULT_BASEPLATE     = "Baseplate",
	ROCK_LOOKS            = "RockLooks",
	STUDENT_ROCK_VALIDATION_BOARD = "StudentRockValidationBoard",
	STUDENT_ROCK_VALIDATION_GUI = "StudentRockValidationGui",
	STUDENT_ROCK_VALIDATION_GUI_BACK = "StudentRockValidationGuiBack",
	STUDENT_ROCK_VALIDATION_TEXT = "StudentRockValidationText",
	STUDENT_ROCK_DESIGNS  = "StudentRockDesigns01",
	STUDENT_BRICK_DESIGNS = "StudentBrickDesigns02",
	STUDENT_RESOURCE_WALL_DESIGNS = "StudentResourceWallDesigns03",
	STUDENT_SWORD_DESIGNS = "StudentSwordDesigns04",
	STUDENT_BOW_DESIGNS = "StudentBowDesigns05",
	STUDENT_SHIELD_DESIGNS = "StudentShieldDesigns06",
	STUDENT_ARMOR_DESIGNS = "StudentArmorDesigns07",
	STUDENT_GATE_DESIGNS = "StudentGateDesigns08",
	STUDENT_STONE_WALL_DESIGNS = "StudentStoneWallDesigns09",
	STUDENT_SIEGE_ENGINE_DESIGNS = "StudentSiegeEngineDesigns10",
	STUDENT_MAGIC_DESIGNS = "StudentMagicDesigns11",
	STUDENT_FINAL_BATTLE_DESIGNS = "StudentFinalBattleDesigns12",
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
	DAMAGE_FEEDBACK_GUI   = "DamageFeedbackGui",
	DAMAGE_FEEDBACK_TEXT  = "DamageFeedbackText",
	THROWING_STONE_LOOK   = "ThrowingStoneLook",
	PROJECTILE_ALL        = "Projectile",  -- [의미/의도] 공통 투사체 이름 ➔ 방어/충돌 규칙에서 넓게 투사체를 구분하기 위함
	PROJECTILE_ARROW      = "Arrow",       -- [의미/의도] 화살 이름 ➔ 화살 계열 투사체를 구분하기 위함
	PROJECTILE_ARROW_FIELD = "FieldArrow", -- [의미/의도] 전장 화살 이름 ➔ 원거리 무기 수업의 서버 생성 화살을 구분하기 위함
	SIEGE_STONE           = "SiegeStone",   -- [의미/의도] 중장비 탄환 이름 ➔ 문/벽 피해를 주는 무거운 탄환을 구분하기 위함

	COVER_MARKER_PREFIX   = "CoverMarker_",  -- [의미/의도] 엄폐물 배치 마커 접두사 ➔ 학생 건축 위치 힌트를 번호로 구분하기 위함
	COVER_BLOCK_PREFIX    = "CoverBlock_",   -- [의미/의도] 엄폐 블록 접두사 ➔ 엄폐물 모델 내부 블록을 층별로 구분하기 위함
	COVER_STUDENT_PREFIX  = "StudentCover_", -- [의미/의도] 학생 엄폐물 접두사 ➔ 학생이 만든 엄폐 모델을 구분하기 위함
	STACK_BRICK           = "StackBrick",    -- [의미/의도] 2일차 빌딩 재료 Tool 타입 ➔ 돌멩이와 같은 파밍/투척/배치 흐름으로 쓰기 위함
	STACK_BRICK_PREFIX    = "StackBrick_",   -- [의미/의도] 2일차 물리 벽돌 접두사 ➔ 학생 벽돌 디자인으로 생성된 쌓기 재료를 구분하기 위함
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
	THROWING_STONE_AIM    = "ThrowingStoneAim", -- [의미/의도] 돌 투척 조준 RemoteEvent 이름 ➔ 클라이언트 커서 조준점을 서버 투척 판정에 전달하기 위함
	FIST_ATTACK           = "FistAttack",       -- [의미/의도] 빈손 타격 RemoteEvent 이름 ➔ 기본 좌클릭 근접 공격을 서버 판정으로 처리하기 위함
	CAST_MAGIC            = "CastMagic",    -- [의미/의도] 마법 시전 RemoteEvent 이름 ➔ 클라이언트 입력과 서버 판정을 연결하기 위함
	SPECIALIZATION_SELECT = "SpecializationSelect", -- [의미/의도] 플레이어 특화(힘/민첩/체력) 선택 RemoteEvent 이름 ➔ 1일차 특화 선택 통신에 사용하기 위함
	DROP_CARRIED_BLOCK    = "DropCarriedBlock", -- [의미/의도] 장착한 돌/벽돌 Tool 배치 RemoteEvent 이름 ➔ Q 빌딩 배치를 서버와 연결하기 위함

	TEAM_BLUE             = "Blue",             -- [의미/의도] 청팀 이름 ➔ 전초기지 공방전 팀 구분에 사용하기 위함
	TEAM_RED              = "Red",              -- [의미/의도] 홍팀 이름 ➔ 전초기지 공방전 팀 구분에 사용하기 위함
	TEAM_SYMBOL_PREFIX    = "TeamSymbol_",      -- [의미/의도] 팀 상징물 접두사 ➔ 1일차부터 공격할 상대 진영을 눈으로 구분하기 위함
	TEAM_SYMBOL_POLE      = "TeamSymbolPole",   -- [의미/의도] 팀 깃대 이름 ➔ 상징물 모델 내부의 기준 기둥을 식별하기 위함
	TEAM_SYMBOL_BANNER    = "TeamSymbolBanner", -- [의미/의도] 팀 깃발 이름 ➔ 팀 색상 상징 면을 식별하기 위함
	ROUND_START_BUTTON    = "RoundStartButton", -- [의미/의도] 라운드 시작 버튼 이름 ➔ 최종 목표전 시작 입력 장치를 식별하기 위함
	SPAWN_POINT_NEUTRAL   = "SpawnPoint_Neutral", -- [의미/의도] 과거 중립 스폰 지점 이름 ➔ 이전 실행 흔적을 정리할 때 같은 이름을 안전하게 찾기 위함
	SPAWN_POINT_PREFIX    = "SpawnPoint_",      -- [의미/의도] 스폰 지점 접두사 ➔ 팀별 스폰 패드를 이름으로 구분하기 위함

	RESERVED_UPPER_TORSO  = "UpperTorso",       -- [의미/의도] R15 상체 예약 이름 ➔ 짊어진 자원 블록을 Weld할 기준 부위를 .Name으로 찾기 위함(수정 금지)
	RESERVED_TORSO        = "Torso",            -- [의미/의도] R6 몸통 예약 이름 ➔ R6 리그에서 자원 블록 Weld 기준 부위를 .Name으로 찾기 위함(수정 금지)
	CORE_BLOCK            = "CoreBlock",         -- [의미/의도] 다목적 물리 블록 .Name ➔ 채굴/짊어지기/방벽/투사체로 쓰는 공통 블록을 식별하기 위함
	CARRIED_RESOURCES     = "CarriedResources",  -- [의미/의도] 짊어진 자원 폴더 .Name ➔ 플레이어 캐릭터가 등에 멘 자원 블록을 모아 관리하기 위함
	RESOURCE_DROP_PREFIX  = "ResourceDrop_",     -- [의미/의도] 자원 드랍 조각 .Name 접두사 ➔ 블록 파괴 시 흩어지는 획득 가능한 자원 파편을 구분하기 위함
}


-- --------------------------------------------------------------------------------


CoreEnums.eEngineAttributeKey = { -- [의미/의도] 엔진 Attribute 키 이넘 정의 ➔ 서버/클라이언트가 문자열 키를 공유할 때 오타 없이 같은 계약을 사용하기 위함
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
	FIELD_ITEM_WORLD_ANCHORED = "FieldItemWorldAnchored",
	FIELD_ITEM_WORLD_CAN_COLLIDE = "FieldItemWorldCanCollide",
	FIELD_ITEM_WORLD_MASSLESS = "FieldItemWorldMassless",
	FIELD_ITEM_LOOK_SHAPE = "LookShape",
	DAMAGE_FEEDBACK_SCORE  = "DamageFeedbackScore",

	BLOCK_MAX_HEALTH       = "MaxHealth",     -- [의미/의도] 블록 최대 체력 키 ➔ CoreBlock 방벽/엄폐물의 내구도 상한을 런타임에 공유하기 위함
	BLOCK_HEALTH           = "Health",        -- [의미/의도] 블록 현재 체력 키 ➔ 피해 누적과 파괴 판정을 속성으로 추적하기 위함
	BLOCK_RESOURCE_YIELD   = "ResourceYield", -- [의미/의도] 블록 자원 산출량 키 ➔ 채굴/파괴 시 떨어질 자원 양을 공유하기 위함
	BLOCK_RESOURCE_TYPE    = "ResourceType",  -- [의미/의도] 블록 자원 종류 키 ➔ Gold/Wood/Stone 등 자원 종류를 구분하기 위함
	BLOCK_DAMAGE           = "Damage",        -- [의미/의도] 블록 공격력 키 ➔ 투사체로 쓰일 때 가할 피해량을 공유하기 위함
	BLOCK_IS_MINING        = "IsMining",      -- [의미/의도] 블록 채굴 진행 플래그 ➔ 채굴 중복 처리를 막기 위함
	BLOCK_IS_PROJECTILE    = "IsProjectile",  -- [의미/의도] 블록 투사체 상태 플래그 ➔ 발사된 블록의 상호작용을 분기하기 위함
	BLOCK_IS_CARRIED       = "IsCarried",     -- [의미/의도] 블록 짊어짐 상태 플래그 ➔ 등에 멘 블록의 피해/상호작용을 차단하기 위함
	BLOCK_CAN_MINE         = "CanMine",       -- [의미/의도] 블록 채굴 허용 플래그 ➔ 채굴 가능 여부를 속성으로 통제하기 위함
	BLOCK_CAN_TAKE_DAMAGE  = "CanTakeDamage", -- [의미/의도] 블록 피해 허용 플래그 ➔ 파괴 가능 여부를 속성으로 통제하기 위함
	BLOCK_ORIGINAL_SIZE    = "OriginalSize",  -- [의미/의도] 블록 원본 크기 키 ➔ 짊어지며 축소된 블록을 드롭 시 원래 크기로 복구하기 위함
	RESOURCE_DROP_VALUE    = "Value",         -- [의미/의도] 자원 조각 가치 키 ➔ 획득한 자원 파편의 점수/수량 가치를 공유하기 위함
}


-- --------------------------------------------------------------------------------


CoreEnums.eRoundStateValue = { -- [의미/의도] 라운드 상태값 이넘 정의 ➔ ROUND_STATE Attribute에 저장되는 진행 상태 문자열을 한곳에서 안전하게 관리하기 위함
	PREPARING = "Preparing", -- [의미/의도] Preparing 상태 ➔ 라운드 준비 중 단계를 나타내기 위함
	PLAYING   = "Playing",   -- [의미/의도] Playing 상태 ➔ 라운드 진행 중 단계를 나타내기 위함
	FINISHED  = "Finished",  -- [의미/의도] Finished 상태 ➔ 라운드 종료 단계를 나타내기 위함
}


-- --------------------------------------------------------------------------------


CoreEnums.eStudentLessonDesignConceptKey = {
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


function CoreEnums.hasEngineLogicalNamePrefix(strName, strPrefix) -- [의미/의도] 엔진 논리 이름이 지정된 enum 접두사로 시작하는지 검사 ➔ 부분 문자열 검색이 다른 logical type 경계를 침범하지 않도록 접두사 기준으로만 판정하기 위함
	return strName:sub(1, #strPrefix) == strPrefix -- [의미/의도] 이름 앞부분이 접두사와 정확히 일치하는지 반환 ➔ "TargetPoint"처럼 접두사 경계가 다른 이름을 오인하지 않도록 하기 위함
end

-- --------------------------------------------------------------------------------

return CoreEnums
