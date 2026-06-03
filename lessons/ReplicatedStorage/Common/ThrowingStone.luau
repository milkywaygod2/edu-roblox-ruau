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
			Material = ThrowingStone.RealMaterial.Rock,
			Size = Vector3.new(1.2, 1.2, 1.2),
			CollisionShape = Enum.PartType.Ball,
			LookShape = "",
		},
	}
end


-- --------------------------------------------------------------------------------


local MaterialDatabase = {
	[Enum.Material.Slate] = { Density = 2700, Hardness = 4.0, DefaultColor = Color3.fromRGB(120, 120, 120), Transparency = 0 },
	[Enum.Material.Metal] = { Density = 7870, Hardness = 4.5, DefaultColor = Color3.fromRGB(190, 190, 195), Transparency = 0 },
	[Enum.Material.CorrodedMetal] = { Density = 7200, Hardness = 3.5, DefaultColor = Color3.fromRGB(130, 100, 90), Transparency = 0 },
	[Enum.Material.Wood] = { Density = 700, Hardness = 0.8, DefaultColor = Color3.fromRGB(130, 90, 60), Transparency = 0 },
	[Enum.Material.WoodPlanks] = { Density = 650, Hardness = 0.8, DefaultColor = Color3.fromRGB(140, 100, 70), Transparency = 0 },
	[Enum.Material.Ice] = { Density = 917, Hardness = 1.5, DefaultColor = Color3.fromRGB(180, 220, 255), Transparency = 0.2 },
	[Enum.Material.Glass] = { Density = 2500, Hardness = 5.5, DefaultColor = Color3.fromRGB(240, 250, 255), Transparency = 0.45 },
	[Enum.Material.Neon] = { Density = 600, Hardness = 2.0, DefaultColor = Color3.fromRGB(255, 100, 0), Transparency = 0 },
	[Enum.Material.Basalt] = { Density = 2400, Hardness = 5.5, DefaultColor = Color3.fromRGB(30, 30, 35), Transparency = 0 },
	[Enum.Material.Concrete] = { Density = 2400, Hardness = 4.5, DefaultColor = Color3.fromRGB(150, 150, 150), Transparency = 0 },
	[Enum.Material.Brick] = { Density = 1900, Hardness = 4.0, DefaultColor = Color3.fromRGB(160, 80, 70), Transparency = 0 },
	[Enum.Material.Pebble] = { Density = 2600, Hardness = 3.5, DefaultColor = Color3.fromRGB(115, 115, 115), Transparency = 0 },
	[Enum.Material.Sand] = { Density = 1600, Hardness = 2.0, DefaultColor = Color3.fromRGB(225, 200, 150), Transparency = 0 },
	[Enum.Material.Grass] = { Density = 300, Hardness = 0.5, DefaultColor = Color3.fromRGB(90, 140, 70), Transparency = 0 },
	[Enum.Material.Fabric] = { Density = 150, Hardness = 0.1, DefaultColor = Color3.fromRGB(180, 160, 160), Transparency = 0 },
	[Enum.Material.Plastic] = { Density = 900, Hardness = 1.5, DefaultColor = Color3.fromRGB(170, 170, 170), Transparency = 0 },
	[Enum.Material.SmoothPlastic] = { Density = 900, Hardness = 1.5, DefaultColor = Color3.fromRGB(180, 180, 180), Transparency = 0 },
	[Enum.Material.Foil] = { Density = 2700, Hardness = 2.5, DefaultColor = Color3.fromRGB(220, 220, 225), Transparency = 0 },
	[Enum.Material.Granite] = { Density = 2700, Hardness = 6.0, DefaultColor = Color3.fromRGB(100, 95, 95), Transparency = 0 },
	[Enum.Material.Marble] = { Density = 2700, Hardness = 3.0, DefaultColor = Color3.fromRGB(230, 230, 235), Transparency = 0 },
	[Enum.Material.Cobblestone] = { Density = 2500, Hardness = 4.0, DefaultColor = Color3.fromRGB(110, 110, 110), Transparency = 0 },
	[Enum.Material.Sandstone] = { Density = 2200, Hardness = 3.0, DefaultColor = Color3.fromRGB(195, 160, 120), Transparency = 0 },
	[Enum.Material.Rock] = { Density = 2700, Hardness = 4.0, DefaultColor = Color3.fromRGB(110, 110, 110), Transparency = 0 },
	[Enum.Material.Glacier] = { Density = 900, Hardness = 1.5, DefaultColor = Color3.fromRGB(190, 230, 250), Transparency = 0.1 },
	[Enum.Material.Mud] = { Density = 1500, Hardness = 0.5, DefaultColor = Color3.fromRGB(80, 60, 50), Transparency = 0 },
	[Enum.Material.Snow] = { Density = 300, Hardness = 0.2, DefaultColor = Color3.fromRGB(245, 245, 245), Transparency = 0 },
	[Enum.Material.Salt] = { Density = 2160, Hardness = 2.5, DefaultColor = Color3.fromRGB(225, 225, 230), Transparency = 0.05 },
}


