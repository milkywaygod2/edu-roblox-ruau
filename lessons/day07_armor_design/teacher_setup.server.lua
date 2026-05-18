-- Roblox Studio Lesson Script Guide
-- Lesson: day07_armor_design - 갑옷과 이동 패널티
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day07_armor_design_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: StarterPack/HeavyArmor
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local oldTool = StarterPack:FindFirstChild("HeavyArmor")
if oldTool then oldTool:Destroy() end

local armor = Instance.new("Tool")
armor.Name = "HeavyArmor"
armor.RequiresHandle = true
armor.ToolTip = "Equip for armor stats"
armor.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(2, 2, 1)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Really black")
handle.Parent = armor

print("Day 07 setup complete")
