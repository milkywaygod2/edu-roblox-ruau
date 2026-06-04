-- [Module] CurriculumSetup
local CurriculumSetup = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local BattlefieldLayout = require(script.Parent.BattlefieldLayout)
local FieldItem = require(script.Parent.FieldItem)
local StudentConfig = require(script.Parent.StudentConfig)
local ThrowingStone = require(script.Parent.ThrowingStone)
local BuildSystems = require(script.Parent.BuildSystems)
local WeaponSystems = require(script.Parent.WeaponSystems)
local Fortification = require(script.Parent.Fortification)
local SiegeEngine = require(script.Parent.SiegeEngine)
local MagicSystem = require(script.Parent.MagicSystem)
local FinalBattle = require(script.Parent.FinalBattle)
local CombatRules = require(script.Parent.CombatRules)

local tblWorldLayout = BattlefieldLayout.tblOutpostBattleWorldLayout

local DEFAULT_ACTIVE_LESSON_DAY = 12
local MIN_ACTIVE_LESSON_DAY = 1
local MAX_ACTIVE_LESSON_DAY = 12
local DEFAULT_WORKSPACE_GRAVITY = 130
local DEFAULT_PLAYER_JUMP_POWER = 30
local DEFAULT_PLAYER_JUMP_HEIGHT = 3.6
local DEFAULT_PLAYER_RESPAWN_SECONDS = 5
local DEFAULT_ACTIVE_CLASS = "Example"

-- --------------------------------------------------------------------------------


function CurriculumSetup.readCurriculumActiveLessonDay(valueConfig)
	local valueActiveLessonDay = valueConfig
	if type(valueConfig) == "table" then
		valueActiveLessonDay = valueConfig.ActiveLessonDay
	end

	local numberActiveLessonDay = tonumber(valueActiveLessonDay)
	if type(numberActiveLessonDay) ~= "number" or numberActiveLessonDay ~= numberActiveLessonDay then
		return DEFAULT_ACTIVE_LESSON_DAY
	end

	return math.clamp(math.floor(numberActiveLessonDay), MIN_ACTIVE_LESSON_DAY, MAX_ACTIVE_LESSON_DAY)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.readCurriculumActiveClass(valueConfig)
	local valueActiveClass = nil
	if type(valueConfig) == "table" then
		valueActiveClass = valueConfig.ActiveClass
	end
	if type(valueActiveClass) == "string" and valueActiveClass ~= "" then
		return valueActiveClass
	end
	return DEFAULT_ACTIVE_CLASS
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, intRequiredLessonDay)
	if type(intActiveLessonDay) ~= "number" then
		return true
	end

	return intRequiredLessonDay <= intActiveLessonDay
end

-- --------------------------------------------------------------------------------


