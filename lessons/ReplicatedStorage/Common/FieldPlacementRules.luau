-- [Module] FieldPlacementRules
local FieldPlacementRules = {}

local CoreEnums = require(script.Parent.CoreEnums)

local FIELD_ITEM_PLACE_MAX_DISTANCE = 45
local FIELD_ITEM_PLACE_SURFACE_CLEARANCE = 0.04
local FIELD_ITEM_PLACE_SUPPORT_RAY_HEIGHT = 12
local FIELD_ITEM_PLACE_SUPPORT_RAY_DISTANCE = 80
local FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y = 0.35
local FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ = 0.92
local FIELD_ITEM_PLACE_OVERLAP_SCALE_Y = 0.88
local FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE = 0.1
local STACK_BRICK_SNAP_RADIUS = 7
local STACK_BRICK_SNAP_TARGET_MAX_DISTANCE = 5.5


-- --------------------------------------------------------------------------------


local function append_filter_instance(tblFilterDescendants, instanceTarget)
	if instanceTarget then
		table.insert(tblFilterDescendants, instanceTarget)
	end
end


-- --------------------------------------------------------------------------------


local function create_filter_descendants(modelCharacter, toolPickup, instanceExtraIgnore)
	local tblFilterDescendants = {}
	append_filter_instance(tblFilterDescendants, modelCharacter)
	append_filter_instance(tblFilterDescendants, toolPickup)
	append_filter_instance(tblFilterDescendants, instanceExtraIgnore)
	return tblFilterDescendants
end


-- --------------------------------------------------------------------------------


local function create_raycast_params(modelCharacter, toolPickup, instanceExtraIgnore)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = create_filter_descendants(modelCharacter, toolPickup, instanceExtraIgnore)
	raycastParams.IgnoreWater = true
	return raycastParams
end


-- --------------------------------------------------------------------------------


local function create_overlap_params(modelCharacter, toolPickup, instanceExtraIgnore)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = create_filter_descendants(modelCharacter, toolPickup, instanceExtraIgnore)
	return overlapParams
end


-- --------------------------------------------------------------------------------


local function create_overlap_size(vectorPlacementSize)
	return Vector3.new(
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.X * FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ),
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.Y * FIELD_ITEM_PLACE_OVERLAP_SCALE_Y),
		math.max(FIELD_ITEM_PLACE_OVERLAP_MIN_SIZE, vectorPlacementSize.Z * FIELD_ITEM_PLACE_OVERLAP_SCALE_XZ)
	)
end


-- --------------------------------------------------------------------------------


local function is_overlap_part_blocking(partCandidate, modelCharacter, toolPickup, instanceExtraIgnore)
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
	if instanceExtraIgnore and partCandidate:IsDescendantOf(instanceExtraIgnore) then
		return false
	end

	return true
end


-- --------------------------------------------------------------------------------


function FieldPlacementRules.isPlacementBlocked(modelCharacter, toolPickup, cframePlacement, vectorPlacementSize, instanceExtraIgnore)
	local overlapParams = create_overlap_params(modelCharacter, toolPickup, instanceExtraIgnore)
	local vectorOverlapSize = create_overlap_size(vectorPlacementSize)
	local tblOverlapParts = workspace:GetPartBoundsInBox(cframePlacement, vectorOverlapSize, overlapParams)

	for _, partCandidate in ipairs(tblOverlapParts) do
		if is_overlap_part_blocking(partCandidate, modelCharacter, toolPickup, instanceExtraIgnore) then
			return true
		end
	end

	return false
end


-- --------------------------------------------------------------------------------


local function flatten_unit_vector(vectorTarget, vectorFallback)
	local vectorFlat = Vector3.new(vectorTarget.X, 0, vectorTarget.Z)
	if vectorFlat.Magnitude > 0.01 then
		return vectorFlat.Unit
	end

	local vectorFallbackFlat = Vector3.new(vectorFallback.X, 0, vectorFallback.Z)
	if vectorFallbackFlat.Magnitude > 0.01 then
		return vectorFallbackFlat.Unit
	end

	return Vector3.new(0, 0, -1)
end


-- --------------------------------------------------------------------------------


