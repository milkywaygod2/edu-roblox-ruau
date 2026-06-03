-- [Module] WeaponSystems
local WeaponSystems = {}

local Appearance = require(script.Parent.Appearance)
local CombatRules = require(script.Parent.CombatRules)
local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local FieldItem = require(script.Parent.FieldItem)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function WeaponSystems.installFieldSwordPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 검 파밍 설치 함수 정의 ➔ 검 장비 도메인이 자기 스폰 규격과 서버 시스템 연결을 소유하게 하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.FIELD_SWORD, "클릭해서 주운 뒤 근접 교전에 사용합니다", tblConfig, {
		Vector3.new(-54, 0.1, -6),
		Vector3.new(54, 0.1, -6),
	}, {
		Size = Vector3.new(1, 5, 1),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Medium stone grey"),
	}, WeaponSystems.installFieldSwordTool)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldBowPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 활 파밍 설치 함수 정의 ➔ 활 장비 도메인이 자기 스폰 규격과 서버 시스템 연결을 소유하게 하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.FIELD_BOW, "클릭해서 주운 뒤 원거리 견제에 사용합니다", tblConfig, {
		Vector3.new(-102, 0.1, -18),
		Vector3.new(102, 0.1, -18),
	}, {
		Size = Vector3.new(1, 4, 1),
		Material = Enum.Material.Wood,
		BrickColor = BrickColor.new("Reddish brown"),
	}, WeaponSystems.installFieldBowTool)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldShieldPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 방패 파밍 설치 함수 정의 ➔ 방패 장비 도메인이 자기 스폰 규격과 서버 시스템 연결을 소유하게 하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.FIELD_SHIELD, "클릭해서 주운 뒤 투사체를 막습니다", tblConfig, {
		Vector3.new(-36, 0.1, 54),
		Vector3.new(36, 0.1, -54),
	}, {
		Size = Vector3.new(4, 5, 0.6),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Dark stone grey"),
	}, WeaponSystems.installFieldShieldTool)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldArmorPickups(svcWorkspace, tblConfig) -- [의미/의도] 전장 갑옷 파밍 설치 함수 정의 ➔ 갑옷 장비 도메인이 자기 스폰 규격과 서버 시스템 연결을 소유하게 하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.FIELD_ARMOR, "클릭해서 주운 뒤 장착 능력치를 적용합니다", tblConfig, {
		Vector3.new(-90, 0.1, 66),
		Vector3.new(90, 0.1, -66),
	}, {
		Size = Vector3.new(2, 2, 1),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Really black"),
	}, WeaponSystems.installFieldArmorTool)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFistAttackServerSystem(svcReplicatedStorage, svcPlayers, tblConfig) -- [의미/의도] 빈손 기본 공격 서버 시스템 설치 함수 정의 ➔ Tool이 없을 때도 1일차부터 목표물을 공격할 수 있게 하기 위함
	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local svcWorkspace = game:GetService(eService.WORKSPACE)
	local eventFistAttack = EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.FIST_ATTACK, svcReplicatedStorage)
	if not EngineEnsure.markRuntimeInstalled(eventFistAttack, "RuntimeInstalled_FistAttack") then
		return eventFistAttack
	end

	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 8, 1, 20)
	local numberRange = StudentConfig.readConfigNumber(tblConfig, "Range", 8, 3, 14)
	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 0.45, 0.15, 2)
	local numberKnockbackForward = StudentConfig.readConfigNumber(tblConfig, "KnockbackForward", 14, 0, 40)
	local numberKnockbackUp = StudentConfig.readConfigNumber(tblConfig, "KnockbackUp", 4, 0, 20)
	local tblLastAttackClockByPlayer = {}

	local function find_equipped_tool(modelCharacter)
		for _, instanceChild in ipairs(modelCharacter:GetChildren()) do
			if instanceChild:IsA(ePhysical.TOOL) then
				return instanceChild
			end
		end

		return nil
	end

	local function read_punch_direction(partHumanoidRoot, vectorAimPosition)
		local vectorStartPosition = partHumanoidRoot.Position + Vector3.new(0, 1.5, 0)
		if typeof(vectorAimPosition) == "Vector3" and (vectorAimPosition - vectorStartPosition).Magnitude > 0.1 then
			return (vectorAimPosition - vectorStartPosition).Unit
		end

		return partHumanoidRoot.CFrame.LookVector
	end

	eventFistAttack.OnServerEvent:Connect(function(playerAttacker, vectorAimPosition)
		local numberNow = os.clock()
		local numberLastAttack = tblLastAttackClockByPlayer[playerAttacker] or 0
		if numberNow - numberLastAttack < numberCooldown then return end

		local modelCharacter = playerAttacker.Character
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end
		if find_equipped_tool(modelCharacter) then return end

		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot or not partHumanoidRoot:IsA(ePhysical.BASE_PART) then return end

		tblLastAttackClockByPlayer[playerAttacker] = numberNow

		local vectorStartPosition = partHumanoidRoot.Position + Vector3.new(0, 1.5, 0)
		local vectorPunchDirection = read_punch_direction(partHumanoidRoot, vectorAimPosition)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {modelCharacter}

		local raycastResult = svcWorkspace:Raycast(vectorStartPosition, vectorPunchDirection * numberRange, raycastParams)
		if not raycastResult then return end

		local modelTarget, humTarget = CombatRules.findHumanoidDamageTargetFromPart(raycastResult.Instance)
		if not humTarget or modelTarget == modelCharacter then return end

		local boolDamageApplied = CombatRules.applyHumanoidDamage(playerAttacker, modelTarget, humTarget, numberDamage)

		local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if boolDamageApplied and partTargetRoot and partTargetRoot:IsA(ePhysical.BASE_PART) then
			local vectorFlatDirection = Vector3.new(vectorPunchDirection.X, 0, vectorPunchDirection.Z)
			local vectorKnockbackDirection = vectorFlatDirection.Magnitude > 0.01 and vectorFlatDirection.Unit or partHumanoidRoot.CFrame.LookVector
			partTargetRoot.AssemblyLinearVelocity = vectorKnockbackDirection * numberKnockbackForward + Vector3.new(0, numberKnockbackUp, 0)
		end
	end)

	svcPlayers.PlayerRemoving:Connect(function(playerLeaving)
		tblLastAttackClockByPlayer[playerLeaving] = nil
	end)

	return eventFistAttack
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldSwordTool(toolFieldSword, tblConfig) -- [의미/의도] 전장 검 서버 시스템 설치 함수 정의 ➔ 근접 타격 판정과 쿨타임을 공통 서버 코드가 책임지게 하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolFieldSword, "RuntimeInstalled_FieldSword") then
		return
	end

	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local svcPlayers = game:GetService(eService.PLAYERS)
	local partHandle = Appearance.applyToolHandleStudentStyle(toolFieldSword, tblConfig)
	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 20, 1, 45)
	local numberActiveTime = StudentConfig.readConfigNumber(tblConfig, "ActiveTime", 0.25, 0.05, 1)
	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 1.2, 0.2, 5)
	local brickActiveColor = StudentConfig.readConfigBrickColor(tblConfig, "ActiveColor", "Really red")
	local brickIdleColor = StudentConfig.readConfigBrickColor(tblConfig, "IdleColor", "Medium stone grey")
	local boolCanAttack = true

	toolFieldSword.Activated:Connect(function()
		if not boolCanAttack then return end

		boolCanAttack = false
		local tableAlreadyHit = {}
		partHandle.BrickColor = brickActiveColor

		local connectionTouched = partHandle.Touched:Connect(function(partHit)
			local playerAttacker = svcPlayers:GetPlayerFromCharacter(toolFieldSword.Parent)
			local modelTarget, humTarget = CombatRules.findHumanoidDamageTargetFromPart(partHit)
			if not humTarget or modelTarget == toolFieldSword.Parent or tableAlreadyHit[humTarget] then return end

			tableAlreadyHit[humTarget] = true
			CombatRules.applyHumanoidDamage(playerAttacker, modelTarget, humTarget, numberDamage)
		end)

		task.wait(numberActiveTime)
		connectionTouched:Disconnect()
		partHandle.BrickColor = brickIdleColor
		task.wait(numberCooldown)
		boolCanAttack = true
	end)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldBowTool(toolFieldBow, tblConfig) -- [의미/의도] 전장 활 서버 시스템 설치 함수 정의 ➔ 발사체 생성/피해/자동 삭제를 공통 서버 코드가 책임지게 하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolFieldBow, "RuntimeInstalled_FieldBow") then
		return
	end

	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcPlayers = game:GetService(eService.PLAYERS)
	Appearance.applyToolHandleStudentStyle(toolFieldBow, tblConfig)

	local numberSpeed = StudentConfig.readConfigNumber(tblConfig, "Speed", 110, 30, 160)
	local numberArc = StudentConfig.readConfigNumber(tblConfig, "Arc", 28, 0, 80)
	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 18, 1, 35)
	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 0.9, 0.2, 4)
	local numberLifetime = StudentConfig.readConfigNumber(tblConfig, "Lifetime", 6, 1, 12)
	local vectorArrowSize = StudentConfig.readConfigVector3(tblConfig, "ArrowSize", Vector3.new(0.4, 0.4, 3), Vector3.new(0.2, 0.2, 1), Vector3.new(2, 2, 6))
	local enumArrowMaterial = StudentConfig.readConfigEnumItem(tblConfig, "ArrowMaterial", Enum.Material.Wood)
	local brickTargetHitColor = StudentConfig.readConfigBrickColor(tblConfig, "TargetHitColor", "Lime green")
	local boolReady = true

	toolFieldBow.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolFieldBow.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local playerAttacker = svcPlayers:GetPlayerFromCharacter(modelCharacter)
		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partArrow = Instance.new(ePhysical.PART)
		partArrow.Name = eLogical.PROJECTILE_ARROW_FIELD
		partArrow.Size = vectorArrowSize
		partArrow.Material = enumArrowMaterial
		partArrow.CFrame = partHumanoidRoot.CFrame * CFrame.new(0, 1.5, -4)
		partArrow.Parent = workspace
		partArrow.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberSpeed + Vector3.new(0, numberArc, 0)
		svcDebris:AddItem(partArrow, numberLifetime)

		partArrow.Touched:Connect(function(partHit)
			if partHit:IsDescendantOf(modelCharacter) then return end

			local modelTarget, humTarget = CombatRules.findHumanoidDamageTargetFromPart(partHit)
			if humTarget then
				CombatRules.applyHumanoidDamage(playerAttacker, modelTarget, humTarget, numberDamage)
			end
			if CoreEnums.hasEngineLogicalNamePrefix(partHit.Name, eLogical.RANGE_TARGET_PREFIX) then
				partHit.BrickColor = brickTargetHitColor
			end
			partArrow:Destroy()
		end)

		task.wait(numberCooldown)
		boolReady = true
	end)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldShieldTool(toolFieldShield, tblConfig) -- [의미/의도] 전장 방패 서버 시스템 설치 함수 정의 ➔ 방어 스탯과 투사체 차단 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolFieldShield, "RuntimeInstalled_FieldShield") then
		return
	end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local partHandle = Appearance.applyToolHandleStudentStyle(toolFieldShield, tblConfig)
	local numberBonusHealth = StudentConfig.readConfigNumber(tblConfig, "BonusHealth", 60, 0, 100)
	local numberBlockHeal = StudentConfig.readConfigNumber(tblConfig, "BlockHeal", 5, 0, 20)
	local numberWalkSpeedPenalty = StudentConfig.readConfigNumber(tblConfig, "WalkSpeedPenalty", 2, 0, 8)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolFieldShield.Equipped:Connect(function()
		modelEquippedCharacter = toolFieldShield.Parent
		if not modelEquippedCharacter or not modelEquippedCharacter:IsA(ePhysical.MODEL) then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humPlayer then return end

		tableSavedStats = {MaxHealth = humPlayer.MaxHealth, WalkSpeed = humPlayer.WalkSpeed}
		humPlayer.MaxHealth += numberBonusHealth
		humPlayer.Health = math.min(humPlayer.Health + numberBonusHealth, humPlayer.MaxHealth)
		humPlayer.WalkSpeed = math.max(4, humPlayer.WalkSpeed - numberWalkSpeedPenalty)
	end)

	toolFieldShield.Unequipped:Connect(function()
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
		if not CombatRules.isCombatProjectilePart(partHit) then return end
		if not modelEquippedCharacter then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humPlayer then
			humPlayer.Health = math.min(humPlayer.Health + numberBlockHeal, humPlayer.MaxHealth)
		end
		if CombatRules.isCombatProjectileName(partHit.Name) then
			partHit:Destroy()
		end
	end)
