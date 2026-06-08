-- [Module] FieldItem
local FieldItem = {}

local Appearance = require(script.Parent.Appearance)
local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local FieldPlacementRules = require(script.Parent.FieldPlacementRules)
local StudentConfig = require(script.Parent.StudentConfig)

local FIELD_ITEM_OUTSIDE_CHECK_SECONDS = 0.25
local FIELD_ITEM_REST_SURFACE_PADDING = 0.05
local FIELD_ITEM_SPAWN_RADIUS_MAX = 24
local FIELD_ITEM_PICKUP_PROMPT_BASE_DISTANCE = 10
local FIELD_ITEM_PICKUP_CLICK_BASE_DISTANCE = 18
local FIELD_ITEM_PICKUP_INTERACTION_DISTANCE_MAX = 80
local FIELD_ITEM_PICKUP_STANDARD_MASS_LIMIT_KG = 50
local FIELD_ITEM_PICKUP_STRENGTH_MASS_LIMIT_KG = 70
local FIELD_ITEM_PICKUP_ABSOLUTE_MASS_LIMIT_KG = 70
local FIELD_ITEM_PLACE_MAX_DISTANCE = 45
local FIELD_ITEM_PLACE_SURFACE_CLEARANCE = 0.04
local FIELD_ITEM_PLACE_SUPPORT_RAY_HEIGHT = 12
local FIELD_ITEM_PLACE_SUPPORT_RAY_DISTANCE = 80
local FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y = 0.35
local FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ = 0.92
local FIELD_ITEM_PLACE_OVERLAP_SCALE_Y = 0.88
local FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE = 0.1
local randomFieldItemRespawn = Random.new()

-- --------------------------------------------------------------------------------
function FieldItem.applyFieldToolBasePartState(partTarget, boolAnchored, boolCanTouch, boolCanQuery, boolCanCollide, boolMassless)
	partTarget.Anchored = boolAnchored
	partTarget.CanCollide = boolCanCollide == true
	partTarget.CanTouch = boolCanTouch == true
	partTarget.CanQuery = boolCanQuery == true
	partTarget.Massless = boolMassless ~= false
end


-- --------------------------------------------------------------------------------


function FieldItem.calculateFieldToolPickupDistance(partHandle, numberBaseDistance)
	local numberDistance = numberBaseDistance
	if partHandle and typeof(partHandle.Size) == "Vector3" then
		numberDistance += partHandle.Size.Magnitude / 2
	end

	return math.min(numberDistance, FIELD_ITEM_PICKUP_INTERACTION_DISTANCE_MAX)
end


-- --------------------------------------------------------------------------------


function FieldItem.setFieldToolClickDistance(partHandle, intMaxActivationDistance)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local clickPickup = partHandle:FindFirstChildOfClass(ePhysical.CLICK_DETECTOR)
	if clickPickup then
		clickPickup.MaxActivationDistance = intMaxActivationDistance
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.refreshFieldToolPickupInteractionDistance(partHandle)
	if not partHandle then return end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local numberClickDistance = FieldItem.calculateFieldToolPickupDistance(partHandle, FIELD_ITEM_PICKUP_CLICK_BASE_DISTANCE)
	EngineEnsure.ensureClickDetector(partHandle, numberClickDistance)
	FieldItem.setFieldToolClickDistance(partHandle, numberClickDistance)

	local promptPickup = partHandle:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if promptPickup then
		promptPickup.MaxActivationDistance = FieldItem.calculateFieldToolPickupDistance(partHandle, FIELD_ITEM_PICKUP_PROMPT_BASE_DISTANCE)
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.ensureFieldToolPickupPrompt(partHandle, strDisplayName)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local promptPickup = partHandle:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if not promptPickup then
		promptPickup = Instance.new(ePhysical.PROXIMITY_PROMPT)
		promptPickup.Parent = partHandle
	end

	promptPickup.ObjectText = strDisplayName or "전장 아이템"
	promptPickup.ActionText = "줍기"
	promptPickup.HoldDuration = 0
	promptPickup.MaxActivationDistance = FieldItem.calculateFieldToolPickupDistance(partHandle, FIELD_ITEM_PICKUP_PROMPT_BASE_DISTANCE)
	promptPickup.RequiresLineOfSight = false
	promptPickup.KeyboardKeyCode = Enum.KeyCode.E
	promptPickup.ClickablePrompt = false
	promptPickup.Style = Enum.ProximityPromptStyle.Custom
	promptPickup.Enabled = true
	return promptPickup
