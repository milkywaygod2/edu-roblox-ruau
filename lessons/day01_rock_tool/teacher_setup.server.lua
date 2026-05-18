-- Roblox Studio Lesson Script Guide
-- Lesson: day01_rock_tool - 돌멩이 기초 무기
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day01_rock_tool_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day01_Arena, StarterPack/PracticeRock
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldArena = Workspace:FindFirstChild("Day01_Arena")
if oldArena then oldArena:Destroy() end

local arena = Instance.new("Folder")
arena.Name = "Day01_Arena"
arena.Parent = Workspace

local base = Instance.new("Part")
base.Name = "PracticeBase"
base.Size = Vector3.new(80, 1, 80)
base.Position = Vector3.new(0, -0.5, 0)
base.Anchored = true
base.Material = Enum.Material.Grass
base.Parent = arena

for index = 1, 4 do
    local dummy = Instance.new("Model")
    dummy.Name = "PracticeDummy_" .. index
    dummy.Parent = arena

    local body = Instance.new("Part")
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(3, 5, 2)
    body.Position = Vector3.new(index * 8 - 20, 2.5, -18)
    body.Anchored = true
    body.BrickColor = BrickColor.new("Bright red")
    body.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = dummy
end

local oldTool = StarterPack:FindFirstChild("PracticeRock")
if oldTool then oldTool:Destroy() end

local tool = Instance.new("Tool")
tool.Name = "PracticeRock"
tool.ToolTip = "Click to throw a practice rock"
tool.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Shape = Enum.PartType.Ball
handle.Size = Vector3.new(1, 1, 1)
handle.Material = Enum.Material.Slate
handle.Parent = tool

print("Day 01 setup complete")
