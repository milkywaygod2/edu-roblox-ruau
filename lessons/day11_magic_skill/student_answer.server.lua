-- Roblox Studio Lesson Script Guide
-- Lesson: day11_magic_skill - 마법 스킬과 서버 판정
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > MagicStaff > Script named Day11StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: StarterPack/MagicStaff, Workspace/Day11_MagicArena
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local tool = script.Parent

local RANGE = 28
local RADIUS = 12
local DAMAGE = 25
local COOLDOWN = 1.8
local ready = true

local function cast_magic()
    if not ready then return end

    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    ready = false
    local center = root.Position + root.CFrame.LookVector * RANGE

    local explosion = Instance.new("Explosion")
    explosion.Position = center
    explosion.BlastRadius = RADIUS
    explosion.BlastPressure = 0
    explosion.Parent = workspace

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Humanoid") then
            local targetRoot = object.Parent:FindFirstChild("HumanoidRootPart")
            if targetRoot and (targetRoot.Position - center).Magnitude <= RADIUS and object.Parent ~= character then
                object:TakeDamage(DAMAGE)
            end
        end
    end

    task.wait(COOLDOWN)
    ready = true
end

tool.Activated:Connect(cast_magic)