end


-- --------------------------------------------------------------------------------


function FieldItem.setFieldToolPromptEnabled(partHandle, boolEnabled)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local promptPickup = partHandle:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if promptPickup then
		promptPickup.Enabled = boolEnabled
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.createFieldToolRestPosition(vectorBasePosition, partHandle)
	return Vector3.new(vectorBasePosition.X, vectorBasePosition.Y + partHandle.Size.Y / 2, vectorBasePosition.Z)
end


-- --------------------------------------------------------------------------------


function FieldItem.createFieldToolBattlefieldRestPosition(fldItemSpawnArea, partHandle, vectorCandidatePosition)
	if typeof(vectorCandidatePosition) ~= "Vector3" then return nil end

	local partBattlefieldBase = FieldItem.findFieldItemBattlefieldBase(fldItemSpawnArea)
	if not partBattlefieldBase then
		return vectorCandidatePosition
	end

	local numberBaseSurfaceY = partBattlefieldBase.Position.Y + partBattlefieldBase.Size.Y / 2
	local vectorGroundPosition = Vector3.new(
		vectorCandidatePosition.X,
		numberBaseSurfaceY + FIELD_ITEM_REST_SURFACE_PADDING,
		vectorCandidatePosition.Z
	)
	return FieldItem.createFieldToolRestPosition(vectorGroundPosition, partHandle)
end


-- --------------------------------------------------------------------------------


function FieldItem.applyFieldToolVisualState(toolPickup, partHandle)
	local ePhysical = CoreEnums.eEnginePhysicalType

	for _, instanceDescendant in ipairs(toolPickup:GetDescendants()) do
		if instanceDescendant:IsA(ePhysical.BASE_PART) and instanceDescendant ~= partHandle then
			FieldItem.applyFieldToolBasePartState(instanceDescendant, false, false, false)
		end
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.applyFieldToolWorldState(toolPickup, partHandle, vectorHomePosition)
	if not partHandle then return end

	local eAttrKey = CoreEnums.eEngineAttributeKey
	local boolWorldAnchored = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_WORLD_ANCHORED) ~= false
	local boolWorldCanCollide = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_WORLD_CAN_COLLIDE) == true
	local boolWorldMassless = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_WORLD_MASSLESS) ~= false
	toolPickup:SetAttribute(eAttrKey.BLOCK_IS_PROJECTILE, false)
	FieldItem.applyFieldToolBasePartState(partHandle, boolWorldAnchored, false, true, boolWorldCanCollide, boolWorldMassless)

	-- [물리 순간이동 강제 보장]
	-- Position 대신 CFrame을 설정하여 물리 고착 관계를 무시하고 스폰 좌표로 확실하게 강제 텔레포트시킵니다.
	partHandle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	partHandle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	partHandle.CFrame = CFrame.new(vectorHomePosition)
	if boolWorldCanCollide and not boolWorldAnchored then
		pcall(function()
			partHandle:SetNetworkOwner(nil)
		end)
	end

	FieldItem.applyFieldToolVisualState(toolPickup, partHandle)
	FieldItem.refreshFieldToolPickupInteractionDistance(partHandle)
	FieldItem.setFieldToolPromptEnabled(partHandle, true)
end


-- --------------------------------------------------------------------------------


local function resolve_field_tool_world_parent()
	local eLogical = CoreEnums.eEngineLogicalType
	local fldOutpostWorld = workspace:FindFirstChild(eLogical.OUTPOST_BATTLE_WORLD)
	local fldItemSpawnArea = fldOutpostWorld and fldOutpostWorld:FindFirstChild(eLogical.ITEM_SPAWN_AREA)
	return fldItemSpawnArea or workspace
end


-- --------------------------------------------------------------------------------


local function create_field_tool_placement_rotation(partHumanoidRoot, vectorRayDirection)
	local vectorForward = partHumanoidRoot.CFrame.LookVector
	if typeof(vectorRayDirection) == "Vector3" and vectorRayDirection.Magnitude > 0.01 then
		vectorForward = vectorRayDirection.Unit
	end

	local vectorFlatForward = Vector3.new(vectorForward.X, 0, vectorForward.Z)
	if vectorFlatForward.Magnitude <= 0.01 then
		vectorFlatForward = Vector3.new(partHumanoidRoot.CFrame.LookVector.X, 0, partHumanoidRoot.CFrame.LookVector.Z)
	end
	if vectorFlatForward.Magnitude <= 0.01 then
		vectorFlatForward = Vector3.new(0, 0, -1)
	end

	return CFrame.lookAt(Vector3.new(0, 0, 0), vectorFlatForward.Unit)
