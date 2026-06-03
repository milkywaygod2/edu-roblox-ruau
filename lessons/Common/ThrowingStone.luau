-- [Module] ThrowingStone
local module = {}

local Appearance = require(script.Parent:WaitForChild("Appearance"))
local CombatRules = require(script.Parent:WaitForChild("CombatRules"))
local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))
local FieldItem = require(script.Parent:WaitForChild("FieldItem"))
local StudentConfig = require(script.Parent:WaitForChild("StudentConfig"))

-- --------------------------------------------------------------------------------
module.tblEquipmentSizeRule = {
	ThrowingStone = {
		Default = Vector3.new(1.2, 1.2, 1.2),
		Min = Vector3.new(0.5, 0.5, 0.5),
		Max = Vector3.new(2.6, 2.6, 2.6),
	},
	SiegeStone = {
		Default = Vector3.new(4, 4, 4),
		Min = Vector3.new(1.5, 1.5, 1.5),
		Max = Vector3.new(10, 10, 10),
	},
}


-- --------------------------------------------------------------------------------


module.tblThrowingStoneMaterialBlockList = {
	Enum.Material.Air,
	Enum.Material.Water,
	Enum.Material.ForceField,
}


-- --------------------------------------------------------------------------------


function module.isThrowingStoneMaterialBlocked(enumMaterial)
	for _, enumBlockedMaterial in ipairs(module.tblThrowingStoneMaterialBlockList) do
		if enumMaterial == enumBlockedMaterial then
			return true
		end
	end

	return false
end


-- --------------------------------------------------------------------------------


function module.hashTextToInteger(strText)
	local intHash = 0
	for index = 1, #strText do
		intHash = (intHash * 31 + string.byte(strText, index)) % 2147483647
	end

	return intHash
end


-- --------------------------------------------------------------------------------


function module.createFlatSpawnJitter(strSeedText, intIndex, numberRadius)
	if numberRadius <= 0 then
		return Vector3.new(0, 0, 0)
	end

	local randomJitter = Random.new(module.hashTextToInteger(strSeedText .. "_" .. intIndex))
	local numberDistance = math.sqrt(randomJitter:NextNumber()) * numberRadius
	local numberAngle = randomJitter:NextNumber() * math.pi * 2
	return Vector3.new(math.cos(numberAngle) * numberDistance, 0, math.sin(numberAngle) * numberDistance)
end


-- --------------------------------------------------------------------------------


function module.createAutoRockVariantId()
	intAutoRockDesignId += 1
	return "RockAuto_" .. intAutoRockDesignId
end


-- --------------------------------------------------------------------------------


function module.createRockDesign(strDisplayName) -- [의미/의도] 학생용 돌멩이 디자인 객체 생성 함수 정의 ➔ 학생마다 독립된 table을 받아 = 대입으로 외형과 컨셉만 바꾸게 하기 위함
	local strSafeDisplayName = StudentConfig.readConfigString({DisplayName = strDisplayName}, "DisplayName", "전장 돌멩이")
	return {
		DesignKind = "ThrowingStone",
		VariantId = module.createAutoRockVariantId(),
		DisplayName = strSafeDisplayName,
		SpawnCount = 3,
		SpawnRadius = 4,
		Appearance = {
			BrickColor = BrickColor.new("Dark stone grey"),
			Material = Enum.Material.Slate,
			Size = Vector3.new(1.2, 1.2, 1.2),
			CollisionShape = Enum.PartType.Ball,
			LookShape = "",
		},
		Trait = "Balanced",
	}
end


-- --------------------------------------------------------------------------------


function module.getThrowingStoneMaterialProfile(enumMaterial)
	if enumMaterial == Enum.Material.Metal then
		return {Mass = 1.45, Hardness = 1.2}
	elseif enumMaterial == Enum.Material.Wood then
		return {Mass = 0.7, Hardness = 0.75}
	elseif enumMaterial == Enum.Material.Neon then
		return {Mass = 0.85, Hardness = 0.8}
	elseif enumMaterial == Enum.Material.Ice then
		return {Mass = 0.8, Hardness = 1}
	elseif enumMaterial == Enum.Material.Concrete then
		return {Mass = 1.25, Hardness = 1.05}
	end

	return {Mass = 1, Hardness = 1}
end


-- --------------------------------------------------------------------------------


