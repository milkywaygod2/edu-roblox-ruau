-- [Module] CurriculumSetup
local module = {}

local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))
local FieldItem = require(script.Parent:WaitForChild("FieldItem"))
local StudentConfig = require(script.Parent:WaitForChild("StudentConfig"))
local ThrowingStone = require(script.Parent:WaitForChild("ThrowingStone"))

-- --------------------------------------------------------------------------------
function module.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType

	local fldOutpostAssets = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_ASSETS, svcReplicatedStorage)
	local fldRockLooks = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.ROCK_LOOKS, fldOutpostAssets)
	local fldStudentRockDesigns = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_ROCK_DESIGNS, svcServerScriptService)
	local fldStudentLessonConfigs = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_LESSON_CONFIGS, svcServerScriptService)

	return {
		fldOutpostAssets = fldOutpostAssets,
		fldRockLooks = fldRockLooks,
		fldStudentRockDesigns = fldStudentRockDesigns,
		fldStudentLessonConfigs = fldStudentLessonConfigs,
	}
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumCoreTargets(fldObjectiveArea)
	local eLogical = EngineNames.eEngineLogicalType

	for _, tblCoreConfig in ipairs({
		{Name = eLogical.TEAM_BLUE, Position = Vector3.new(0, 3, 32), Color = "Bright blue"},
		{Name = eLogical.TEAM_RED, Position = Vector3.new(0, 3, -32), Color = "Bright red"},
	}) do
		EngineEnsure.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. tblCoreConfig.Name, fldObjectiveArea, {
			Size = Vector3.new(6, 6, 4),
			Position = tblCoreConfig.Position,
			BrickColor = BrickColor.new(tblCoreConfig.Color),
		}, {
			MaxHealth = 160,
			Health = 160,
		})
	end
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumPracticeTargets(fldObjectiveArea)
	local eLogical = EngineNames.eEngineLogicalType

	for index, vectorPosition in ipairs({
		Vector3.new(-16, 2.5, 24),
		Vector3.new(16, 2.5, 24),
		Vector3.new(-16, 2.5, -24),
		Vector3.new(16, 2.5, -24),
	}) do
		EngineEnsure.ensureHumanoidTarget(eLogical.OUTPOST_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new(index <= 2 and "Bright blue" or "Bright red"),
		}, {
			MaxHealth = 100,
			Health = 100,
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-18, 2.5, -8),
		Vector3.new(-9, 2.5, -8),
		Vector3.new(0, 2.5, -8),
		Vector3.new(9, 2.5, -8),
		Vector3.new(18, 2.5, -8),
	}) do
		EngineEnsure.ensureHumanoidTarget(eLogical.DUEL_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright orange"),
		}, {
			MaxHealth = 120,
			Health = 120,
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-32, 3, -30),
		Vector3.new(-20, 3, -34),
		Vector3.new(-8, 3, -38),
		Vector3.new(8, 3, -38),
		Vector3.new(20, 3, -34),
		Vector3.new(32, 3, -30),
	}) do
		EngineEnsure.ensureStaticPart(eLogical.RANGE_TARGET_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(4, 6, 1),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright red"),
		})
	end

	for index, vectorPosition in ipairs({
		Vector3.new(-21, 2.5, -26),
		Vector3.new(-14, 2.5, -30),
		Vector3.new(-7, 2.5, -34),
		Vector3.new(7, 2.5, -34),
		Vector3.new(14, 2.5, -30),
		Vector3.new(21, 2.5, -26),
	}) do
		EngineEnsure.ensureHumanoidTarget(eLogical.ARCANE_GUARD_PREFIX .. index, fldObjectiveArea, {
			Size = Vector3.new(3, 5, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Royal purple"),
		}, {
			MaxHealth = 100,
			Health = 100,
		})
	end
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumBattlefieldMarkers(fldBattlefield)
	local eLogical = EngineNames.eEngineLogicalType

	for index, vectorPosition in ipairs({
		Vector3.new(-28, 0.1, 0),
		Vector3.new(-14, 0.1, -4),
		Vector3.new(0, 0.1, 0),
		Vector3.new(14, 0.1, 4),
		Vector3.new(28, 0.1, 0),
	}) do
		EngineEnsure.ensureStaticPart(eLogical.COVER_MARKER_PREFIX .. index, fldBattlefield, {
			Size = Vector3.new(2, 0.2, 2),
			Position = vectorPosition,
			BrickColor = BrickColor.new("Bright yellow"),
		})
	end

	local partRoundStartButton = EngineEnsure.ensureStaticPart(eLogical.ROUND_START_BUTTON, fldBattlefield, {
		Size = Vector3.new(8, 1, 8),
		Position = Vector3.new(0, 0.5, 0),
		BrickColor = BrickColor.new("Lime green"),
	})
	EngineEnsure.ensureClickDetector(partRoundStartButton, 30)

	for _, tblSpawnConfig in ipairs({
		{Team = eLogical.TEAM_BLUE, Position = Vector3.new(0, 0.5, 38), Color = "Bright blue"},
		{Team = eLogical.TEAM_RED, Position = Vector3.new(0, 0.5, -38), Color = "Bright red"},
	}) do
		EngineEnsure.ensureStaticPart(eLogical.SPAWN_POINT_PREFIX .. tblSpawnConfig.Team, fldBattlefield, {
			Size = Vector3.new(8, 1, 8),
			Position = tblSpawnConfig.Position,
			BrickColor = BrickColor.new(tblSpawnConfig.Color),
			Material = Enum.Material.Neon,
		})
	end
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumBuildArea(fldBuildArea)
	local eLogical = EngineNames.eEngineLogicalType

	local partBuildButton = EngineEnsure.ensureStaticPart(eLogical.BUILD_BUTTON, fldBuildArea, {
		Size = Vector3.new(6, 1, 6),
		Position = Vector3.new(0, 0.5, 18),
		BrickColor = BrickColor.new("Bright green"),
	})
	EngineEnsure.ensureClickDetector(partBuildButton, 24)

	EngineEnsure.ensureStaticPart(eLogical.WALL_SPAWN, fldBuildArea, {
		Size = Vector3.new(2, 0.2, 2),
		Position = Vector3.new(0, 0.1, 24),
		Transparency = 0.35,
		BrickColor = BrickColor.new("Bright yellow"),
	})
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumItemSpawnMarkers(fldItemSpawnArea)
	local eLogical = EngineNames.eEngineLogicalType

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.THROWING_STONE, {
		Vector3.new(-24, 0.1, 8),
		Vector3.new(0, 0.1, 4),
		Vector3.new(24, 0.1, 8),
	}, "Bright yellow")

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SWORD, {
		Vector3.new(-18, 0.1, -2),
		Vector3.new(18, 0.1, -2),
	}, "Really red")

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_BOW, {
		Vector3.new(-34, 0.1, -6),
		Vector3.new(34, 0.1, -6),
	}, "Bright blue")

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SHIELD, {
		Vector3.new(-12, 0.1, 18),
		Vector3.new(12, 0.1, -18),
	}, "Dark stone grey")

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_ARMOR, {
		Vector3.new(-30, 0.1, 22),
		Vector3.new(30, 0.1, -22),
	}, "Really black")

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.MAGIC_STAFF, {
		Vector3.new(-8, 0.1, -30),
		Vector3.new(8, 0.1, -30),
	}, "Royal purple")
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumFortification(fldFortification)
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	local modelGate = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.GATE, fldFortification)

	for index = 1, 5 do
		EngineEnsure.ensureStaticPart(eLogical.GATE_PLANK_PREFIX .. index, modelGate, {
			Size = Vector3.new(2, 10, 1),
			Position = Vector3.new((index - 3) * 2, 5, -26),
			Material = Enum.Material.WoodPlanks,
			BrickColor = BrickColor.new("Reddish brown"),
		})
	end

	local modelStoneWall = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.STONE_WALL, fldFortification)
	for section = 1, 5 do
		local modelWallSection = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.WALL_SECTION_PREFIX .. section, modelStoneWall)
		for height = 1, 4 do
			EngineEnsure.ensureStaticPart(eLogical.STONE_BLOCK_PREFIX .. height, modelWallSection, {
				Size = Vector3.new(6, 2, 2),
				Position = Vector3.new((section - 3) * 6, height * 2 - 1, -30),
				Material = Enum.Material.Slate,
				BrickColor = BrickColor.new("Dark stone grey"),
			})
		end
	end
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumSiegeEngine(fldSiegeEngine)
	local eLogical = EngineNames.eEngineLogicalType

	local partLaunchButton = EngineEnsure.ensureStaticPart(eLogical.LAUNCH_BUTTON, fldSiegeEngine, {
		Size = Vector3.new(6, 1, 6),
		Position = Vector3.new(0, 0.5, 12),
		BrickColor = BrickColor.new("Bright blue"),
	})
	EngineEnsure.ensureClickDetector(partLaunchButton, 24)

	EngineEnsure.ensureStaticPart(eLogical.LAUNCH_POINT, fldSiegeEngine, {
		Size = Vector3.new(2, 2, 2),
		Position = Vector3.new(0, 4, 4),
		Transparency = 0.4,
	})

	EngineEnsure.ensureStaticPart(eLogical.TARGET_POINT, fldSiegeEngine, {
		Size = Vector3.new(4, 4, 4),
		Position = Vector3.new(0, 4, -34),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Bright red"),
	})
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage)
end


