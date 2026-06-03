--[[
   Roblox Studio 수업 공통 모듈 (Facade)
   역할: 하위 15개 모듈을 하나로 병합하여 레거시 호출 규격을 완벽히 유지하는 엔트리 포인트입니다.
   LSP 자동완성(녹색 힌트) 지원을 위해 모든 멤버를 정적(Static)으로 명시하여 내보냅니다.
]]
local Common = {}

local Appearance = require(script:WaitForChild("Appearance"))
local BuildSystems = require(script:WaitForChild("BuildSystems"))
local CombatRules = require(script:WaitForChild("CombatRules"))
local CurriculumSetup = require(script:WaitForChild("CurriculumSetup"))
local Effect = require(script:WaitForChild("Effect"))
local EngineEnsure = require(script:WaitForChild("EngineEnsure"))
local EngineNames = require(script:WaitForChild("EngineNames"))
local FieldItem = require(script:WaitForChild("FieldItem"))
local FinalBattle = require(script:WaitForChild("FinalBattle"))
local Fortification = require(script:WaitForChild("Fortification"))
local MagicSystem = require(script:WaitForChild("MagicSystem"))
local SiegeEngine = require(script:WaitForChild("SiegeEngine"))
local StudentConfig = require(script:WaitForChild("StudentConfig"))
local ThrowingStone = require(script:WaitForChild("ThrowingStone"))
local WeaponSystems = require(script:WaitForChild("WeaponSystems"))

-- ================================================================================
-- [Module] Appearance
-- ================================================================================
Common.applyRockLook = Appearance.applyRockLook
Common.applyToolHandleStudentStyle = Appearance.applyToolHandleStudentStyle
Common.calculateFitScaleWithinBounds = Appearance.calculateFitScaleWithinBounds
Common.clearRockLook = Appearance.clearRockLook
Common.findRockLookTemplate = Appearance.findRockLookTemplate
Common.fitBasePartWithinBounds = Appearance.fitBasePartWithinBounds
Common.fitModelWithinBounds = Appearance.fitModelWithinBounds
Common.pivotModelBoundsToTarget = Appearance.pivotModelBoundsToTarget
Common.prepareRockLookPart = Appearance.prepareRockLookPart

-- ================================================================================
-- [Module] BuildSystems
-- ================================================================================
Common.installResourceWallSystem = BuildSystems.installResourceWallSystem
Common.installStudentCoverDesign = BuildSystems.installStudentCoverDesign

-- ================================================================================
-- [Module] CombatRules
-- ================================================================================
Common.canPlayerDamageModel = CombatRules.canPlayerDamageModel
Common.getOutpostObjectiveTeamName = CombatRules.getOutpostObjectiveTeamName
Common.isCombatProjectileName = CombatRules.isCombatProjectileName

-- ================================================================================
-- [Module] CurriculumSetup
-- ================================================================================
Common.ensureCurriculumBattlefieldMarkers = CurriculumSetup.ensureCurriculumBattlefieldMarkers
Common.ensureCurriculumBuildArea = CurriculumSetup.ensureCurriculumBuildArea
Common.ensureCurriculumCoreTargets = CurriculumSetup.ensureCurriculumCoreTargets
Common.ensureCurriculumFortification = CurriculumSetup.ensureCurriculumFortification
Common.ensureCurriculumItemSpawnMarkers = CurriculumSetup.ensureCurriculumItemSpawnMarkers
Common.ensureCurriculumPracticeTargets = CurriculumSetup.ensureCurriculumPracticeTargets
Common.ensureCurriculumRemoteEvents = CurriculumSetup.ensureCurriculumRemoteEvents
Common.ensureCurriculumSharedAssets = CurriculumSetup.ensureCurriculumSharedAssets
Common.ensureCurriculumSiegeEngine = CurriculumSetup.ensureCurriculumSiegeEngine
Common.ensureCurriculumTeams = CurriculumSetup.ensureCurriculumTeams
Common.installStudentLessonConfig = CurriculumSetup.installStudentLessonConfig
Common.installStudentLessonConfigByDayNumber = CurriculumSetup.installStudentLessonConfigByDayNumber
Common.installStudentLessonConfigs = CurriculumSetup.installStudentLessonConfigs
Common.readStudentLessonConceptConfig = CurriculumSetup.readStudentLessonConceptConfig
Common.readStudentLessonConfigDayNumber = CurriculumSetup.readStudentLessonConfigDayNumber
Common.readStudentLessonConfigModule = CurriculumSetup.readStudentLessonConfigModule
Common.setupCurriculumWorld = CurriculumSetup.setupCurriculumWorld