-- --------------------------------------------------------------------------------
function ThrowingStone.getThrowingStoneMaterialProfile(customMaterialNameOrEnum)
	local enumMaterial = nil
	if typeof(customMaterialNameOrEnum) == "EnumItem" then
		enumMaterial = customMaterialNameOrEnum
	elseif type(customMaterialNameOrEnum) == "string" then
		for _, item in ipairs(Enum.Material:GetEnumItems()) do
			if item.Name:lower() == customMaterialNameOrEnum:lower() then
				enumMaterial = item
				break
			end
		end
		
		-- 구버전 텍스트 "Rock" 에셋 처리 호환성 유지
		if not enumMaterial and customMaterialNameOrEnum:lower() == "rock" then
			enumMaterial = Enum.Material.Rock or Enum.Material.Slate
		end
	end

	local data = enumMaterial and MaterialDatabase[enumMaterial]
	if data then
		return data, enumMaterial
	end

	-- 로블록스 순정 재질에 따른 임시 하위 호환 매핑
	if customMaterialNameOrEnum == Enum.Material.Metal then
		return MaterialDatabase[Enum.Material.Metal], Enum.Material.Metal
	elseif customMaterialNameOrEnum == Enum.Material.Wood then
		return MaterialDatabase[Enum.Material.Wood], Enum.Material.Wood
	elseif customMaterialNameOrEnum == Enum.Material.Ice then
		return MaterialDatabase[Enum.Material.Ice], Enum.Material.Ice
	end

	return MaterialDatabase[Enum.Material.Slate], Enum.Material.Slate
end