end


-- --------------------------------------------------------------------------------


local function create_field_tool_placement_cframe(vectorPosition, cframeRotation)
	return CFrame.lookAt(vectorPosition, vectorPosition + cframeRotation.LookVector, cframeRotation.UpVector)
end


-- --------------------------------------------------------------------------------


local function create_field_tool_placement_raycast_params(modelCharacter, toolPickup)
	local tblFilterDescendants = {}
	if modelCharacter then
		table.insert(tblFilterDescendants, modelCharacter)
	end
	if toolPickup then
		table.insert(tblFilterDescendants, toolPickup)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = tblFilterDescendants
	raycastParams.IgnoreWater = true
	return raycastParams
end


-- --------------------------------------------------------------------------------


local function create_field_tool_placement_overlap_params(modelCharacter, toolPickup)
	local tblFilterDescendants = {}
	if modelCharacter then
		table.insert(tblFilterDescendants, modelCharacter)
	end
	if toolPickup then
		table.insert(tblFilterDescendants, toolPickup)
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = tblFilterDescendants
	return overlapParams
end


-- --------------------------------------------------------------------------------


local function create_field_tool_placement_overlap_size(vectorPlacementSize)
	return Vector3.new(
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.X * FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ),
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.Y * FIELD_ITEM_PLACE_OVERLAP_SCALE_Y),
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.Z * FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ)
	)
end


-- --------------------------------------------------------------------------------


local function is_field_tool_placement_overlap_part(partCandidate, modelCharacter, toolPickup)
	local ePhysical = CoreEnums.eEnginePhysicalType
	if not partCandidate or not partCandidate:IsA(ePhysical.BASE_PART) then
		return false
	end
	if not partCandidate.CanCollide then
		return false
	end
	if modelCharacter and partCandidate:IsDescendantOf(modelCharacter) then
		return false
	end
	if toolPickup and partCandidate:IsDescendantOf(toolPickup) then
		return false
	end

	return true
end


-- --------------------------------------------------------------------------------


local function is_field_tool_placement_blocked(modelCharacter, toolPickup, cframePlacement, vectorPlacementSize)
	local overlapParams = create_field_tool_placement_overlap_params(modelCharacter, toolPickup)
	local vectorOverlapSize = create_field_tool_placement_overlap_size(vectorPlacementSize)
	local tblOverlapParts = workspace:GetPartBoundsInBox(cframePlacement, vectorOverlapSize, overlapParams)

	for _, partCandidate in ipairs(tblOverlapParts) do
		if is_field_tool_placement_overlap_part(partCandidate, modelCharacter, toolPickup) then
			return true
		end
	end

	return false
end


-- --------------------------------------------------------------------------------


local function raycast_field_tool_placement_surface(modelCharacter, toolPickup, partHumanoidRoot, vectorRayOrigin, vectorRayDirection)
	local vectorOrigin = partHumanoidRoot.Position + Vector3.new(0, 2, 0)
	local vectorDirection = partHumanoidRoot.CFrame.LookVector * FIELD_ITEM_PLACE_MAX_DISTANCE + Vector3.new(0, -8, 0)

	if typeof(vectorRayOrigin) == "Vector3" and typeof(vectorRayDirection) == "Vector3" and vectorRayDirection.Magnitude > 0.01 then
		if (vectorRayOrigin - partHumanoidRoot.Position).Magnitude <= 90 then
			vectorOrigin = vectorRayOrigin
		end
		vectorDirection = vectorRayDirection.Unit * FIELD_ITEM_PLACE_MAX_DISTANCE
	end

	local raycastParams = create_field_tool_placement_raycast_params(modelCharacter, toolPickup)
	local raycastResult = workspace:Raycast(vectorOrigin, vectorDirection, raycastParams)
	if raycastResult then
		return raycastResult
	end

	local vectorFallbackStart = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 5 + Vector3.new(0, 8, 0)
	return workspace:Raycast(vectorFallbackStart, Vector3.new(0, -40, 0), raycastParams)
end


-- --------------------------------------------------------------------------------


