-- Roblox Studio Lesson Script Guide
-- Lesson: day11_magic_skill - 마법 스킬과 서버 판정
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day11_magic_skill_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: StarterPack/MagicStaff, Workspace/Day11_MagicArena
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldTool = StarterPack:FindFirstChild("MagicStaff")
if oldTool then oldTool:Destroy() end

local staff = Instance.new("Tool")
staff.Name = "MagicStaff"
staff.ToolTip = "Cast server magic"
staff.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.6, 5, 0.6)
handle.Material = Enum.Material.Neon
handle.BrickColor = BrickColor.new("Royal purple")
handle.Parent = staff

local oldArena = Workspace:FindFirstChild("Day11_MagicArena")
if oldArena then oldArena:Destroy() end

local arena = Instance.new("Folder")
arena.Name = "Day11_MagicArena"
arena.Parent = Workspace

for index = 1, 6 do
    local dummy = Instance.new("Model")
    dummy.Name = "MagicDummy_" .. index
    dummy.Parent = arena

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3, 5, 2)
    root.Position = Vector3.new(index * 7 - 24, 2.5, -25)
    root.Anchored = true
    root.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
end

print("Day 11 setup complete")
