-- Roblox Studio 수업 스크립트 안내
-- 역할: 학생 클라이언트 공통 입력 런타임을 켭니다.

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

common.installPlayerCombatClientControls()

-- ==============================================================================
-- [11회차 실습 마법 지팡이(Magic Staff) 모범 답안 구현]
-- ==============================================================================
local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType
local eAttrKey = common.eEngineAttributeKey

local svcPlayers = game:GetService(eService.PLAYERS)
local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)

local playerLocal = svcPlayers.LocalPlayer
local mousePlayer = playerLocal:GetMouse()
local tblConnectedTools = {}

local function is_magic_staff(toolTarget)
	if not toolTarget:IsA("Tool") then return false end

	return toolTarget:GetAttribute(eAttrKey.FIELD_ITEM_TYPE) == eLogical.MAGIC_STAFF
		or toolTarget.Name:sub(1, #eLogical.MAGIC_STAFF) == eLogical.MAGIC_STAFF
end

local function connect_magic_staff(toolMagicStaff)
	if tblConnectedTools[toolMagicStaff] or not is_magic_staff(toolMagicStaff) then return end

	tblConnectedTools[toolMagicStaff] = true
	toolMagicStaff.Activated:Connect(function()
		local eventCastMagic = svcReplicatedStorage:FindFirstChild(eLogical.CAST_MAGIC)
		if not eventCastMagic then return end

		eventCastMagic:FireServer(mousePlayer.Hit.Position)
	end)
end

local function watch_container(instanceContainer)
	for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
		connect_magic_staff(instanceChild)
	end

	instanceContainer.ChildAdded:Connect(connect_magic_staff)
end

if playerLocal then
	watch_container(playerLocal:WaitForChild("Backpack"))
	if playerLocal.Character then
		watch_container(playerLocal.Character)
	end
	playerLocal.CharacterAdded:Connect(watch_container)
end
