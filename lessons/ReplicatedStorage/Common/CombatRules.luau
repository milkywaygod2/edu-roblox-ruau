-- [Module] CombatRules
local CombatRules = {}

local CoreEnums = require(script.Parent.CoreEnums)

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
	guiDamageFeedback.MaxDistance = 180
	guiDamageFeedback.Size = UDim2.fromOffset(150, 70)
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
	labelDamageFeedback.BackgroundTransparency = 0.2
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
	
	-- [점수 차감식 변경] 
	-- 누적 방식 대신 최초 500점에서 피해량만큼 차감해 나가는 방식으로 동작합니다.
	local intScore = modelTarget:GetAttribute(eAttrKey.DAMAGE_FEEDBACK_SCORE)
	if intScore == nil then
		intScore = 500
	end
	
	local intNewScore = math.max(0, intScore - intDamage)
	modelTarget:SetAttribute(eAttrKey.DAMAGE_FEEDBACK_SCORE, intNewScore)

	labelDamageFeedback.Text = tostring(intNewScore)
	labelDamageFeedback.TextColor3 = Color3.fromRGB(255, 230, 90)
	guiDamageFeedback.Enabled = true

	-- [대문짝만한 승리팀 스크린 프린트]
	-- 점수가 0점이 되는 순간, 상대 팀의 승리를 스크린에 대문짝만하게 표시합니다.
	if intScore > 0 and intNewScore == 0 then
		local strDefeatedTeam = CombatRules.getOutpostObjectiveTeamName(modelTarget)
		if strDefeatedTeam then
			local strWinningTeam = (strDefeatedTeam == "Blue") and "Red" or "Blue"
			local colorWinning = (strWinningTeam == "Red") and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 80, 255)
			
			local Players = game:GetService(CoreEnums.eEngineServiceSingleton.PLAYERS)
			for _, player in ipairs(Players:GetPlayers()) do
				local playerGui = player:FindFirstChildOfClass("PlayerGui")
				if playerGui then
					-- 기존 승리 화면이 있다면 제거
					local existingGui = playerGui:FindFirstChild("VictoryScreenGui")
					if existingGui then
						existingGui:Destroy()
					end

					local screenGui = Instance.new("ScreenGui")
					screenGui.Name = "VictoryScreenGui"
					screenGui.ResetOnSpawn = false
					screenGui.IgnoreGuiInset = true
					
					local textLabel = Instance.new("TextLabel")
					textLabel.Size = UDim2.fromScale(1, 1)
					textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					textLabel.BackgroundTransparency = 0.4
					textLabel.Text = "★ " .. strWinningTeam:upper() .. " TEAM VICTORY ★"
					textLabel.TextColor3 = colorWinning
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextScaled = true
					textLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
					textLabel.TextStrokeTransparency = 0.3
					textLabel.Parent = screenGui
					
					-- 약간의 UI 패딩 효과 제공
					local uiPadding = Instance.new("UIPadding")
					uiPadding.PaddingTop = UDim.new(0.2, 0)
					uiPadding.PaddingBottom = UDim.new(0.2, 0)
					uiPadding.PaddingLeft = UDim.new(0.1, 0)
					uiPadding.PaddingRight = UDim.new(0.1, 0)
					uiPadding.Parent = textLabel

					screenGui.Parent = playerGui
				end
			end
		end
	end
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
