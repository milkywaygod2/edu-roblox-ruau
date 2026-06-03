-- [Module] CombatRules
local module = {}

local EngineNames = require(script.Parent:WaitForChild("EngineNames"))

-- --------------------------------------------------------------------------------
function module.isCombatProjectileName(strName) -- [의미/의도] 전투 투사체 이름 판별 함수 정의 ➔ 문/벽/방패가 받을 수 있는 공격 투사체를 공통으로 구분하기 위함
	local eLogical = EngineNames.eEngineLogicalType
	return strName == eLogical.THROWN_STONE
		or strName == eLogical.PROJECTILE_ARROW_FIELD
		or strName == eLogical.PROJECTILE_ALL
		or strName == eLogical.SIEGE_STONE
end


-- --------------------------------------------------------------------------------


function module.getOutpostObjectiveTeamName(modelTarget)
	if not modelTarget then return nil end

	local strPrefix = EngineNames.eEngineLogicalType.OUTPOST_CORE_PREFIX
	if EngineNames.hasEngineLogicalNamePrefix(modelTarget.Name, strPrefix) then
		return modelTarget.Name:sub(#strPrefix + 1)
	end

	return nil
end


-- --------------------------------------------------------------------------------


function module.canPlayerDamageModel(playerAttacker, modelTarget)
	if not modelTarget then return false end
	if not playerAttacker then return true end
	if not playerAttacker.Team then return false end

	local svcPlayers = game:GetService(EngineNames.eEngineServiceSingleton.PLAYERS)
	local playerTarget = svcPlayers:GetPlayerFromCharacter(modelTarget)
	if playerTarget and playerTarget.Team == playerAttacker.Team then
		return false
	end

	local strObjectiveTeamName = module.getOutpostObjectiveTeamName(modelTarget)
	if strObjectiveTeamName and strObjectiveTeamName == playerAttacker.Team.Name then
		return false
	end

	return true
end

-- --------------------------------------------------------------------------------

return module