function CurriculumSetup.resetCurriculumWorld(svcWorkspace)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

	return EngineEnsure.resetNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_BATTLE_WORLD, svcWorkspace)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeNamedChild(instanceParent, strName)
	if not instanceParent then return end

	local instanceChild = instanceParent:FindFirstChild(strName)
	if instanceChild then
		instanceChild:Destroy()
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeChildrenByNamePrefix(instanceParent, strPrefix)
	if not instanceParent then return end

	for _, instanceChild in ipairs(instanceParent:GetChildren()) do
		if CoreEnums.hasEngineLogicalNamePrefix(instanceChild.Name, strPrefix) then
			instanceChild:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeChildrenByNameFragment(instanceParent, strFragment)
	if not instanceParent then return end

	for _, instanceChild in ipairs(instanceParent:GetChildren()) do
		if string.find(instanceChild.Name, strFragment, 1, true) then
			instanceChild:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeDescendantsByName(instanceRoot, strName)
	if not instanceRoot then return end

	for _, instanceDescendant in ipairs(instanceRoot:GetDescendants()) do
		if instanceDescendant.Name == strName then
			instanceDescendant:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeFieldItemToolsFromContainer(instanceContainer, strToolName)
	if not instanceContainer then return end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
		if instanceChild:IsA(ePhysical.TOOL) and instanceChild:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == strToolName then
			instanceChild:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeFieldItemToolDescendants(instanceRoot, strToolName)
	if not instanceRoot then return end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	for _, instanceDescendant in ipairs(instanceRoot:GetDescendants()) do
		if instanceDescendant:IsA(ePhysical.TOOL) and instanceDescendant:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == strToolName then
			instanceDescendant:Destroy()
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, strToolName)
	local eLogical = CoreEnums.eEngineLogicalType

	CurriculumSetup.removeChildrenByNamePrefix(fldItemSpawnArea, eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_")
	CurriculumSetup.removeChildrenByNamePrefix(fldItemSpawnArea, eLogical.FIELD_ITEM_PREFIX .. strToolName .. "_")
	CurriculumSetup.removeFieldItemToolDescendants(svcWorkspace, strToolName)

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		CurriculumSetup.removeFieldItemToolsFromContainer(playerPlayer:FindFirstChild("Backpack"), strToolName)
		CurriculumSetup.removeFieldItemToolsFromContainer(playerPlayer.Character, strToolName)
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.clearCurriculumRoundRuntimeState(svcWorkspace)
	local eAttrKey = CoreEnums.eEngineAttributeKey

	for _, strAttributeKey in ipairs({
		eAttrKey.ROUND_STARTER_PLAYER_NAME_RUNTIME,
		eAttrKey.ROUND_STATE,
		eAttrKey.TIME_LEFT_RUNTIME,
		eAttrKey.ROUND_WINNER_RUNTIME,
		eAttrKey.ROUND_END_REASON_RUNTIME,
		eAttrKey.ROUND_BLUE_PLAYER_COUNT_RUNTIME,
		eAttrKey.ROUND_RED_PLAYER_COUNT_RUNTIME,
	}) do
		svcWorkspace:SetAttribute(strAttributeKey, nil)
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.cleanupCurriculumArtifactsAfterActiveLessonDay(svcWorkspace, svcPlayers, svcReplicatedStorage, tblOutpostWorld, intActiveLessonDay)
	local eLogical = CoreEnums.eEngineLogicalType
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local fldBuildArea = tblOutpostWorld.fldBuildArea
	local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local fldFortification = tblOutpostWorld.fldFortification
	local fldSiegeEngine = tblOutpostWorld.fldSiegeEngine

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 2) then
		CurriculumSetup.removeChildrenByNamePrefix(fldBattlefield, eLogical.COVER_MARKER_PREFIX)
		CurriculumSetup.removeChildrenByNamePrefix(fldBattlefield, eLogical.COVER_STUDENT_PREFIX)
		CurriculumSetup.removeChildrenByNamePrefix(fldObjectiveArea, eLogical.OUTPOST_GUARD_PREFIX)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 3) then
		CurriculumSetup.removeNamedChild(fldBuildArea, eLogical.BUILD_BUTTON)
		CurriculumSetup.removeNamedChild(fldBuildArea, eLogical.WALL_SPAWN)
		CurriculumSetup.removeChildrenByNameFragment(fldBuildArea, eLogical.WALL_BLOCK_SUFFIX)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 4) then
		CurriculumSetup.removeChildrenByNamePrefix(fldObjectiveArea, eLogical.DUEL_GUARD_PREFIX)
		CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, eLogical.FIELD_SWORD)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 5) then
		CurriculumSetup.removeChildrenByNamePrefix(fldObjectiveArea, eLogical.RANGE_TARGET_PREFIX)
		CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, eLogical.FIELD_BOW)
		CurriculumSetup.removeDescendantsByName(svcWorkspace, eLogical.PROJECTILE_ARROW_FIELD)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 6) then
		CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, eLogical.FIELD_SHIELD)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 7) then
		CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, eLogical.FIELD_ARMOR)
		CurriculumSetup.removeDescendantsByName(svcWorkspace, eLogical.ARMOR_AURA)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 8) then
		CurriculumSetup.removeNamedChild(fldFortification, eLogical.GATE)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 9) then
		CurriculumSetup.removeNamedChild(fldFortification, eLogical.STONE_WALL)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 10) then
		CurriculumSetup.removeNamedChild(fldSiegeEngine, eLogical.LAUNCH_BUTTON)
		CurriculumSetup.removeNamedChild(fldSiegeEngine, eLogical.LAUNCH_POINT)
		CurriculumSetup.removeNamedChild(fldSiegeEngine, eLogical.TARGET_POINT)
		CurriculumSetup.removeDescendantsByName(svcWorkspace, eLogical.SIEGE_STONE)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 11) then
		CurriculumSetup.removeChildrenByNamePrefix(fldObjectiveArea, eLogical.ARCANE_GUARD_PREFIX)
		CurriculumSetup.removeCurriculumFieldItemArtifacts(svcWorkspace, svcPlayers, fldItemSpawnArea, eLogical.MAGIC_STAFF)
		CurriculumSetup.removeNamedChild(svcReplicatedStorage, eLogical.CAST_MAGIC)
		CurriculumSetup.removeDescendantsByName(svcWorkspace, eLogical.PARTICLE_EFFECT)
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 12) then
		CurriculumSetup.removeNamedChild(fldBattlefield, eLogical.ROUND_START_BUTTON)
		CurriculumSetup.clearCurriculumRoundRuntimeState(svcWorkspace)
	end
