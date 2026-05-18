-- Roblox Studio Lesson Script Guide
-- Lesson: day01_rock_tool - 돌멩이 기초 무기
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > PracticeRock > Script named Day01StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day01_Arena, StarterPack/PracticeRock
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Debris = game:GetService("Debris")
local tool = script.Parent

local DAMAGE = 15
local COOLDOWN = 0.8
local SPEED = 90
local ready = true

tool.Activated:Connect(function()
    if not ready then return end

    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    ready = false

    local rock = Instance.new("Part")
    rock.Name = "ThrownPracticeRock"
    rock.Shape = Enum.PartType.Ball
    rock.Size = Vector3.new(1.2, 1.2, 1.2)
    rock.Material = Enum.Material.Slate
    rock.Position = root.Position + root.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0)
    rock.Parent = workspace
    rock.AssemblyLinearVelocity = root.CFrame.LookVector * SPEED + Vector3.new(0, 12, 0)
    Debris:AddItem(rock, 5)

    local hitOnce = false
    rock.Touched:Connect(function(hit)
        if hitOnce then return end

        local targetModel = hit:FindFirstAncestorOfClass("Model")
        local humanoid = targetModel and targetModel:FindFirstChildOfClass("Humanoid")
        local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
        if not humanoid or targetModel == character then return end

        hitOnce = true
        humanoid:TakeDamage(DAMAGE)
        if targetRoot then
            targetRoot.AssemblyLinearVelocity = root.CFrame.LookVector * 45 + Vector3.new(0, 18, 0)
        end
        rock:Destroy()
    end)

    task.wait(COOLDOWN)
    ready = true
end)
