-- [Module] ThrowingStone
local ThrowingStone = {}

local Appearance = require(script.Parent.Appearance)
local BattlefieldLayout = require(script.Parent.BattlefieldLayout)
local CombatRules = require(script.Parent.CombatRules)
local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local FieldItem = require(script.Parent.FieldItem)
local StudentConfig = require(script.Parent.StudentConfig)

local intAutoRockDesignId = 0

-- --------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------




-- --------------------------------------------------------------------------------


function ThrowingStone.isThrowingStoneMaterialBlocked(enumMaterial)
	return StudentConfig.isThrowingStoneMaterialBlocked(enumMaterial)
end


-- --------------------------------------------------------------------------------


function ThrowingStone.hashTextToInteger(strText)
	return FieldItem.hashTextToInteger(strText)
end


-- --------------------------------------------------------------------------------


function ThrowingStone.createFlatSpawnJitter(strSeedText, intIndex, numberRadius)
	return FieldItem.createFlatSpawnJitter(strSeedText, intIndex, numberRadius)
end


-- --------------------------------------------------------------------------------


function ThrowingStone.createAutoRockVariantId()
	intAutoRockDesignId += 1
	return "RockAuto_" .. intAutoRockDesignId
end


-- --------------------------------------------------------------------------------


function ThrowingStone.createRockDesign(strDisplayName) -- [의미/의도] 학생용 돌멩이 디자인 객체 생성 함수 정의 ➔ 학생마다 독립된 table을 받아 = 대입으로 외형과 컨셉만 바꾸게 하기 위함
	local strSafeDisplayName = StudentConfig.readConfigString({DisplayName = strDisplayName}, "DisplayName", "전장 돌멩이")
	return {
		DesignKind = "ThrowingStone",
		VariantId = ThrowingStone.createAutoRockVariantId(),
		DisplayName = strSafeDisplayName,
		SpawnCount = 10,
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


function ThrowingStone.getThrowingStoneMaterialProfile(enumMaterial)
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


function ThrowingStone.getThrowingStoneTraitProfile(strTrait)
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


function ThrowingStone.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)
	local tblMaterialProfile = ThrowingStone.getThrowingStoneMaterialProfile(enumMaterial)
	local tblTraitProfile = ThrowingStone.getThrowingStoneTraitProfile(strTrait)
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


function ThrowingStone.resolveThrowingStoneDesign(tblConfig, tblValidationMessages, strSourceName)
	local strVariantId = tblConfig and tblConfig.VariantId
	if type(strVariantId) ~= "string" or strVariantId == "" then
		strVariantId = ThrowingStone.createAutoRockVariantId()
	end

	local tblAppearance = StudentConfig.readConfigTable(tblConfig, "Appearance", nil, tblValidationMessages, strSourceName)
	local tblAppearanceConfig = StudentConfig.mergeConfigTables(tblConfig, tblAppearance)
	local vectorSize = StudentConfig.readEquipmentSize(tblAppearanceConfig, "Size", "ThrowingStone", tblValidationMessages, strSourceName)
	if tblAppearanceConfig and tblAppearanceConfig.Size == nil and tblAppearanceConfig.CollisionSize ~= nil then
		vectorSize = StudentConfig.readEquipmentSize(tblAppearanceConfig, "CollisionSize", "ThrowingStone", tblValidationMessages, strSourceName)
	end
	local enumMaterial = StudentConfig.readThrowingStoneMaterial(tblAppearanceConfig, "Material", Enum.Material.Slate, tblValidationMessages, strSourceName)
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
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "SpawnCount는 숫자여야 해서 기본 10으로 보정했습니다.")
	end
	local tblStats = ThrowingStone.calculateThrowingStoneStats(vectorSize, enumMaterial, strTrait)

	return {
		VariantId = strVariantId,
		DisplayName = StudentConfig.readConfigString(tblConfig, "DisplayName", "전장 돌멩이"),
		SpawnCount = StudentConfig.readConfigInteger(tblConfig, "SpawnCount", 10, 1, 10),
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


function ThrowingStone.installThrowingStonePickups(svcWorkspace, tblConfig) -- [의미/의도] 투척 돌 파밍 설치 함수 정의 ➔ 1회차 기본 무기를 맵에서 찾아 줍는 루프로 제공하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
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
		tblThrowingStoneConfig = ThrowingStone.resolveThrowingStoneDesign(tblConfig)
	end

	tblThrowingStoneConfig = tblThrowingStoneConfig or {}
	tblThrowingStoneConfig.SpawnCount = 10

	return FieldItem.installFieldToolPickups(svcWorkspace, eLogical.THROWING_STONE, "클릭해서 주운 뒤 전초기지 목표에 던집니다", tblThrowingStoneConfig, BattlefieldLayout.tblThrowingStoneSpawnPositions, {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.Slate,
		BrickColor = BrickColor.new("Dark stone grey"),
	}, ThrowingStone.installThrowingStoneTool)
end


-- --------------------------------------------------------------------------------


function ThrowingStone.createFallbackRockDesign(strSourceName)
	local tblRockDesign = ThrowingStone.createRockDesign(strSourceName .. " 기본 돌")
	tblRockDesign.Appearance.BrickColor = BrickColor.new("Medium stone grey")
	tblRockDesign.Appearance.Material = Enum.Material.Slate
	tblRockDesign.Appearance.Size = Vector3.new(1.1, 1.1, 1.1)
	tblRockDesign.Appearance.CollisionShape = Enum.PartType.Ball
	tblRockDesign.Trait = "Balanced"
	return tblRockDesign
end


-- --------------------------------------------------------------------------------


function ThrowingStone.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
	if not moduleRockDesign:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblRockDesign = pcall(require, moduleRockDesign)
	if not boolSuccess then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "코드 실행 오류가 있어 기본 돌로 대체했습니다. " .. tostring(tblRockDesign))
		return ThrowingStone.createFallbackRockDesign(moduleRockDesign.Name)
	end

	if type(tblRockDesign) ~= "table" then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleRockDesign.Name, "마지막 줄에서 table을 return해야 해서 기본 돌로 대체했습니다.")
		return ThrowingStone.createFallbackRockDesign(moduleRockDesign.Name)
	end

	return tblRockDesign
