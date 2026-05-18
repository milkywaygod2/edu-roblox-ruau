-- Roblox Studio Lesson Script Guide
-- Lesson: day09_stone_wall - 석조 성벽과 부분 파괴
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day09StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day09_StoneWall
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local wall = workspace:WaitForChild("Day09_StoneWall")
local SECTION_HEALTH = 90
local sectionHealth = {}

local function collapse_section(section)
    for _, part in ipairs(section:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-10, 10))
        end
    end
end

local function register_section(section)
    sectionHealth[section] = SECTION_HEALTH
    for _, part in ipairs(section:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if hit.Name ~= "SiegeStone" and hit.Name ~= "TrainingArrow" then return end
                hit:Destroy()
                sectionHealth[section] -= 30
                part.BrickColor = BrickColor.new("Dark stone grey")
                if sectionHealth[section] <= 0 then collapse_section(section) end
            end)
        end
    end
end

for _, section in ipairs(wall:GetChildren()) do
    if section:IsA("Model") then register_section(section) end
end
