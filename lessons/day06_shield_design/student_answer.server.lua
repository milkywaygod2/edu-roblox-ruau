-- Roblox Studio Lesson Script Guide
-- Lesson: day06_shield_design - 방패와 방어 규칙
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > PracticeShield > Script named Day06StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: StarterPack/PracticeShield
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local tool = script.Parent

local BONUS_HEALTH = 60
local BLOCK_HEAL = 5
local equippedCharacter = nil
local savedStats = nil

tool.Equipped:Connect(function()
    equippedCharacter = tool.Parent
    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    savedStats = {MaxHealth = humanoid.MaxHealth, WalkSpeed = humanoid.WalkSpeed}
    humanoid.MaxHealth += BONUS_HEALTH
    humanoid.Health = math.min(humanoid.Health + BONUS_HEALTH, humanoid.MaxHealth)
    humanoid.WalkSpeed -= 2
end)

tool.Unequipped:Connect(function()
    if not equippedCharacter or not savedStats then return end

    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = savedStats.MaxHealth
        humanoid.Health = math.min(humanoid.Health, savedStats.MaxHealth)
        humanoid.WalkSpeed = savedStats.WalkSpeed
    end

    equippedCharacter = nil
    savedStats = nil
end)

tool.Handle.Touched:Connect(function(hit)
    if not hit.Name:match("Arrow") and not hit.Name:match("Projectile") then return end
    if not equippedCharacter then return end

    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.Health = math.min(humanoid.Health + BLOCK_HEAL, humanoid.MaxHealth) end
    hit:Destroy()
end)
