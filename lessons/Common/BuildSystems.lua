-- [Module] BuildSystems
local BuildSystems = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function BuildSystems.installStudentCoverDesign(svcWorkspace, tblConfig) -- [의미/의도] 학생 엄폐물 디자인 적용 함수 정의 ➔ 학생은 위치/재질/색 같은 에셋 설정만 바꾸고 생성 방식은 공통 코드가 관리하기 위함
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

		for level = 1, intLevels do
			EngineEnsure.ensureStaticPart(eLogical.COVER_BLOCK_PREFIX .. level, modelCover, {
				Size = Vector3.new(math.max(3, 8 - level), 2, 2),
				Position = vectorOrigin + Vector3.new(0, level, 0),
				CanCollide = true,
				Material = enumMaterial,
				BrickColor = brickColor,
			})
		end
	end
end


-- --------------------------------------------------------------------------------


function BuildSystems.installResourceWallSystem(svcWorkspace, svcPlayers, tblConfig) -- [의미/의도] 자원 방벽 서버 시스템 설치 함수 정의 ➔ 자원 지급/차감/방벽 생성 규칙을 학생 코드 밖의 공통 서버 코드로 관리하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldBuildArea = tblOutpostWorld.fldBuildArea
	local partBuildButton = fldBuildArea:WaitForChild(eLogical.BUILD_BUTTON)
	local partWallSpawn = fldBuildArea:WaitForChild(eLogical.WALL_SPAWN)
	local intStartWood = StudentConfig.readConfigInteger(tblConfig, "StartWood", 30, 0, 200)
	local intWallCost = StudentConfig.readConfigInteger(tblConfig, "WallCost", 10, 1, 100)
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

		local ivalWood = fldLeaderstats:FindFirstChild(eLogical.WOOD)
		if not ivalWood then
			ivalWood = Instance.new(ePhysical.INT_VALUE)
			ivalWood.Name = eLogical.WOOD
			ivalWood.Value = intStartWood
			ivalWood.Parent = fldLeaderstats
		end
	end

	local function build_wall(player)
		local fldLeaderstats = player:FindFirstChild(eLogical.RESERVED_LEADERSTATS)
		local ivalWood = fldLeaderstats and fldLeaderstats:FindFirstChild(eLogical.WOOD)
		if not ivalWood or ivalWood.Value < intWallCost then return end

		ivalWood.Value -= intWallCost
		intNextRow += 1

		for index = 1, intBlockCount do
			local partWallBlock = Instance.new(ePhysical.PART)
			partWallBlock.Name = player.Name .. eLogical.WALL_BLOCK_SUFFIX .. "_" .. intNextRow .. "_" .. index
			partWallBlock.Size = vectorBlockSize
			partWallBlock.Position = partWallSpawn.Position + Vector3.new((index - (intBlockCount + 1) / 2) * vectorBlockSize.X, vectorBlockSize.Y / 2, intNextRow * 3)
			partWallBlock.Anchored = true
			partWallBlock.Material = enumMaterial
			partWallBlock.BrickColor = brickColor
			partWallBlock.Parent = fldBuildArea
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