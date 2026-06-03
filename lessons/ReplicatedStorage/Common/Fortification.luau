-- [Module] Fortification
local Fortification = {}

local CombatRules = require(script.Parent.CombatRules)
local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function Fortification.installGateDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 전초기지 문 피해 서버 시스템 설치 함수 정의 ➔ 문 체력/피격/붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local modelGate = tblOutpostWorld.fldFortification:WaitForChild(eLogical.GATE)
	if not EngineEnsure.markRuntimeInstalled(modelGate, "RuntimeInstalled_GateDamage") then
		return
	end

	local numberHealth = StudentConfig.readConfigNumber(tblConfig, "Health", 120, 30, 300)
	local numberDamagePerHit = StudentConfig.readConfigNumber(tblConfig, "DamagePerHit", 30, 5, 80)
	local numberWarningHealth = StudentConfig.readConfigNumber(tblConfig, "WarningHealth", numberHealth / 2, 0, numberHealth)
	local brickWarningColor = StudentConfig.readConfigBrickColor(tblConfig, "WarningColor", "Bright orange")
	local boolBroken = false

	local function set_gate_color(brickColor)
		for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
			if partGatePlank:IsA(ePhysical.BASE_PART) then
				partGatePlank.BrickColor = brickColor
			end
		end
	end

	local function break_gate()
		boolBroken = true
		for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
			if partGatePlank:IsA(ePhysical.BASE_PART) then
				partGatePlank.Anchored = false
				partGatePlank.AssemblyLinearVelocity = Vector3.new(math.random(-25, 25), 35, math.random(-20, 20))
			end
		end
	end

	local function damage_gate(numberAmount)
		if boolBroken then return end

		numberHealth -= numberAmount
		if numberHealth <= numberWarningHealth then set_gate_color(brickWarningColor) end
		if numberHealth <= 0 then break_gate() end
	end

	for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
		if partGatePlank:IsA(ePhysical.BASE_PART) then
			partGatePlank.Touched:Connect(function(partHit)
				if not CombatRules.isCombatProjectileName(partHit.Name) then return end

				partHit:Destroy()
				damage_gate(numberDamagePerHit)
			end)
		end
	end
end


-- --------------------------------------------------------------------------------


function Fortification.installStoneWallDamageSystem(svcWorkspace, tblConfig) -- [의미/의도] 석조 벽 피해 서버 시스템 설치 함수 정의 ➔ 구역별 체력/부분 붕괴 규칙을 공통 서버 코드가 책임지게 하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local modelStoneWall = tblOutpostWorld.fldFortification:WaitForChild(eLogical.STONE_WALL)
	if not EngineEnsure.markRuntimeInstalled(modelStoneWall, "RuntimeInstalled_StoneWallDamage") then
		return
	end

	local numberSectionHealth = StudentConfig.readConfigNumber(tblConfig, "SectionHealth", 90, 30, 240)
	local numberDamagePerHit = StudentConfig.readConfigNumber(tblConfig, "DamagePerHit", 30, 5, 80)
	local brickDamagedColor = StudentConfig.readConfigBrickColor(tblConfig, "DamagedColor", "Dark stone grey")
	local tableSectionHealth = {}
	local tableCollapsed = {}

	local function collapse_section(modelSection)
		if tableCollapsed[modelSection] then return end

		tableCollapsed[modelSection] = true
		for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do
			if partStoneBlock:IsA(ePhysical.BASE_PART) then
				partStoneBlock.Anchored = false
				partStoneBlock.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-10, 10))
			end
		end
	end

	local function register_section(modelSection)
		tableSectionHealth[modelSection] = numberSectionHealth
		for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do
			if partStoneBlock:IsA(ePhysical.BASE_PART) then
				partStoneBlock.Touched:Connect(function(partHit)
					if not CombatRules.isCombatProjectileName(partHit.Name) then return end

					partHit:Destroy()
					tableSectionHealth[modelSection] -= numberDamagePerHit
					partStoneBlock.BrickColor = brickDamagedColor
					if tableSectionHealth[modelSection] <= 0 then
						collapse_section(modelSection)
					end
				end)
			end
		end
	end

	for _, modelSection in ipairs(modelStoneWall:GetChildren()) do
		if modelSection:IsA(ePhysical.MODEL) then
			register_section(modelSection)
		end
	end
end

-- --------------------------------------------------------------------------------

return Fortification