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
		Vector3.new(-18, 0.1, -2),
		Vector3.new(18, 0.1, -2),
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
		Vector3.new(-34, 0.1, -6),
		Vector3.new(34, 0.1, -6),
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
		Vector3.new(-12, 0.1, 18),
		Vector3.new(12, 0.1, -18),
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
		Vector3.new(-30, 0.1, 22),
		Vector3.new(30, 0.1, -22),
	}, {
		Size = Vector3.new(2, 2, 1),
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Really black"),
	}, WeaponSystems.installFieldArmorTool)
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
			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			if not humTarget or modelTarget == toolFieldSword.Parent or tableAlreadyHit[humTarget] then return end
			if not CombatRules.canPlayerDamageModel(playerAttacker, modelTarget) then return end

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

			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			if humTarget and CombatRules.canPlayerDamageModel(playerAttacker, modelTarget) then humTarget:TakeDamage(numberDamage) end
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
	local eLogical = CoreEnums.eEngineLogicalType
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
		if partHit.Name ~= eLogical.PROJECTILE_ARROW_FIELD and partHit.Name ~= eLogical.PROJECTILE_ALL then return end
		if not modelEquippedCharacter then return end

		local humPlayer = modelEquippedCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humPlayer then
			humPlayer.Health = math.min(humPlayer.Health + numberBlockHeal, humPlayer.MaxHealth)
		end
		partHit:Destroy()
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
