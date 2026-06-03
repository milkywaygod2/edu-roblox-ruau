-- [Module] CurriculumSetup
local CurriculumSetup = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local FieldItem = require(script.Parent.FieldItem)
local StudentConfig = require(script.Parent.StudentConfig)
local ThrowingStone = require(script.Parent.ThrowingStone)
local BuildSystems = require(script.Parent.BuildSystems)
local WeaponSystems = require(script.Parent.WeaponSystems)
local Fortification = require(script.Parent.Fortification)
local SiegeEngine = require(script.Parent.SiegeEngine)
local MagicSystem = require(script.Parent.MagicSystem)
local FinalBattle = require(script.Parent.FinalBattle)

-- --------------------------------------------------------------------------------
function CurriculumSetup.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumCoreTargets(fldObjectiveArea)
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumPracticeTargets(fldObjectiveArea)
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumBattlefieldMarkers(fldBattlefield)
	local eLogical = CoreEnums.eEngineLogicalType

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
		CanCollide = false, -- [스폰 끼임 방지] 기본 스폰 포인트(원점)와 겹칠 때 캐릭터가 물리적으로 끼는 현상 원천 예방 (ClickDetector는 작동함)
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


function CurriculumSetup.ensureCurriculumBuildArea(fldBuildArea)
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumItemSpawnMarkers(fldItemSpawnArea)
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumFortification(fldFortification)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
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


function CurriculumSetup.ensureCurriculumSiegeEngine(fldSiegeEngine)
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumTeams(svcTeams)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

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


function CurriculumSetup.setupCurriculumWorld(gameRoot, tblConfig)
	local eService = CoreEnums.eEngineServiceSingleton
	local dataModel = gameRoot or game
	local svcWorkspace = dataModel:GetService(eService.WORKSPACE)
	local svcPlayers = dataModel:GetService(eService.PLAYERS)
	local svcReplicatedStorage = dataModel:GetService(eService.REPLICATED_STORAGE)
	local svcServerScriptService = dataModel:GetService(eService.SERVER_SCRIPT_SERVICE)
	local svcTeams = dataModel:GetService(eService.TEAMS)
	local tblOutpostWorld = EngineEnsure.ensureOutpostBattleWorld(svcWorkspace)
	local tblSharedAssets = CurriculumSetup.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService)
	local boolInstallStudentThrowingStones = tblConfig == nil or tblConfig.InstallStudentThrowingStones ~= false
	local boolInstallStudentLessonConfigs = tblConfig == nil or tblConfig.InstallStudentLessonConfigs ~= false

	CurriculumSetup.ensureCurriculumRemoteEvents(svcReplicatedStorage)
	CurriculumSetup.ensureCurriculumTeams(svcTeams)
	CurriculumSetup.ensureCurriculumCoreTargets(tblOutpostWorld.fldObjectiveArea)
	CurriculumSetup.ensureCurriculumPracticeTargets(tblOutpostWorld.fldObjectiveArea)
	CurriculumSetup.ensureCurriculumBattlefieldMarkers(tblOutpostWorld.fldBattlefield)
	CurriculumSetup.ensureCurriculumBuildArea(tblOutpostWorld.fldBuildArea)
	CurriculumSetup.ensureCurriculumItemSpawnMarkers(tblOutpostWorld.fldItemSpawnArea)
	CurriculumSetup.ensureCurriculumFortification(tblOutpostWorld.fldFortification)
	CurriculumSetup.ensureCurriculumSiegeEngine(tblOutpostWorld.fldSiegeEngine)

	if boolInstallStudentThrowingStones then
		ThrowingStone.installStudentThrowingStoneDesigns(svcWorkspace, tblSharedAssets.fldStudentRockDesigns)
	end

	if boolInstallStudentLessonConfigs then
		CurriculumSetup.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, tblSharedAssets.fldStudentLessonConfigs)
	end

	print("수업 월드 준비 완료")
	return {
		tblOutpostWorld = tblOutpostWorld,
		tblSharedAssets = tblSharedAssets,
	}
end

-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Student Config Installation Services (Moved to resolve circular dependencies)
-- --------------------------------------------------------------------------------

