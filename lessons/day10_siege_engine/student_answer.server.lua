-- Roblox Studio Lesson Script Guide
-- Lesson: day10_siege_engine - 공성 병기와 원격 발사
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day10StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day10_SiegeEngine/LaunchButton, LaunchPoint, TargetPoint
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Debris = game:GetService("Debris")
local folder = workspace:WaitForChild("Day10_SiegeEngine")
local button = folder:WaitForChild("LaunchButton")
local launchPoint = folder:WaitForChild("LaunchPoint")
local targetPoint = folder:WaitForChild("TargetPoint")

local COOLDOWN = 2.5
local ready = true

local function launch_stone(player)
    if not ready then return end
    ready = false

    local stone = Instance.new("Part")
    stone.Name = "SiegeStone"
    stone.Shape = Enum.PartType.Ball
    stone.Size = Vector3.new(3, 3, 3)
    stone.Material = Enum.Material.Slate
    stone.Position = launchPoint.Position
    stone.Parent = workspace

    local direction = (targetPoint.Position - launchPoint.Position).Unit
    stone.AssemblyLinearVelocity = direction * 95 + Vector3.new(0, 45, 0)
    Debris:AddItem(stone, 8)

    task.wait(COOLDOWN)
    ready = true
end

button.ClickDetector.MouseClick:Connect(launch_stone)
