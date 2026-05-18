-- Roblox Studio Lesson Script Guide
-- Lesson: day04_melee_weapon - 일반 무기와 디바운스
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > BalanceSword > Script named Day04StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: StarterPack/BalanceSword, Workspace/Day04_Dummies
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local tool = script.Parent

local DAMAGE = 20
local ACTIVE_TIME = 0.25
local COOLDOWN = 1.2
local canAttack = true

tool.Activated:Connect(function()
    if not canAttack then return end

    canAttack = false
    local alreadyHit = {}
    tool.Handle.BrickColor = BrickColor.new("Really red")

    local connection = tool.Handle.Touched:Connect(function(hit)
        local model = hit:FindFirstAncestorOfClass("Model")
        local humanoid = model and model:FindFirstChildOfClass("Humanoid")
        if not humanoid or model == tool.Parent or alreadyHit[humanoid] then return end

        alreadyHit[humanoid] = true
        humanoid:TakeDamage(DAMAGE)
    end)

    task.wait(ACTIVE_TIME)
    connection:Disconnect()
    tool.Handle.BrickColor = BrickColor.new("Medium stone grey")
    task.wait(COOLDOWN)
    canAttack = true
end)