local function create_rotation_from_look(vectorLook)
	local vectorFlatLook = flatten_unit_vector(vectorLook, Vector3.new(0, 0, -1))
	return CFrame.lookAt(Vector3.new(0, 0, 0), vectorFlatLook)
end


-- --------------------------------------------------------------------------------


local function create_placement_rotation(partHumanoidRoot, vectorRayDirection, intRotationQuarterTurns)
	local vectorForward = partHumanoidRoot.CFrame.LookVector
	if typeof(vectorRayDirection) == "Vector3" and vectorRayDirection.Magnitude > 0.01 then
		vectorForward = vectorRayDirection.Unit
	end

	local cframeRotation = create_rotation_from_look(vectorForward)
	local intSafeQuarterTurns = math.floor(tonumber(intRotationQuarterTurns) or 0) % 4
	if intSafeQuarterTurns ~= 0 then
		cframeRotation *= CFrame.Angles(0, math.rad(90 * intSafeQuarterTurns), 0)
	end

	return cframeRotation
end


-- --------------------------------------------------------------------------------


local function create_placement_cframe(vectorPosition, cframeRotation)
	return CFrame.lookAt(vectorPosition, vectorPosition + cframeRotation.LookVector, cframeRotation.UpVector)
end


-- --------------------------------------------------------------------------------


local function raycast_placement_surface(modelCharacter, toolPickup, partHumanoidRoot, vectorRayOrigin, vectorRayDirection, instanceExtraIgnore)
	local vectorOrigin = partHumanoidRoot.Position + Vector3.new(0, 2, 0)
	local vectorDirection = partHumanoidRoot.CFrame.LookVector * FIELD_ITEM_PLACE_MAX_DISTANCE + Vector3.new(0, -8, 0)

	if typeof(vectorRayOrigin) == "Vector3" and typeof(vectorRayDirection) == "Vector3" and vectorRayDirection.Magnitude > 0.01 then
		if (vectorRayOrigin - partHumanoidRoot.Position).Magnitude <= 90 then
			vectorOrigin = vectorRayOrigin
		end
		vectorDirection = vectorRayDirection.Unit * FIELD_ITEM_PLACE_MAX_DISTANCE
	end

	local raycastParams = create_raycast_params(modelCharacter, toolPickup, instanceExtraIgnore)
	local raycastResult = workspace:Raycast(vectorOrigin, vectorDirection, raycastParams)
	if raycastResult then
		return raycastResult
	end

	local vectorFallbackStart = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 5 + Vector3.new(0, 8, 0)
	return workspace:Raycast(vectorFallbackStart, Vector3.new(0, -40, 0), raycastParams)
end


-- --------------------------------------------------------------------------------


local function raycast_placement_support(modelCharacter, toolPickup, vectorTargetPosition, instanceExtraIgnore)
	local raycastParams = create_raycast_params(modelCharacter, toolPickup, instanceExtraIgnore)
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


local function resolve_placement_support(modelCharacter, toolPickup, raycastResult, vectorFallbackPosition, instanceExtraIgnore)
	local vectorTargetPosition = raycastResult and raycastResult.Position or vectorFallbackPosition
	if not vectorTargetPosition then
		return nil
	end

	if raycastResult and raycastResult.Normal.Y >= FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y then
		return raycastResult, vectorTargetPosition
	end

	local raycastSupport = raycast_placement_support(modelCharacter, toolPickup, vectorTargetPosition, instanceExtraIgnore)
	if raycastSupport and raycastSupport.Normal.Y >= FIELD_ITEM_PLACE_MIN_SUPPORT_NORMAL_Y then
		return raycastSupport, vectorTargetPosition
	end

	return nil, vectorTargetPosition
end


-- --------------------------------------------------------------------------------


