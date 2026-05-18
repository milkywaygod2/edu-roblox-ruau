-- Roblox Studio Lesson Script Guide
-- Lesson: day02_cover_design - 기초 엄폐물 디자인
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day02_cover_design_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day02_CoverField
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day02_CoverField")
if old then old:Destroy() end

local field = Instance.new("Folder")
field.Name = "Day02_CoverField"
field.Parent = Workspace

local base = Instance.new("Part")
base.Name = "GridBase"
base.Size = Vector3.new(90, 1, 70)
base.Position = Vector3.new(0, -0.5, 0)
base.Anchored = true
base.Material = Enum.Material.Concrete
base.Parent = field

for index = 1, 5 do
    local marker = Instance.new("Part")
    marker.Name = "CoverMarker_" .. index
    marker.Size = Vector3.new(2, 0.2, 2)
    marker.Position = Vector3.new(index * 8 - 24, 0.1, -10)
    marker.Anchored = true
    marker.BrickColor = BrickColor.new("Bright yellow")
    marker.Parent = field
end

print("Day 02 setup complete")
