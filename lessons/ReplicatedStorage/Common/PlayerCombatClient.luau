-- [Module] PlayerCombatClient
local PlayerCombatClient = {}

local CoreEnums = require(script.Parent.CoreEnums)

local boolPlayerCombatClientControlsInstalled = false

local MAX_CHARGE_SECONDS = 1.25
local FIST_ATTACK_COOLDOWN_SECONDS = 0.45
local FIST_ACTION_SECONDS = 0.32
local CROSSHAIR_SIZE = 18
local CAMERA_FOLLOW_RENDER_STEP = "PlayerCombatFollowCamera"
local CAMERA_BACK_DISTANCE = 13
local CAMERA_HEIGHT = 6
local CAMERA_LOOK_AHEAD_DISTANCE = 16
local CAMERA_LOOK_HEIGHT = 3
local CAMERA_RIGHT_OFFSET = 2
local CAMERA_LERP_ALPHA = 0.22
local CAMERA_MOUSE_SENSITIVITY = 0.003
local CAMERA_MIN_PITCH = math.rad(-55)
local CAMERA_MAX_PITCH = math.rad(30)
local CAMERA_AIM_DISTANCE = 500

-- --------------------------------------------------------------------------------


function PlayerCombatClient.installPlayerCombatClientControls()
	if boolPlayerCombatClientControlsInstalled then
		return false
	end

	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey

	local svcPlayers = game:GetService(eService.PLAYERS)
	local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)
	local svcRunService = game:GetService(eService.RUN_SERVICE)
	local svcUserInputService = game:GetService(eService.USER_INPUT_SERVICE)
	local svcWorkspace = game:GetService(eService.WORKSPACE)

	local playerLocal = svcPlayers.LocalPlayer
	if not playerLocal then
		return false
	end
	boolPlayerCombatClientControlsInstalled = true

	local mousePlayer = playerLocal:GetMouse()
	local tblConnectedTools = {}
	local toolActiveThrowingStone = nil
	local numberChargeStartTime = nil
	local numberLastFistAttackTime = 0
	local numberFistActionStartTime = nil
	local motorFistRightShoulder = nil
	local humanoidAimCharacter = nil
	local boolSavedAutoRotate = nil
	local boolSavedMouseIconEnabled = nil
	local enumSavedMouseBehavior = nil
	local boolCameraFollowEnabled = false
	local enumSavedCameraType = nil
	local instanceSavedCameraSubject = nil
	local numberSavedFieldOfView = nil
	local cframeCameraFollow = nil
	local numberCameraYaw = 0
	local numberCameraPitch = math.rad(-10)

	local guiCrosshair = Instance.new(ePhysical.SCREEN_GUI)
	guiCrosshair.Name = "PlayerCombatCrosshairGui"
	guiCrosshair.ResetOnSpawn = false
	guiCrosshair.Enabled = false
	guiCrosshair.Parent = playerLocal:WaitForChild("PlayerGui")

	local frameCrosshair = Instance.new(ePhysical.FRAME)
	frameCrosshair.Name = "Crosshair"
	frameCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	frameCrosshair.Size = UDim2.fromOffset(CROSSHAIR_SIZE, CROSSHAIR_SIZE)
	frameCrosshair.BackgroundTransparency = 1
	frameCrosshair.Parent = guiCrosshair

	local function make_line(strName, sizeLine, positionLine)
		local frameLine = Instance.new(ePhysical.FRAME)
		frameLine.Name = strName
		frameLine.AnchorPoint = Vector2.new(0.5, 0.5)
		frameLine.Size = sizeLine
		frameLine.Position = positionLine
		frameLine.BorderSizePixel = 0
		frameLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frameLine.Parent = frameCrosshair
		return frameLine
	end

	make_line("Horizontal", UDim2.fromOffset(CROSSHAIR_SIZE, 2), UDim2.fromScale(0.5, 0.5))
	make_line("Vertical", UDim2.fromOffset(2, CROSSHAIR_SIZE), UDim2.fromScale(0.5, 0.5))

	local frameChargeBack = Instance.new(ePhysical.FRAME)
	frameChargeBack.Name = "ChargeBack"
	frameChargeBack.AnchorPoint = Vector2.new(0.5, 0)
	frameChargeBack.Size = UDim2.fromOffset(42, 5)
	frameChargeBack.Position = UDim2.fromOffset(0, CROSSHAIR_SIZE)
	frameChargeBack.BorderSizePixel = 0
	frameChargeBack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frameChargeBack.Visible = false
	frameChargeBack.Parent = frameCrosshair

	local frameChargeFill = Instance.new(ePhysical.FRAME)
	frameChargeFill.Name = "ChargeFill"
	frameChargeFill.Size = UDim2.fromScale(0, 1)
	frameChargeFill.BorderSizePixel = 0
	frameChargeFill.BackgroundColor3 = Color3.fromRGB(255, 218, 86)
	frameChargeFill.Parent = frameChargeBack

	local function get_fist_action_progress()
		if not numberFistActionStartTime then return nil end

		local numberProgress = (os.clock() - numberFistActionStartTime) / FIST_ACTION_SECONDS
		if numberProgress >= 1 then
			return nil
		end

		return math.max(0, numberProgress)
	end

	local function is_throwing_stone(toolTarget)
		if not toolTarget:IsA(ePhysical.TOOL) then return false end

		return toolTarget:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == eLogical.THROWING_STONE
			or toolTarget.Name:sub(1, #eLogical.THROWING_STONE) == eLogical.THROWING_STONE
	end

	local function set_crosshair_enabled(boolEnabled)
		guiCrosshair.Enabled = boolEnabled
		if boolEnabled then
			if boolSavedMouseIconEnabled == nil then
				boolSavedMouseIconEnabled = svcUserInputService.MouseIconEnabled
			end

			if enumSavedMouseBehavior == nil then
				enumSavedMouseBehavior = svcUserInputService.MouseBehavior
			end

			svcUserInputService.MouseIconEnabled = false
			svcUserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			if boolSavedMouseIconEnabled ~= nil then
				svcUserInputService.MouseIconEnabled = boolSavedMouseIconEnabled
			end

			if enumSavedMouseBehavior ~= nil then
				svcUserInputService.MouseBehavior = enumSavedMouseBehavior
			end

			boolSavedMouseIconEnabled = nil
			enumSavedMouseBehavior = nil
		end

		if not boolEnabled then
			numberChargeStartTime = nil
			frameChargeFill.Size = UDim2.fromScale(0, 1)
		end
	end

	local function set_throw_charge_visible(boolVisible)
		frameChargeBack.Visible = boolVisible
		if not boolVisible then
			numberChargeStartTime = nil
			frameChargeFill.Size = UDim2.fromScale(0, 1)
		end
	end

	local function set_character_aim_enabled(boolEnabled)
		if not boolEnabled then
			if humanoidAimCharacter and boolSavedAutoRotate ~= nil then
				humanoidAimCharacter.AutoRotate = boolSavedAutoRotate
			end

			humanoidAimCharacter = nil
			boolSavedAutoRotate = nil
			return
		end

		local modelCharacter = playerLocal.Character
		local humanoidPlayer = modelCharacter and modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humanoidPlayer then return end
		if humanoidAimCharacter == humanoidPlayer then return end

		humanoidAimCharacter = humanoidPlayer
		boolSavedAutoRotate = humanoidPlayer.AutoRotate
		humanoidPlayer.AutoRotate = false
	end

	local function update_character_aim()
		if not boolCameraFollowEnabled then return end

		local modelCharacter = playerLocal.Character
		local partHumanoidRoot = modelCharacter and modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not partHumanoidRoot then return end

		local vectorLook = CFrame.Angles(0, numberCameraYaw, 0).LookVector
		local vectorFlatTarget = partHumanoidRoot.Position + Vector3.new(vectorLook.X, 0, vectorLook.Z)
		if (vectorFlatTarget - partHumanoidRoot.Position).Magnitude <= 0.01 then return end

		partHumanoidRoot.CFrame = CFrame.lookAt(partHumanoidRoot.Position, vectorFlatTarget)
	end

	local function get_camera_aim_position()
		local cameraCurrent = svcWorkspace.CurrentCamera
		if not cameraCurrent then
			return mousePlayer.Hit.Position
		end

		local tblRaycastFilter = {}
		if playerLocal.Character then
			table.insert(tblRaycastFilter, playerLocal.Character)
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = tblRaycastFilter

		local vectorOrigin = cameraCurrent.CFrame.Position
		local vectorDirection = cameraCurrent.CFrame.LookVector * CAMERA_AIM_DISTANCE
		local raycastResult = svcWorkspace:Raycast(vectorOrigin, vectorDirection, raycastParams)
		if raycastResult then
			return raycastResult.Position
		end

		return vectorOrigin + vectorDirection
	end

	local function update_follow_camera()
		if not boolCameraFollowEnabled then return end

		local cameraCurrent = svcWorkspace.CurrentCamera
		local modelCharacter = playerLocal.Character
		local partHumanoidRoot = modelCharacter and modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if not cameraCurrent or not partHumanoidRoot then return end

		local cframeRotation = CFrame.Angles(0, numberCameraYaw, 0) * CFrame.Angles(numberCameraPitch, 0, 0)
		local cframeYaw = CFrame.Angles(0, numberCameraYaw, 0)
		local vectorLook = cframeRotation.LookVector
		local vectorRight = cframeYaw.RightVector
		local vectorFocusBase = partHumanoidRoot.Position + Vector3.new(0, CAMERA_LOOK_HEIGHT, 0)
		local vectorFocus = partHumanoidRoot.Position
			+ Vector3.new(0, CAMERA_LOOK_HEIGHT, 0)
			+ vectorLook * CAMERA_LOOK_AHEAD_DISTANCE
		local vectorCamera = vectorFocusBase
			- vectorLook * CAMERA_BACK_DISTANCE
			+ vectorRight * CAMERA_RIGHT_OFFSET
			+ Vector3.new(0, CAMERA_HEIGHT, 0)

		local numberFistProgress = get_fist_action_progress()
		if numberFistProgress then
			local numberPunchPower = math.sin(numberFistProgress * math.pi)
			vectorCamera += vectorRight * (0.35 * numberPunchPower) + vectorLook * (0.45 * numberPunchPower)
			vectorFocus += Vector3.new(0, 0.2 * numberPunchPower, 0)
		end

		local cframeTarget = CFrame.lookAt(vectorCamera, vectorFocus)

		if cframeCameraFollow then
			cframeCameraFollow = cframeCameraFollow:Lerp(cframeTarget, CAMERA_LERP_ALPHA)
		else
			cframeCameraFollow = cframeTarget
		end

		cameraCurrent.CFrame = cframeCameraFollow
	end

	local function find_right_shoulder_motor(modelCharacter)
		if not modelCharacter then return nil end

		for _, instanceDescendant in ipairs(modelCharacter:GetDescendants()) do
			if instanceDescendant:IsA(ePhysical.MOTOR_6D)
				and (instanceDescendant.Name == "RightShoulder" or instanceDescendant.Name == "Right Shoulder") then
				return instanceDescendant
			end
		end

		return nil
	end

	local function reset_fist_action_visuals()
		if motorFistRightShoulder then
			motorFistRightShoulder.Transform = CFrame.new()
			motorFistRightShoulder = nil
		end
	end

	local function get_fist_punch_motor_transform(numberFistProgress)
		if numberFistProgress < 0.32 then
			local numberWindup = numberFistProgress / 0.32
			return CFrame.Angles(
				math.rad(-35) * numberWindup,
				math.rad(28) * numberWindup,
				math.rad(38) * numberWindup
			)
		end

		local numberThrust = math.clamp((numberFistProgress - 0.32) / 0.28, 0, 1)
		local numberRecover = math.clamp((numberFistProgress - 0.6) / 0.4, 0, 1)
		local numberPunchPower = math.sin(numberThrust * math.pi * 0.5) * (1 - numberRecover)
		return CFrame.Angles(
			math.rad(-105) * numberPunchPower,
			math.rad(-10) * numberPunchPower,
			math.rad(-22) * numberPunchPower
		) * CFrame.new(0, 0, -0.45 * numberPunchPower)
	end

	local function update_fist_action_visuals()
		local numberFistProgress = get_fist_action_progress()
		if not numberFistProgress then
			numberFistActionStartTime = nil
			reset_fist_action_visuals()
			return
		end

		local modelCharacter = playerLocal.Character
		motorFistRightShoulder = motorFistRightShoulder or find_right_shoulder_motor(modelCharacter)
		if motorFistRightShoulder then
			motorFistRightShoulder.Transform = get_fist_punch_motor_transform(numberFistProgress)
		end
	end

	local function start_fist_action_visuals()
		numberFistActionStartTime = os.clock()
	end

	local function set_camera_follow_enabled(boolEnabled)
		if not boolEnabled then
			svcRunService:UnbindFromRenderStep(CAMERA_FOLLOW_RENDER_STEP)

			local cameraCurrent = svcWorkspace.CurrentCamera
			if cameraCurrent then
				if enumSavedCameraType then
					cameraCurrent.CameraType = enumSavedCameraType
				end

				if instanceSavedCameraSubject then
					cameraCurrent.CameraSubject = instanceSavedCameraSubject
				end

				if numberSavedFieldOfView then
					cameraCurrent.FieldOfView = numberSavedFieldOfView
				end
			end

			boolCameraFollowEnabled = false
			enumSavedCameraType = nil
			instanceSavedCameraSubject = nil
			numberSavedFieldOfView = nil
			cframeCameraFollow = nil
			return
		end

		if boolCameraFollowEnabled then return end

		local cameraCurrent = svcWorkspace.CurrentCamera
		local modelCharacter = playerLocal.Character
		local humanoidPlayer = modelCharacter and modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not cameraCurrent or not humanoidPlayer then return end

		boolCameraFollowEnabled = true
		enumSavedCameraType = cameraCurrent.CameraType
		instanceSavedCameraSubject = cameraCurrent.CameraSubject
		numberSavedFieldOfView = cameraCurrent.FieldOfView
		cframeCameraFollow = cameraCurrent.CFrame

		local numberInitialPitch, numberInitialYaw = cameraCurrent.CFrame:ToOrientation()
		numberCameraYaw = numberInitialYaw
		numberCameraPitch = math.clamp(numberInitialPitch, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)

		cameraCurrent.CameraSubject = humanoidPlayer
		cameraCurrent.CameraType = Enum.CameraType.Scriptable

		svcRunService:BindToRenderStep(CAMERA_FOLLOW_RENDER_STEP, Enum.RenderPriority.Camera.Value + 1, function()
			update_character_aim()
			update_follow_camera()
		end)
	end

	local function set_default_aim_control_enabled(boolEnabled)
		set_crosshair_enabled(boolEnabled)
		set_character_aim_enabled(boolEnabled)
		set_camera_follow_enabled(boolEnabled)
	end

	local function start_default_aim_control_for_character(modelCharacter)
		if not modelCharacter then return end

		local humanoidPlayer = modelCharacter:WaitForChild(ePhysical.HUMANOID, 5)
		local partHumanoidRoot = modelCharacter:WaitForChild(eLogical.RESERVED_HUMANOID_ROOT_PART, 5)
		if not humanoidPlayer or not partHumanoidRoot then return end

		if playerLocal.Character ~= modelCharacter then return end

		set_default_aim_control_enabled(true)
	end

	local function get_charge()
		if not numberChargeStartTime then
			return 0
		end

		return math.clamp((os.clock() - numberChargeStartTime) / MAX_CHARGE_SECONDS, 0, 1)
	end

	local function get_equipped_tool()
		local modelCharacter = playerLocal.Character
		if not modelCharacter then return nil end

		for _, instanceChild in ipairs(modelCharacter:GetChildren()) do
			if instanceChild:IsA(ePhysical.TOOL) then
				return instanceChild
			end
		end

		return nil
	end

	local function request_fist_attack()
		if get_equipped_tool() then return end

		local numberNow = os.clock()
		if numberNow - numberLastFistAttackTime < FIST_ATTACK_COOLDOWN_SECONDS then return end

		local eventFistAttack = svcReplicatedStorage:FindFirstChild(eLogical.FIST_ATTACK)
		if not eventFistAttack then return end

		numberLastFistAttackTime = numberNow
		start_fist_action_visuals()
		eventFistAttack:FireServer(get_camera_aim_position())
	end

	local function connect_throwing_stone(toolThrowingStone)
		if tblConnectedTools[toolThrowingStone] or not is_throwing_stone(toolThrowingStone) then return end

		tblConnectedTools[toolThrowingStone] = true

		toolThrowingStone.Equipped:Connect(function()
			toolActiveThrowingStone = toolThrowingStone
			set_default_aim_control_enabled(true)
			set_throw_charge_visible(true)
		end)

		toolThrowingStone.Unequipped:Connect(function()
			if toolActiveThrowingStone == toolThrowingStone then
				toolActiveThrowingStone = nil
				set_throw_charge_visible(false)
			end
		end)

		toolThrowingStone.AncestryChanged:Connect(function()
			local modelCharacter = playerLocal.Character
			if toolActiveThrowingStone == toolThrowingStone and modelCharacter and not toolThrowingStone:IsDescendantOf(modelCharacter) then
				toolActiveThrowingStone = nil
				set_throw_charge_visible(false)
			end
		end)
	end

	local function watch_container(instanceContainer)
		for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
			connect_throwing_stone(instanceChild)
		end

		instanceContainer.ChildAdded:Connect(connect_throwing_stone)
	end

	mousePlayer.Button1Down:Connect(function()
		if not toolActiveThrowingStone then
			request_fist_attack()
			return
		end

		numberChargeStartTime = os.clock()
	end)

	mousePlayer.Button1Up:Connect(function()
		if not toolActiveThrowingStone or not numberChargeStartTime then return end

		local eventThrowingStoneAim = svcReplicatedStorage:FindFirstChild(eLogical.THROWING_STONE_AIM)
		if eventThrowingStoneAim then
			eventThrowingStoneAim:FireServer(toolActiveThrowingStone, get_camera_aim_position(), get_charge())
		end

		numberChargeStartTime = nil
		frameChargeFill.Size = UDim2.fromScale(0, 1)
	end)

	svcUserInputService.InputChanged:Connect(function(inputChanged)
		if not boolCameraFollowEnabled or inputChanged.UserInputType ~= Enum.UserInputType.MouseMovement then return end

		numberCameraYaw -= inputChanged.Delta.X * CAMERA_MOUSE_SENSITIVITY
		numberCameraPitch = math.clamp(
			numberCameraPitch - inputChanged.Delta.Y * CAMERA_MOUSE_SENSITIVITY,
			CAMERA_MIN_PITCH,
			CAMERA_MAX_PITCH
		)
	end)

	svcRunService.RenderStepped:Connect(function()
		local cameraCurrent = svcWorkspace.CurrentCamera
		if cameraCurrent then
			local vectorViewportSize = cameraCurrent.ViewportSize
			frameCrosshair.Position = UDim2.fromOffset(vectorViewportSize.X / 2, vectorViewportSize.Y / 2)
		else
			frameCrosshair.Position = UDim2.fromOffset(mousePlayer.X, mousePlayer.Y)
		end

		frameChargeFill.Size = UDim2.fromScale(get_charge(), 1)
		update_fist_action_visuals()
	end)

	watch_container(playerLocal:WaitForChild("Backpack"))
	if playerLocal.Character then
		watch_container(playerLocal.Character)
		task.defer(start_default_aim_control_for_character, playerLocal.Character)
	end

	playerLocal.CharacterAdded:Connect(function(modelCharacter)
		toolActiveThrowingStone = nil
		set_throw_charge_visible(false)
		reset_fist_action_visuals()
		set_default_aim_control_enabled(false)
		watch_container(modelCharacter)
		task.defer(start_default_aim_control_for_character, modelCharacter)
	end)

	return true
end


-- --------------------------------------------------------------------------------

return PlayerCombatClient