end


-- --------------------------------------------------------------------------------
function CurriculumSetup.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService, strActiveClass)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

	local fldOutpostAssets = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_ASSETS, svcReplicatedStorage)
	local fldRockLooks = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.ROCK_LOOKS, fldOutpostAssets)
	local strClassFolderName = strActiveClass or DEFAULT_ACTIVE_CLASS
	local fldStudentRockDesignsRoot = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_ROCK_DESIGNS, svcServerScriptService)
	local fldStudentRockDesigns = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, strClassFolderName, fldStudentRockDesignsRoot)
	local fldStudentLessonConfigsRoot = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.STUDENT_LESSON_CONFIGS, svcServerScriptService)
	local fldStudentLessonConfigs = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, strClassFolderName, fldStudentLessonConfigsRoot)

	return {
		fldOutpostAssets = fldOutpostAssets,
		fldRockLooks = fldRockLooks,
		fldStudentRockDesigns = fldStudentRockDesigns,
		fldStudentLessonConfigs = fldStudentLessonConfigs,
	}
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumTeamSymbol(fldObjectiveArea, strTeamName, vectorCorePosition, strColorName)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local modelSymbol = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.TEAM_SYMBOL_PREFIX .. strTeamName, fldObjectiveArea)
	local vectorPolePosition = vectorCorePosition + Vector3.new(0, 7.5, 0)
	local vectorBannerDirection = strTeamName == eLogical.TEAM_BLUE and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)

	EngineEnsure.ensureStaticPart(eLogical.TEAM_SYMBOL_POLE, modelSymbol, {
		Size = Vector3.new(0.8, 9, 0.8),
		Position = vectorPolePosition,
		Material = Enum.Material.Metal,
		BrickColor = BrickColor.new("Medium stone grey"),
	})
	EngineEnsure.ensureStaticPart(eLogical.TEAM_SYMBOL_BANNER, modelSymbol, {
		Size = Vector3.new(5, 3, 0.5),
		Position = vectorPolePosition + vectorBannerDirection * 2.6 + Vector3.new(0, 2.5, 0),
		Material = Enum.Material.Neon,
		BrickColor = BrickColor.new(strColorName),
		CanCollide = false,
	})
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumCoreTargets(fldObjectiveArea)
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	CurriculumSetup.removeDescendantsByName(fldObjectiveArea, eLogical.DAMAGE_FEEDBACK_GUI)

	for _, tblCoreConfig in ipairs({
		{Name = eLogical.TEAM_BLUE, Position = tblWorldLayout.BLUE_CORE, Color = "Bright blue"},
		{Name = eLogical.TEAM_RED, Position = tblWorldLayout.RED_CORE, Color = "Bright red"},
	}) do
		local modelCore = EngineEnsure.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. tblCoreConfig.Name, fldObjectiveArea, {
			Size = Vector3.new(6, 6, 4),
			Position = tblCoreConfig.Position,
			BrickColor = BrickColor.new(tblCoreConfig.Color),
		}, {
			MaxHealth = 160,
			Health = 160,
		})
		modelCore:SetAttribute(eAttrKey.DAMAGE_FEEDBACK_SCORE, 1000)
		CurriculumSetup.ensureCurriculumTeamSymbol(fldObjectiveArea, tblCoreConfig.Name, tblCoreConfig.Position, tblCoreConfig.Color)
		CombatRules.showDamageFeedback(modelCore, 0, 160, 160)
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumPracticeTargets(fldObjectiveArea, intActiveLessonDay)
	local eLogical = CoreEnums.eEngineLogicalType

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 2) then
		for index, vectorPosition in ipairs({
			Vector3.new(-48, 2.5, 63),
			Vector3.new(48, 2.5, -63),
		}) do
			EngineEnsure.ensureHumanoidTarget(eLogical.OUTPOST_GUARD_PREFIX .. index, fldObjectiveArea, {
				Size = Vector3.new(3, 5, 2),
				Position = vectorPosition,
				BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red"),
			}, {
				MaxHealth = 100,
				Health = 100,
			})
		end
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 4) then
		for index, vectorPosition in ipairs({
			Vector3.new(-54, 2.5, -24),
			Vector3.new(-27, 2.5, -24),
			Vector3.new(0, 2.5, -24),
			Vector3.new(27, 2.5, -24),
			Vector3.new(54, 2.5, -24),
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
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 5) then
		for index, vectorPosition in ipairs({
			Vector3.new(-96, 3, -90),
			Vector3.new(-60, 3, -102),
			Vector3.new(-24, 3, -114),
			Vector3.new(24, 3, -114),
			Vector3.new(60, 3, -102),
			Vector3.new(96, 3, -90),
		}) do
			EngineEnsure.ensureStaticPart(eLogical.RANGE_TARGET_PREFIX .. index, fldObjectiveArea, {
				Size = Vector3.new(4, 6, 1),
				Position = vectorPosition,
				BrickColor = BrickColor.new("Bright red"),
			})
		end
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 11) then
		for index, vectorPosition in ipairs({
			Vector3.new(-63, 2.5, -78),
			Vector3.new(-42, 2.5, -90),
			Vector3.new(-21, 2.5, -102),
			Vector3.new(21, 2.5, -102),
			Vector3.new(42, 2.5, -90),
			Vector3.new(63, 2.5, -78),
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
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumBattlefieldMarkers(fldBattlefield, intActiveLessonDay)
	local eLogical = CoreEnums.eEngineLogicalType

	CurriculumSetup.removeNamedChild(fldBattlefield, eLogical.SPAWN_POINT_NEUTRAL)

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 2) then
		for index, vectorPosition in ipairs({
			Vector3.new(-84, 0.1, 0),
			Vector3.new(-42, 0.1, -12),
			Vector3.new(0, 0.1, 0),
			Vector3.new(42, 0.1, 12),
			Vector3.new(84, 0.1, 0),
		}) do
			EngineEnsure.ensureStaticPart(eLogical.COVER_MARKER_PREFIX .. index, fldBattlefield, {
				Size = Vector3.new(2, 0.2, 2),
				Position = vectorPosition,
				BrickColor = BrickColor.new("Bright yellow"),
				CanCollide = false,
			})
		end
	end

	for _, tblSpawnConfig in ipairs({
		{Team = eLogical.TEAM_BLUE, Position = tblWorldLayout.BLUE_SPAWN, Color = "Bright blue"},
		{Team = eLogical.TEAM_RED, Position = tblWorldLayout.RED_SPAWN, Color = "Bright red"},
	}) do
		EngineEnsure.ensureSpawnLocation(eLogical.SPAWN_POINT_PREFIX .. tblSpawnConfig.Team, fldBattlefield, {
			Size = Vector3.new(8, 1, 8),
			Position = tblSpawnConfig.Position,
			BrickColor = BrickColor.new(tblSpawnConfig.Color),
			Material = Enum.Material.Neon,
			Neutral = false,
			TeamColor = BrickColor.new(tblSpawnConfig.Color),
		})
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 12) then
		local partRoundStartButton = EngineEnsure.ensureStaticPart(eLogical.ROUND_START_BUTTON, fldBattlefield, {
			Size = Vector3.new(6, 1, 6),
			Position = tblWorldLayout.ROUND_START_BUTTON,
			BrickColor = BrickColor.new("Lime green"),
			CanCollide = false,
		})
		EngineEnsure.ensureClickDetector(partRoundStartButton, 30)
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumBuildArea(fldBuildArea)
	local eLogical = CoreEnums.eEngineLogicalType

	local partBuildButton = EngineEnsure.ensureStaticPart(eLogical.BUILD_BUTTON, fldBuildArea, {
		Size = Vector3.new(6, 1, 6),
		Position = tblWorldLayout.BUILD_BUTTON,
		BrickColor = BrickColor.new("Bright green"),
		CanCollide = false,
	})
	EngineEnsure.ensureClickDetector(partBuildButton, 24)

	EngineEnsure.ensureStaticPart(eLogical.WALL_SPAWN, fldBuildArea, {
		Size = Vector3.new(2, 0.2, 2),
		Position = tblWorldLayout.WALL_SPAWN,
		Transparency = 0.35,
		BrickColor = BrickColor.new("Bright yellow"),
		CanCollide = false,
	})
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumItemSpawnMarkers(fldItemSpawnArea, intActiveLessonDay)
	local eLogical = CoreEnums.eEngineLogicalType

	FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.THROWING_STONE, BattlefieldLayout.tblThrowingStoneSpawnPositions, "Bright yellow")

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 4) then
		FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SWORD, {
			Vector3.new(-54, 0.1, -6),
			Vector3.new(54, 0.1, -6),
		}, "Really red")
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 5) then
		FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_BOW, {
			Vector3.new(-102, 0.1, -18),
			Vector3.new(102, 0.1, -18),
		}, "Bright blue")
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 6) then
		FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SHIELD, {
			Vector3.new(-36, 0.1, 54),
			Vector3.new(36, 0.1, -54),
		}, "Dark stone grey")
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 7) then
		FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_ARMOR, {
			Vector3.new(-90, 0.1, 66),
			Vector3.new(90, 0.1, -66),
		}, "Really black")
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 11) then
		FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.MAGIC_STAFF, {
			Vector3.new(-24, 0.1, -90),
			Vector3.new(24, 0.1, -90),
		}, "Royal purple")
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumFortification(fldFortification, intActiveLessonDay)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 8) then
		local modelGate = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.GATE, fldFortification)
		for index = 1, 5 do
			EngineEnsure.ensureStaticPart(eLogical.GATE_PLANK_PREFIX .. index, modelGate, {
				Size = Vector3.new(2, 10, 1),
				Position = Vector3.new((index - 3) * 3, 5, -78),
				Material = Enum.Material.WoodPlanks,
				BrickColor = BrickColor.new("Reddish brown"),
			})
		end
	end

	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 9) then
		local modelStoneWall = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.STONE_WALL, fldFortification)
		for section = 1, 5 do
			local modelWallSection = EngineEnsure.ensureNamedInstance(ePhysical.MODEL, eLogical.WALL_SECTION_PREFIX .. section, modelStoneWall)
			for height = 1, 4 do
				EngineEnsure.ensureStaticPart(eLogical.STONE_BLOCK_PREFIX .. height, modelWallSection, {
					Size = Vector3.new(6, 2, 2),
					Position = Vector3.new((section - 3) * 18, height * 2 - 1, -90),
					Material = Enum.Material.Slate,
					BrickColor = BrickColor.new("Dark stone grey"),
				})
			end
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumSiegeEngine(fldSiegeEngine)
	local eLogical = CoreEnums.eEngineLogicalType

	local partLaunchButton = EngineEnsure.ensureStaticPart(eLogical.LAUNCH_BUTTON, fldSiegeEngine, {
		Size = Vector3.new(6, 1, 6),
		Position = Vector3.new(0, 0.5, 36),
		BrickColor = BrickColor.new("Bright blue"),
		CanCollide = false,
	})
	EngineEnsure.ensureClickDetector(partLaunchButton, 24)

	EngineEnsure.ensureStaticPart(eLogical.LAUNCH_POINT, fldSiegeEngine, {
		Size = Vector3.new(2, 2, 2),
		Position = Vector3.new(0, 4, 12),
		Transparency = 0.4,
		CanCollide = false,
	})

	EngineEnsure.ensureStaticPart(eLogical.TARGET_POINT, fldSiegeEngine, {
		Size = Vector3.new(4, 4, 4),
		Position = Vector3.new(0, 4, -102),
		Transparency = 0.4,
		BrickColor = BrickColor.new("Bright red"),
		CanCollide = false,
	})
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.ensureCurriculumRemoteEvents(svcReplicatedStorage, intActiveLessonDay)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.SPECIALIZATION_SELECT, svcReplicatedStorage)

	if intActiveLessonDay == nil or intActiveLessonDay >= 11 then
		EngineEnsure.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage)
	end
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


