-- Roblox Studio Lesson Script Guide
-- Lesson: day02_cover_design - 기초 엄폐물 디자인
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day02StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day02_CoverField
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local field = workspace:WaitForChild("Day02_CoverField")
local materials = {Enum.Material.WoodPlanks, Enum.Material.Slate, Enum.Material.Metal}
local colors = {"Reddish brown", "Dark stone grey", "Medium blue"}

local function create_cover(name, origin, material, colorName)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = field

    for level = 1, 3 do
        local block = Instance.new("Part")
        block.Name = "CoverBlock_" .. level
        block.Size = Vector3.new(8 - level, 2, 2)
        block.Position = origin + Vector3.new(0, level, 0)
        block.Anchored = true
        block.CanCollide = true
        block.Material = material
        block.BrickColor = BrickColor.new(colorName)
        block.Parent = model
    end
end

for index = 1, 3 do
    create_cover("StudentCover_" .. index, Vector3.new(index * 14 - 28, 1, 8), materials[index], colors[index])
end

print("Day 02 answer complete")