local function raycast_field_tool_placement_support(modelCharacter, toolPickup, vectorTargetPosition)
	local raycastParams = create_field_tool_placement_raycast_params(modelCharacter, toolPickup)
	local vectorOrigin = Vector3.new(
		vectorTargetPosition.X,
		vectorTargetPosition.Y + FIELD_ITEM_PLACE_SUPPORT_RAY_HEIGHT,
		vectorTargetPosition.Z
	)

	return workspace:Raycast(
		vectorOrigin,
		Vector3.new(0, -FIELD_ITEM_PLACE_SUPPORT_RAY_DISTANCE, 0),
		raycastParams
	)
end


-- --------------------------------------------------------------------------------


local function resolve_field_tool_placement_support(modelCharacter, toolPickup, raycastResult, vectorFallbackPosition)
	local vectorTargetPosition = raycastResult and raycastResult.Position or vectorFallbackPosition
	if not vectorTargetPosition then
		return nil
	end

	if raycastResult and raycastResult.Normal.Y >= FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y then
		return raycastResult, vectorTargetPosition
	end

	local raycastSupport = raycast_field_tool_placement_support(modelCharacter, toolPickup, vectorTargetPosition)
	if raycastSupport and raycastSupport.Normal.Y >= FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y then
		return raycastSupport, vectorTargetPosition
	end

	return nil, vectorTargetPosition
end


-- --------------------------------------------------------------------------------


local function calculate_field_tool_placement_cframe(modelCharacter, toolPickup, partHumanoidRoot, partHandle, vectorRayOrigin, vectorRayDirection)
	local cframeRotation = create_field_tool_placement_rotation(partHumanoidRoot, vectorRayDirection)
	local raycastResult = raycast_field_tool_placement_surface(modelCharacter, toolPickup, partHumanoidRoot, vectorRayOrigin, vectorRayDirection)
	local vectorFallbackPosition = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 5
	local raycastSupport, vectorTargetPosition = resolve_field_tool_placement_support(modelCharacter, toolPickup, raycastResult, vectorFallbackPosition)

	if raycastSupport then
		local vectorPosition = Vector3.new(
			vectorTargetPosition.X,
			raycastSupport.Position.Y + partHandle.Size.Y * 0.5 + FIELD_ITEM_PLACE_SURFACE_CLEARANCE,
			vectorTargetPosition.Z
		)
		return create_field_tool_placement_cframe(vectorPosition, cframeRotation)
	end

	vectorFallbackPosition = Vector3.new(vectorFallbackPosition.X, partHumanoidRoot.Position.Y - 2 + partHandle.Size.Y * 0.5, vectorFallbackPosition.Z)
	return create_field_tool_placement_cframe(vectorFallbackPosition, cframeRotation)
end


-- --------------------------------------------------------------------------------


function FieldItem.isBuildPlaceableFieldTool(toolPickup)
	if not toolPickup or not toolPickup:IsA(CoreEnums.eEnginePhysicalType.TOOL) then
		return false
	end

	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local strFieldItemType = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_TYPE)
	return strFieldItemType == eLogical.THROWING_STONE
		or strFieldItemType == eLogical.STACK_BRICK
end


-- --------------------------------------------------------------------------------


function FieldItem.placeEquippedBuildTool(playerPlayer, vectorRayOrigin, vectorRayDirection, intRotationQuarterTurns, boolEndpointSnap)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local modelCharacter = playerPlayer and playerPlayer.Character
	if not modelCharacter then return nil end

	local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
	if not partHumanoidRoot then return nil end

	local toolPickup = nil
	for _, instanceChild in ipairs(modelCharacter:GetChildren()) do
		if instanceChild:IsA(ePhysical.TOOL) and FieldItem.isBuildPlaceableFieldTool(instanceChild) then
			toolPickup = instanceChild
			break
		end
	end
	if not toolPickup then return nil end

	local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
	if not partHandle or not partHandle:IsA(ePhysical.BASE_PART) then return nil end

	local cframePlacement = FieldPlacementRules.calculatePlacementCFrame(
		modelCharacter,
		toolPickup,
		partHumanoidRoot,
		partHandle,
		vectorRayOrigin,
		vectorRayDirection,
		{
			RotationQuarterTurns = intRotationQuarterTurns,
			EndpointSnap = boolEndpointSnap,
		}
	)
	if FieldPlacementRules.isPlacementBlocked(modelCharacter, toolPickup, cframePlacement, partHandle.Size) then
		return nil
	end

	local humanoidPlayer = modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
	if humanoidPlayer then
		humanoidPlayer:UnequipTools()
	end

	local fldItemSpawnArea = resolve_field_tool_world_parent()
	local strHomeName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME)
	if type(strHomeName) == "string" then
		toolPickup.Name = strHomeName
	end

	toolPickup.Parent = fldItemSpawnArea
	toolPickup:SetAttribute(eAttrKey.BLOCK_IS_PROJECTILE, false)
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, cframePlacement.Position)
	FieldItem.applyFieldToolBasePartState(partHandle, false, false, true, true, false)
	FieldItem.applyFieldToolVisualState(toolPickup, partHandle)
	partHandle.CFrame = cframePlacement
	partHandle.AssemblyLinearVelocity = Vector3.new(0, -2, 0)
	partHandle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	pcall(function()
		partHandle:SetNetworkOwner(nil)
	end)
	FieldItem.refreshFieldToolPickupInteractionDistance(partHandle)
	FieldItem.setFieldToolPromptEnabled(partHandle, true)
	return toolPickup
