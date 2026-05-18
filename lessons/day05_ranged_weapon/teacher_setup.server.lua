-- Roblox Studio Lesson Script Guide
-- Lesson: day05_ranged_weapon - 원거리 무기와 포물선
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day05_ranged_weapon_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: StarterPack/TrainingBow, Workspace/Day05_TargetRange
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldRange = Workspace:FindFirstChild("Day05_TargetRange")
if oldRange then oldRange:Destroy() end

local range = Instance.new("Folder")
range.Name = "Day05_TargetRange"
range.Parent = Workspace

for index = 1, 6 do
    local target = Instance.new("Part")
    target.Name = "Target_" .. index
    target.Size = Vector3.new(4, 6, 1)
    target.Position = Vector3.new(index * 8 - 28, 3, -40)
    target.Anchored = true
    target.BrickColor = BrickColor.new("Bright red")
    target.Parent = range
end

local oldTool = StarterPack:FindFirstChild("TrainingBow")
if oldTool then oldTool:Destroy() end

local tool = Instance.new("Tool")
tool.Name = "TrainingBow"
tool.ToolTip = "Server projectile bow"
tool.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 4, 1)
handle.Material = Enum.Material.Wood
handle.Parent = tool

print("Day 05 setup complete")