local function calculate_free_placement_cframe(modelCharacter, toolPickup, partHumanoidRoot, partHandle, vectorRayOrigin, vectorRayDirection, intRotationQuarterTurns, instanceExtraIgnore)
	local cframeRotation = create_placement_rotation(partHumanoidRoot, vectorRayDirection, intRotationQuarterTurns)
	local raycastResult = raycast_placement_surface(modelCharacter, toolPickup, partHumanoidRoot, vectorRayOrigin, vectorRayDirection, instanceExtraIgnore)
	local vectorFallbackPosition = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 5
	local raycastSupport, vectorTargetPosition = resolve_placement_support(modelCharacter, toolPickup, raycastResult, vectorFallbackPosition, instanceExtraIgnore)
	local vectorPosition = nil

	if raycastSupport then
		vectorPosition = Vector3.new(
			vectorTargetPosition.X,
			raycastSupport.Position.Y + partHandle.Size.Y * 0.5 + FIELD_ITEM_PLACE_SURFACE_CLEARANCE,
			vectorTargetPosition.Z
		)
	else
		vectorPosition = Vector3.new(
			vectorFallbackPosition.X,
			partHumanoidRoot.Position.Y - 2 + partHandle.Size.Y * 0.5,
			vectorFallbackPosition.Z
		)
	end

	return create_placement_cframe(vectorPosition, cframeRotation), vectorTargetPosition
end


-- --------------------------------------------------------------------------------


local function is_stack_brick_tool(toolTarget)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	return toolTarget
		and toolTarget:IsA(ePhysical.TOOL)
		and toolTarget:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == eLogical.STACK_BRICK
end


-- --------------------------------------------------------------------------------


local function find_stack_brick_tool_from_part(partCandidate)
	local instanceCurrent = partCandidate
	while instanceCurrent do
		if is_stack_brick_tool(instanceCurrent) then
			return instanceCurrent
		end
		instanceCurrent = instanceCurrent.Parent
	end

	return nil
end


-- --------------------------------------------------------------------------------


local function get_tool_handle(toolTarget)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local partHandle = toolTarget and toolTarget:FindFirstChild(eLogical.RESERVED_HANDLE)
	if partHandle and partHandle:IsA(ePhysical.BASE_PART) then
		return partHandle
	end

	return nil
end


-- --------------------------------------------------------------------------------


local function collect_nearby_stack_brick_handles(modelCharacter, toolPickup, vectorTargetPosition, instanceExtraIgnore)
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local overlapParams = create_overlap_params(modelCharacter, toolPickup, instanceExtraIgnore)
	local tblParts = workspace:GetPartBoundsInRadius(vectorTargetPosition, STACK_BRICK_SNAP_RADIUS, overlapParams)
	local tblHandles = {}
	local mapSeenTools = {}

	for _, partCandidate in ipairs(tblParts) do
		local toolStackBrick = find_stack_brick_tool_from_part(partCandidate)
		if toolStackBrick and not mapSeenTools[toolStackBrick] and toolStackBrick:GetAttribute(eAttrKey.BLOCK_IS_PROJECTILE) ~= true then
			local partHandle = get_tool_handle(toolStackBrick)
			if partHandle and partHandle.CanCollide then
				mapSeenTools[toolStackBrick] = true
				table.insert(tblHandles, partHandle)
			end
		end
	end

	return tblHandles
end


-- --------------------------------------------------------------------------------


local function get_brick_axes(cframeRotation, vectorSize)
	if vectorSize.X >= vectorSize.Z then
		return flatten_unit_vector(cframeRotation.RightVector, Vector3.new(1, 0, 0)),
			flatten_unit_vector(cframeRotation.LookVector, Vector3.new(0, 0, -1)),
			vectorSize.X,
			vectorSize.Z
	end

	return flatten_unit_vector(cframeRotation.LookVector, Vector3.new(0, 0, -1)),
		flatten_unit_vector(cframeRotation.RightVector, Vector3.new(1, 0, 0)),
		vectorSize.Z,
		vectorSize.X
end


-- --------------------------------------------------------------------------------


local function get_rotation_only(cframeTarget)
	return create_rotation_from_look(cframeTarget.LookVector)
end


-- --------------------------------------------------------------------------------


local function append_candidate(tblCandidates, vectorPosition, cframeRotation, strReason)
	table.insert(tblCandidates, {
		CFrame = create_placement_cframe(vectorPosition, cframeRotation),
		Reason = strReason,
	})
end


-- --------------------------------------------------------------------------------


