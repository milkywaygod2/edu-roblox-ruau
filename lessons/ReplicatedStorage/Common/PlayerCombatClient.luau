-- [Module] PlayerCombatClient
local PlayerCombatClient = {}

local CoreEnums = require(script.Parent.CoreEnums)
local FieldPlacementRules = require(script.Parent.FieldPlacementRules)
local StudentConfig = require(script.Parent.StudentConfig)

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
local RESPAWN_COUNTDOWN_SECONDS = 5
local FIELD_PICKUP_PROMPT_WIDTH = 280
local FIELD_PICKUP_PROMPT_HEIGHT = 44
local FIELD_PICKUP_PROMPT_BOTTOM_OFFSET = 107
local FIELD_PICKUP_PROMPT_RIGHT_OFFSET = 25
local BRICK_PLACE_MAX_DISTANCE = 45
local BRICK_PLACE_SURFACE_CLEARANCE = 0.04
local BRICK_PLACE_SUPPORT_RAY_HEIGHT = 12
local BRICK_PLACE_SUPPORT_RAY_DISTANCE = 80
local BRICK_PLACE_MIN_SUPPORT_NORMAL_Y = 0.35
local BRICK_PLACE_OVERLAP_SCALE_XZ = 0.92
local BRICK_PLACE_OVERLAP_SCALE_Y = 0.88
local BRICK_PLACE_OVERLAP_MIN_SIZE = 0.1
local BRICK_PLACE_PREVIEW_VALID_COLOR = Color3.fromRGB(90, 210, 140)
local BRICK_PLACE_PREVIEW_VALID_OUTLINE_COLOR = Color3.fromRGB(220, 255, 230)
local BRICK_PLACE_PREVIEW_BLOCKED_COLOR = Color3.fromRGB(235, 75, 75)
local BRICK_PLACE_PREVIEW_BLOCKED_OUTLINE_COLOR = Color3.fromRGB(255, 205, 205)

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
	local svcProximityPromptService = game:GetService(eService.PROXIMITY_PROMPT_SERVICE)
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
	local motorFistRightElbow = nil
	local cframeFistRightShoulderOriginalC0 = nil
	local cframeFistRightElbowOriginalC0 = nil
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
	local set_default_aim_control_enabled = nil
	local connectionHumanoidDied = nil
	local intRespawnCountdownToken = 0
	local boolBuildPlacementPreviewRequested = false
	local boolBuildPlacementPreviewBlocked = false
	local intBuildPlacementRotationQuarterTurns = 0
	local promptActiveFieldPickup = nil

	local eventSpecializationSelect = svcReplicatedStorage:WaitForChild(eLogical.SPECIALIZATION_SELECT, 5)
	if eventSpecializationSelect and not playerLocal:GetAttribute("Specialization") then
		task.spawn(function()
			local playerGui = playerLocal:WaitForChild("PlayerGui", 10)
			if not playerGui then return end

			local guiSpec = Instance.new("ScreenGui")
			guiSpec.Name = "SpecializationSelectGui"
			guiSpec.ResetOnSpawn = false
			guiSpec.Parent = playerGui

			local frameSpecSelect = Instance.new("Frame")
			frameSpecSelect.Name = "SpecSelectFrame"
			frameSpecSelect.AnchorPoint = Vector2.new(0.5, 0.5)
			frameSpecSelect.Position = UDim2.fromScale(0.5, 0.5)
			frameSpecSelect.Size = UDim2.fromOffset(480, 260)
			frameSpecSelect.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
			frameSpecSelect.BackgroundTransparency = 0.15
			frameSpecSelect.BorderSizePixel = 0
			frameSpecSelect.Parent = guiSpec

			local cornerSpec = Instance.new("UICorner")
			cornerSpec.CornerRadius = UDim.new(0, 12)
			cornerSpec.Parent = frameSpecSelect

			local strokeSpec = Instance.new("UIStroke")
			strokeSpec.Color = Color3.fromRGB(80, 80, 100)
			strokeSpec.Thickness = 2
			strokeSpec.Parent = frameSpecSelect

			local labelTitle = Instance.new("TextLabel")
			labelTitle.Size = UDim2.new(1, 0, 0, 40)
			labelTitle.Position = UDim2.fromOffset(0, 15)
			labelTitle.BackgroundTransparency = 1
			labelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			labelTitle.TextSize = 18
			labelTitle.Font = Enum.Font.GothamBold
			labelTitle.Text = "전투 특화 선택 (Select Specialization)"
			labelTitle.Parent = frameSpecSelect

			local labelDesc = Instance.new("TextLabel")
			labelDesc.Size = UDim2.new(1, 0, 0, 35)
			labelDesc.Position = UDim2.fromOffset(0, 50)
			labelDesc.BackgroundTransparency = 1
			labelDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
			labelDesc.TextSize = 11
			labelDesc.Font = Enum.Font.Gotham
			labelDesc.Text = "처음 스폰 시 한 가지 특화를 선택하여 능력치를 20% 강화할 수 있습니다.\n[키보드 1, 2, 3 키 입력으로도 선택 가능]"
			labelDesc.Parent = frameSpecSelect

			local frameButtons = Instance.new("Frame")
			frameButtons.Size = UDim2.new(0.9, 0, 0.55, 0)
			frameButtons.Position = UDim2.fromScale(0.05, 0.35)
			frameButtons.BackgroundTransparency = 1
			frameButtons.Parent = frameSpecSelect

			local listLayout = Instance.new("UIListLayout")
			listLayout.FillDirection = Enum.FillDirection.Horizontal
			listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			listLayout.Padding = UDim.new(0, 15)
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = frameButtons

			local tblButtonConfigs = {
				{
					Name = "Strength",
					Title = "힘 (Strength)",
					Desc = "• 투척 에너지 1.2배\n• 한계 중량 70kg (기본 50kg)\n• 무거운 물체 조작",
					Color = Color3.fromRGB(150, 45, 45),
					LayoutOrder = 1
				},
				{
					Name = "Agility",
					Title = "민첩 (Agility)",
					Desc = "• 이동 속도 +20%\n• 스피드/기동성 강화\n• 빠른 위치 선점",
					Color = Color3.fromRGB(45, 130, 95),
					LayoutOrder = 2
				},
				{
					Name = "Constitution",
					Title = "체력 (Health)",
					Desc = "• 최대 체력 +20%\n• 탱킹/생존력 특화\n• 맷집 대폭 강화",
					Color = Color3.fromRGB(150, 115, 30),
					LayoutOrder = 3
				}
			}

			local UserInputService = game:GetService("UserInputService")
			local connectionInput

			local function selectSpec(specName)
				if connectionInput then
					connectionInput:Disconnect()
					connectionInput = nil
				end
				-- 클라이언트 측 속성을 선제적으로 적용하여 서버 복제(Replication) 지연 동안 리셋 덮어쓰기 현상을 예방합니다.
				playerLocal:SetAttribute("Specialization", specName)

				eventSpecializationSelect:FireServer(specName)
				guiSpec:Destroy()

				-- 프레임 통제 주기와의 꼬임 현상을 확실히 해결하기 위해 task.defer로 조준 제어 시스템을 안전하게 활성화합니다.
				task.defer(function()
					set_default_aim_control_enabled(true)
				end)
			end

			guiSpec.Destroying:Connect(function()
				if connectionInput then
					connectionInput:Disconnect()
					connectionInput = nil
				end
			end)

			for _, config in ipairs(tblButtonConfigs) do
				local btn = Instance.new("TextButton")
				btn.Name = config.Name .. "Btn"
				btn.Size = UDim2.fromOffset(130, 130)
				btn.BackgroundColor3 = config.Color
				btn.BorderSizePixel = 0
				btn.Text = ""
				btn.LayoutOrder = config.LayoutOrder
				btn.Parent = frameButtons

				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 8)
				btnCorner.Parent = btn

				local strokeBtn = Instance.new("UIStroke")
				strokeBtn.Color = Color3.fromRGB(255, 255, 255)
				strokeBtn.Thickness = 1
				strokeBtn.Transparency = 0.6
				strokeBtn.Parent = btn

				local textTitle = Instance.new("TextLabel")
				textTitle.Size = UDim2.new(1, 0, 0, 30)
				textTitle.Position = UDim2.fromOffset(0, 10)
				textTitle.BackgroundTransparency = 1
				textTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
				textTitle.TextSize = 13
				textTitle.Font = Enum.Font.GothamBold
				textTitle.Text = config.Title
				textTitle.Parent = btn

				local textDesc = Instance.new("TextLabel")
				textDesc.Size = UDim2.new(0.9, 0, 0.7, -30)
				textDesc.Position = UDim2.fromScale(0.05, 0.3)
				textDesc.BackgroundTransparency = 1
				textDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
				textDesc.TextSize = 10
				textDesc.Font = Enum.Font.Gotham
				textDesc.Text = config.Desc
				textDesc.TextYAlignment = Enum.TextYAlignment.Top
				textDesc.TextXAlignment = Enum.TextXAlignment.Left
				textDesc.Parent = btn

				btn.MouseButton1Click:Connect(function()
					selectSpec(config.Name)
				end)
			end

			connectionInput = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.KeypadOne then
						selectSpec("Strength")
					elseif input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.KeypadTwo then
						selectSpec("Agility")
					elseif input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.KeypadThree then
						selectSpec("Constitution")
					end
				end
			end)
		end)
	end

	local guiCrosshair = Instance.new(ePhysical.SCREEN_GUI)
	guiCrosshair.Name = "PlayerCombatCrosshairGui"
	guiCrosshair.ResetOnSpawn = false
	guiCrosshair.Enabled = false
	guiCrosshair.Parent = playerLocal:WaitForChild("PlayerGui")

	-- HUD UI ScreenGui
	local guiHud = Instance.new(ePhysical.SCREEN_GUI)
	guiHud.Name = "PlayerCombatHudGui"
	guiHud.ResetOnSpawn = false
	guiHud.Enabled = true
	guiHud.Parent = playerLocal:WaitForChild("PlayerGui")

	-- 1. [좌하단 HP HUD] Health Container
	local frameHealthHud = Instance.new(ePhysical.FRAME)
	frameHealthHud.Name = "HealthHud"
	frameHealthHud.AnchorPoint = Vector2.new(0, 1)
	frameHealthHud.Size = UDim2.fromOffset(200, 48)
	frameHealthHud.Position = UDim2.new(0, 25, 1, -25) -- 좌하단 구석에서 마진
	frameHealthHud.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frameHealthHud.BackgroundTransparency = 0.25
	frameHealthHud.BorderSizePixel = 0
	frameHealthHud.Parent = guiHud

	local cornerHealthHud = Instance.new("UICorner")
	cornerHealthHud.CornerRadius = UDim.new(0, 8)
	cornerHealthHud.Parent = frameHealthHud

	local strokeHealthHud = Instance.new("UIStroke")
	strokeHealthHud.Color = Color3.fromRGB(65, 65, 80)
	strokeHealthHud.Thickness = 2
	strokeHealthHud.Parent = frameHealthHud

	-- Health Bar Background
	local frameHealthBack = Instance.new(ePhysical.FRAME)
	frameHealthBack.Name = "HealthBack"
	frameHealthBack.Position = UDim2.fromOffset(10, 8)
	frameHealthBack.Size = UDim2.fromOffset(180, 12)
	frameHealthBack.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
	frameHealthBack.BorderSizePixel = 0
	frameHealthBack.Parent = frameHealthHud

	local cornerHealthBack = Instance.new("UICorner")
	cornerHealthBack.CornerRadius = UDim.new(0, 4)
	cornerHealthBack.Parent = frameHealthBack

	-- Health Bar Fill
	local frameHealthFill = Instance.new(ePhysical.FRAME)
	frameHealthFill.Name = "HealthFill"
	frameHealthFill.Size = UDim2.fromScale(1, 1)
	frameHealthFill.BackgroundColor3 = Color3.fromRGB(225, 45, 45)
	frameHealthFill.BorderSizePixel = 0
	frameHealthFill.Parent = frameHealthBack

	local cornerHealthFill = Instance.new("UICorner")
	cornerHealthFill.CornerRadius = UDim.new(0, 4)
	cornerHealthFill.Parent = frameHealthFill

	-- Health Text Label
	local labelHealth = Instance.new("TextLabel")
	labelHealth.Name = "HealthLabel"
	labelHealth.Position = UDim2.fromOffset(10, 24)
	labelHealth.Size = UDim2.fromOffset(180, 18)
	labelHealth.BackgroundTransparency = 1
	labelHealth.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelHealth.TextSize = 11
	labelHealth.Font = Enum.Font.GothamBold
	labelHealth.TextXAlignment = Enum.TextXAlignment.Left
	labelHealth.Text = "HP: 100 / 100"
	labelHealth.Parent = frameHealthHud


	-- 2. [우하단 무기 HUD] Weapon Container
	local frameWeaponHud = Instance.new(ePhysical.FRAME)
	frameWeaponHud.Name = "WeaponHud"
	frameWeaponHud.AnchorPoint = Vector2.new(1, 1)
	frameWeaponHud.Size = UDim2.fromOffset(280, 72)
	frameWeaponHud.Position = UDim2.new(1, -25, 1, -25) -- 우하단 구석에서 마진
	frameWeaponHud.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frameWeaponHud.BackgroundTransparency = 0.25
	frameWeaponHud.BorderSizePixel = 0
	frameWeaponHud.Parent = guiHud

	local cornerWeaponHud = Instance.new("UICorner")
	cornerWeaponHud.CornerRadius = UDim.new(0, 8)
	cornerWeaponHud.Parent = frameWeaponHud

	local strokeWeaponHud = Instance.new("UIStroke")
	strokeWeaponHud.Color = Color3.fromRGB(65, 65, 80)
	strokeWeaponHud.Thickness = 2
	strokeWeaponHud.Parent = frameWeaponHud

	-- Weapon Name Label
	local labelWeaponName = Instance.new("TextLabel")
	labelWeaponName.Name = "WeaponName"
	labelWeaponName.Position = UDim2.fromOffset(12, 6)
	labelWeaponName.Size = UDim2.fromOffset(256, 16)
	labelWeaponName.BackgroundTransparency = 1
	labelWeaponName.TextColor3 = Color3.fromRGB(240, 240, 245)
	labelWeaponName.TextSize = 12
	labelWeaponName.Font = Enum.Font.GothamBold
	labelWeaponName.TextXAlignment = Enum.TextXAlignment.Left
	labelWeaponName.Text = "장착: 주먹"
	labelWeaponName.Parent = frameWeaponHud

	-- Weapon Stats Label
	local labelWeaponStats = Instance.new("TextLabel")
	labelWeaponStats.Name = "WeaponStats"
	labelWeaponStats.Position = UDim2.fromOffset(12, 24)
	labelWeaponStats.Size = UDim2.fromOffset(256, 42)
	labelWeaponStats.BackgroundTransparency = 1
	labelWeaponStats.TextColor3 = Color3.fromRGB(170, 170, 185)
	labelWeaponStats.TextSize = 10
	labelWeaponStats.Font = Enum.Font.GothamMedium
	labelWeaponStats.TextXAlignment = Enum.TextXAlignment.Left
	labelWeaponStats.TextYAlignment = Enum.TextYAlignment.Top
	labelWeaponStats.TextWrapped = true
	labelWeaponStats.Text = "데미지: 10 | 재질: 없음\n무게: - | 콜리전: -"
	labelWeaponStats.Parent = frameWeaponHud

	local frameFieldPickupPrompt = Instance.new(ePhysical.FRAME)
	frameFieldPickupPrompt.Name = "FieldPickupPromptHud"
	frameFieldPickupPrompt.AnchorPoint = Vector2.new(1, 1)
	frameFieldPickupPrompt.Size = UDim2.fromOffset(FIELD_PICKUP_PROMPT_WIDTH, FIELD_PICKUP_PROMPT_HEIGHT)
	frameFieldPickupPrompt.Position = UDim2.new(1, -FIELD_PICKUP_PROMPT_RIGHT_OFFSET, 1, -FIELD_PICKUP_PROMPT_BOTTOM_OFFSET)
	frameFieldPickupPrompt.BackgroundColor3 = Color3.fromRGB(14, 17, 22)
	frameFieldPickupPrompt.BackgroundTransparency = 0.16
	frameFieldPickupPrompt.BorderSizePixel = 0
	frameFieldPickupPrompt.Visible = false
	frameFieldPickupPrompt.Parent = guiHud

	local cornerFieldPickupPrompt = Instance.new("UICorner")
	cornerFieldPickupPrompt.CornerRadius = UDim.new(0, 8)
	cornerFieldPickupPrompt.Parent = frameFieldPickupPrompt

	local strokeFieldPickupPrompt = Instance.new("UIStroke")
	strokeFieldPickupPrompt.Color = Color3.fromRGB(92, 112, 132)
	strokeFieldPickupPrompt.Thickness = 2
	strokeFieldPickupPrompt.Transparency = 0.15
	strokeFieldPickupPrompt.Parent = frameFieldPickupPrompt

	local labelFieldPickupKey = Instance.new(ePhysical.TEXT_LABEL)
	labelFieldPickupKey.Name = "FieldPickupKey"
	labelFieldPickupKey.Position = UDim2.fromOffset(10, 8)
	labelFieldPickupKey.Size = UDim2.fromOffset(34, 28)
	labelFieldPickupKey.BackgroundColor3 = Color3.fromRGB(225, 230, 238)
	labelFieldPickupKey.BackgroundTransparency = 0.05
	labelFieldPickupKey.BorderSizePixel = 0
	labelFieldPickupKey.TextColor3 = Color3.fromRGB(16, 19, 24)
	labelFieldPickupKey.TextSize = 15
	labelFieldPickupKey.Font = Enum.Font.GothamBold
	labelFieldPickupKey.Text = "E"
	labelFieldPickupKey.Parent = frameFieldPickupPrompt

	local cornerFieldPickupKey = Instance.new("UICorner")
	cornerFieldPickupKey.CornerRadius = UDim.new(0, 6)
	cornerFieldPickupKey.Parent = labelFieldPickupKey

	local labelFieldPickupName = Instance.new(ePhysical.TEXT_LABEL)
	labelFieldPickupName.Name = "FieldPickupName"
	labelFieldPickupName.Position = UDim2.fromOffset(54, 6)
	labelFieldPickupName.Size = UDim2.fromOffset(220, 17)
	labelFieldPickupName.BackgroundTransparency = 1
	labelFieldPickupName.TextColor3 = Color3.fromRGB(245, 245, 245)
	labelFieldPickupName.TextSize = 12
	labelFieldPickupName.Font = Enum.Font.GothamBold
	labelFieldPickupName.TextXAlignment = Enum.TextXAlignment.Left
	labelFieldPickupName.TextTruncate = Enum.TextTruncate.AtEnd
	labelFieldPickupName.Text = "전장 아이템"
	labelFieldPickupName.Parent = frameFieldPickupPrompt

	local labelFieldPickupAction = Instance.new(ePhysical.TEXT_LABEL)
	labelFieldPickupAction.Name = "FieldPickupAction"
	labelFieldPickupAction.Position = UDim2.fromOffset(54, 23)
	labelFieldPickupAction.Size = UDim2.fromOffset(220, 14)
	labelFieldPickupAction.BackgroundTransparency = 1
	labelFieldPickupAction.TextColor3 = Color3.fromRGB(175, 190, 205)
	labelFieldPickupAction.TextSize = 10
	labelFieldPickupAction.Font = Enum.Font.GothamMedium
	labelFieldPickupAction.TextXAlignment = Enum.TextXAlignment.Left
	labelFieldPickupAction.TextTruncate = Enum.TextTruncate.AtEnd
	labelFieldPickupAction.Text = "줍기"
	labelFieldPickupAction.Parent = frameFieldPickupPrompt

	local frameBrickGuide = Instance.new(ePhysical.FRAME)
	frameBrickGuide.Name = "BrickBuildGuide"
	frameBrickGuide.AnchorPoint = Vector2.new(0.5, 1)
	frameBrickGuide.Size = UDim2.fromOffset(540, 38)
	frameBrickGuide.Position = UDim2.new(0.5, 0, 1, -94)
	frameBrickGuide.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
	frameBrickGuide.BackgroundTransparency = 0.18
	frameBrickGuide.BorderSizePixel = 0
	frameBrickGuide.Visible = false
	frameBrickGuide.Parent = guiHud

	local cornerBrickGuide = Instance.new("UICorner")
	cornerBrickGuide.CornerRadius = UDim.new(0, 8)
	cornerBrickGuide.Parent = frameBrickGuide

	local strokeBrickGuide = Instance.new("UIStroke")
	strokeBrickGuide.Color = Color3.fromRGB(95, 110, 125)
	strokeBrickGuide.Thickness = 2
	strokeBrickGuide.Transparency = 0.2
	strokeBrickGuide.Parent = frameBrickGuide

	local labelBrickGuide = Instance.new(ePhysical.TEXT_LABEL)
	labelBrickGuide.Name = "BrickBuildGuideText"
	labelBrickGuide.Size = UDim2.new(1, -20, 1, 0)
	labelBrickGuide.Position = UDim2.fromOffset(10, 0)
	labelBrickGuide.BackgroundTransparency = 1
	labelBrickGuide.TextColor3 = Color3.fromRGB(245, 245, 245)
	labelBrickGuide.TextSize = 13
	labelBrickGuide.TextScaled = true
	labelBrickGuide.Font = Enum.Font.GothamBold
	labelBrickGuide.TextXAlignment = Enum.TextXAlignment.Center
	labelBrickGuide.Text = ""
	labelBrickGuide.Parent = frameBrickGuide

	local constraintBrickGuideText = Instance.new("UITextSizeConstraint")
	constraintBrickGuideText.MinTextSize = 9
	constraintBrickGuideText.MaxTextSize = 13
	constraintBrickGuideText.Parent = labelBrickGuide

	local partBrickPlacementPreview = Instance.new(ePhysical.PART)
	partBrickPlacementPreview.Name = "BrickPlacementPreview"
	partBrickPlacementPreview.Anchored = true
	partBrickPlacementPreview.CanCollide = false
	partBrickPlacementPreview.CanTouch = false
	partBrickPlacementPreview.CanQuery = false
	partBrickPlacementPreview.CastShadow = false
	partBrickPlacementPreview.Material = Enum.Material.Neon
	partBrickPlacementPreview.Color = BRICK_PLACE_PREVIEW_VALID_COLOR
	partBrickPlacementPreview.Transparency = 0.62
	partBrickPlacementPreview.Parent = nil

	local selectionBrickPlacementPreview = Instance.new("SelectionBox")
	selectionBrickPlacementPreview.Name = "BrickPlacementPreviewOutline"
	selectionBrickPlacementPreview.Adornee = partBrickPlacementPreview
	selectionBrickPlacementPreview.Color3 = BRICK_PLACE_PREVIEW_VALID_OUTLINE_COLOR
	selectionBrickPlacementPreview.LineThickness = 0.05
	selectionBrickPlacementPreview.SurfaceTransparency = 1
	selectionBrickPlacementPreview.Parent = partBrickPlacementPreview

	local guiRespawnCountdown = Instance.new(ePhysical.SCREEN_GUI)
	guiRespawnCountdown.Name = "PlayerRespawnCountdownGui"
	guiRespawnCountdown.ResetOnSpawn = false
	guiRespawnCountdown.Enabled = false
	guiRespawnCountdown.Parent = playerLocal:WaitForChild("PlayerGui")

	local frameRespawnCountdown = Instance.new(ePhysical.FRAME)
	frameRespawnCountdown.Name = "RespawnCountdownFrame"
	frameRespawnCountdown.AnchorPoint = Vector2.new(0.5, 0.5)
	frameRespawnCountdown.Size = UDim2.fromOffset(180, 150)
	frameRespawnCountdown.Position = UDim2.fromScale(0.5, 0.45)
	frameRespawnCountdown.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
	frameRespawnCountdown.BackgroundTransparency = 0.25
	frameRespawnCountdown.BorderSizePixel = 0
	frameRespawnCountdown.Parent = guiRespawnCountdown

	local cornerRespawnCountdown = Instance.new("UICorner")
	cornerRespawnCountdown.CornerRadius = UDim.new(0, 8)
	cornerRespawnCountdown.Parent = frameRespawnCountdown

	local strokeRespawnCountdown = Instance.new("UIStroke")
	strokeRespawnCountdown.Color = Color3.fromRGB(220, 220, 230)
	strokeRespawnCountdown.Thickness = 2
	strokeRespawnCountdown.Transparency = 0.35
	strokeRespawnCountdown.Parent = frameRespawnCountdown

	local labelRespawnTitle = Instance.new(ePhysical.TEXT_LABEL)
	labelRespawnTitle.Name = "RespawnTitle"
	labelRespawnTitle.Size = UDim2.new(1, 0, 0, 28)
	labelRespawnTitle.Position = UDim2.fromOffset(0, 18)
	labelRespawnTitle.BackgroundTransparency = 1
	labelRespawnTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
	labelRespawnTitle.TextSize = 15
	labelRespawnTitle.Font = Enum.Font.GothamBold
	labelRespawnTitle.Text = "부활까지"
	labelRespawnTitle.Parent = frameRespawnCountdown

	local labelRespawnNumber = Instance.new(ePhysical.TEXT_LABEL)
	labelRespawnNumber.Name = "RespawnNumber"
	labelRespawnNumber.Size = UDim2.new(1, 0, 0, 82)
	labelRespawnNumber.Position = UDim2.fromOffset(0, 45)
	labelRespawnNumber.BackgroundTransparency = 1
	labelRespawnNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelRespawnNumber.TextSize = 72
	labelRespawnNumber.Font = Enum.Font.GothamBlack
	labelRespawnNumber.Text = tostring(RESPAWN_COUNTDOWN_SECONDS)
	labelRespawnNumber.Parent = frameRespawnCountdown

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
	frameChargeBack.Position = UDim2.new(0.5, 0, 1, 8)
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
			or toolTarget:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == eLogical.STACK_BRICK
			or toolTarget.Name:sub(1, #eLogical.THROWING_STONE) == eLogical.THROWING_STONE
	end

	local function find_field_item_tool_from_prompt(promptPickup)
		local instanceCurrent = promptPickup and promptPickup.Parent
		while instanceCurrent do
			if instanceCurrent:IsA(ePhysical.TOOL) and instanceCurrent:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) then
				return instanceCurrent
			end

			instanceCurrent = instanceCurrent.Parent
		end

		return nil
	end

	local function get_field_pickup_prompt_key_text(promptPickup, enumInputType)
		local enumKeyCode = promptPickup and promptPickup.KeyboardKeyCode
		if enumInputType == Enum.ProximityPromptInputType.Gamepad and promptPickup then
			enumKeyCode = promptPickup.GamepadKeyCode
		end

		if enumKeyCode and enumKeyCode ~= Enum.KeyCode.Unknown then
			return enumKeyCode.Name
		end

		return "E"
	end

	local function show_field_pickup_prompt(promptPickup, enumInputType)
		local toolPickup = find_field_item_tool_from_prompt(promptPickup)
		if not toolPickup then
			return
		end

		local strObjectText = promptPickup.ObjectText
		if type(strObjectText) ~= "string" or strObjectText == "" then
			strObjectText = toolPickup:GetAttribute(eAttrKey.FIELD_ITEM_DISPLAY_NAME) or toolPickup.Name
		end

		local strActionText = promptPickup.ActionText
		if type(strActionText) ~= "string" or strActionText == "" then
			strActionText = "줍기"
		end

		promptActiveFieldPickup = promptPickup
		labelFieldPickupKey.Text = get_field_pickup_prompt_key_text(promptPickup, enumInputType)
		labelFieldPickupName.Text = strObjectText
		labelFieldPickupAction.Text = strActionText
		frameFieldPickupPrompt.Visible = true
	end

	local function hide_field_pickup_prompt(promptPickup)
		if promptPickup and promptPickup ~= promptActiveFieldPickup then
			return
		end

		promptActiveFieldPickup = nil
		frameFieldPickupPrompt.Visible = false
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

	local function get_camera_aim_ray()
		local cameraCurrent = svcWorkspace.CurrentCamera
		if cameraCurrent then
			return cameraCurrent.CFrame.Position, cameraCurrent.CFrame.LookVector
		end

		local unitRayMouse = mousePlayer.UnitRay
		return unitRayMouse.Origin, unitRayMouse.Direction
	end

	local function get_character_root()
		local modelCharacter = playerLocal.Character
		return modelCharacter and modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
	end

	local function get_equipped_placeable_tool()
		local modelCharacter = playerLocal.Character
		if not modelCharacter then
			return nil
		end

		for _, instanceChild in ipairs(modelCharacter:GetChildren()) do
			if instanceChild:IsA(ePhysical.TOOL) and is_throwing_stone(instanceChild) then
				return instanceChild
			end
		end

		return nil
	end

	local function create_brick_placement_rotation(partHumanoidRoot, vectorRayDirection)
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

	local function create_brick_placement_cframe(vectorPosition, cframeRotation)
		return CFrame.lookAt(vectorPosition, vectorPosition + cframeRotation.LookVector, cframeRotation.UpVector)
	end

	local function create_brick_preview_raycast_params(toolPlaceable)
		local tblRaycastFilter = { partBrickPlacementPreview }
		if playerLocal.Character then
			table.insert(tblRaycastFilter, playerLocal.Character)
		end
		if toolPlaceable then
			table.insert(tblRaycastFilter, toolPlaceable)
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = tblRaycastFilter
		raycastParams.IgnoreWater = true
		return raycastParams
	end

	local function create_brick_preview_overlap_params(toolPlaceable)
		local tblOverlapFilter = { partBrickPlacementPreview }
		if playerLocal.Character then
			table.insert(tblOverlapFilter, playerLocal.Character)
		end
		if toolPlaceable then
			table.insert(tblOverlapFilter, toolPlaceable)
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = tblOverlapFilter
		return overlapParams
	end

	local function create_brick_preview_overlap_size(vectorPreviewSize)
		return Vector3.new(
			math.max(BRICK_PLACE_OVERLAP_MIN_SIZE, vectorPreviewSize.X * BRICK_PLACE_OVERLAP_SCALE_XZ),
			math.max(BRICK_PLACE_OVERLAP_MIN_SIZE, vectorPreviewSize.Y * BRICK_PLACE_OVERLAP_SCALE_Y),
			math.max(BRICK_PLACE_OVERLAP_MIN_SIZE, vectorPreviewSize.Z * BRICK_PLACE_OVERLAP_SCALE_XZ)
		)
	end

	local function is_brick_preview_overlap_part(partCandidate, toolPlaceable)
		if not partCandidate or not partCandidate:IsA(ePhysical.BASE_PART) then
			return false
		end
		if not partCandidate.CanCollide then
			return false
		end
		if partCandidate == partBrickPlacementPreview or partCandidate:IsDescendantOf(partBrickPlacementPreview) then
			return false
		end
		if playerLocal.Character and partCandidate:IsDescendantOf(playerLocal.Character) then
			return false
		end
		if toolPlaceable and partCandidate:IsDescendantOf(toolPlaceable) then
			return false
		end

		return true
	end

	local function is_brick_preview_blocked(cframePreview, vectorPreviewSize, toolPlaceable)
		local overlapParams = create_brick_preview_overlap_params(toolPlaceable)
		local vectorOverlapSize = create_brick_preview_overlap_size(vectorPreviewSize)
		local tblOverlapParts = svcWorkspace:GetPartBoundsInBox(cframePreview, vectorOverlapSize, overlapParams)

		for _, partCandidate in ipairs(tblOverlapParts) do
			if is_brick_preview_overlap_part(partCandidate, toolPlaceable) then
				return true
			end
		end

		return false
	end

	local function set_brick_preview_blocked(boolBlocked)
		boolBuildPlacementPreviewBlocked = boolBlocked == true
		if boolBuildPlacementPreviewBlocked then
			partBrickPlacementPreview.Color = BRICK_PLACE_PREVIEW_BLOCKED_COLOR
			selectionBrickPlacementPreview.Color3 = BRICK_PLACE_PREVIEW_BLOCKED_OUTLINE_COLOR
		else
			partBrickPlacementPreview.Color = BRICK_PLACE_PREVIEW_VALID_COLOR
			selectionBrickPlacementPreview.Color3 = BRICK_PLACE_PREVIEW_VALID_OUTLINE_COLOR
		end
	end

	local function raycast_brick_preview_surface(partHumanoidRoot, toolPlaceable, vectorRayOrigin, vectorRayDirection)
		local vectorOrigin = partHumanoidRoot.Position + Vector3.new(0, 2, 0)
		local vectorDirection = partHumanoidRoot.CFrame.LookVector * BRICK_PLACE_MAX_DISTANCE + Vector3.new(0, -8, 0)

		if typeof(vectorRayOrigin) == "Vector3" and typeof(vectorRayDirection) == "Vector3" and vectorRayDirection.Magnitude > 0.01 then
			if (vectorRayOrigin - partHumanoidRoot.Position).Magnitude <= 90 then
				vectorOrigin = vectorRayOrigin
			end
			vectorDirection = vectorRayDirection.Unit * BRICK_PLACE_MAX_DISTANCE
		end

		local raycastParams = create_brick_preview_raycast_params(toolPlaceable)
		local raycastResult = svcWorkspace:Raycast(vectorOrigin, vectorDirection, raycastParams)
		if raycastResult then
			return raycastResult
		end

		local vectorFallbackStart = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 5 + Vector3.new(0, 8, 0)
		return svcWorkspace:Raycast(vectorFallbackStart, Vector3.new(0, -40, 0), raycastParams)
	end

	local function raycast_brick_preview_support(toolPlaceable, vectorTargetPosition)
		local raycastParams = create_brick_preview_raycast_params(toolPlaceable)
		local vectorOrigin = Vector3.new(
			vectorTargetPosition.X,
			vectorTargetPosition.Y + BRICK_PLACE_SUPPORT_RAY_HEIGHT,
			vectorTargetPosition.Z
		)
		return svcWorkspace:Raycast(
			vectorOrigin,
			Vector3.new(0, -BRICK_PLACE_SUPPORT_RAY_DISTANCE, 0),
			raycastParams
		)
	end

	local function resolve_brick_preview_support(toolPlaceable, raycastResult, vectorFallbackPosition)
		local vectorTargetPosition = raycastResult and raycastResult.Position or vectorFallbackPosition
		if not vectorTargetPosition then
			return nil
		end

		if raycastResult and raycastResult.Normal.Y >= BRICK_PLACE_MIN_SUPPORT_NORMAL_Y then
			return raycastResult, vectorTargetPosition
		end

		local raycastSupport = raycast_brick_preview_support(toolPlaceable, vectorTargetPosition)
		if raycastSupport and raycastSupport.Normal.Y >= BRICK_PLACE_MIN_SUPPORT_NORMAL_Y then
			return raycastSupport, vectorTargetPosition
		end

		return nil, vectorTargetPosition
	end

	local function get_placeable_tool_preview_size(toolPlaceable)
		local partHandle = toolPlaceable and toolPlaceable:FindFirstChild(eLogical.RESERVED_HANDLE)
		if not partHandle or not partHandle:IsA(ePhysical.BASE_PART) then
			return nil
		end

		return partHandle.Size
	end

	local function get_build_placement_endpoint_snap()
		return svcUserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or svcUserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end

	local function set_brick_preview_visible(boolVisible)
		if boolVisible then
			if not partBrickPlacementPreview.Parent then
				partBrickPlacementPreview.Parent = svcWorkspace
			end
		else
			partBrickPlacementPreview.Parent = nil
			set_brick_preview_blocked(false)
		end
	end

	local function reset_build_placement_preview()
		boolBuildPlacementPreviewRequested = false
		intBuildPlacementRotationQuarterTurns = 0
		set_brick_preview_visible(false)
	end

	local function update_brick_placement_preview()
		if not boolBuildPlacementPreviewRequested then
			set_brick_preview_visible(false)
			return
		end

		local modelCharacter = playerLocal.Character
		local partHumanoidRoot = get_character_root()
		local toolPlaceable = get_equipped_placeable_tool()
		local partHandle = toolPlaceable and toolPlaceable:FindFirstChild(eLogical.RESERVED_HANDLE)
		if not modelCharacter or not partHumanoidRoot or not partHandle or not partHandle:IsA(ePhysical.BASE_PART) then
			reset_build_placement_preview()
			return
		end

		local vectorRayOrigin, vectorRayDirection = get_camera_aim_ray()
		local cframePreview = FieldPlacementRules.calculatePlacementCFrame(
			modelCharacter,
			toolPlaceable,
			partHumanoidRoot,
			partHandle,
			vectorRayOrigin,
			vectorRayDirection,
			{
				RotationQuarterTurns = intBuildPlacementRotationQuarterTurns,
				EndpointSnap = get_build_placement_endpoint_snap(),
				ExtraIgnore = partBrickPlacementPreview,
			}
		)
		partBrickPlacementPreview.Size = partHandle.Size
		partBrickPlacementPreview.CFrame = cframePreview
		set_brick_preview_blocked(FieldPlacementRules.isPlacementBlocked(modelCharacter, toolPlaceable, cframePreview, partHandle.Size, partBrickPlacementPreview))
		set_brick_preview_visible(true)
	end

	local function fire_carried_block_place()
		local eventDropCarriedBlock = svcReplicatedStorage:FindFirstChild(eLogical.DROP_CARRIED_BLOCK)
		if not eventDropCarriedBlock then
			return
		end

		local vectorRayOrigin, vectorRayDirection = get_camera_aim_ray()
		eventDropCarriedBlock:FireServer(vectorRayOrigin, vectorRayDirection, intBuildPlacementRotationQuarterTurns, get_build_placement_endpoint_snap())
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

	local function find_character_motor(modelCharacter, tblMotorNames, tblPart1Names)
		if not modelCharacter then return nil end

		for _, instanceDescendant in ipairs(modelCharacter:GetDescendants()) do
			if instanceDescendant:IsA(ePhysical.MOTOR_6D) then
				for _, strMotorName in ipairs(tblMotorNames) do
					if instanceDescendant.Name == strMotorName then
						return instanceDescendant
					end
				end

				if instanceDescendant.Part1 then
					for _, strPartName in ipairs(tblPart1Names) do
						if instanceDescendant.Part1.Name == strPartName then
							return instanceDescendant
						end
					end
				end
			end
		end

		return nil
	end

	local function cache_fist_action_motors(modelCharacter)
		if motorFistRightShoulder and motorFistRightShoulder.Parent then return end

		motorFistRightShoulder = find_character_motor(modelCharacter, {"RightShoulder", "Right Shoulder"}, {"RightUpperArm", "Right Arm"})
		motorFistRightElbow = find_character_motor(modelCharacter, {"RightElbow", "Right Elbow"}, {"RightLowerArm"})
		cframeFistRightShoulderOriginalC0 = motorFistRightShoulder and motorFistRightShoulder.C0 or nil
		cframeFistRightElbowOriginalC0 = motorFistRightElbow and motorFistRightElbow.C0 or nil
	end

	local function reset_fist_action_visuals()
		if motorFistRightShoulder and motorFistRightShoulder.Parent and cframeFistRightShoulderOriginalC0 then
			motorFistRightShoulder.C0 = cframeFistRightShoulderOriginalC0
			motorFistRightShoulder.Transform = CFrame.new()
		end

		if motorFistRightElbow and motorFistRightElbow.Parent and cframeFistRightElbowOriginalC0 then
			motorFistRightElbow.C0 = cframeFistRightElbowOriginalC0
			motorFistRightElbow.Transform = CFrame.new()
		end

		motorFistRightShoulder = nil
		motorFistRightElbow = nil
		cframeFistRightShoulderOriginalC0 = nil
		cframeFistRightElbowOriginalC0 = nil
	end

	local function get_fist_punch_joint_offsets(numberFistProgress)
		if numberFistProgress < 0.32 then
			local numberWindup = numberFistProgress / 0.32
			return CFrame.Angles(math.rad(60) * numberWindup, math.rad(28) * numberWindup, math.rad(80) * numberWindup),
				CFrame.Angles(math.rad(-75) * numberWindup, 0, 0)
		end

		local numberThrust = math.clamp((numberFistProgress - 0.32) / 0.28, 0, 1)
		local numberRecover = math.clamp((numberFistProgress - 0.6) / 0.4, 0, 1)
		local numberPunchPower = math.sin(numberThrust * math.pi * 0.5) * (1 - numberRecover)
		return CFrame.Angles(math.rad(-150) * numberPunchPower, math.rad(-20) * numberPunchPower, math.rad(-55) * numberPunchPower)
				* CFrame.new(0, 0, -0.35 * numberPunchPower),
			CFrame.Angles(math.rad(70) * numberPunchPower, 0, 0)
	end

	local function update_fist_action_visuals()
		local numberFistProgress = get_fist_action_progress()
		if not numberFistProgress then
			numberFistActionStartTime = nil
			reset_fist_action_visuals()
			return
		end

		local modelCharacter = playerLocal.Character
		cache_fist_action_motors(modelCharacter)
		local cframeShoulderOffset, cframeElbowOffset = get_fist_punch_joint_offsets(numberFistProgress)
		if motorFistRightShoulder and cframeFistRightShoulderOriginalC0 then
			motorFistRightShoulder.C0 = cframeFistRightShoulderOriginalC0 * cframeShoulderOffset
			motorFistRightShoulder.Transform = cframeShoulderOffset
		end

		if motorFistRightElbow and cframeFistRightElbowOriginalC0 then
			motorFistRightElbow.C0 = cframeFistRightElbowOriginalC0 * cframeElbowOffset
			motorFistRightElbow.Transform = cframeElbowOffset
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

	function set_default_aim_control_enabled(boolEnabled)
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

		-- 특화 선택이 이미 되어 있다면 즉시 조준 컨트롤을 활성화하고,
		-- 그렇지 않은 최초 진입 상태라면 UI를 통해 특화를 고를 때까지 비활성화 상태(기본 마우스/카메라)를 유지합니다.
		if playerLocal:GetAttribute("Specialization") then
			set_default_aim_control_enabled(true)
		else
			set_default_aim_control_enabled(false)
		end
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

		numberLastFistAttackTime = numberNow
		start_fist_action_visuals()
		local eventFistAttack = svcReplicatedStorage:FindFirstChild(eLogical.FIST_ATTACK)
		if eventFistAttack then
			eventFistAttack:FireServer(get_camera_aim_position())
		end
	end

	local function is_magic_staff(toolTarget)
		if not toolTarget:IsA(ePhysical.TOOL) then return false end

		return toolTarget:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == eLogical.MAGIC_STAFF
			or toolTarget.Name:sub(1, #eLogical.MAGIC_STAFF) == eLogical.MAGIC_STAFF
	end

	local function connect_magic_staff(toolMagicStaff)
		if tblConnectedTools[toolMagicStaff] or not is_magic_staff(toolMagicStaff) then return end

		tblConnectedTools[toolMagicStaff] = true
		toolMagicStaff.Activated:Connect(function()
			local eventCastMagic = svcReplicatedStorage:FindFirstChild(eLogical.CAST_MAGIC)
			if not eventCastMagic then return end

			eventCastMagic:FireServer(get_camera_aim_position())
		end)
	end

	local function get_stone_mass(toolStone)
		local numberMassKg = toolStone:GetAttribute("MassKg")
		if type(numberMassKg) == "number" then
			return numberMassKg
		end

		local handle = toolStone:FindFirstChild("Handle")
		local size = handle and handle.Size or Vector3.new(1.2, 1.2, 1.2)
		local realMaterial = toolStone:GetAttribute("RealMaterial") or "Rock"
		
		local Common = script.Parent
		local ThrowingStone = require(Common:WaitForChild("ThrowingStone"))
		local profile = ThrowingStone.getThrowingStoneMaterialProfile(realMaterial)
		local density = profile and profile.Density or 2700

		return StudentConfig.calculateEquipmentMassKg(size, density)
	end

	local function get_tool_mass_text(toolTarget)
		if is_throwing_stone(toolTarget) then
			return string.format("%.1fkg", get_stone_mass(toolTarget))
		end

		local numberMassKg = toolTarget:GetAttribute("MassKg")
		if type(numberMassKg) == "number" then
			return string.format("%.1fkg", numberMassKg)
		end

		return "-"
	end

	local function get_tool_collision_mode_text(toolTarget)
		local strCollisionShapeMode = toolTarget:GetAttribute("CollisionShapeMode")
		local strCollisionShapeModeResolved = toolTarget:GetAttribute("CollisionShapeModeResolved")

		if type(strCollisionShapeMode) == "string" and type(strCollisionShapeModeResolved) == "string" and strCollisionShapeMode ~= strCollisionShapeModeResolved then
			return strCollisionShapeMode .. "->" .. strCollisionShapeModeResolved
		end

		if type(strCollisionShapeModeResolved) == "string" and strCollisionShapeModeResolved ~= "" then
			return strCollisionShapeModeResolved
		end

		if type(strCollisionShapeMode) == "string" and strCollisionShapeMode ~= "" then
			return strCollisionShapeMode
		end

		return "-"
	end

	local function show_warning_notification(textMessage)
		local playerGui = playerLocal:FindFirstChild("PlayerGui")
		if not playerGui then return end

		local guiNotif = Instance.new("ScreenGui")
		guiNotif.Name = "WeightWarningGui"
		guiNotif.ResetOnSpawn = true
		guiNotif.Parent = playerGui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(360, 50)
		frame.Position = UDim2.new(0.5, -180, 0.25, 0)
		frame.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
		frame.BackgroundTransparency = 0.1
		frame.BorderSizePixel = 0
		frame.Parent = guiNotif

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(180, 45, 45)
		stroke.Thickness = 2
		stroke.Parent = frame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = frame

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 100, 100)
		label.TextSize = 13
		label.Font = Enum.Font.GothamBold
		label.Text = textMessage
		label.Parent = frame

		task.delay(2.2, function()
			for i = 1, 10 do
				task.wait(0.04)
				if frame then
					frame.BackgroundTransparency = 0.1 + (i * 0.09)
					stroke.Transparency = i * 0.1
					label.TextTransparency = i * 0.1
				end
			end
			guiNotif:Destroy()
		end)
	end

	local function connect_throwing_stone(toolThrowingStone)
		if tblConnectedTools[toolThrowingStone] or not is_throwing_stone(toolThrowingStone) then return end

		tblConnectedTools[toolThrowingStone] = true

		toolThrowingStone.Equipped:Connect(function()
			local mass = get_stone_mass(toolThrowingStone)
			local spec = playerLocal:GetAttribute("Specialization") or "None"
			local maxWeight = (spec == "Strength") and 70 or 50

			if mass > maxWeight then
				task.spawn(function()
					local humanoid = playerLocal.Character and playerLocal.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid:UnequipTools()
					end
				end)
				show_warning_notification(string.format("너무 무거워서 들 수 없습니다!\n무게: %.1fkg (한계: %dkg)", mass, maxWeight))
				return
			end

			toolActiveThrowingStone = toolThrowingStone
			set_default_aim_control_enabled(true)
			set_throw_charge_visible(true)
		end)

		toolThrowingStone.Unequipped:Connect(function()
			if toolActiveThrowingStone == toolThrowingStone then
				toolActiveThrowingStone = nil
				set_throw_charge_visible(false)
			end
			reset_build_placement_preview()
		end)

		toolThrowingStone.AncestryChanged:Connect(function()
			local modelCharacter = playerLocal.Character
			if toolActiveThrowingStone == toolThrowingStone and modelCharacter and not toolThrowingStone:IsDescendantOf(modelCharacter) then
				toolActiveThrowingStone = nil
				set_throw_charge_visible(false)
			end
			if modelCharacter and not toolThrowingStone:IsDescendantOf(modelCharacter) then
				reset_build_placement_preview()
			end
		end)
	end

	local function connect_pickup_sensor(toolPickup)
		if not toolPickup:IsA("Tool") then return end

		local function check_and_notify_weight(player)
			if player ~= playerLocal then return end

			local mass = get_stone_mass(toolPickup)
			local spec = playerLocal:GetAttribute("Specialization") or "None"
			local maxWeight = (spec == "Strength") and 70 or 50

			if mass > 70 then
				show_warning_notification(string.format("너무 무거워서 들 수 없습니다!\n무게: %.1fkg (절대 한계: 70kg)", mass))
			elseif mass > maxWeight then
				show_warning_notification(string.format("힘 특화가 필요하여 들 수 없습니다!\n무게: %.1fkg (현재 한계: %dkg)", mass, maxWeight))
			end
		end

		task.spawn(function()
			local partHandle = toolPickup:WaitForChild("Handle", 5)
			if partHandle then
				local clickDetector = partHandle:WaitForChild("ClickDetector", 3)
				if clickDetector then
					clickDetector.MouseClick:Connect(check_and_notify_weight)
				end
				local proximityPrompt = partHandle:WaitForChild("ProximityPrompt", 3)
				if proximityPrompt then
					proximityPrompt.Triggered:Connect(check_and_notify_weight)
				end
			end
		end)
	end

	local function watch_container(instanceContainer)
		for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
			connect_throwing_stone(instanceChild)
			connect_magic_staff(instanceChild)
			connect_pickup_sensor(instanceChild)
		end

		instanceContainer.ChildAdded:Connect(function(instanceChild)
			connect_throwing_stone(instanceChild)
			connect_magic_staff(instanceChild)
			connect_pickup_sensor(instanceChild)
		end)
	end

	svcProximityPromptService.PromptShown:Connect(function(promptPickup, enumInputType)
		show_field_pickup_prompt(promptPickup, enumInputType)
	end)

	svcProximityPromptService.PromptHidden:Connect(function(promptPickup)
		hide_field_pickup_prompt(promptPickup)
	end)

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

	svcUserInputService.InputBegan:Connect(function(inputBegan, boolGameProcessed)
		if boolGameProcessed then return end
		if inputBegan.UserInputType ~= Enum.UserInputType.Keyboard then return end

		if inputBegan.KeyCode == Enum.KeyCode.W
			or inputBegan.KeyCode == Enum.KeyCode.A
			or inputBegan.KeyCode == Enum.KeyCode.S
			or inputBegan.KeyCode == Enum.KeyCode.D then
			reset_build_placement_preview()
			return
		end

		if inputBegan.KeyCode == Enum.KeyCode.R and boolBuildPlacementPreviewRequested then
			intBuildPlacementRotationQuarterTurns = (intBuildPlacementRotationQuarterTurns + 1) % 4
			update_brick_placement_preview()
			return
		end

		if inputBegan.KeyCode == Enum.KeyCode.Q then
			if not get_equipped_placeable_tool() then
				reset_build_placement_preview()
				return
			end

			if boolBuildPlacementPreviewRequested then
				update_brick_placement_preview()
				if not boolBuildPlacementPreviewRequested or boolBuildPlacementPreviewBlocked then
					return
				end

				fire_carried_block_place()
				reset_build_placement_preview()
			else
				intBuildPlacementRotationQuarterTurns = 0
				boolBuildPlacementPreviewRequested = true
			end
		end
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

	local numberLastUiUpdateTime = 0

	local function update_hud_ui()
		local modelCharacter = playerLocal.Character
		local humanoidPlayer = modelCharacter and modelCharacter:FindFirstChildOfClass(ePhysical.HUMANOID)

		-- 1. 체력 HUD 동기화
		if humanoidPlayer then
			local numberHealthRatio = math.clamp(humanoidPlayer.Health / humanoidPlayer.MaxHealth, 0, 1)
			frameHealthFill.Size = UDim2.fromScale(numberHealthRatio, 1)
			labelHealth.Text = string.format("HP: %d / %d", math.ceil(humanoidPlayer.Health), math.ceil(humanoidPlayer.MaxHealth))
		else
			frameHealthFill.Size = UDim2.fromScale(0, 1)
			labelHealth.Text = "HP: 0 / 0"
		end

		-- 2. 장착 무기 스탯 동기화
		local toolEquipped = get_equipped_tool()
		if toolEquipped then
			labelWeaponName.Text = "장착: " .. toolEquipped.Name

			local numberDamage = toolEquipped:GetAttribute("Damage") or toolEquipped:GetAttribute("DamageValue")
			local strRealMaterial = toolEquipped:GetAttribute("RealMaterial")

			-- 스탯 속성이 없는 경우 도메인 무기 기준 Fallback
			if not numberDamage then
				if is_throwing_stone(toolEquipped) then
					numberDamage = 15
					strRealMaterial = "Slate"
				elseif toolEquipped.Name:find("Sword") or toolEquipped.Name:find("검") then
					numberDamage = 25
					strRealMaterial = "Metal"
				elseif toolEquipped.Name:find("Bow") or toolEquipped.Name:find("활") then
					numberDamage = 20
					strRealMaterial = "Wood"
				else
					numberDamage = 15
					strRealMaterial = "Plastic"
				end
			else
				if not strRealMaterial then
					if toolEquipped.Name:find("Sword") or toolEquipped.Name:find("검") then
						strRealMaterial = "Metal"
					elseif toolEquipped.Name:find("Bow") or toolEquipped.Name:find("활") then
						strRealMaterial = "Wood"
					else
						strRealMaterial = "Slate"
					end
				end
			end

			local strMassText = get_tool_mass_text(toolEquipped)
			local strCollisionModeText = get_tool_collision_mode_text(toolEquipped)
			labelWeaponStats.Text = string.format("데미지: %d | 재질: %s\n무게: %s | 콜리전: %s", numberDamage, strRealMaterial, strMassText, strCollisionModeText)
		else
			labelWeaponName.Text = "장착: 주먹"
			labelWeaponStats.Text = "데미지: 10 | 재질: 없음\n무게: - | 콜리전: -"
		end

		local toolPlaceable = get_equipped_placeable_tool()
		frameBrickGuide.Visible = toolPlaceable ~= nil
		if toolPlaceable then
			if boolBuildPlacementPreviewRequested then
				local strSnapMode = get_build_placement_endpoint_snap() and "끝점" or "지그재그"
				if boolBuildPlacementPreviewBlocked then
					labelBrickGuide.Text = "겹침: 놓을 수 없음 | R: 회전 | Shift: 끝점 | W/A/S/D: 취소"
				else
					labelBrickGuide.Text = string.format("Q: 배치 | R: 회전(%d) | Shift: %s | W/A/S/D: 취소", intBuildPlacementRotationQuarterTurns, strSnapMode)
				end
			else
				labelBrickGuide.Text = "Q: 놓을 위치 보기"
			end
		end
	end

	local function stop_respawn_countdown()
		intRespawnCountdownToken += 1
		guiRespawnCountdown.Enabled = false
	end

	local function start_respawn_countdown()
		intRespawnCountdownToken += 1
		local intCountdownToken = intRespawnCountdownToken
		guiRespawnCountdown.Enabled = true

		task.spawn(function()
			for intSecondsLeft = RESPAWN_COUNTDOWN_SECONDS, 1, -1 do
				if intRespawnCountdownToken ~= intCountdownToken then
					return
				end

				labelRespawnNumber.Text = tostring(intSecondsLeft)
				task.wait(1)
			end
		end)
	end

	local function bind_respawn_countdown_for_character(modelCharacter)
		stop_respawn_countdown()
		if connectionHumanoidDied then
			connectionHumanoidDied:Disconnect()
			connectionHumanoidDied = nil
		end

		local humanoidPlayer = modelCharacter and modelCharacter:WaitForChild(ePhysical.HUMANOID, 5)
		if not humanoidPlayer or not humanoidPlayer:IsA(ePhysical.HUMANOID) then
			return
		end

		connectionHumanoidDied = humanoidPlayer.Died:Connect(function()
			toolActiveThrowingStone = nil
			reset_build_placement_preview()
			hide_field_pickup_prompt()
			set_throw_charge_visible(false)
			reset_fist_action_visuals()
			set_default_aim_control_enabled(false)
			start_respawn_countdown()
		end)
	end

	svcRunService.RenderStepped:Connect(function()
		local cameraCurrent = svcWorkspace.CurrentCamera
		if cameraCurrent then
			local vectorViewportSize = cameraCurrent.ViewportSize
			frameCrosshair.Position = UDim2.fromOffset(vectorViewportSize.X / 2, vectorViewportSize.Y / 2)
		else
			frameCrosshair.Position = UDim2.fromOffset(mousePlayer.X, mousePlayer.Y)
		end

		frameChargeFill.Size = UDim2.fromScale(get_charge(), 1)
		update_brick_placement_preview()

		local numberNow = os.clock()
		if numberNow - numberLastUiUpdateTime > 0.08 then
			numberLastUiUpdateTime = numberNow
			update_hud_ui()
		end
	end)

	-- [애니메이션 가로채기] 내장 애니메이션 시스템이 Transform 속성을 매 프레임 오버라이드하는 문제를 물리 Stepped 루프에서 가로채서 펀치 모션을 출력시킵니다.
	svcRunService.Stepped:Connect(function()
		update_fist_action_visuals()
	end)

	watch_container(playerLocal:WaitForChild("Backpack"))
	if playerLocal.Character then
		watch_container(playerLocal.Character)
		bind_respawn_countdown_for_character(playerLocal.Character)
		task.defer(start_default_aim_control_for_character, playerLocal.Character)
	end

	playerLocal.CharacterAdded:Connect(function(modelCharacter)
		toolActiveThrowingStone = nil
		reset_build_placement_preview()
		hide_field_pickup_prompt()
		set_throw_charge_visible(false)
		reset_fist_action_visuals()
		set_default_aim_control_enabled(false)
		watch_container(modelCharacter)
		bind_respawn_countdown_for_character(modelCharacter)
		task.defer(start_default_aim_control_for_character, modelCharacter)
	end)

	return true
end


-- --------------------------------------------------------------------------------

return PlayerCombatClient