end


-- --------------------------------------------------------------------------------


function FieldItem.applyFieldToolCarriedState(toolPickup, partHandle)
	if not partHandle then return end

	local eAttrKey = CoreEnums.eEngineAttributeKey
	toolPickup:SetAttribute(eAttrKey.BLOCK_IS_PROJECTILE, false)
	FieldItem.applyFieldToolBasePartState(partHandle, false, true, false)
	FieldItem.applyFieldToolVisualState(toolPickup, partHandle)
	FieldItem.setFieldToolClickDistance(partHandle, 0)
	FieldItem.setFieldToolPromptEnabled(partHandle, false)
end


-- --------------------------------------------------------------------------------


function FieldItem.applyFieldToolThrownState(toolPickup, partHandle)
	if not partHandle then return end

	local eAttrKey = CoreEnums.eEngineAttributeKey
	toolPickup:SetAttribute(eAttrKey.BLOCK_IS_PROJECTILE, true)
	FieldItem.applyFieldToolBasePartState(partHandle, false, true, false, true, false)
	FieldItem.applyFieldToolVisualState(toolPickup, partHandle)
	FieldItem.setFieldToolClickDistance(partHandle, 0)
	FieldItem.setFieldToolPromptEnabled(partHandle, false)
end


-- --------------------------------------------------------------------------------


function FieldItem.findFieldItemBattlefieldBase(fldItemSpawnArea)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local fldOutpostBattleWorld = fldItemSpawnArea and fldItemSpawnArea.Parent
	local fldBattlefield = fldOutpostBattleWorld and fldOutpostBattleWorld:FindFirstChild(eLogical.BATTLEFIELD)
	local partBattlefieldBase = fldBattlefield and fldBattlefield:FindFirstChild(eLogical.BATTLEFIELD_BASE)
	if partBattlefieldBase and partBattlefieldBase:IsA(ePhysical.BASE_PART) then
		return partBattlefieldBase
	end

	return nil
end


-- --------------------------------------------------------------------------------


function FieldItem.isFieldToolWorldPositionSafe(fldItemSpawnArea, vectorPosition)
	if typeof(vectorPosition) ~= "Vector3" then return false end

	local partBattlefieldBase = FieldItem.findFieldItemBattlefieldBase(fldItemSpawnArea)
	if not partBattlefieldBase then return true end

	local vectorLocalPosition = partBattlefieldBase.CFrame:PointToObjectSpace(vectorPosition)
	return math.abs(vectorLocalPosition.X) <= partBattlefieldBase.Size.X / 2
		and math.abs(vectorLocalPosition.Z) <= partBattlefieldBase.Size.Z / 2
end


-- --------------------------------------------------------------------------------


