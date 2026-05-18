-- Roblox Studio Lesson Script Guide
-- Lesson: day08_building_gate - 건물과 파괴되는 성문
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day08_building_gate_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day08_Castle/Gate
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day08_Castle")
if old then old:Destroy() end

local castle = Instance.new("Folder")
castle.Name = "Day08_Castle"
castle.Parent = Workspace

local gate = Instance.new("Model")
gate.Name = "Gate"
gate.Parent = castle

for index = 1, 5 do
    local plank = Instance.new("Part")
    plank.Name = "GatePlank_" .. index
    plank.Size = Vector3.new(2, 10, 1)
    plank.Position = Vector3.new((index - 3) * 2, 5, -20)
    plank.Anchored = true
    plank.Material = Enum.Material.WoodPlanks
    plank.BrickColor = BrickColor.new("Reddish brown")
    plank.Parent = gate
end

print("Day 08 setup complete")