function module.getThrowingStoneTraitProfile(strTrait)
	if strTrait == "Heavy" then
		return {Mass = 1.35, Hardness = 1.1, Speed = 0.82, Cooldown = 1.18, Knockback = 1.25}
	elseif strTrait == "Light" then
		return {Mass = 0.75, Hardness = 0.9, Speed = 1.18, Cooldown = 0.88, Knockback = 0.8}
	elseif strTrait == "Bouncy" then
		return {Mass = 0.95, Hardness = 0.85, Speed = 1, Cooldown = 1, Knockback = 1.35}
	elseif strTrait == "Sharp" then
		return {Mass = 1, Hardness = 1.25, Speed = 0.95, Cooldown = 1.12, Knockback = 0.95}
	end

	return {Mass = 1, Hardness = 1, Speed = 1, Cooldown = 1, Knockback = 1}
end


-- --------------------------------------------------------------------------------


function module.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)
	local tblMaterialProfile = module.getThrowingStoneMaterialProfile(enumMaterial)
	local tblTraitProfile = module.getThrowingStoneTraitProfile(strTrait)
	local numberVolume = vectorSize.X * vectorSize.Y * vectorSize.Z
	local numberSizeMass = StudentConfig.clampNumber(numberVolume / 1.728, 0.25, 5)
	local numberMass = numberSizeMass * tblMaterialProfile.Mass * tblTraitProfile.Mass
	local numberHardness = tblMaterialProfile.Hardness * tblTraitProfile.Hardness

	return {
		Damage = StudentConfig.clampNumber(9 + numberMass * numberHardness * 5.5, 8, 30),
		Cooldown = StudentConfig.clampNumber((0.55 + numberMass * 0.22) * tblTraitProfile.Cooldown, 0.45, 2.4),
		Speed = StudentConfig.clampNumber((105 / math.sqrt(numberMass)) * tblTraitProfile.Speed, 45, 135),
		Arc = StudentConfig.clampNumber(18 - numberMass * 1.8, 5, 35),
		KnockbackForward = StudentConfig.clampNumber((28 + numberMass * 10) * tblTraitProfile.Knockback, 18, 80),
		KnockbackUp = StudentConfig.clampNumber(12 + numberMass * 3, 8, 35),
		Lifetime = StudentConfig.clampNumber(4 + numberMass * 0.35, 3, 8),
	}
end


-- --------------------------------------------------------------------------------


function module.resolveThrowingStoneDesign(tblConfig, tblValidationMessages, strSourceName)
	local strVariantId = tblConfig and tblConfig.VariantId
	if type(strVariantId) ~= "string" or strVariantId == "" then
		strVariantId = module.createAutoRockVariantId()
	end

	local tblAppearance = StudentConfig.readConfigTable(tblConfig, "Appearance", nil, tblValidationMessages, strSourceName)
	local tblAppearanceConfig = StudentConfig.mergeConfigTables(tblConfig, tblAppearance)
	local vectorSize = common.readEquipmentSize(tblAppearanceConfig, "Size", "ThrowingStone", tblValidationMessages, strSourceName)
	if tblAppearanceConfig and tblAppearanceConfig.Size == nil and tblAppearanceConfig.CollisionSize ~= nil then
		vectorSize = common.readEquipmentSize(tblAppearanceConfig, "CollisionSize", "ThrowingStone", tblValidationMessages, strSourceName)
	end
	local enumMaterial = common.readThrowingStoneMaterial(tblAppearanceConfig, "Material", Enum.Material.Slate, tblValidationMessages, strSourceName)
	local enumShape = StudentConfig.readConfigEnumItem(tblAppearanceConfig, "CollisionShape", Enum.PartType.Ball)
	local valueShape = tblAppearanceConfig and tblAppearanceConfig.CollisionShape
	if tblAppearanceConfig and tblAppearanceConfig.CollisionShape == nil and tblAppearanceConfig.Shape ~= nil then
		enumShape = StudentConfig.readConfigEnumItem(tblAppearanceConfig, "Shape", Enum.PartType.Ball)
		valueShape = tblAppearanceConfig.Shape
	end
	if valueShape ~= nil and enumShape == Enum.PartType.Ball and valueShape ~= Enum.PartType.Ball then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "CollisionShape는 Enum.PartType 값을 써야 해서 Ball로 보정했습니다.")
	end
	local brickColor = StudentConfig.readConfigBrickColor(tblAppearanceConfig, "BrickColor", "Dark stone grey")
	local colorProjectile = brickColor.Color
	if tblAppearanceConfig and tblAppearanceConfig.Color ~= nil then
		colorProjectile = StudentConfig.readConfigColor3(tblAppearanceConfig, "Color", colorProjectile, tblValidationMessages, strSourceName)
		brickColor = StudentConfig.createBrickColorFromColor3(colorProjectile)
	end
	local strTrait = StudentConfig.readConfigString(tblConfig, "Trait", "Balanced")
	local strLookShape = StudentConfig.readConfigString(tblAppearanceConfig, "LookShape", "")
	if strLookShape == "" then
		strLookShape = StudentConfig.readConfigString(tblAppearanceConfig, "Look", "")
	end
	if strLookShape ~= "" and not Appearance.findRockLookTemplate(strLookShape) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "LookShape '" .. strLookShape .. "'를 ReplicatedStorage/OutpostAssets/RockLooks에서 찾지 못해 기본 모양을 사용합니다.")
	end
	local valueSpawnCount = tblConfig and tblConfig.SpawnCount
	if type(valueSpawnCount) == "number" and (valueSpawnCount < 1 or valueSpawnCount > 10) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "SpawnCount는 1~10 범위로 보정했습니다.")
	elseif valueSpawnCount ~= nil and type(valueSpawnCount) ~= "number" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "SpawnCount는 숫자여야 해서 기본 3으로 보정했습니다.")
	end
	local tblStats = module.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)

	return {
		VariantId = strVariantId,
		DisplayName = StudentConfig.readConfigString(tblConfig, "DisplayName", "전장 돌멩이"),
		SpawnCount = StudentConfig.readConfigInteger(tblConfig, "SpawnCount", 3, 1, 10),
		SpawnOffset = StudentConfig.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8)),
		SpawnRadius = StudentConfig.readConfigNumber(tblConfig, "SpawnRadius", 4, 0, 8),
		Damage = tblStats.Damage,
		Cooldown = tblStats.Cooldown,
		Speed = tblStats.Speed,
		Arc = tblStats.Arc,
		KnockbackForward = tblStats.KnockbackForward,
		KnockbackUp = tblStats.KnockbackUp,
		Lifetime = tblStats.Lifetime,
		LookShape = strLookShape,
		Look = strLookShape,
		ProjectileSize = vectorSize,
		ProjectileMaterial = enumMaterial,
		ProjectileBrickColor = brickColor,
		ProjectileColor = colorProjectile,
		ProjectileShape = enumShape,
		Handle = {
			Size = vectorSize,
			Material = enumMaterial,
			BrickColor = brickColor,
			Color = colorProjectile,
			Shape = enumShape,
		},
	}