function FieldItem.getFieldToolSpawnMarkerPositions(fldItemSpawnArea, strToolName)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local tblMarkerPositions = {}
	local strMarkerPrefix = eLogical.ITEM_SPAWN_PREFIX .. strToolName .. "_"

	for _, instanceChild in ipairs(fldItemSpawnArea:GetChildren()) do
		if instanceChild:IsA(ePhysical.BASE_PART)
			and instanceChild.Name:sub(1, #strMarkerPrefix) == strMarkerPrefix then
			table.insert(tblMarkerPositions, instanceChild.Position)
		end
	end

	return tblMarkerPositions
end


-- --------------------------------------------------------------------------------


function FieldItem.pickFieldToolRespawnPosition(toolPickup, fldItemSpawnArea, partHandle)
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local strToolName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_TYPE)
	local tblMarkerPositions = type(strToolName) == "string"
		and FieldItem.getFieldToolSpawnMarkerPositions(fldItemSpawnArea, strToolName)
		or {}

	if #tblMarkerPositions > 0 then
		local vectorSpawnPosition = tblMarkerPositions[randomFieldItemRespawn:NextInteger(1, #tblMarkerPositions)]
		return FieldItem.createFieldToolRestPosition(vectorSpawnPosition, partHandle)
	end

	local vectorHomePosition = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION)
	if FieldItem.isFieldToolWorldPositionSafe(fldItemSpawnArea, vectorHomePosition) then
		return vectorHomePosition
	end

	return FieldItem.createFieldToolRestPosition(Vector3.new(0, 0.1, 0), partHandle)
end


-- --------------------------------------------------------------------------------


function FieldItem.resolveFieldToolSafeRestPosition(toolPickup, fldItemSpawnArea, partHandle, vectorCandidatePosition)
	if FieldItem.isFieldToolWorldPositionSafe(fldItemSpawnArea, vectorCandidatePosition) then
		return FieldItem.createFieldToolBattlefieldRestPosition(fldItemSpawnArea, partHandle, vectorCandidatePosition)
	end

	return FieldItem.pickFieldToolRespawnPosition(toolPickup, fldItemSpawnArea, partHandle)
end


-- --------------------------------------------------------------------------------


function FieldItem.respawnFieldToolToWorld(toolPickup, fldItemSpawnArea)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
	if not partHandle or not partHandle:IsA(ePhysical.BASE_PART) then return end

	local strHomeName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME)
	if typeof(strHomeName) == "string" then
		toolPickup.Name = strHomeName
	end

	local vectorRespawnPosition = FieldItem.pickFieldToolRespawnPosition(toolPickup, fldItemSpawnArea, partHandle)
	partHandle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	partHandle.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	toolPickup.Enabled = true
	toolPickup.Parent = fldItemSpawnArea
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, vectorRespawnPosition)
	FieldItem.applyFieldToolWorldState(toolPickup, partHandle, vectorRespawnPosition)
end


-- --------------------------------------------------------------------------------


function FieldItem.bindFieldToolOutOfBoundsRespawn(toolPickup, fldItemSpawnArea)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	if not EngineEnsure.markRuntimeInstalled(toolPickup, "RuntimeInstalled_FieldOutOfBoundsRespawn") then return end

	task.spawn(function()
		while toolPickup.Parent do
			task.wait(FIELD_ITEM_OUTSIDE_CHECK_SECONDS)
			if toolPickup.Parent == fldItemSpawnArea or toolPickup.Parent == workspace then
				local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
				if partHandle and partHandle:IsA(ePhysical.BASE_PART)
					and not FieldItem.isFieldToolWorldPositionSafe(fldItemSpawnArea, partHandle.Position) then
					FieldItem.respawnFieldToolToWorld(toolPickup, fldItemSpawnArea)
				end
			end
		end
	end)
end


-- --------------------------------------------------------------------------------


function FieldItem.bindFieldToolDropToWorld(toolPickup, fldItemSpawnArea)
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	if not EngineEnsure.markRuntimeInstalled(toolPickup, "RuntimeInstalled_FieldDropToWorld") then return end

	toolPickup:GetPropertyChangedSignal("Parent"):Connect(function()
		if toolPickup.Parent ~= workspace then return end

		local partDroppedHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
		if partDroppedHandle then
			FieldItem.applyFieldToolBasePartState(partDroppedHandle, true, false, true)
		end

		task.defer(function()
			if toolPickup.Parent ~= workspace then return end

			local partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
			if not partHandle then return end

			local strHomeName = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME)
			local vectorDropPosition = FieldItem.createFieldToolRestPosition(Vector3.new(partHandle.Position.X, 0.1, partHandle.Position.Z), partHandle)
			vectorDropPosition = FieldItem.resolveFieldToolSafeRestPosition(toolPickup, fldItemSpawnArea, partHandle, vectorDropPosition)
			if typeof(strHomeName) == "string" then
				toolPickup.Name = strHomeName
			end
			toolPickup.Parent = fldItemSpawnArea
			toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, vectorDropPosition)
			FieldItem.applyFieldToolWorldState(toolPickup, partHandle, vectorDropPosition)
			FieldItem.refreshFieldToolPickupInteractionDistance(partHandle)
		end)
	end)
end


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
			Transparency = 1,
			BrickColor = brickColor,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
		})
	end
