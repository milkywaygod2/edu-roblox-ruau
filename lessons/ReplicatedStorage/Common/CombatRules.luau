-- [Module] CombatRules
local CombatRules = {}

local CoreEnums = require(script.Parent.CoreEnums)
local DAMAGE_FEEDBACK_HIDE_SECONDS = 0.9
local DAMAGE_FEEDBACK_MAX_DISTANCE = 120
local DAMAGE_FEEDBACK_WORLD_SIZE = UDim2.fromScale(4.8, 2.1)

-- --------------------------------------------------------------------------------
function CombatRules.isCombatProjectileName(strName) -- [의미/의도] 전투 투사체 이름 판별 함수 정의 ➔ 문/벽/방패가 받을 수 있는 공격 투사체를 공통으로 구분하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	return strName == eLogical.THROWN_STONE
		or strName == eLogical.PROJECTILE_ARROW_FIELD
		or strName == eLogical.PROJECTILE_ALL
		or strName == eLogical.SIEGE_STONE
end


-- --------------------------------------------------------------------------------


function CombatRules.isCombatProjectilePart(partHit)
	if not partHit then return false end

	return CombatRules.isCombatProjectileName(partHit.Name)
		or partHit:GetAttribute(CoreEnums.eEngineAttributeKey.BLOCK_IS_PROJECTILE) == true
end


-- --------------------------------------------------------------------------------