end


-- --------------------------------------------------------------------------------


function module.installThrowingStonePickups(svcWorkspace, tblConfig) -- [의미/의도] 투척 돌 파밍 설치 함수 정의 ➔ 1회차 기본 무기를 맵에서 찾아 줍는 루프로 제공하기 위함
	local eLogical = EngineNames.eEngineLogicalType
	local tblThrowingStoneConfig = tblConfig
	local boolAlreadyResolved = tblConfig and tblConfig.ProjectileSize ~= nil and tblConfig.ProjectileMaterial ~= nil
	local boolLooksLikeStudentDesign = tblConfig and (
		tblConfig.DesignKind == "ThrowingStone"
		or tblConfig.Appearance
		or tblConfig.CollisionSize
		or tblConfig.CollisionShape
		or tblConfig.LookShape
		or tblConfig.Size
		or tblConfig.Material
		or tblConfig.BrickColor
		or tblConfig.Color
		or tblConfig.Shape
		or tblConfig.Trait
	)
	if boolLooksLikeStudentDesign and not boolAlreadyResolved then
		tblThrowingStoneConfig = module.resolveThrowingStoneDesign(tblConfig)
	end

	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.THROWING_STONE, "클릭해서 주운 뒤 전초기지 목표에 던집니다", tblThrowingStoneConfig, {
		Vector3.new(-24, 0.1, 8),
		Vector3.new(0, 0.1, 4),
		Vector3.new(24, 0.1, 8),
	}, {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.Slate,
		BrickColor = BrickColor.new("Dark stone grey"),
	}, module.installThrowingStoneTool)
end


-- --------------------------------------------------------------------------------


function module.createFallbackRockDesign(strSourceName)
	local tblRockDesign = module.createRockDesign(strSourceName .. " 기본 돌")
	tblRockDesign.Appearance.BrickColor = BrickColor.new("Medium stone grey")
	tblRockDesign.Appearance.Material = Enum.Material.Slate
	tblRockDesign.Appearance.Size = Vector3.new(1.1, 1.1, 1.1)
	tblRockDesign.Appearance.CollisionShape = Enum.PartType.Ball
	tblRockDesign.Trait = "Balanced"
	return tblRockDesign
end


-- --------------------------------------------------------------------------------


function module.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
	if not moduleRockDesign:IsA(EngineNames.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblRockDesign = pcall(require, moduleRockDesign)
	if not boolSuccess then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "코드 실행 오류가 있어 기본 돌로 대체했습니다. " .. tostring(tblRockDesign))
		return module.createFallbackRockDesign(moduleRockDesign.Name)
	end

	if type(tblRockDesign) ~= "table" then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "마지막 줄에서 table을 return해야 해서 기본 돌로 대체했습니다.")
		return module.createFallbackRockDesign(moduleRockDesign.Name)
	end

	return tblRockDesign