end


-- --------------------------------------------------------------------------------


function FieldItem.createShuffledSpawnPositions(tblSpawnPositions)
	local tblShuffledPositions = {}
	for index, vectorPosition in ipairs(tblSpawnPositions) do
		tblShuffledPositions[index] = vectorPosition
	end

	local randomShuffle = Random.new()
	for index = #tblShuffledPositions, 2, -1 do
		local intSwapIndex = randomShuffle:NextInteger(1, index)
		tblShuffledPositions[index], tblShuffledPositions[intSwapIndex] = tblShuffledPositions[intSwapIndex], tblShuffledPositions[index]
	end

	return tblShuffledPositions
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


function FieldItem.installFieldToolPickupInArea(fldItemSpawnArea, strToolName, strToolTip, tblConfig, strInstanceSuffix, vectorSpawnPosition, tblDefaultHandleProperties, fnInstallToolSystem)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local strDisplayName = StudentConfig.readConfigString(tblConfig, "DisplayName", strToolName)
	local strToolHomeName = eLogical.FIELD_ITEM_PREFIX .. strToolName .. "_" .. strInstanceSuffix
	local toolPickup = EngineEnsure.ensureToolWithHandle(strToolHomeName, strToolTip, fldItemSpawnArea, tblDefaultHandleProperties)
	toolPickup.ToolTip = strDisplayName .. " - 클릭해서 줍기"
	toolPickup.CanBeDropped = true
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_TYPE, strToolName)
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_DISPLAY_NAME, strDisplayName)
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_NAME, strToolHomeName)
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_WORLD_ANCHORED, StudentConfig.readConfigBoolean(tblConfig, "WorldAnchored", true))
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_WORLD_CAN_COLLIDE, StudentConfig.readConfigBoolean(tblConfig, "WorldCanCollide", false))
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_WORLD_MASSLESS, StudentConfig.readConfigBoolean(tblConfig, "WorldMassless", true))

	local partHandle = Appearance.applyToolHandleStudentStyle(toolPickup, tblConfig)
	if fnInstallToolSystem then
		fnInstallToolSystem(toolPickup, tblConfig)
	end

	partHandle = toolPickup:FindFirstChild(eLogical.RESERVED_HANDLE)
	local vectorHomePosition = FieldItem.createFieldToolRestPosition(vectorSpawnPosition, partHandle)
	FieldItem.applyFieldToolWorldState(toolPickup, partHandle, vectorHomePosition)
	toolPickup:SetAttribute(eAttrKey.FIELD_ITEM_HOME_POSITION, vectorHomePosition)
	FieldItem.bindFieldToolDropToWorld(toolPickup, fldItemSpawnArea)
	FieldItem.bindFieldToolOutOfBoundsRespawn(toolPickup, fldItemSpawnArea)

	local clickPickup = EngineEnsure.ensureClickDetector(partHandle, FieldItem.calculateFieldToolPickupDistance(partHandle, FIELD_ITEM_PICKUP_CLICK_BASE_DISTANCE))
	local promptPickup = FieldItem.ensureFieldToolPickupPrompt(partHandle, strDisplayName)
	if EngineEnsure.markRuntimeInstalled(toolPickup, "RuntimeInstalled_FieldPickup") then
		local function pickup_tool(player)
			local backpackPlayer = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
			if not backpackPlayer or toolPickup.Parent ~= fldItemSpawnArea then return end
			if toolPickup:GetAttribute(eAttrKey.BLOCK_IS_PROJECTILE) == true then return end

			-- [무게 제한 검사] 일반 50kg, 힘 특화 70kg 기준으로 서버에서 최종 검증
			local tblDensities = {
				Basalt = 2400, Brick = 1900, Cobblestone = 2500, Concrete = 2400,
				CorrodedMetal = 7200, Fabric = 150, Foil = 2700, Glass = 2500,
				Glacier = 900, Granite = 2700, Grass = 300, Ice = 917,
				Marble = 2700, Metal = 7870, Mud = 1500, Neon = 600,
				Pebble = 2600, Plastic = 900, Rock = 2700, Salt = 2160,
				Sand = 1600, Sandstone = 2200, Slate = 2700, SmoothPlastic = 900,
				Snow = 300, Wood = 700, WoodPlanks = 650
			}

			local partHandle = toolPickup:FindFirstChild("Handle")
			local size = partHandle and partHandle.Size or Vector3.new(1.2, 1.2, 1.2)
			local realMaterial = toolPickup:GetAttribute("RealMaterial") or "Rock"
			local density = tblDensities[realMaterial] or 2700
			local massKg = StudentConfig.calculateEquipmentMassKg(size, density)

			local strSpec = player:GetAttribute("Specialization") or "None"
			local maxCarryLimit = FIELD_ITEM_PICKUP_ABSOLUTE_MASS_LIMIT_KG
			local maxPickupLimit = (strSpec == "Strength")
				and FIELD_ITEM_PICKUP_STRENGTH_MASS_LIMIT_KG
				or FIELD_ITEM_PICKUP_STANDARD_MASS_LIMIT_KG

			if massKg > maxCarryLimit then
				-- 아예 들 수 없는 초고중량 (주머니 넣기 불가능)
				return
			end

			if massKg > maxPickupLimit then
				-- 힘 특화 유저가 아니라서 획득 불가
				return
			end

			-- [소지 제한 검사] 배낭(Backpack)과 캐릭터(쥐고 있는 상태)의 총 도구 개수가 2개 이상이면 더 주울 수 없습니다.
			local intToolCount = 0
			for _, instanceItem in ipairs(backpackPlayer:GetChildren()) do
				if instanceItem:IsA(ePhysical.TOOL) then
					intToolCount += 1
				end
			end
			local modelCharacter = player.Character
			if modelCharacter then
				for _, instanceItem in ipairs(modelCharacter:GetChildren()) do
					if instanceItem:IsA(ePhysical.TOOL) then
						intToolCount += 1
					end
				end
			end

			if intToolCount >= 2 then
				return -- 획득 거부
			end

			FieldItem.applyFieldToolCarriedState(toolPickup, partHandle)
			toolPickup.Name = strDisplayName
			toolPickup.Parent = backpackPlayer
			if modelCharacter then
				local humanoidPlayer = modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
				if humanoidPlayer then
					humanoidPlayer:EquipTool(toolPickup)
				end
			end
		end

		clickPickup.MouseClick:Connect(pickup_tool)
		promptPickup.Triggered:Connect(pickup_tool)
	end

	return toolPickup
