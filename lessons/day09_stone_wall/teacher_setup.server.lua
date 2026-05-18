-- Roblox Studio Lesson Script Guide
-- Lesson: day09_stone_wall - 석조 성벽과 부분 파괴
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day09_stone_wall_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day09_StoneWall
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day09_StoneWall")
if old then old:Destroy() end

local wall = Instance.new("Folder")
wall.Name = "Day09_StoneWall"
wall.Parent = Workspace

for section = 1, 5 do
    local model = Instance.new("Model")
    model.Name = "WallSection_" .. section
    model.Parent = wall

    for height = 1, 4 do
        local block = Instance.new("Part")
        block.Name = "StoneBlock"
        block.Size = Vector3.new(6, 2, 2)
        block.Position = Vector3.new((section - 3) * 6, height * 2 - 1, -24)
        block.Anchored = true
        block.Material = Enum.Material.Slate
        block.Parent = model
    end
end

print("Day 09 setup complete")