end


-- --------------------------------------------------------------------------------


function module.installStudentThrowingStoneDesigns(svcWorkspace, fldStudentRockDesigns)
	local tblModules = {}
	local tblValidationMessages = {}
	if fldStudentRockDesigns then
		for _, instanceChild in ipairs(fldStudentRockDesigns:GetChildren()) do
			if instanceChild:IsA(EngineNames.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	if #tblModules == 0 then
		StudentConfig.addValidationMessage(tblValidationMessages, "StudentRockDesigns", "학생 ModuleScript가 없어 전장 기본 돌을 설치했습니다.")
		module.installThrowingStonePickups(svcWorkspace, module.resolveThrowingStoneDesign(module.createFallbackRockDesign("전장"), tblValidationMessages, "전장"))
		StudentConfig.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
		return 1
	end

	for _, moduleRockDesign in ipairs(tblModules) do
		local tblRockDesign = module.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
		if tblRockDesign then
			module.installThrowingStonePickups(svcWorkspace, module.resolveThrowingStoneDesign(tblRockDesign, tblValidationMessages, moduleRockDesign.Name))
		end
	end

	StudentConfig.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
	return #tblModules
end


-- --------------------------------------------------------------------------------


function module.installThrowingStoneTool(toolThrowingStone, tblConfig) -- [의미/의도] 투척 돌 서버 시스템 설치 함수 정의 ➔ 학생 파일에는 외형/수치 설정만 남기고 실제 공격 규칙은 서버 공통 코드가 처리하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolThrowingStone, "RuntimeInstalled_ThrowingStone") then
		return
	end

	local eService = EngineNames.eEngineServiceSingleton
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local svcPlayers = game:GetService(eService.PLAYERS)
	local partHandle = Appearance.applyToolHandleStudentStyle(toolThrowingStone, tblConfig)

	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 15, 1, 30)
	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 0.8, 0.2, 3)
	local numberSpeed = StudentConfig.readConfigNumber(tblConfig, "Speed", 90, 20, 140)
	local numberArc = StudentConfig.readConfigNumber(tblConfig, "Arc", 12, 0, 60)
	local numberKnockbackForward = StudentConfig.readConfigNumber(tblConfig, "KnockbackForward", 45, 0, 80)
	local numberKnockbackUp = StudentConfig.readConfigNumber(tblConfig, "KnockbackUp", 18, 0, 60)
	local numberLifetime = StudentConfig.readConfigNumber(tblConfig, "Lifetime", 5, 1, 12)
	local vectorProjectileSize = StudentConfig.readConfigVector3(tblConfig, "ProjectileSize", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0.3, 0.3, 0.3), Vector3.new(4, 4, 4))
	local enumProjectileMaterial = common.readThrowingStoneMaterial(tblConfig, "ProjectileMaterial", Enum.Material.Slate)
	local colorProjectile = StudentConfig.readConfigColor3(tblConfig, "ProjectileColor", BrickColor.new("Dark stone grey").Color)
	local enumProjectileShape = StudentConfig.readConfigEnumItem(tblConfig, "ProjectileShape", Enum.PartType.Ball)
	local strLookShape = StudentConfig.readConfigString(tblConfig, "LookShape", StudentConfig.readConfigString(tblConfig, "Look", ""))
	local boolReady = true
	Appearance.applyRockLook(partHandle, strLookShape)

	toolThrowingStone.Activated:Connect(function()
		if not boolReady then return end

		local modelCharacter = toolThrowingStone.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		local playerAttacker = svcPlayers:GetPlayerFromCharacter(modelCharacter)
		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false

		local partRock = Instance.new(ePhysical.PART)
		partRock.Name = eLogical.THROWN_STONE
		partRock.Shape = enumProjectileShape
		partRock.Size = vectorProjectileSize
		partRock.Material = enumProjectileMaterial
		partRock.Color = colorProjectile
		partRock.Position = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0)
		partRock.Parent = workspace
		Appearance.applyRockLook(partRock, strLookShape)
		partRock.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * numberSpeed + Vector3.new(0, numberArc, 0)
		svcDebris:AddItem(partRock, numberLifetime)

		local boolHitOnce = false
		partRock.Touched:Connect(function(partHit)
			if boolHitOnce then return end

			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
			local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
			if not humTarget or modelTarget == modelCharacter then return end
			if not CombatRules.canPlayerDamageModel(playerAttacker, modelTarget) then return end

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

return module