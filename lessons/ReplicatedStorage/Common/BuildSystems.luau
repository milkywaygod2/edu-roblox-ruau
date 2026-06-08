-- [Module] BuildSystems
local BuildSystems = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)
local CoreBlock = require(script.Parent.CoreBlock)
local Appearance = require(script.Parent.Appearance)
local ThrowingStone = require(script.Parent.ThrowingStone)

local tblStudentBrickSpawnOrigins = {
	Vector3.new(-28, 0, 18),
	Vector3.new(-14, 0, 18),
	Vector3.new(0, 0, 18),
	Vector3.new(14, 0, 18),
	Vector3.new(28, 0, 18),
}

local STUDENT_BRICK_DROP_RUNTIME_ATTRIBUTE = "RuntimeInstalled_StudentBrickDrop"

-- --------------------------------------------------------------------------------
-- [Role 1] 학생 벽돌 디자인 설치 (2일차 물리 쌓기 실습)
-- --------------------------------------------------------------------------------
function BuildSystems.createFallbackBrickDesign(strSourceName)
	local tblBrickDesign = ThrowingStone.createRockDesign(strSourceName .. " 기본 벽돌")
	tblBrickDesign.DesignKind = "StackBrick"
	tblBrickDesign.DisplayName = strSourceName .. " 기본 벽돌"
	tblBrickDesign.SpawnCount = 10
	tblBrickDesign.Appearance.Material = Enum.Material.Brick
	tblBrickDesign.Appearance.Size = Vector3.new(4, 2, 2)
	tblBrickDesign.Appearance.CollisionShape = Enum.PartType.Block
	tblBrickDesign.Appearance.CollisionShapeMode = "Auto"
	tblBrickDesign.Appearance.LookShape = ""
	return tblBrickDesign
end


-- --------------------------------------------------------------------------------


function BuildSystems.readStudentBrickDesignModule(moduleBrickDesign, tblValidationMessages)
	if not moduleBrickDesign:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblBrickDesign = pcall(require, moduleBrickDesign)
	if not boolSuccess then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleBrickDesign.Name, "코드 실행 오류가 있어 기본 벽돌로 대체했습니다. " .. tostring(tblBrickDesign))
		return BuildSystems.createFallbackBrickDesign(moduleBrickDesign.Name)
	end

	if type(tblBrickDesign) ~= "table" then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleBrickDesign.Name, "마지막 줄에서 table을 return해야 해서 기본 벽돌로 대체했습니다.")
		return BuildSystems.createFallbackBrickDesign(moduleBrickDesign.Name)
	end

	return tblBrickDesign
end


-- --------------------------------------------------------------------------------


local function read_brick_design_look_shape(tblBrickDesign)
	if type(tblBrickDesign) ~= "table" then return nil end

	local tblAppearance = type(tblBrickDesign.Appearance) == "table" and tblBrickDesign.Appearance or nil
	local valueLookShape = tblAppearance and (tblAppearance.LookShape or tblAppearance.Look)
	if valueLookShape == nil then
		valueLookShape = tblBrickDesign.LookShape or tblBrickDesign.Look
	end

	if type(valueLookShape) == "number" then
		return tostring(valueLookShape)
	end

	if type(valueLookShape) == "string" and valueLookShape ~= "" then
		return valueLookShape
	end

	return nil
end


-- --------------------------------------------------------------------------------


local function append_unique_brick_look_shape(tblLookShapes, mapLookShapes, tblBrickDesign)
	local strLookShape = read_brick_design_look_shape(tblBrickDesign)
	if not strLookShape or mapLookShapes[strLookShape] then return end

	mapLookShapes[strLookShape] = true
	table.insert(tblLookShapes, strLookShape)
end


-- --------------------------------------------------------------------------------


function BuildSystems.installStudentBrickDropSystem(svcReplicatedStorage)
	if not svcReplicatedStorage then
		return false
	end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eventDropCarriedBlock = EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.DROP_CARRIED_BLOCK, svcReplicatedStorage)
	if not EngineEnsure.markRuntimeInstalled(eventDropCarriedBlock, STUDENT_BRICK_DROP_RUNTIME_ATTRIBUTE) then
		return false
	end

	eventDropCarriedBlock.OnServerEvent:Connect(function(playerPlayer)
		CoreBlock.dropCarriedBlock(playerPlayer)
	end)
	return true
