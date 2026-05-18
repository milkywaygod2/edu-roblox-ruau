-- Roblox Studio Lesson Script Guide
-- Lesson: day04_melee_weapon - 일반 무기와 디바운스
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day04_melee_weapon_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: StarterPack/BalanceSword, Workspace/Day04_Dummies
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldTool = StarterPack:FindFirstChild("BalanceSword")
if oldTool then oldTool:Destroy() end

local tool = Instance.new("Tool")
tool.Name = "BalanceSword"
tool.ToolTip = "Cooldown sword"
tool.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 5, 1)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Medium stone grey")
handle.Parent = tool

local oldDummies = Workspace:FindFirstChild("Day04_Dummies")
if oldDummies then oldDummies:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day04_Dummies"
folder.Parent = Workspace

for index = 1, 5 do
    local dummy = Instance.new("Model")
    dummy.Name = "CooldownDummy_" .. index
    dummy.Parent = folder

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3, 5, 2)
    root.Position = Vector3.new(index * 7 - 21, 2.5, -15)
    root.Anchored = true
    root.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
end

print("Day 04 setup complete")
