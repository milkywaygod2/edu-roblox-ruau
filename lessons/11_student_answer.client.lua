-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차의 서버 통신 마법을 전장 파밍 Tool 입력으로 구성했습니다.
-- 역할: student_answer.client.lua, 학생용 클라이언트 입력 모범답안 코드입니다.
-- 붙여넣기 위치: StarterPlayer > StarterPlayerScripts > LocalScript 이름 MagicClient11
-- 선행 조건: 선생님 setup이 ReplicatedStorage/CastMagic을 만들고, 서버 학생 코드가 MagicStaff 파밍 Tool을 설치해야 합니다.
-- 검증 기준: 전장에서 지팡이를 주워 장착하고 클릭하면 마우스 위치가 서버로 전달되어 폭발 마법이 실행되면 성공입니다.

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType
local eAttrKey = common.eEngineAttributeKey

local svcPlayers = game:GetService(eService.PLAYERS)
local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)

local playerLocal = svcPlayers.LocalPlayer
local eventCastMagic = svcReplicatedStorage:WaitForChild(eLogical.CAST_MAGIC)
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
        eventCastMagic:FireServer(mousePlayer.Hit.Position)
    end)
end

local function watch_container(instanceContainer)
    for _, instanceChild in ipairs(instanceContainer:GetChildren()) do
        connect_magic_staff(instanceChild)
    end

    instanceContainer.ChildAdded:Connect(connect_magic_staff)
end

watch_container(playerLocal:WaitForChild("Backpack"))
if playerLocal.Character then
    watch_container(playerLocal.Character)
end
playerLocal.CharacterAdded:Connect(watch_container)