end


-- --------------------------------------------------------------------------------


function BuildSystems.clearStudentBrickParts(fldBattlefield)
	local eLogical = CoreEnums.eEngineLogicalType
	for _, instanceChild in ipairs(fldBattlefield:GetChildren()) do
		if CoreEnums.hasEngineLogicalNamePrefix(instanceChild.Name, eLogical.STACK_BRICK_PREFIX) then
			instanceChild:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function BuildSystems.createStudentBrickPart(fldBattlefield, tblResolvedDesign, intDesignIndex, intBrickIndex)
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey
	local vectorSize = tblResolvedDesign.ProjectileSize
	local vectorBase = tblStudentBrickSpawnOrigins[((intDesignIndex - 1) % #tblStudentBrickSpawnOrigins) + 1]
	local vectorJitter = ThrowingStone.createFlatSpawnJitter(tblResolvedDesign.VariantId, intBrickIndex, tblResolvedDesign.SpawnRadius)
	local vectorPosition = Vector3.new(
		vectorBase.X + vectorJitter.X,
		vectorSize.Y * 0.5 + 0.08,
		vectorBase.Z + vectorJitter.Z
	) + tblResolvedDesign.SpawnOffset
	local cframeBrick = CFrame.new(vectorPosition) * CFrame.Angles(0, math.rad((intBrickIndex % 4) * 8), 0)

	local partBrick = CoreBlock.create(fldBattlefield, cframeBrick, {
		DisplayName = tblResolvedDesign.DisplayName,
		Size = vectorSize,
		Material = tblResolvedDesign.ProjectileMaterial,
		BrickColor = tblResolvedDesign.ProjectileBrickColor,
		Shape = tblResolvedDesign.ProjectileShape,
		LookShape = tblResolvedDesign.LookShape,
		CanMine = true,
		CanTakeDamage = true,
		MaxHealth = 140,
		ResourceYield = 10,
		ResourceType = tblResolvedDesign.RealMaterial,
		Anchored = tblResolvedDesign.WorldAnchored,
		CanCollide = tblResolvedDesign.WorldCanCollide,
		CanTouch = true,
		CanQuery = true,
		Massless = tblResolvedDesign.WorldMassless,
	})

	partBrick.Name = eLogical.STACK_BRICK_PREFIX .. tblResolvedDesign.VariantId .. "_" .. intBrickIndex
	partBrick:SetAttribute("CollisionShapeMode", tblResolvedDesign.CollisionShapeMode)
	partBrick:SetAttribute("CollisionShapeModeResolved", tblResolvedDesign.CollisionShapeModeResolved)
	partBrick:SetAttribute("RealMaterial", tblResolvedDesign.RealMaterial)
	partBrick:SetAttribute("MassKg", StudentConfig.calculateEquipmentMassKg(
		vectorSize,
		ThrowingStone.getThrowingStoneMaterialProfile(tblResolvedDesign.ProjectileMaterial).Density
	))
	partBrick:SetAttribute(eAttr.FIELD_ITEM_DISPLAY_NAME, tblResolvedDesign.DisplayName)

	pcall(function()
		partBrick:SetNetworkOwner(nil)
	end)
	return partBrick
end


-- --------------------------------------------------------------------------------


function BuildSystems.installStudentBrickDesigns(svcWorkspace, svcReplicatedStorage, fldStudentBrickDesigns)
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local tblModules = {}
	local tblValidationMessages = {}

	BuildSystems.installStudentBrickDropSystem(svcReplicatedStorage)
	BuildSystems.clearStudentBrickParts(fldBattlefield)

	if fldStudentBrickDesigns then
		for _, instanceChild in ipairs(fldStudentBrickDesigns:GetChildren()) do
			if instanceChild:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	local tblBrickDesignEntries = {}
	local tblLookShapes = {}
	local mapLookShapes = {}
	if #tblModules == 0 then
		StudentConfig.addValidationMessage(tblValidationMessages, "StudentBrickDesigns", "학생 ModuleScript가 없어 기본 벽돌을 설치했습니다.")
		local tblFallbackBrickDesign = BuildSystems.createFallbackBrickDesign("StudentBrickDesigns")
		table.insert(tblBrickDesignEntries, {
			SourceName = "StudentBrickDesigns",
			Config = tblFallbackBrickDesign,
		})
		append_unique_brick_look_shape(tblLookShapes, mapLookShapes, tblFallbackBrickDesign)
	else
		for _, moduleBrickDesign in ipairs(tblModules) do
			local tblBrickDesign = BuildSystems.readStudentBrickDesignModule(moduleBrickDesign, tblValidationMessages)

			if tblBrickDesign then
				table.insert(tblBrickDesignEntries, {
					SourceName = moduleBrickDesign.Name,
					Config = tblBrickDesign,
				})
				append_unique_brick_look_shape(tblLookShapes, mapLookShapes, tblBrickDesign)
			end
		end
	end

	Appearance.preloadRockLookTemplates(tblLookShapes, tblValidationMessages, "StudentBrickDesigns")
	local intInstalledCount = 0
	for intDesignIndex, tblBrickDesignEntry in ipairs(tblBrickDesignEntries) do
		local tblResolvedDesign = ThrowingStone.resolveThrowingStoneDesign(tblBrickDesignEntry.Config, tblValidationMessages, tblBrickDesignEntry.SourceName)
		for intBrickIndex = 1, tblResolvedDesign.SpawnCount do
			BuildSystems.createStudentBrickPart(fldBattlefield, tblResolvedDesign, intDesignIndex, intBrickIndex)
			intInstalledCount += 1
		end
	end

	for _, strMessage in ipairs(tblValidationMessages) do
		warn("학생 벽돌 설정 검사: " .. strMessage)
	end

	return intInstalledCount
end


-- --------------------------------------------------------------------------------
-- [Role 1] 학생 엄폐물 디자인 설치 (2일차 실습)
-- --------------------------------------------------------------------------------
function BuildSystems.installStudentCoverDesign(svcWorkspace, tblConfig)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local tblCovers = tblConfig and tblConfig.Covers or {}

	if #tblCovers == 0 then
		tblCovers = {
			{Origin = Vector3.new(-14, 1, 8), Material = Enum.Material.WoodPlanks, Color = "Reddish brown"},
			{Origin = Vector3.new(0, 1, 8), Material = Enum.Material.Slate, Color = "Dark stone grey"},
			{Origin = Vector3.new(14, 1, 8), Material = Enum.Material.Metal, Color = "Medium blue"},
		}
	end

	for index, tblCoverConfig in ipairs(tblCovers) do
		local intLevels = StudentConfig.readConfigInteger(tblCoverConfig, "Levels", 3, 1, 5)
		local vectorOrigin = StudentConfig.readConfigVector3(tblCoverConfig, "Origin", Vector3.new(index * 14 - 28, 1, 8), Vector3.new(-50, 0, -50), Vector3.new(50, 15, 50))
		local enumMaterial = StudentConfig.readConfigEnumItem(tblCoverConfig, "Material", Enum.Material.WoodPlanks)
		local brickColor = StudentConfig.readConfigBrickColor(tblCoverConfig, "Color", "Reddish brown")
		local modelCover = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.COVER_STUDENT_PREFIX .. index, fldBattlefield)

		-- 기존 생성된 자식들 청소 (중복 적재 방지)
		modelCover:ClearAllChildren()

		for level = 1, intLevels do
			local size = Vector3.new(math.max(3, 8 - level), 2, 2)
			-- 기존의 중첩 좌표 배치 규칙 보존 (Y축 level 오프셋)
			local blockPos = vectorOrigin + Vector3.new(0, level, 0)

			local partCover = CoreBlock.create(modelCover, blockPos, {
				Size = size,
				Material = enumMaterial,
				BrickColor = brickColor,
				CanMine = false,          -- 설치된 엄폐물은 채굴 불가
				CanTakeDamage = true,     -- 엄폐물이므로 대미지를 받아 부서짐
				MaxHealth = 80 + (level * 20), -- 위층으로 갈수록 가벼우나 고정 내구도 보정
				ResourceYield = 10,       -- 파괴 시 10 나무 자원 파편 드랍
				ResourceType = "Wood",
				Anchored = true
			})
			partCover.Name = eLogical.COVER_BLOCK_PREFIX .. level
		end
	end
end

-- --------------------------------------------------------------------------------
-- [Role 2] 자원 기반 방벽 시스템 설치 (3일차 실습)
-- --------------------------------------------------------------------------------
function BuildSystems.installResourceWallSystem(svcWorkspace, svcPlayers, tblConfig)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldBuildArea = tblOutpostWorld.fldBuildArea
	local partBuildButton = fldBuildArea:WaitForChild(eLogical.BUILD_BUTTON)
	local partWallSpawn = fldBuildArea:WaitForChild(eLogical.WALL_SPAWN)
	local intStartCredit = StudentConfig.readConfigInteger(tblConfig, "StartCredit", 100, 0, 500)
	local intWallCost = StudentConfig.readConfigInteger(tblConfig, "WallCost", 20, 1, 100)
	local intBlockCount = StudentConfig.readConfigInteger(tblConfig, "BlockCount", 8, 2, 12)
	local vectorBlockSize = StudentConfig.readConfigVector3(tblConfig, "BlockSize", Vector3.new(4, 6, 1), Vector3.new(1, 2, 0.5), Vector3.new(8, 12, 4))
	local enumMaterial = StudentConfig.readConfigEnumItem(tblConfig, "BlockMaterial", Enum.Material.WoodPlanks)
	local brickColor = StudentConfig.readConfigBrickColor(tblConfig, "BlockColor", "Reddish brown")
	local intNextRow = 0

	local function setup_stats(player)
		local fldLeaderstats = player:FindFirstChild(eLogical.RESERVED_LEADERSTATS)
		if not fldLeaderstats then
			fldLeaderstats = Instance.new(ePhysical.FOLDER)
			fldLeaderstats.Name = eLogical.RESERVED_LEADERSTATS
			fldLeaderstats.Parent = player
		end

		local ivalCredit = fldLeaderstats:FindFirstChild("Credit")
		if not ivalCredit then
			ivalCredit = Instance.new(ePhysical.INT_VALUE)
			ivalCredit.Name = "Credit"
			ivalCredit.Value = intStartCredit
			ivalCredit.Parent = fldLeaderstats
		end
	end

	local function build_wall(player)
		local fldLeaderstats = player:FindFirstChild(eLogical.RESERVED_LEADERSTATS)
		local ivalCredit = fldLeaderstats and fldLeaderstats:FindFirstChild("Credit")
		if not ivalCredit or ivalCredit.Value < intWallCost then return end

		ivalCredit.Value -= intWallCost
		intNextRow += 1

		for index = 1, intBlockCount do
			local blockPos = partWallSpawn.Position + Vector3.new(
				(index - (intBlockCount + 1) / 2) * vectorBlockSize.X,
				vectorBlockSize.Y / 2,
				intNextRow * 3
			)

			-- 단단하고 피해 시 물리 파편이 드롭되는 CoreBlock으로 방벽 생성
			local partWallBlock = CoreBlock.create(fldBuildArea, blockPos, {
				Size = vectorBlockSize,
				Material = enumMaterial,
				BrickColor = brickColor,
				CanMine = false,          -- 자원 방벽은 도끼로 채굴 불가
				CanTakeDamage = true,     -- 투사체 공격으로 파괴 가능
				MaxHealth = 120,          -- 단단한 방벽 내구도
				ResourceYield = 10,       -- 부서지면 자원 파편 드랍
				ResourceType = "Wood",    -- 부서지면 나무 자원 파편 드랍 (회수)
				Anchored = true
			})
			partWallBlock.Name = player.Name .. eLogical.WALL_BLOCK_SUFFIX .. "_" .. intNextRow .. "_" .. index
		end
	end

	if not EngineEnsure.markRuntimeInstalled(partBuildButton, "RuntimeInstalled_ResourceWall") then
		return
	end

	for _, player in ipairs(svcPlayers:GetPlayers()) do setup_stats(player) end
	svcPlayers.PlayerAdded:Connect(setup_stats)

	EngineEnsure.ensureClickDetector(partBuildButton, 24).MouseClick:Connect(build_wall)
end

-- --------------------------------------------------------------------------------

return BuildSystems
