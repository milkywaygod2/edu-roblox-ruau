-- [Module] FieldItem
local FieldItem = {}

local Appearance = require(script.Parent.Appearance)
local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function FieldItem.hashTextToInteger(strText)
	local intHash = 0
	for index = 1, #strText do
		intHash = (intHash * 31 + string.byte(strText, index)) % 2147483647
	end

	return intHash
end


-- --------------------------------------------------------------------------------


function FieldItem.createFlatSpawnJitter(strSeedText, intIndex, numberRadius)
	if numberRadius <= 0 then
		return Vector3.new(0, 0, 0)
	end

	local randomJitter = Random.new(FieldItem.hashTextToInteger(strSeedText .. "_" .. intIndex))
	local numberDistance = math.sqrt(randomJitter:NextNumber()) * numberRadius
	local numberAngle = randomJitter:NextNumber() * math.pi * 2
	return Vector3.new(math.cos(numberAngle) * numberDistance, 0, math.sin(numberAngle) * numberDistance)
end


-- --------------------------------------------------------------------------------


function FieldItem.ensureFieldItemSpawnMarkers(fldItemSpawnArea, strToolName, tblSpawnPositions, strColorName) -- [의미/의도] 전장 아이템 스폰 마커 보장 함수 정의 ➔ 학생 튜닝 장비가 어디에 나타날지 선생 코드에서 지도처럼 배치하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	local brickColor = BrickColor.new(strColorName or "Bright yellow")

	for index, vectorPosition in ipairs(tblSpawnPositions) do
		EngineEnsure.ensureStaticPart(eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_" .. index, fldItemSpawnArea, {
			Size = Vector3.new(2, 0.2, 2),
			Position = vectorPosition,
			Transparency = 0.35,
			BrickColor = brickColor,
		})
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.getFieldItemSpawnPositions(fldItemSpawnArea, strToolName, tblDefaultSpawnPositions) -- [의미/의도] 전장 아이템 스폰 위치 조회 함수 정의 ➔ 선생 setup 마커가 있으면 그 위치를 쓰고 없으면 기본 위치를 사용하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	local tblSpawnPositions = {}

	for index, vectorDefaultPosition in ipairs(tblDefaultSpawnPositions) do
		local partSpawnMarker = fldItemSpawnArea:FindFirstChild(eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_" .. index)
		table.insert(tblSpawnPositions, partSpawnMarker and partSpawnMarker.Position or vectorDefaultPosition)
	end

	return tblSpawnPositions
end


-- --------------------------------------------------------------------------------


function FieldItem.installFieldToolPickups(svcWorkspace, strToolName, strToolTip, tblConfig, tblDefaultSpawnPositions, tblDefaultHandleProperties, fnInstallToolSystem) -- [의미/의도] 파밍 Tool 묶음 설치 함수 정의 ➔ 직접 지급하지 않고 맵에 놓인 장비를 플레이어가 찾아서 줍게 하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local tblSpawnPositions = FieldItem.getFieldItemSpawnPositions(fldItemSpawnArea, strToolName, tblDefaultSpawnPositions)
	local intSpawnCount = StudentConfig.readConfigInteger(tblConfig, "SpawnCount", #tblSpawnPositions, 1, 12)
	local strDisplayName = StudentConfig.readConfigString(tblConfig, "DisplayName", strToolName)
	local strVariantId = StudentConfig.readConfigString(tblConfig, "VariantId", strToolName)
	local vectorSpawnOffset = StudentConfig.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8))
	local numberSpawnRadius = StudentConfig.readConfigNumber(tblConfig, "SpawnRadius", 0, 0, 12)

	for index = 1, intSpawnCount do
		local vectorSpawnJitter = FieldItem.createFlatSpawnJitter(strVariantId, index, numberSpawnRadius)
		local vectorSpawnPosition = tblSpawnPositions[((index - 1) % #tblSpawnPositions) + 1] + vectorSpawnOffset + vectorSpawnJitter
		local toolPickup = EngineEnsure.ensureToolWithHandle(eLogical.FIELD_ITEM_PREFIX .. strToolName .. "_" .. strVariantId .. "_" .. index, strToolTip, fldItemSpawnArea, tblDefaultHandleProperties)
		toolPickup.ToolTip = strDisplayName .. " - 클릭해서 줍기"
		toolPickup.CanBeDropped = true
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_TYPE, strToolName)
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_DISPLAY_NAME, strDisplayName)
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME, toolPickup.Name)

		local partHandle = Appearance.applyToolHandleStudentStyle(toolPickup, tblConfig)
		partHandle.Position = vectorSpawnPosition + Vector3.new(0, math.max(1.5, partHandle.Size.Y / 2 + 0.5), 0)
		partHandle.Anchored = true
		partHandle.CanCollide = false
		toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, partHandle.Position)

		if fnInstallToolSystem then
			fnInstallToolSystem(toolPickup, tblConfig)
		end

		local clickPickup = EngineEnsure.ensureClickDetector(partHandle, 18)
		if EngineEnsure.markRuntimeInstalled(toolPickup, "RuntimeInstalled_FieldPickup") then
			clickPickup.MouseClick:Connect(function(player)
				local backpackPlayer = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
				if not backpackPlayer or toolPickup.Parent ~= fldItemSpawnArea then return end

				partHandle.Anchored = false
				partHandle.CanCollide = false
				toolPickup.Name = strDisplayName
				toolPickup.Parent = backpackPlayer
			end)
		end
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.resetFieldToolPickupsToWorld(svcPlayers, fldItemSpawnArea) -- [의미/의도] 플레이어가 들고 있는 파밍 Tool을 전장 스폰 위치로 되돌리는 함수 정의 ➔ 새 라운드가 시작될 때 다시 찾아 줍는 흐름을 유지하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey

	local function reset_tool(toolPickup)
		if not toolPickup:IsA(ePhysical.TOOL) or not toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) then return end

		local strHomeName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME)
		local vectorHomePosition = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION)
		if typeof(strHomeName) ~= "string" or typeof(vectorHomePosition) ~= "Vector3" then return end

		toolPickup.Name = strHomeName
		toolPickup.Parent = fldItemSpawnArea

		local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
		if partHandle and partHandle:IsA(ePhysical.BASE_PART) then
			partHandle.Position = vectorHomePosition
			partHandle.Anchored = true
			partHandle.CanCollide = false
			EngineEnsure.ensureClickDetector(partHandle, 18)
		end
	end

	local function scan_container(instanceContainer)
		if not instanceContainer then return end

		for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
			reset_tool(instanceChild)
		end
	end

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		scan_container(playerPlayer:FindFirstChild("Backpack"))
		scan_container(playerPlayer.Character)
	end
end


-- --------------------------------------------------------------------------------


return FieldItem