-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
function ThrowingStone.calculateThrowingStoneStats(vectorSize, customMaterialNameOrEnum)
	local tblMaterialProfile = ThrowingStone.getThrowingStoneMaterialProfile(customMaterialNameOrEnum)
	
	-- 1. 부피 연산 (1 Stud = 0.3m 고증)
	-- 실제 부피 (m³) = 스터드 부피 * (0.3m)^3 = 스터드 부피 * 0.027
	local volumeStud = vectorSize.X * vectorSize.Y * vectorSize.Z
	local volumeM3 = volumeStud * 0.027
	
	-- 2. 실제 질량 (kg) = 실제 부피 (m³) * 실제 밀도 (kg/m³)
	local densityKgM3 = tblMaterialProfile.Density
	local massKg = volumeM3 * densityKgM3
	
	-- 3. 모스 경도 (Mohs Hardness)
	local hardnessMohs = tblMaterialProfile.Hardness

	-- 4. 투척 에너지 (E = 20,000 Joules = 20 kJ)
	-- 게임 플레이 감각에 맞는 속도 범위 유지를 위해 마법적인 일정한 투척 에너지 설정
	local energyJoules = 20000
	
	-- 5. 발사 속도 (v = sqrt(2E/m) m/s)
	-- 1m = 3.333 studs 비례식 적용하여 스터드 속도(studs/s) 산출
	local speedMS = math.sqrt(2 * energyJoules / massKg)
	local speedStud = speedMS * 3.333

	-- 6. 충격 시의 운동량 (P = m * v_m_s)
	local momentum = massKg * speedMS

	-- 7. 넉백: 타격 시 전달되는 운동량 P에 비례
	local knockbackForward = 18 + momentum * 0.015
	local knockbackUp = 10 + momentum * 0.005

	-- 8. 데미지: 충돌 에너지 전달율과 밀접한 운동량 P와 경도 H의 제곱근 조화
	-- 경도가 낮으면(Rubber 등) 찌그러지며 피해를 흡수하고, 높으면(Diamond 등) 무기 손실 없이 대상에게 에너지 충격력을 100% 가함
	local damage = 8 + 0.2 * math.sqrt(momentum * hardnessMohs)

	-- 9. 쿨다운 (충전 시간): 질량(kg)에 비례하여 무거운 재질일수록 던질 준비가 무거움
	local cooldown = 0.45 + massKg * 0.005

	-- 10. 투척 궤적 (아크): 가볍고 빠를수록 직사(작은 Arc), 무거울수록 곡사(큰 Arc)
	local arc = 5 + massKg * 0.025

	return {
		Damage = StudentConfig.clampNumber(damage, 8, 30),
		Cooldown = StudentConfig.clampNumber(cooldown, 0.45, 2.4),
		Speed = StudentConfig.clampNumber(speedStud, 45, 135),
		Arc = StudentConfig.clampNumber(arc, 5, 35),
		KnockbackForward = StudentConfig.clampNumber(knockbackForward, 18, 80),
		KnockbackUp = StudentConfig.clampNumber(knockbackUp, 8, 35),
		Lifetime = StudentConfig.clampNumber(4 + massKg * 0.002, 3, 8),
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
	
	-- Material 파싱 및 검증 (EnumItem 반환)
	local enumMaterial = StudentConfig.readThrowingStoneMaterial(tblAppearanceConfig, "Material", Enum.Material.Slate, tblValidationMessages, strSourceName)
	local tblMaterialProfile, matchedEnum = ThrowingStone.getThrowingStoneMaterialProfile(enumMaterial)

	local enumShape = StudentConfig.readConfigEnumItem(tblAppearanceConfig, "CollisionShape", Enum.PartType.Ball)
	local valueShape = tblAppearanceConfig and tblAppearanceConfig.CollisionShape
	if tblAppearanceConfig and tblAppearanceConfig.CollisionShape == nil and tblAppearanceConfig.Shape ~= nil then
		enumShape = StudentConfig.readConfigEnumItem(tblAppearanceConfig, "Shape", Enum.PartType.Ball)
		valueShape = tblAppearanceConfig.Shape
	end
	if valueShape ~= nil and enumShape == Enum.PartType.Ball and valueShape ~= Enum.PartType.Ball then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "CollisionShape는 Enum.PartType 값을 써야 해서 Ball로 보정했습니다.")
	end
	-- 리얼머티리얼(실물 재질) 고증에 따라 색상 속성은 재질 고유의 기본 색상으로 강제 지정
	if tblAppearanceConfig and (tblAppearanceConfig.BrickColor ~= nil or tblAppearanceConfig.Color ~= nil) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "재질 고증 시스템에 따라 색상은 자동으로 " .. matchedEnum.Name .. "의 기본 고증 색상으로 통제되어 지정된 색상은 제외되었습니다.")
	end

	local colorProjectile = tblMaterialProfile.DefaultColor or Color3.fromRGB(120, 120, 120)
	local brickColor = StudentConfig.createBrickColorFromColor3(colorProjectile)

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
	local tblStats = ThrowingStone.calculateThrowingStoneStats(vectorSize, matchedEnum)

	return {
		VariantId = strVariantId,
		DisplayName = StudentConfig.readConfigString(tblConfig, "DisplayName", "전장 돌멩이"),
		SpawnCount = StudentConfig.readConfigInteger(tblConfig, "SpawnCount", 10, 1, 10),
		SpawnOffset = StudentConfig.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8)),
		SpawnRadius = StudentConfig.readConfigNumber(tblConfig, "SpawnRadius", 4, 0, 8),
		RealMaterial = matchedEnum.Name,
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
		ProjectileTransparency = tblMaterialProfile.Transparency or 0,
		Handle = {
			Size = vectorSize,
			Material = enumMaterial,
			BrickColor = brickColor,
			Color = colorProjectile,
			Shape = enumShape,
			Transparency = tblMaterialProfile.Transparency or 0,
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
		or tblConfig.RealMaterial
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
	tblRockDesign.Appearance.Material = ThrowingStone.RealMaterial.Rock
	tblRockDesign.Appearance.Size = Vector3.new(1.1, 1.1, 1.1)
	tblRockDesign.Appearance.CollisionShape = Enum.PartType.Ball
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
	partHandle.Transparency = tblConfig and tblConfig.Handle and tblConfig.Handle.Transparency or 0

	local numberDamage = StudentConfig.readConfigNumber(tblConfig, "Damage", 15, 1, 30)
	toolThrowingStone:SetAttribute("Damage", math.floor(numberDamage + 0.5))
	toolThrowingStone:SetAttribute("RealMaterial", tblConfig and tblConfig.RealMaterial or "Rock")
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
		
		-- 1 Stud = 0.3m 물리 고증 기반 질량(kg) 서버 검증
		local tblMaterialProfile = ThrowingStone.getThrowingStoneMaterialProfile(enumProjectileMaterial)
		local volumeM3 = (vectorProjectileSize.X * vectorProjectileSize.Y * vectorProjectileSize.Z) * 0.027
		local massKg = volumeM3 * tblMaterialProfile.Density

		-- 특화에 따른 무게 제한 및 발사 에너지 증가 (20,000J -> 24,000J)
		local strSpec = playerAttacker:GetAttribute("Specialization") or "None"
		local numberMaxWeight = 30
		local energyJoules = 20000

		if strSpec == "Strength" then
			numberMaxWeight = 50 -- 힘 특화 시 50kg으로 제한 완화
			energyJoules = 24000  -- 힘 특화 시 발사 에너지 20% 증가
		end

		-- 무게 초과 시 투척 불가 처리 및 원상복구
		if massKg > numberMaxWeight then
			toolThrowingStone.Enabled = true
			boolReady = true
			return
		end

		-- 운동에너지(E = 0.5 * m * v^2)에 의거한 투척 탄속 정밀 동적 재산출
		local speedMS = math.sqrt(2 * energyJoules / massKg)
		local speedStud = speedMS * 3.333 -- studs/s로 환산

		local vectorStartPosition = partHumanoidRoot.Position + Vector3.new(0, 1.5, 0)
		local vectorAimDirection = partHumanoidRoot.CFrame.LookVector
		if typeof(vectorAimPosition) == "Vector3" and (vectorAimPosition - vectorStartPosition).Magnitude > 0.1 then
			vectorAimDirection = (vectorAimPosition - vectorStartPosition).Unit
		end

		local numberChargedSpeed = speedStud * (0.55 + numberSafeCharge * 0.75)
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
		partHandle.Transparency = tblConfig and tblConfig.ProjectileTransparency or 0
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
