--[[
    Roblox Studio 수업 공통 모듈 (Facade)
    역할: 하위 공통 모듈을 하나로 병합하여 레거시 호출 규격을 완벽히 유지하는 엔트리 포인트입니다.
    특징:
      1. 런타임에는 메타테이블 __index 동적 포워딩 및 캐싱을 활용해 유지보수 오버헤드를 제거합니다.
      2. 개발 환경(LSP)에서는 Luau의 교집합 타입(Intersection) 캐스팅을 사용하여 모든 하위 모듈의 자동완성과 린팅을 그대로 상속받습니다.
]]
local Common = {}

local Appearance = require(script.Appearance)
local BattlefieldLayout = require(script.BattlefieldLayout)
local BuildSystems = require(script.BuildSystems)
local CombatRules = require(script.CombatRules)
local CoreBlock = require(script.CoreBlock)
local CurriculumSetup = require(script.CurriculumSetup)
local Effect = require(script.Effect)
local EngineEnsure = require(script.EngineEnsure)
local CoreEnums = require(script.CoreEnums)
local FieldItem = require(script.FieldItem)
local FinalBattle = require(script.FinalBattle)
local Fortification = require(script.Fortification)
local MagicSystem = require(script.MagicSystem)
local PlayerCombatClient = require(script.PlayerCombatClient)
local SiegeEngine = require(script.SiegeEngine)
local StudentConfig = require(script.StudentConfig)
local ThrowingStone = require(script.ThrowingStone)
local WeaponSystems = require(script.WeaponSystems)

-- 런타임 동적 포워딩용 모듈 목록
local subModules = {
	Appearance,
	BattlefieldLayout,
	BuildSystems,
	CombatRules,
	CoreBlock,
	CurriculumSetup,
	Effect,
	EngineEnsure,
	CoreEnums,
	FieldItem,
	FinalBattle,
	Fortification,
	MagicSystem,
	PlayerCombatClient,
	SiegeEngine,
	StudentConfig,
	ThrowingStone,
	WeaponSystems,
}

setmetatable(Common, {
	__index = function(tbl, key)
		for _, module in ipairs(subModules) do
			local val = module[key]
			if val ~= nil then
				tbl[key] = val -- 최초 조회 시 테이블에 캐싱하여 조회 성능 보존
				return val
			end
		end
		return nil
	end
})

-- Luau LSP가 하위 모듈의 모든 함수/이넘 타입을 병합 추론하도록 Intersection 캐스팅 지정
type CommonType = 
	typeof(Appearance) & 
	typeof(BattlefieldLayout) &
	typeof(BuildSystems) & 
	typeof(CombatRules) & 
	typeof(CoreBlock) & 
	typeof(CurriculumSetup) & 
	typeof(Effect) & 
	typeof(EngineEnsure) & 
	typeof(CoreEnums) & 
	typeof(FieldItem) & 
	typeof(FinalBattle) & 
	typeof(Fortification) & 
	typeof(MagicSystem) & 
	typeof(PlayerCombatClient) &
	typeof(SiegeEngine) & 
	typeof(StudentConfig) & 
	typeof(ThrowingStone) & 
	typeof(WeaponSystems)

return (Common :: any) :: CommonType
