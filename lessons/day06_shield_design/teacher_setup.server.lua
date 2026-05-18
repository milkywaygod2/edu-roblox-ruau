-- Roblox Studio Lesson Script Guide
-- Lesson: day06_shield_design - 방패와 방어 규칙
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day06_shield_design_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: StarterPack/PracticeShield
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local oldTool = StarterPack:FindFirstChild("PracticeShield")
if oldTool then oldTool:Destroy() end

local shield = Instance.new("Tool")
shield.Name = "PracticeShield"
shield.ToolTip = "Equip to block and gain health"
shield.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(4, 5, 0.6)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Dark stone grey")
handle.Parent = shield

print("Day 06 setup complete")