-- --------------------------------------------------------------------------------


function module.ensureCurriculumTeams(svcTeams)
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType

	for _, tblTeamConfig in ipairs({
		{Name = eLogical.TEAM_BLUE, Color = "Bright blue"},
		{Name = eLogical.TEAM_RED, Color = "Bright red"},
	}) do
		EngineEnsure.ensureNamedInstance(ePhysical.TEAM, tblTeamConfig.Name, svcTeams, {
			TeamColor = BrickColor.new(tblTeamConfig.Color),
			AutoAssignable = false,
		})
	end
end


-- --------------------------------------------------------------------------------


function module.setupCurriculumWorld(gameRoot, tblConfig)
	local eService = EngineNames.eEngineServiceSingleton
	local dataModel = gameRoot or game
	local svcWorkspace = dataModel:GetService(eService.WORKSPACE)
	local svcPlayers = dataModel:GetService(eService.PLAYERS)
	local svcReplicatedStorage = dataModel:GetService(eService.REPLICATED_STORAGE)
	local svcServerScriptService = dataModel:GetService(eService.SERVER_SCRIPT_SERVICE)
	local svcTeams = dataModel:GetService(eService.TEAMS)
	local tblOutpostWorld = EngineEnsure.ensureOutpostBattleWorld(svcWorkspace)
	local tblSharedAssets = module.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local boolInstallStudentThrowingStones = tblConfig == nil or tblConfig.InstallStudentThrowingStones ~= false
	local boolInstallStudentLessonConfigs = tblConfig == nil or tblConfig.InstallStudentLessonConfigs ~= false

	module.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	module.ensureCurriculumTeams(svcTeams)
	module.ensureCurriculumCoreTargets(tblOutpostWorld.fldObjectiveArea)
	module.ensureCurriculumPracticeTargets(tblOutpostWorld.fldObjectiveArea)
	module.ensureCurriculumBattlefieldMarkers(tblOutpostWorld.fldBattlefield)
	module.ensureCurriculumBuildArea(tblOutpostWorld.fldBuildArea)
	module.ensureCurriculumItemSpawnMarkers(tblOutpostWorld.fldItemSpawnArea)
	module.ensureCurriculumFortification(tblOutpostWorld.fldFortification)
	module.ensureCurriculumSiegeEngine(tblOutpostWorld.fldSiegeEngine)

	if boolInstallStudentThrowingStones then
		ThrowingStone.installStudentThrowingStoneDesigns(svcWorkspace, tblSharedAssets.fldStudentRockDesigns)
	end

	if boolInstallStudentLessonConfigs then
		StudentConfig.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, tblSharedAssets.fldStudentLessonConfigs)
	end

	print("수업 월드 준비 완료")
	return {
		tblOutpostWorld = tblOutpostWorld,
		tblSharedAssets = tblSharedAssets,
	}
end

-- --------------------------------------------------------------------------------

return module