end


-- --------------------------------------------------------------------------------


function WeaponSystems.installFieldArmorTool(toolFieldArmor, tblConfig) -- [의미/의도] 전장 갑옷 서버 시스템 설치 함수 정의 ➔ 장착 스탯과 장식 이펙트 규칙을 공통 서버 코드가 책임지게 하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolFieldArmor, "RuntimeInstalled_FieldArmor") then
		return
	end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	Appearance.applyToolHandleStudentStyle(toolFieldArmor, tblConfig)

	local numberMaxHealth = StudentConfig.readConfigNumber(tblConfig, "MaxHealth", 180, 100, 240)
	local numberHealOnEquip = StudentConfig.readConfigNumber(tblConfig, "HealOnEquip", 80, 0, 120)
	local numberWalkSpeed = StudentConfig.readConfigNumber(tblConfig, "WalkSpeed", 10, 4, 20)
	local numberJumpPower = StudentConfig.readConfigNumber(tblConfig, "JumpPower", 32, 10, 80)
	local numberAuraRate = StudentConfig.readConfigNumber(tblConfig, "AuraRate", 20, 0, 80)
	local modelEquippedCharacter = nil
	local tableSavedStats = nil

	toolFieldArmor.Equipped:Connect(function()
		modelEquippedCharacter = toolFieldArmor.Parent
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

	toolFieldArmor.Unequipped:Connect(function()
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

return WeaponSystems
