-- Roblox Studio Lesson Script Guide
-- Lesson: day05_ranged_weapon - 원거리 무기와 포물선
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > TrainingBow > Script named Day05StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: StarterPack/TrainingBow, Workspace/Day05_TargetRange
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Debris = game:GetService("Debris")
local tool = script.Parent

local SPEED = 110
local ARC = 28
local DAMAGE = 18
local COOLDOWN = 0.9
local ready = true

tool.Activated:Connect(function()
    if not ready then return end

    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    ready = false

    local arrow = Instance.new("Part")
    arrow.Name = "TrainingArrow"
    arrow.Size = Vector3.new(0.4, 0.4, 3)
    arrow.Material = Enum.Material.Wood
    arrow.CFrame = root.CFrame * CFrame.new(0, 1.5, -4)
    arrow.Parent = workspace
    arrow.AssemblyLinearVelocity = root.CFrame.LookVector * SPEED + Vector3.new(0, ARC, 0)
    Debris:AddItem(arrow, 6)

    arrow.Touched:Connect(function(hit)
        if hit:IsDescendantOf(character) then return end
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:TakeDamage(DAMAGE) end
        if hit.Name:match("Target") then hit.BrickColor = BrickColor.new("Lime green") end
        arrow:Destroy()
    end)

    task.wait(COOLDOWN)
    ready = true
end)
