-- [Module] BuildSystems
local BuildSystems = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)
local CoreBlock = require(script.Parent.CoreBlock)

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