end


-- --------------------------------------------------------------------------------


function FieldItem.installFieldToolPickups(svcWorkspace, strToolName, strToolTip, tblConfig, tblDefaultSpawnPositions, tblDefaultHandleProperties, fnInstallToolSystem) -- [의미/의도] 파밍 Tool 묶음 설치 함수 정의 ➔ 직접 지급하지 않고 맵에 놓인 장비를 플레이어가 찾아서 줍게 하기 위함
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local tblSpawnPositions = FieldItem.getFieldItemSpawnPositions(fldItemSpawnArea, strToolName, tblDefaultSpawnPositions)
	local intSpawnCount = StudentConfig.readConfigInteger(tblConfig, "SpawnCount", #tblSpawnPositions, 1, 12)
	local strVariantId = StudentConfig.readConfigString(tblConfig, "VariantId", strToolName)
	local vectorSpawnOffset = StudentConfig.readConfigVector3(tblConfig, "SpawnOffset", Vector3.new(0, 0, 0), Vector3.new(-8, 0, -8), Vector3.new(8, 4, 8))
	local numberSpawnRadius = StudentConfig.readConfigNumber(tblConfig, "SpawnRadius", 0, 0, FIELD_ITEM_SPAWN_RADIUS_MAX)
	local tblRandomizedSpawnPositions = FieldItem.createShuffledSpawnPositions(tblSpawnPositions)

	for index = 1, intSpawnCount do
		local vectorSpawnJitter = FieldItem.createFlatSpawnJitter(strVariantId, index, numberSpawnRadius)
		local vectorSpawnPosition = tblRandomizedSpawnPositions[((index - 1) % #tblRandomizedSpawnPositions) + 1] + vectorSpawnOffset + vectorSpawnJitter
		local strInstanceSuffix = strVariantId .. "_" .. tostring(index)
		FieldItem.installFieldToolPickupInArea(
			fldItemSpawnArea,
			strToolName,
			strToolTip,
			tblConfig,
			strInstanceSuffix,
			vectorSpawnPosition,
			tblDefaultHandleProperties,
			fnInstallToolSystem
		)
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
			FieldItem.applyFieldToolWorldState(toolPickup, partHandle, vectorHomePosition)
			FieldItem.refreshFieldToolPickupInteractionDistance(partHandle)
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