local function append_default_wall_candidates(tblCandidates, partBaseBrick, vectorNewSize)
	local cframeBaseRotation = get_rotation_only(partBaseBrick.CFrame)
	local vectorBaseSize = partBaseBrick.Size
	local vectorBaseLongAxis, vectorBaseDepthAxis, numberBaseLength, numberBaseDepth = get_brick_axes(cframeBaseRotation, vectorBaseSize)
	local _, _, numberNewLength, numberNewDepth = get_brick_axes(cframeBaseRotation, vectorNewSize)
	local vectorBasePosition = partBaseBrick.Position
	local numberYStep = (vectorBaseSize.Y + vectorNewSize.Y) * 0.5
	local numberLengthStep = (numberBaseLength + numberNewLength) * 0.5
	local numberDepthStep = (numberBaseDepth + numberNewDepth) * 0.5

	append_candidate(tblCandidates, vectorBasePosition + vectorBaseLongAxis * numberLengthStep, cframeBaseRotation, "Straight")
	append_candidate(tblCandidates, vectorBasePosition - vectorBaseLongAxis * numberLengthStep, cframeBaseRotation, "Straight")
	append_candidate(tblCandidates, vectorBasePosition + vectorBaseDepthAxis * numberDepthStep, cframeBaseRotation, "Parallel")
	append_candidate(tblCandidates, vectorBasePosition - vectorBaseDepthAxis * numberDepthStep, cframeBaseRotation, "Parallel")
	append_candidate(tblCandidates, vectorBasePosition + Vector3.new(0, numberYStep, 0) + vectorBaseLongAxis * (numberBaseLength * 0.5), cframeBaseRotation, "Stagger")
	append_candidate(tblCandidates, vectorBasePosition + Vector3.new(0, numberYStep, 0) - vectorBaseLongAxis * (numberBaseLength * 0.5), cframeBaseRotation, "Stagger")
end


-- --------------------------------------------------------------------------------


local function append_endpoint_candidates(tblCandidates, partBaseBrick, vectorNewSize)
	local cframeBaseRotation = get_rotation_only(partBaseBrick.CFrame)
	local vectorBaseSize = partBaseBrick.Size
	local vectorBaseLongAxis, _, numberBaseLength = get_brick_axes(cframeBaseRotation, vectorBaseSize)
	local _, _, numberNewLength = get_brick_axes(cframeBaseRotation, vectorNewSize)
	local vectorBasePosition = partBaseBrick.Position
	local numberYStep = (vectorBaseSize.Y + vectorNewSize.Y) * 0.5
	local numberLengthStep = (numberBaseLength + numberNewLength) * 0.5

	append_candidate(tblCandidates, vectorBasePosition + Vector3.new(0, numberYStep, 0), cframeBaseRotation, "EndpointTop")
	append_candidate(tblCandidates, vectorBasePosition + vectorBaseLongAxis * numberLengthStep, cframeBaseRotation, "Endpoint")
	append_candidate(tblCandidates, vectorBasePosition - vectorBaseLongAxis * numberLengthStep, cframeBaseRotation, "Endpoint")
end


-- --------------------------------------------------------------------------------


local function append_corner_candidates(tblCandidates, partBaseBrick, vectorNewSize, intRotationQuarterTurns)
	local cframeBaseRotation = get_rotation_only(partBaseBrick.CFrame)
	local cframeNewRotation = cframeBaseRotation * CFrame.Angles(0, math.rad(90 * (intRotationQuarterTurns % 4)), 0)
	local vectorBaseSize = partBaseBrick.Size
	local vectorBaseLongAxis, _, numberBaseLength, numberBaseDepth = get_brick_axes(cframeBaseRotation, vectorBaseSize)
	local vectorNewLongAxis, _, numberNewLength, numberNewDepth = get_brick_axes(cframeNewRotation, vectorNewSize)
	local vectorBasePosition = partBaseBrick.Position

	for _, intEndSign in ipairs({-1, 1}) do
		for _, intSideSign in ipairs({-1, 1}) do
			local vectorPosition = vectorBasePosition
				+ vectorBaseLongAxis * intEndSign * ((numberBaseLength + numberNewDepth) * 0.5)
				+ vectorNewLongAxis * intSideSign * math.max(0, (numberNewLength - numberBaseDepth) * 0.5)
			append_candidate(tblCandidates, vectorPosition, cframeNewRotation, "Corner")
		end
	end
end