function CurriculumSetup.readStudentLessonConfigModule(moduleLessonConfig, tblValidationMessages)
	if not moduleLessonConfig:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
		return nil
	end

	local boolSuccess, tblLessonConfig = pcall(require, moduleLessonConfig)
	if not boolSuccess then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "코드 실행 오류가 있어 이 설정을 건너뜁니다. " .. tostring(tblLessonConfig))
		return nil
	end

	if type(tblLessonConfig) ~= "table" then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "마지막 줄에서 table을 return해야 해서 이 설정을 건너뜁니다.")
		return nil
	end

	return tblLessonConfig
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.readStudentLessonConfigDayNumber(moduleLessonConfig, tblValidationMessages)
	local strModuleName = moduleLessonConfig.Name
	local valueDayNumber = tonumber(strModuleName:match("^(%d+)") or strModuleName:match("(%d+)$"))
	if type(valueDayNumber) ~= "number" then
		StudentConfig.addValidationMessage(tblValidationMessages, moduleLessonConfig.Name, "파일명 앞이나 뒤에 회차 숫자가 없어 건너뜁니다. 예: 02_student_answer 또는 StudentAnswer02")
		return nil
	end

	return math.floor(valueDayNumber)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, strConceptKey)
	local tblConceptConfig = tblLessonConfig[strConceptKey]
	if type(tblConceptConfig) == "table" then
		return tblConceptConfig
	end

	return tblLessonConfig
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.installStudentLessonConfigByDayNumber(svcWorkspace, svcPlayers, svcReplicatedStorage, intDayNumber, tblLessonConfig, tblValidationMessages, strSourceName)
	local eConfigKey = CoreEnums.eStudentLessonConfigKey

	if intDayNumber == 2 then
		BuildSystems.installStudentCoverDesign(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.COVER_DESIGN))
	elseif intDayNumber == 3 then
		BuildSystems.installResourceWallSystem(svcWorkspace, svcPlayers, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.RESOURCE_WALL))
	elseif intDayNumber == 4 then
		WeaponSystems.installFieldSwordPickups(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SWORD))
	elseif intDayNumber == 5 then
		WeaponSystems.installFieldBowPickups(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.BOW))
	elseif intDayNumber == 6 then
		WeaponSystems.installFieldShieldPickups(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SHIELD))
	elseif intDayNumber == 7 then
		WeaponSystems.installFieldArmorPickups(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.ARMOR))
	elseif intDayNumber == 8 then
		Fortification.installGateDamageSystem(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.GATE))
	elseif intDayNumber == 9 then
		Fortification.installStoneWallDamageSystem(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.STONE_WALL))
	elseif intDayNumber == 10 then
		SiegeEngine.installSiegeEngineSystem(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.SIEGE_ENGINE))
	elseif intDayNumber == 11 then
		MagicSystem.installMagicStaffPickups(svcWorkspace, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.STAFF))
		MagicSystem.installMagicServerSystem(svcReplicatedStorage, svcPlayers, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.MAGIC))
	elseif intDayNumber == 12 then
		FinalBattle.installFinalBattleSystem(svcWorkspace, svcPlayers, CurriculumSetup.readStudentLessonConceptConfig(tblLessonConfig, eConfigKey.FINAL_BATTLE))
	else
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "지원하지 않는 " .. tostring(intDayNumber) .. "회차 설정이라 건너뜁니다.")
		return false
	end

	return true
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages)
	local tblLessonConfig = CurriculumSetup.readStudentLessonConfigModule(moduleLessonConfig, tblValidationMessages)
	if not tblLessonConfig then
		return false
	end

	local intDayNumber = CurriculumSetup.readStudentLessonConfigDayNumber(moduleLessonConfig, tblValidationMessages)
	if not intDayNumber then
		return false
	end

	return CurriculumSetup.installStudentLessonConfigByDayNumber(svcWorkspace, svcPlayers, svcReplicatedStorage, intDayNumber, tblLessonConfig, tblValidationMessages, moduleLessonConfig.Name)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, fldStudentLessonConfigs)
	local tblModules = {}
	local tblValidationMessages = {}
	if fldStudentLessonConfigs then
		for _, instanceChild in ipairs(fldStudentLessonConfigs:GetChildren()) do
			if instanceChild:IsA(CoreEnums.eEnginePhysicalType.MODULE_SCRIPT) then
				table.insert(tblModules, instanceChild)
			end
		end
	end

	table.sort(tblModules, function(moduleLeft, moduleRight)
		return moduleLeft.Name < moduleRight.Name
	end)

	local intInstalledCount = 0
	for _, moduleLessonConfig in ipairs(tblModules) do
		if CurriculumSetup.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages) then
			intInstalledCount += 1
		end
	end

	for _, strMessage in ipairs(tblValidationMessages) do
		warn("학생 수업 설정 검사: " .. strMessage)
	end

	return intInstalledCount
end

-- --------------------------------------------------------------------------------

return CurriculumSetup