-- ================================================================================
-- [Module] Effect
-- ================================================================================
Common.applyParticleEffect = Effect.applyParticleEffect
Common.createOrderedNumberRange = Effect.createOrderedNumberRange
Common.eParticleTexture = Effect.eParticleTexture
Common.isAllowedParticleTexture = Effect.isAllowedParticleTexture
Common.readEffectBoolean = Effect.readEffectBoolean
Common.readEffectColor = Effect.readEffectColor
Common.readEffectEnumItem = Effect.readEffectEnumItem
Common.readEffectNumber = Effect.readEffectNumber
Common.readEffectNumberRange = Effect.readEffectNumberRange
Common.readEffectNumberSequence = Effect.readEffectNumberSequence
Common.readEffectTexture = Effect.readEffectTexture
Common.readEffectVector2 = Effect.readEffectVector2
Common.readEffectVector3 = Effect.readEffectVector3
Common.readParticleEffectConfig = Effect.readParticleEffectConfig

-- ================================================================================
-- [Module] EngineEnsure
-- ================================================================================
Common.applyInstanceProperties = EngineEnsure.applyInstanceProperties
Common.ensureClickDetector = EngineEnsure.ensureClickDetector
Common.ensureHumanoidTarget = EngineEnsure.ensureHumanoidTarget
Common.ensureNamedInstance = EngineEnsure.ensureNamedInstance
Common.ensureOutpostBattleWorld = EngineEnsure.ensureOutpostBattleWorld
Common.ensureStaticPart = EngineEnsure.ensureStaticPart
Common.ensureToolWithHandle = EngineEnsure.ensureToolWithHandle
Common.markRuntimeInstalled = EngineEnsure.markRuntimeInstalled
Common.removeLuaSourceDescendants = EngineEnsure.removeLuaSourceDescendants
Common.resetNamedInstance = EngineEnsure.resetNamedInstance
Common.waitForOutpostBattleWorld = EngineEnsure.waitForOutpostBattleWorld

-- ================================================================================
-- [Module] EngineNames
-- ================================================================================
Common.eEngineAttributeKey = EngineNames.eEngineAttributeKey
Common.eEngineLogicalType = EngineNames.eEngineLogicalType
Common.eEnginePhysicalType = EngineNames.eEnginePhysicalType
Common.eEngineServiceSingleton = EngineNames.eEngineServiceSingleton
Common.eRoundStateValue = EngineNames.eRoundStateValue
Common.eStudentLessonConfigKey = EngineNames.eStudentLessonConfigKey
Common.hasEngineLogicalNamePrefix = EngineNames.hasEngineLogicalNamePrefix

-- ================================================================================
-- [Module] FieldItem
-- ================================================================================
Common.ensureFieldItemSpawnMarkers = FieldItem.ensureFieldItemSpawnMarkers
Common.getFieldItemSpawnPositions = FieldItem.getFieldItemSpawnPositions
Common.installFieldArmorPickups = FieldItem.installFieldArmorPickups
Common.installFieldBowPickups = FieldItem.installFieldBowPickups
Common.installFieldShieldPickups = FieldItem.installFieldShieldPickups
Common.installFieldSwordPickups = FieldItem.installFieldSwordPickups
Common.installFieldToolPickups = FieldItem.installFieldToolPickups
Common.installMagicStaffPickups = FieldItem.installMagicStaffPickups
Common.resetFieldToolPickupsToWorld = FieldItem.resetFieldToolPickupsToWorld