-- --------------------------------------------------------------------------------


local function calculate_candidate_score(cframeCandidate, vectorTargetPosition)
	return (cframeCandidate.Position - vectorTargetPosition).Magnitude
end


-- --------------------------------------------------------------------------------


local function choose_best_candidate(tblCandidates, modelCharacter, toolPickup, vectorTargetPosition, vectorPlacementSize, instanceExtraIgnore)
	local tblBestBlocked = nil
	local numberBestBlockedScore = math.huge
	local tblBestValid = nil
	local numberBestValidScore = math.huge
	local numberMaxDistance = math.max(STACK_BRICK_SNAP_TARGET_MAX_DISTANCE, vectorPlacementSize.Magnitude * 1.25)

	for _, tblCandidate in ipairs(tblCandidates) do
		local numberScore = calculate_candidate_score(tblCandidate.CFrame, vectorTargetPosition)
		if numberScore <= numberMaxDistance then
			local boolBlocked = FieldPlacementRules.isPlacementBlocked(modelCharacter, toolPickup, tblCandidate.CFrame, vectorPlacementSize, instanceExtraIgnore)
			if boolBlocked then
				if numberScore < numberBestBlockedScore then
					tblBestBlocked = tblCandidate
					numberBestBlockedScore = numberScore
				end
			elseif numberScore < numberBestValidScore then
				tblBestValid = tblCandidate
				numberBestValidScore = numberScore
			end
		end
	end

	return tblBestValid or tblBestBlocked
end


-- --------------------------------------------------------------------------------


local function calculate_stack_brick_snap_cframe(modelCharacter, toolPickup, partHandle, vectorTargetPosition, intRotationQuarterTurns, boolEndpointSnap, instanceExtraIgnore)
	local tblBaseBrickHandles = collect_nearby_stack_brick_handles(modelCharacter, toolPickup, vectorTargetPosition, instanceExtraIgnore)
	if #tblBaseBrickHandles == 0 then
		return nil
	end

	local tblCandidates = {}
	local intSafeQuarterTurns = math.floor(tonumber(intRotationQuarterTurns) or 0) % 4
	for _, partBaseBrick in ipairs(tblBaseBrickHandles) do
		if boolEndpointSnap then
			append_endpoint_candidates(tblCandidates, partBaseBrick, partHandle.Size)
		elseif intSafeQuarterTurns % 2 == 1 then
			append_corner_candidates(tblCandidates, partBaseBrick, partHandle.Size, intSafeQuarterTurns)
		else
			append_default_wall_candidates(tblCandidates, partBaseBrick, partHandle.Size)
		end
	end

	local tblBestCandidate = choose_best_candidate(tblCandidates, modelCharacter, toolPickup, vectorTargetPosition, partHandle.Size, instanceExtraIgnore)
	return tblBestCandidate and tblBestCandidate.CFrame or nil
end


-- --------------------------------------------------------------------------------


function FieldPlacementRules.calculatePlacementCFrame(modelCharacter, toolPickup, partHumanoidRoot, partHandle, vectorRayOrigin, vectorRayDirection, tblOptions)
	local intRotationQuarterTurns = tblOptions and tblOptions.RotationQuarterTurns or 0
	local boolEndpointSnap = tblOptions and tblOptions.EndpointSnap == true
	local instanceExtraIgnore = tblOptions and tblOptions.ExtraIgnore or nil
	local cframeFreePlacement, vectorTargetPosition = calculate_free_placement_cframe(
		modelCharacter,
		toolPickup,
		partHumanoidRoot,
		partHandle,
		vectorRayOrigin,
		vectorRayDirection,
		intRotationQuarterTurns,
		instanceExtraIgnore
	)

	if is_stack_brick_tool(toolPickup) then
		local cframeSmartPlacement = calculate_stack_brick_snap_cframe(
			modelCharacter,
			toolPickup,
			partHandle,
			vectorTargetPosition or cframeFreePlacement.Position,
			intRotationQuarterTurns,
			boolEndpointSnap,
			instanceExtraIgnore
		)
		if cframeSmartPlacement then
			return cframeSmartPlacement
		end
	end

	return cframeFreePlacement
end


-- --------------------------------------------------------------------------------


return FieldPlacementRules
