-- [Module] SiegeEngine
local module = {}

local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))
local StudentConfig = require(script.Parent:WaitForChild("StudentConfig"))

-- --------------------------------------------------------------------------------
function module.installSiegeEngineSystem(svcWorkspace, tblConfig) -- [의미/의도] 중장비 서버 시스템 설치 함수 정의 ➔ 발사 버튼/무거운 탄환/쿨타임 규칙을 공통 서버 코드가 책임지게 하기 위함
	local eService = EngineNames.eEngineServiceSingleton
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	local svcDebris = game:GetService(eService.DEBRIS)
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldSiegeEngine = tblOutpostWorld.fldSiegeEngine
	local partLaunchButton = fldSiegeEngine:WaitForChild(eLogical.LAUNCH_BUTTON)
	local partLaunchPoint = fldSiegeEngine:WaitForChild(eLogical.LAUNCH_POINT)
	local partTargetPoint = fldSiegeEngine:WaitForChild(eLogical.TARGET_POINT)
	if not EngineEnsure.markRuntimeInstalled(partLaunchButton, "RuntimeInstalled_SiegeEngine") then
		return
	end

	local numberCooldown = StudentConfig.readConfigNumber(tblConfig, "Cooldown", 2.5, 0.5, 8)
	local numberForwardSpeed = StudentConfig.readConfigNumber(tblConfig, "ForwardSpeed", 95, 30, 160)
	local numberUpSpeed = StudentConfig.readConfigNumber(tblConfig, "UpSpeed", 45, 0, 100)
	local numberLifetime = StudentConfig.readConfigNumber(tblConfig, "Lifetime", 8, 2, 20)
	local vectorStoneSize = StudentConfig.readConfigVector3(tblConfig, "StoneSize", Vector3.new(3, 3, 3), Vector3.new(1, 1, 1), Vector3.new(6, 6, 6))
	local enumStoneMaterial = StudentConfig.readConfigEnumItem(tblConfig, "StoneMaterial", Enum.Material.Slate)
	local boolReady = true

	local function launch_stone()
		if not boolReady then return end

		local vectorOffset = partTargetPoint.Position - partLaunchPoint.Position
		if vectorOffset.Magnitude <= 0 then return end

		boolReady = false

		local partSiegeStone = Instance.new(ePhysical.PART)
		partSiegeStone.Name = eLogical.SIEGE_STONE
		partSiegeStone.Shape = Enum.PartType.Ball
		partSiegeStone.Size = vectorStoneSize
		partSiegeStone.Material = enumStoneMaterial
		partSiegeStone.Position = partLaunchPoint.Position
		partSiegeStone.Parent = workspace
		partSiegeStone.AssemblyLinearVelocity = vectorOffset.Unit * numberForwardSpeed + Vector3.new(0, numberUpSpeed, 0)
		svcDebris:AddItem(partSiegeStone, numberLifetime)

		task.wait(numberCooldown)
		boolReady = true
	end

	EngineEnsure.ensureClickDetector(partLaunchButton, 24).MouseClick:Connect(launch_stone)
end

-- --------------------------------------------------------------------------------

return module