end


-- --------------------------------------------------------------------------------


function ThrowingStone.installStudentThrowingStoneDesigns(svcWorkspace, fldStudentRockDesigns)
	local tblModules = {}
	local tblValidationMessages = {}
	if fldStudentRockDesigns then
		for _, instanceChild in ipairs(fldStudentRockDesigns:GetChildren()) do
			if instanceChild:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	if #tblModules == 0 then
		StudentConfig.addValidationMessage(tblValidationMessages, "StudentRockDesigns", "학생 ModuleScript가 없어 전장 기본 돌을 설치했습니다.")
		ThrowingStone.installThrowingStonePickups(svcWorkspace, ThrowingStone.resolveThrowingStoneDesign(ThrowingStone.createFallbackRockDesign("전장"), tblValidationMessages, "전장"))
		StudentConfig.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
		return 1
	end

	for _, moduleRockDesign in ipairs(tblModules) do
		local tblRockDesign = ThrowingStone.readStudentRockDesignModule(moduleRockDesign, tblValidationMessages)
		if tblRockDesign then
			ThrowingStone.installThrowingStonePickups(svcWorkspace, ThrowingStone.resolveThrowingStoneDesign(tblRockDesign, tblValidationMessages, moduleRockDesign.Name))
		end
	end

	StudentConfig.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
	return #tblModules
end


-- --------------------------------------------------------------------------------