-- ================================================================================
-- [Module] FinalBattle
-- ================================================================================
Common.installFinalBattleSystem = FinalBattle.installFinalBattleSystem

-- ================================================================================
-- [Module] Fortification
-- ================================================================================
Common.installGateDamageSystem = Fortification.installGateDamageSystem
Common.installStoneWallDamageSystem = Fortification.installStoneWallDamageSystem

-- ================================================================================
-- [Module] MagicSystem
-- ================================================================================
Common.installMagicServerSystem = MagicSystem.installMagicServerSystem
Common.installMagicStaffTool = MagicSystem.installMagicStaffTool

-- ================================================================================
-- [Module] SiegeEngine
-- ================================================================================
Common.installSiegeEngineSystem = SiegeEngine.installSiegeEngineSystem

-- ================================================================================
-- [Module] StudentConfig
-- ================================================================================
Common.addValidationMessage = StudentConfig.addValidationMessage
Common.clampNumber = StudentConfig.clampNumber
Common.createBrickColorFromColor3 = StudentConfig.createBrickColorFromColor3
Common.formatStudentRockValidationText = StudentConfig.formatStudentRockValidationText
Common.isVector3OutsideRange = StudentConfig.isVector3OutsideRange
Common.mergeConfigTables = StudentConfig.mergeConfigTables
Common.readConfigBrickColor = StudentConfig.readConfigBrickColor
Common.readConfigColor3 = StudentConfig.readConfigColor3
Common.readConfigEnumItem = StudentConfig.readConfigEnumItem
Common.readConfigInteger = StudentConfig.readConfigInteger
Common.readConfigNumber = StudentConfig.readConfigNumber
Common.readConfigString = StudentConfig.readConfigString
Common.readConfigTable = StudentConfig.readConfigTable
Common.readConfigVector3 = StudentConfig.readConfigVector3
Common.readEquipmentSize = StudentConfig.readEquipmentSize
Common.showStudentRockValidationBoard = StudentConfig.showStudentRockValidationBoard
Common.tblEquipmentSizeRule = StudentConfig.tblEquipmentSizeRule
Common.tblThrowingStoneMaterialBlockList = StudentConfig.tblThrowingStoneMaterialBlockList

-- ================================================================================
-- [Module] ThrowingStone
-- ================================================================================
Common.calculateThrowingStoneStats = ThrowingStone.calculateThrowingStoneStats
Common.createAutoRockVariantId = ThrowingStone.createAutoRockVariantId
Common.createFallbackRockDesign = ThrowingStone.createFallbackRockDesign
Common.createFlatSpawnJitter = ThrowingStone.createFlatSpawnJitter
Common.createRockDesign = ThrowingStone.createRockDesign
Common.getThrowingStoneMaterialProfile = ThrowingStone.getThrowingStoneMaterialProfile
Common.getThrowingStoneTraitProfile = ThrowingStone.getThrowingStoneTraitProfile
Common.hashTextToInteger = ThrowingStone.hashTextToInteger
Common.installStudentThrowingStoneDesigns = ThrowingStone.installStudentThrowingStoneDesigns
Common.installThrowingStonePickups = ThrowingStone.installThrowingStonePickups
Common.installThrowingStoneTool = ThrowingStone.installThrowingStoneTool
Common.isThrowingStoneMaterialBlocked = ThrowingStone.isThrowingStoneMaterialBlocked
Common.readStudentRockDesignModule = ThrowingStone.readStudentRockDesignModule
Common.resolveThrowingStoneDesign = ThrowingStone.resolveThrowingStoneDesign

-- ================================================================================
-- [Module] WeaponSystems
-- ================================================================================
Common.installFieldArmorTool = WeaponSystems.installFieldArmorTool
Common.installFieldBowTool = WeaponSystems.installFieldBowTool
Common.installFieldShieldTool = WeaponSystems.installFieldShieldTool
Common.installFieldSwordTool = WeaponSystems.installFieldSwordTool

return Common