function CurriculumSetup.countCurriculumTeamPlayers(svcPlayers, teamTarget)
	local intCount = 0
	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		if playerPlayer.Team == teamTarget then
			intCount += 1
		end
	end

	return intCount
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.pickCurriculumOpenTeam(svcPlayers, teamBlue, teamRed)
	local intBlueCount = CurriculumSetup.countCurriculumTeamPlayers(svcPlayers, teamBlue)
	local intRedCount = CurriculumSetup.countCurriculumTeamPlayers(svcPlayers, teamRed)
	if intRedCount < intBlueCount then
		return teamRed
	end

	return teamBlue
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.assignPlayerToCurriculumTeam(svcPlayers, svcTeams, playerPlayer)
	local eLogical = CoreEnums.eEngineLogicalType
	local teamBlue = svcTeams:FindFirstChild(eLogical.TEAM_BLUE)
	local teamRed = svcTeams:FindFirstChild(eLogical.TEAM_RED)
	if not teamBlue or not teamRed then return end
	if playerPlayer.Team == teamBlue or playerPlayer.Team == teamRed then return end

	playerPlayer.Neutral = false
	playerPlayer.Team = CurriculumSetup.pickCurriculumOpenTeam(svcPlayers, teamBlue, teamRed)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.assignCurriculumTeams(svcPlayers, svcTeams)
	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		CurriculumSetup.assignPlayerToCurriculumTeam(svcPlayers, svcTeams, playerPlayer)
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.findCurriculumSpawnForPlayer(fldBattlefield, playerPlayer)
	local eLogical = CoreEnums.eEngineLogicalType
	if not playerPlayer.Team then return nil end

	return fldBattlefield:FindFirstChild(eLogical.SPAWN_POINT_PREFIX .. playerPlayer.Team.Name)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.applyCurriculumRespawnLocation(fldBattlefield, playerPlayer)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local partSpawn = CurriculumSetup.findCurriculumSpawnForPlayer(fldBattlefield, playerPlayer)
	if partSpawn and partSpawn:IsA(ePhysical.SPAWN_LOCATION) then
		playerPlayer.RespawnLocation = partSpawn
	end

	return partSpawn
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.applyCurriculumPlayerMovement(modelCharacter)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local humPlayer = modelCharacter and modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
	if not humPlayer then return end

	humPlayer.UseJumpPower = true
	humPlayer.JumpPower = DEFAULT_PLAYER_JUMP_POWER
	humPlayer.JumpHeight = DEFAULT_PLAYER_JUMP_HEIGHT
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.movePlayerToCurriculumSpawn(fldBattlefield, playerPlayer, modelCharacter)
	local eLogical = CoreEnums.eEngineLogicalType
	local partSpawn = CurriculumSetup.applyCurriculumRespawnLocation(fldBattlefield, playerPlayer)
	CurriculumSetup.applyCurriculumPlayerMovement(modelCharacter)
	local partHumanoidRoot = modelCharacter and (
		modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		or modelCharacter:WaitForChild(eLogical.RESERVED_HUMANOID_ROOT_PART, 5)
	)
	if partSpawn and partHumanoidRoot then
		partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, tblWorldLayout.NEUTRAL_RESPAWN_HEIGHT, 0))
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.installCurriculumTeamSpawnRouting(svcPlayers, svcTeams, fldBattlefield)
	local function install_player_spawn_routing(playerPlayer)
		CurriculumSetup.assignPlayerToCurriculumTeam(svcPlayers, svcTeams, playerPlayer)
		CurriculumSetup.applyCurriculumRespawnLocation(fldBattlefield, playerPlayer)

		local function on_character_added(modelCharacter)
			local humanoid = modelCharacter:WaitForChild("Humanoid", 10)
			if humanoid and humanoid:IsA("Humanoid") then
				local strSpec = playerPlayer:GetAttribute("Specialization")
				if strSpec == "Constitution" then
					humanoid.MaxHealth = 60
					humanoid.Health = 60
				elseif strSpec == "Agility" then
					humanoid.MaxHealth = 50
					humanoid.Health = 50
					humanoid.WalkSpeed = 19.2 -- 16 * 1.2
				else
					humanoid.MaxHealth = 50
					humanoid.Health = 50
					humanoid.WalkSpeed = 16
				end
			end
			task.defer(CurriculumSetup.movePlayerToCurriculumSpawn, fldBattlefield, playerPlayer, modelCharacter)
		end

		if not playerPlayer:GetAttribute("RuntimeInstalled_CurriculumSpawnRouting") then
			playerPlayer:SetAttribute("RuntimeInstalled_CurriculumSpawnRouting", true)
			playerPlayer.CharacterAdded:Connect(on_character_added)
		end

		if playerPlayer.Character then
			on_character_added(playerPlayer.Character)
		end
	end

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		install_player_spawn_routing(playerPlayer)
	end

	if EngineEnsure.markRuntimeInstalled(svcPlayers, "RuntimeInstalled_CurriculumTeamSpawnRouting") then
		svcPlayers.PlayerAdded:Connect(install_player_spawn_routing)

		local svcReplicatedStorage = game:GetService("ReplicatedStorage")
		local eLogical = CoreEnums.eEngineLogicalType
		local eventSpecializationSelect = svcReplicatedStorage:WaitForChild(eLogical.SPECIALIZATION_SELECT, 5)
		if eventSpecializationSelect then
			eventSpecializationSelect.OnServerEvent:Connect(function(playerPlayer, strSpec)
				if type(strSpec) ~= "string" then return end
				if strSpec ~= "Strength" and strSpec ~= "Agility" and strSpec ~= "Constitution" then return end

				playerPlayer:SetAttribute("Specialization", strSpec)

				local modelCharacter = playerPlayer.Character
				if modelCharacter then
					local humanoid = modelCharacter:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.MaxHealth = 50
						humanoid.Health = math.clamp(humanoid.Health, 0, 50)
						humanoid.WalkSpeed = 16

						if strSpec == "Constitution" then
							humanoid.MaxHealth = 60
							humanoid.Health = 60
						elseif strSpec == "Agility" then
							humanoid.WalkSpeed = 19.2
						end
					end
				end
			end)
		end
	end
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.setupCurriculumWorld(gameRoot, valueConfig)
	local eService = CoreEnums.eEngineServiceSingleton
	local dataModel = gameRoot or game
	local tblSetupConfig = type(valueConfig) == "table" and valueConfig or nil
	local intActiveLessonDay = CurriculumSetup.readCurriculumActiveLessonDay(valueConfig)
	local strActiveClass = CurriculumSetup.readCurriculumActiveClass(valueConfig)
	local svcWorkspace = dataModel:GetService(eService.WORKSPACE)
	local svcPlayers = dataModel:GetService(eService.PLAYERS)
	local svcReplicatedStorage = dataModel:GetService(eService.REPLICATED_STORAGE)
	local svcServerScriptService = dataModel:GetService(eService.SERVER_SCRIPT_SERVICE)
	local svcTeams = dataModel:GetService(eService.TEAMS)
	CurriculumSetup.resetCurriculumWorld(svcWorkspace)
	local tblOutpostWorld = EngineEnsure.ensureOutpostBattleWorld(svcWorkspace)
	local tblSharedAssets = CurriculumSetup.ensureCurriculumSharedAssets(svcReplicatedStorage, svcServerScriptService, strActiveClass)
	local boolInstallStudentThrowingStones = tblSetupConfig == nil or tblSetupConfig.InstallStudentThrowingStones ~= false
	local boolInstallStudentLessonConfigs = tblSetupConfig == nil or tblSetupConfig.InstallStudentLessonConfigs ~= false

	svcWorkspace.Gravity = DEFAULT_WORKSPACE_GRAVITY
	svcPlayers.RespawnTime = DEFAULT_PLAYER_RESPAWN_SECONDS
	EngineEnsure.disableDefaultWorkspaceSpawnLocation(svcWorkspace)
	EngineEnsure.removeDefaultWorkspaceBaseplate(svcWorkspace)
	CurriculumSetup.ensureCurriculumRemoteEvents(svcReplicatedStorage, intActiveLessonDay)
	CurriculumSetup.ensureCurriculumTeams(svcTeams)
	CurriculumSetup.ensureCurriculumCoreTargets(tblOutpostWorld.fldObjectiveArea)
	CurriculumSetup.ensureCurriculumPracticeTargets(tblOutpostWorld.fldObjectiveArea, intActiveLessonDay)
	CurriculumSetup.ensureCurriculumBattlefieldMarkers(tblOutpostWorld.fldBattlefield, intActiveLessonDay)
	CurriculumSetup.assignCurriculumTeams(svcPlayers, svcTeams)
	CurriculumSetup.installCurriculumTeamSpawnRouting(svcPlayers, svcTeams, tblOutpostWorld.fldBattlefield)
	WeaponSystems.installFistAttackServerSystem(svcReplicatedStorage, svcPlayers)
	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 3) then
		CurriculumSetup.ensureCurriculumBuildArea(tblOutpostWorld.fldBuildArea)
	end
	CurriculumSetup.ensureCurriculumItemSpawnMarkers(tblOutpostWorld.fldItemSpawnArea, intActiveLessonDay)
	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 8) then
		CurriculumSetup.ensureCurriculumFortification(tblOutpostWorld.fldFortification, intActiveLessonDay)
	end
	if CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, 10) then
		CurriculumSetup.ensureCurriculumSiegeEngine(tblOutpostWorld.fldSiegeEngine)
	end

	if boolInstallStudentThrowingStones then
		ThrowingStone.installStudentThrowingStoneDesigns(svcWorkspace, tblSharedAssets.fldStudentRockDesigns)
	end

	if boolInstallStudentLessonConfigs then
		CurriculumSetup.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, tblSharedAssets.fldStudentLessonConfigs, intActiveLessonDay)
	end

	CurriculumSetup.cleanupCurriculumArtifactsAfterActiveLessonDay(svcWorkspace, svcPlayers, svcReplicatedStorage, tblOutpostWorld, intActiveLessonDay)

	print("수업 월드 준비 완료: " .. tostring(intActiveLessonDay) .. "일차까지 적용")
	return {
		tblOutpostWorld = tblOutpostWorld,
		tblSharedAssets = tblSharedAssets,
		intActiveLessonDay = intActiveLessonDay,
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


function CurriculumSetup.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages, intActiveLessonDay)
	local intDayNumber = CurriculumSetup.readStudentLessonConfigDayNumber(moduleLessonConfig, tblValidationMessages)
	if not intDayNumber then
		return false
	end

	if not CurriculumSetup.isCurriculumLessonDayEnabled(intActiveLessonDay, intDayNumber) then
		return false
	end

	local tblLessonConfig = CurriculumSetup.readStudentLessonConfigModule(moduleLessonConfig, tblValidationMessages)
	if not tblLessonConfig then
		return false
	end

	return CurriculumSetup.installStudentLessonConfigByDayNumber(svcWorkspace, svcPlayers, svcReplicatedStorage, intDayNumber, tblLessonConfig, tblValidationMessages, moduleLessonConfig.Name)
end


-- --------------------------------------------------------------------------------


function CurriculumSetup.installStudentLessonConfigs(svcWorkspace, svcPlayers, svcReplicatedStorage, fldStudentLessonConfigs, intActiveLessonDay)
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
		if CurriculumSetup.installStudentLessonConfig(svcWorkspace, svcPlayers, svcReplicatedStorage, moduleLessonConfig, tblValidationMessages, intActiveLessonDay) then
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
