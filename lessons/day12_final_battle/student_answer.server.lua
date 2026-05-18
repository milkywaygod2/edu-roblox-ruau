-- Roblox Studio Lesson Script Guide
-- Lesson: day12_final_battle - 최종 공성 대대전
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day12StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day12_FinalBattle, Teams/Blue, Teams/Red
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Players = game:GetService("Players")
local folder = workspace:WaitForChild("Day12_FinalBattle")
local button = folder:WaitForChild("RoundStartButton")

local ROUND_TIME = 180
local RESPAWN_HEIGHT = 4
local roundRunning = false

local function get_spawn_points()
    local result = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name:match("SpawnPoint") and child:IsA("BasePart") then
            table.insert(result, child)
        end
    end
    return result
end

local function move_players_to_spawns()
    local spawns = get_spawn_points()
    for index, player in ipairs(Players:GetPlayers()) do
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        local spawn = spawns[((index - 1) % #spawns) + 1]
        root.CFrame = CFrame.new(spawn.Position + Vector3.new(0, RESPAWN_HEIGHT, 0))
    end
end

local function start_round()
    if roundRunning then return end

    roundRunning = true
    workspace:SetAttribute("RoundState", "Preparing")
    move_players_to_spawns()

    workspace:SetAttribute("RoundState", "Playing")
    for timeLeft = ROUND_TIME, 0, -1 do
        workspace:SetAttribute("TimeLeft", timeLeft)
        task.wait(1)
    end

    workspace:SetAttribute("RoundState", "Finished")
    roundRunning = false
end

button.ClickDetector.MouseClick:Connect(start_round)
