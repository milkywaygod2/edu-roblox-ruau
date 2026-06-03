--[[
   Roblox Studio 수업 공통 모듈 (Facade)
   역할: 하위 15개 모듈을 하나로 병합하여 레거시 호출 규격을 완벽히 유지하는 엔트리 포인트입니다.
]]
local Common = {}

local Appearance = require(script:WaitForChild("Appearance"))
local BuildSystems = require(script:WaitForChild("BuildSystems"))
local CombatRules = require(script:WaitForChild("CombatRules"))
local CurriculumSetup = require(script:WaitForChild("CurriculumSetup"))
local Effect = require(script:WaitForChild("Effect"))
local EngineEnsure = require(script:WaitForChild("EngineEnsure"))
local EngineNames = require(script:WaitForChild("EngineNames"))
local FieldItem = require(script:WaitForChild("FieldItem"))
local FinalBattle = require(script:WaitForChild("FinalBattle"))
local Fortification = require(script:WaitForChild("Fortification"))
local MagicSystem = require(script:WaitForChild("MagicSystem"))
local SiegeEngine = require(script:WaitForChild("SiegeEngine"))
local StudentConfig = require(script:WaitForChild("StudentConfig"))
local ThrowingStone = require(script:WaitForChild("ThrowingStone"))
local WeaponSystems = require(script:WaitForChild("WeaponSystems"))

-- 하위 호환성을 위해 모든 하위 모듈 API를 메인 Common 테이블에 병합
local modules = {
	Appearance,
	BuildSystems,
	CombatRules,
	CurriculumSetup,
	Effect,
	EngineEnsure,
	EngineNames,
	FieldItem,
	FinalBattle,
	Fortification,
	MagicSystem,
	SiegeEngine,
	StudentConfig,
	ThrowingStone,
	WeaponSystems,
}

for _, module in ipairs(modules) do
	for k, v in pairs(module) do
		Common[k] = v
	end
end

return Common