function ThrowingStone.installThrowingStoneTool(toolThrowingStone, tblConfig) -- [의미/의도] 투척 돌 서버 시스템 설치 함수 정의 ➔ 학생 파일에는 외형/수치 설정만 남기고 실제 공격 규칙은 서버 공통 코드가 처리하기 위함
	if not EngineEnsure.markRuntimeInstalled(toolThrowingStone, "RuntimeInstalled_ThrowingStone") then
		return
	end

	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey
	local svcPlayers = game:GetService(eService.PLAYERS)
	local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(workspace)
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local eventThrowingStoneAim = EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.THROWING_STONE_AIM, svcReplicatedStorage)
	local partHandle = Appearance.applyToolHandleStudentStyle(toolThrowingStone, tblConfig)

	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 15, 1, 30)
	toolThrowingStone:SetAttribute("Damage", math.floor(numberDamage + 0.5))
	toolThrowingStone:SetAttribute("Trait", tblConfig and tblConfig.Trait or "Balanced")
	local numberSpeed = StudentConfig.readConfigNumber(tblConfig, "Speed", 90, 20, 140)
	local numberArc = StudentConfig.readConfigNumber(tblConfig, "Arc", 12, 0, 60)
	local numberKnockbackForward = StudentConfig.readConfigNumber(tblConfig, "KnockbackForward", 45, 0, 80)
	local numberKnockbackUp = StudentConfig.readConfigNumber(tblConfig, "KnockbackUp", 18, 0, 60)
	local numberLifetime = StudentConfig.readConfigNumber(tblConfig, "Lifetime", 5, 1, 12)
	local vectorProjectileSize = StudentConfig.readConfigVector3(tblConfig, "ProjectileSize", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0.3, 0.3, 0.3), Vector3.new(4, 4, 4))
	local enumProjectileMaterial = StudentConfig.readThrowingStoneMaterial(tblConfig, "ProjectileMaterial", Enum.Material.Slate)
	local colorProjectile = StudentConfig.readConfigColor3(tblConfig, "ProjectileColor", BrickColor.new("Dark stone grey").Color)
	local enumProjectileShape = StudentConfig.readConfigEnumItem(tblConfig, "ProjectileShape", Enum.PartType.Ball)
	local strLookShape = StudentConfig.readConfigString(tblConfig, "LookShape", StudentConfig.readConfigString(tblConfig, "Look", ""))
	local boolReady = true
	Appearance.applyRockLook(partHandle, strLookShape)
	partHandle.CanCollide = false
	partHandle.CanTouch = false
	partHandle.CanQuery = false
	partHandle.Massless = true
	toolThrowingStone.CanBeDropped = true

	local function throw_toward_aim(playerAttacker, vectorAimPosition, numberCharge)
		if not boolReady
			and toolThrowingStone.Parent == fldItemSpawnArea
			and toolThrowingStone:GetAttribute(eAttr.BLOCK_IS_PROJECTILE) ~= true then
			boolReady = true
			toolThrowingStone.Enabled = true
		end

		if not boolReady then return end

		local modelCharacter = toolThrowingStone.Parent
		if not modelCharacter or not modelCharacter:IsA(ePhysical.MODEL) then return end

		if playerAttacker ~= svcPlayers:GetPlayerFromCharacter(modelCharacter) then return end
		local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		boolReady = false
		toolThrowingStone.Enabled = false

		local numberSafeCharge = StudentConfig.clampNumber(type(numberCharge) == "number" and numberCharge or 0, 0, 1)
		local vectorStartPosition = partHumanoidRoot.Position + Vector3.new(0, 1.5, 0)
		local vectorAimDirection = partHumanoidRoot.CFrame.LookVector
		if typeof(vectorAimPosition) == "Vector3" and (vectorAimPosition - vectorStartPosition).Magnitude > 0.1 then
			vectorAimDirection = (vectorAimPosition - vectorStartPosition).Unit
		end

		local numberChargedSpeed = numberSpeed * (0.55 + numberSafeCharge * 0.75)
		local numberChargedArc = numberArc * (0.45 + numberSafeCharge * 1.2) + numberSafeCharge * 18
		local numberChargedLifetime = numberLifetime * (0.75 + numberSafeCharge * 0.75)
		local startCFrame = CFrame.new(vectorStartPosition + vectorAimDirection * 3)
		local vectorVelocity = vectorAimDirection * numberChargedSpeed + Vector3.new(0, numberChargedArc, 0)
		local strHomeName = toolThrowingStone:GetAttribute(eAttr.FIELD_ITEM_HOME_NAME)
		local boolLanded = false
		local connectionTouched

		local function finish_throw_after_delay(numberDelay)
			if boolLanded then return end
			boolLanded = true

			task.delay(numberDelay, function()
				if connectionTouched then
					connectionTouched:Disconnect()
				end
				if not toolThrowingStone.Parent then return end

				partHandle:SetAttribute(eAttr.BLOCK_IS_PROJECTILE, false)
				partHandle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				partHandle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				toolThrowingStone.Enabled = true
				boolReady = true
				if typeof(strHomeName) == "string" then
					toolThrowingStone.Name = strHomeName
				end
				local vectorSafeRestPosition = FieldItem.resolveFieldToolSafeRestPosition(toolThrowingStone, fldItemSpawnArea, partHandle, partHandle.Position)
				toolThrowingStone.Parent = fldItemSpawnArea
				FieldItem.applyFieldToolWorldState(toolThrowingStone, partHandle, vectorSafeRestPosition)
				toolThrowingStone:SetAttribute(eAttr.FIELD_ITEM_HOME_POSITION, vectorSafeRestPosition)
			end)
		end

		toolThrowingStone.Parent = fldItemSpawnArea
		if typeof(strHomeName) == "string" then
			toolThrowingStone.Name = strHomeName
		end

		partHandle.Size = vectorProjectileSize
		partHandle.Material = enumProjectileMaterial
		partHandle.Color = colorProjectile
		partHandle.Shape = enumProjectileShape
		partHandle.CFrame = startCFrame
		partHandle:SetAttribute(eAttr.BLOCK_IS_PROJECTILE, true)
		Appearance.applyRockLook(partHandle, strLookShape)
		FieldItem.applyFieldToolThrownState(toolThrowingStone, partHandle)
		partHandle.AssemblyLinearVelocity = vectorVelocity
		partHandle.AssemblyAngularVelocity = Vector3.new(math.random(-6, 6), math.random(-10, 10), math.random(-6, 6))

		connectionTouched = partHandle.Touched:Connect(function(partHit)
			if partHit == partHandle or partHit:IsDescendantOf(toolThrowingStone) then return end
			if playerAttacker and playerAttacker.Character and partHit:IsDescendantOf(playerAttacker.Character) then return end

			local modelTarget, humanoidTarget = CombatRules.findHumanoidDamageTargetFromPart(partHit)
			if not partHit.CanCollide and not humanoidTarget then return end

			local numberVelocityMagnitude = partHandle.AssemblyLinearVelocity.Magnitude
			
			-- 이미 비행종료(boolLanded) 상태라면 속도가 빠를 때(예: 굴러떨어질 때)만 1/4 데미지 적용
			local boolCanApplyDamage = not boolLanded or (boolLanded and numberVelocityMagnitude > 12)

			if humanoidTarget and boolCanApplyDamage then
				local numberFinalDamage = numberDamage
				if boolLanded then
					-- 비행 중이 아닐 때는 원래 데미지의 1/4(25%)만 적용
					numberFinalDamage = numberDamage * 0.25
				end

				local boolDamageApplied = CombatRules.applyHumanoidDamage(playerAttacker, modelTarget, humanoidTarget, numberFinalDamage)
				
				-- [조인트 끼임 버그 수정] 
				-- 캐릭터와 부딪혀 데미지를 입히는 즉시 돌의 물리 충돌 및 터치 판정을 끄고 속도를 소멸시켜 달라붙거나 끼이는 문제를 차단합니다.
				partHandle.CanCollide = false
				partHandle.CanTouch = false
				partHandle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				partHandle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

				local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
				-- 넉백은 비행 중(boolLanded == false)인 첫 타격 시에만 적용
				if boolDamageApplied and partTargetRoot and not boolLanded then
					local flatLaunchDir = Vector3.new(vectorVelocity.X, 0, vectorVelocity.Z)
					local knockbackDir = flatLaunchDir.Magnitude > 0 and flatLaunchDir.Unit or Vector3.new(0, 0, -1)
					partTargetRoot.AssemblyLinearVelocity = knockbackDir * (numberKnockbackForward * (0.7 + numberSafeCharge * 0.6)) + Vector3.new(0, numberKnockbackUp, 0)
				end

				if not boolLanded then
					finish_throw_after_delay(0.4)
				end
			elseif not humanoidTarget and not boolLanded then
				-- 지형지물에 일반 충돌 시 비행 해제
				finish_throw_after_delay(0.6)
			end
		end)

		task.spawn(function()
			while not boolLanded and toolThrowingStone.Parent do
				task.wait(0.25)
				if not FieldItem.isFieldToolWorldPositionSafe(fldItemSpawnArea, partHandle.Position) then
					finish_throw_after_delay(0)
					return
				end
			end
		end)

		task.delay(numberChargedLifetime, function()
			finish_throw_after_delay(0)
		end)
	end

	eventThrowingStoneAim.OnServerEvent:Connect(function(playerAttacker, toolRequested, vectorAimPosition, numberCharge)
		if toolRequested ~= toolThrowingStone then return end

		throw_toward_aim(playerAttacker, vectorAimPosition, numberCharge)
	end)
end

-- --------------------------------------------------------------------------------

return ThrowingStone
