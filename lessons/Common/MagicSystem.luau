-- [Module] MagicSystem
local module = {}

local Appearance = require(script.Parent:WaitForChild("Appearance"))
local CombatRules = require(script.Parent:WaitForChild("CombatRules"))
local Effect = require(script.Parent:WaitForChild("Effect"))
local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))
local StudentConfig = require(script.Parent:WaitForChild("StudentConfig"))

-- --------------------------------------------------------------------------------
function module.installMagicStaffTool(toolMagicStaff, tblConfig) -- [의미/의도] 마법 지팡이 Tool 외형 설치 함수 정의 ➔ 입력/피해 판정은 클라이언트 요청과 서버 시스템에 맡기고 장비 외형만 제한적으로 반영하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolMagicStaff, "RuntimeInstalled_MagicStaffTool") then
		return
	end

	Appearance.applyToolHandleStudentStyle(toolMagicStaff, tblConfig)
end


-- --------------------------------------------------------------------------------


function module.installMagicServerSystem(svcReplicatedStorage, svcPlayers, tblConfig) -- [의미/의도] 마법 서버 시스템 설치 함수 정의 ➔ 클라이언트 입력은 요청으로만 받고 거리/쿨타임/피해는 서버가 판정하기 위함
	local eService = EngineNames.eEngineServiceSingleton
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcWorkspace = game:GetService(eService.WORKSPACE)
	local eventCastMagic = svcReplicatedStorage:WaitForChild(eLogical.CAST_MAGIC)
	if not EngineEnsure.markRuntimeInstalled(eventCastMagic, "RuntimeInstalled_MagicServer") then
		return
	end

	local numberMaxDistance = StudentConfig.readConfigNumber(tblConfig, "MaxDistance", 80, 10, 160)
	local numberRadius = StudentConfig.readConfigNumber(tblConfig, "Radius", 12, 2, 30)
	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 25, 1, 60)
	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 1.8, 0.3, 8)
	local numberEffectLifetime = StudentConfig.readConfigNumber(tblConfig, "EffectLifetime", 2, 0.5, 6)
	local tblEffectValidationMessages = {}
	local tblEffectConfig = Effect.readParticleEffectConfig(tblConfig, "Effect", tblEffectValidationMessages, "MagicEffect")
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
		Effect.applyParticleEffect(partEffectAnchor, tblEffectConfig)
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
					and CombatRules.canPlayerDamageModel(player, modelTarget)
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

return module