function CombatRules.getOutpostObjectiveTeamName(modelTarget)
	if not modelTarget then return nil end

	for _, strPrefix in ipairs({
		CoreEnums.eEngineLogicalType.OUTPOST_CORE_PREFIX,
		CoreEnums.eEngineLogicalType.TEAM_SYMBOL_PREFIX,
	}) do
		if CoreEnums.hasEngineLogicalNamePrefix(modelTarget.Name, strPrefix) then
			return modelTarget.Name:sub(#strPrefix + 1)
		end
	end

	return nil
end


-- --------------------------------------------------------------------------------


function CombatRules.canPlayerDamageModel(playerAttacker, modelTarget)
	if not modelTarget then return false end
	if not playerAttacker then return true end

	local svcPlayers = game:GetService(CoreEnums.eEngineServiceSingleton.PLAYERS)
	local playerTarget = svcPlayers:GetPlayerFromCharacter(modelTarget)
	if not playerAttacker.Team then
		return playerTarget == nil
	end

	if playerTarget and playerTarget.Team == playerAttacker.Team then
		return false
	end

	local strObjectiveTeamName = CombatRules.getOutpostObjectiveTeamName(modelTarget)
	if strObjectiveTeamName and strObjectiveTeamName == playerAttacker.Team.Name then
		return false
	end

	return true
end

-- --------------------------------------------------------------------------------


function CombatRules.findCoreModelForTeamSymbol(modelTarget)
	local strObjectiveTeamName = CombatRules.getOutpostObjectiveTeamName(modelTarget)
	if not strObjectiveTeamName then return nil end
	if not CoreEnums.hasEngineLogicalNamePrefix(modelTarget.Name, CoreEnums.eEngineLogicalType.TEAM_SYMBOL_PREFIX) then return nil end

	local instanceParent = modelTarget.Parent
	if not instanceParent then return nil end

	return instanceParent:FindFirstChild(CoreEnums.eEngineLogicalType.OUTPOST_CORE_PREFIX .. strObjectiveTeamName)
end


-- --------------------------------------------------------------------------------


function CombatRules.findHumanoidDamageTargetFromPart(partHit)
	if not partHit then return nil, nil end

	local modelTarget = partHit:FindFirstAncestorOfClass(CoreEnums.eEnginePhysicalType.MODEL)
	local modelCore = CombatRules.findCoreModelForTeamSymbol(modelTarget)
	if modelCore then
		modelTarget = modelCore
	end

	local humanoidTarget = modelTarget and modelTarget:FindFirstChildOfClass(CoreEnums.eEnginePhysicalType.HUMANOID)
	return modelTarget, humanoidTarget
end


-- --------------------------------------------------------------------------------


local function round_damage_number(numberValue)
	return math.floor(numberValue + 0.5)
end


-- --------------------------------------------------------------------------------


function CombatRules.findModelDamageFeedbackAdornee(modelTarget)
	if not modelTarget then return nil end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local strObjectiveTeamName = CombatRules.getOutpostObjectiveTeamName(modelTarget)
	local instanceParent = modelTarget.Parent
	local modelSymbol = strObjectiveTeamName and instanceParent and instanceParent:FindFirstChild(eLogical.TEAM_SYMBOL_PREFIX .. strObjectiveTeamName)
	local partBanner = modelSymbol and modelSymbol:FindFirstChild(eLogical.TEAM_SYMBOL_BANNER)
	if partBanner and partBanner:IsA(ePhysical.BASE_PART) then
		return partBanner
	end

	local partRoot = modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
	if partRoot and partRoot:IsA(ePhysical.BASE_PART) then
		return partRoot
	end

	for _, instanceDescendant in ipairs(modelTarget:GetDescendants()) do
		if instanceDescendant:IsA(ePhysical.BASE_PART) then
			return instanceDescendant
		end
	end

	return nil
end


-- --------------------------------------------------------------------------------


function CombatRules.ensureDamageFeedbackLabel(modelTarget)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local partAdornee = CombatRules.findModelDamageFeedbackAdornee(modelTarget)
	if not partAdornee then return nil, nil end

	local guiDamageFeedback = partAdornee:FindFirstChild(eLogical.DAMAGE_FEEDBACK_GUI)
	local boolDamageFeedbackWasEnabled = guiDamageFeedback and guiDamageFeedback:IsA(ePhysical.BILLBOARD_GUI) and guiDamageFeedback.Enabled == true
	if not guiDamageFeedback or not guiDamageFeedback:IsA(ePhysical.BILLBOARD_GUI) then
		if guiDamageFeedback then
			guiDamageFeedback:Destroy()
		end

		guiDamageFeedback = Instance.new(ePhysical.BILLBOARD_GUI)
		guiDamageFeedback.Name = eLogical.DAMAGE_FEEDBACK_GUI
		guiDamageFeedback.Parent = partAdornee
	end
	guiDamageFeedback.AlwaysOnTop = true
	guiDamageFeedback.Enabled = boolDamageFeedbackWasEnabled
	guiDamageFeedback.MaxDistance = DAMAGE_FEEDBACK_MAX_DISTANCE
	guiDamageFeedback.Size = DAMAGE_FEEDBACK_WORLD_SIZE
	guiDamageFeedback.StudsOffsetWorldSpace = Vector3.new(0, math.max(5, partAdornee.Size.Y * 0.75), 0)
	guiDamageFeedback.Adornee = partAdornee

	local labelDamageFeedback = guiDamageFeedback:FindFirstChild(eLogical.DAMAGE_FEEDBACK_TEXT)
	if not labelDamageFeedback or not labelDamageFeedback:IsA(ePhysical.TEXT_LABEL) then
		if labelDamageFeedback then
			labelDamageFeedback:Destroy()
		end

		labelDamageFeedback = Instance.new(ePhysical.TEXT_LABEL)
		labelDamageFeedback.Name = eLogical.DAMAGE_FEEDBACK_TEXT
		labelDamageFeedback.Parent = guiDamageFeedback
	end
	labelDamageFeedback.AnchorPoint = Vector2.new(0.5, 0.5)
	labelDamageFeedback.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	labelDamageFeedback.BackgroundTransparency = 0.35
	labelDamageFeedback.BorderSizePixel = 0
	labelDamageFeedback.Font = Enum.Font.GothamBold
	labelDamageFeedback.Position = UDim2.fromScale(0.5, 0.5)
	labelDamageFeedback.Size = UDim2.fromScale(1, 1)
	labelDamageFeedback.TextColor3 = Color3.fromRGB(255, 230, 90)
	labelDamageFeedback.TextScaled = true
	labelDamageFeedback.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	labelDamageFeedback.TextStrokeTransparency = 0.25

	return guiDamageFeedback, labelDamageFeedback
end


-- --------------------------------------------------------------------------------


function CombatRules.showDamageFeedback(modelTarget, numberDamage, numberHealth, numberMaxHealth)
	local guiDamageFeedback, labelDamageFeedback = CombatRules.ensureDamageFeedbackLabel(modelTarget)
	if not guiDamageFeedback or not labelDamageFeedback then return end

	local intDamage = math.max(0, round_damage_number(numberDamage))
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local numberScore = tonumber(modelTarget:GetAttribute(eAttrKey.DAMAGE_FEEDBACK_SCORE))
	if numberScore then
		local intScore = math.max(0, round_damage_number(numberScore))
		local intNewScore = math.max(0, intScore - intDamage)
		modelTarget:SetAttribute(eAttrKey.DAMAGE_FEEDBACK_SCORE, intNewScore)
		labelDamageFeedback.Text = tostring(intNewScore)
		labelDamageFeedback.TextColor3 = Color3.fromRGB(255, 230, 90)
		guiDamageFeedback.Enabled = true
		return
	end

	if intDamage <= 0 then return end

	labelDamageFeedback.Text = "-" .. tostring(intDamage)
	labelDamageFeedback.TextColor3 = Color3.fromRGB(255, 230, 90)
	guiDamageFeedback.Enabled = true

	local intFeedbackToken = (tonumber(guiDamageFeedback:GetAttribute("DamageFeedbackToken")) or 0) + 1
	guiDamageFeedback:SetAttribute("DamageFeedbackToken", intFeedbackToken)
	task.delay(DAMAGE_FEEDBACK_HIDE_SECONDS, function()
		if guiDamageFeedback.Parent and guiDamageFeedback:GetAttribute("DamageFeedbackToken") == intFeedbackToken then
			guiDamageFeedback.Enabled = false
		end
	end)
end


-- --------------------------------------------------------------------------------


function CombatRules.applyHumanoidDamage(playerAttacker, modelTarget, humanoidTarget, numberDamage)
	if not humanoidTarget or not modelTarget then return false, 0 end
	if not CombatRules.canPlayerDamageModel(playerAttacker, modelTarget) then return false, 0 end

	local numberHealthBefore = humanoidTarget.Health
	humanoidTarget:TakeDamage(numberDamage)
	local numberActualDamage = math.max(0, numberHealthBefore - humanoidTarget.Health)
	if numberActualDamage <= 0 then return false, 0 end

	CombatRules.showDamageFeedback(modelTarget, numberActualDamage, humanoidTarget.Health, humanoidTarget.MaxHealth)
	return true, numberActualDamage
end


-- --------------------------------------------------------------------------------

return CombatRules
