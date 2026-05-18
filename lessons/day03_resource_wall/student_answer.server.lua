-- Roblox Studio Lesson Script Guide
-- Lesson: day03_resource_wall - 자원 기반 방벽 소환
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day03StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day03_ResourceWall/BuildButton, WallSpawn
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Players = game:GetService("Players")
local folder = workspace:WaitForChild("Day03_ResourceWall")
local button = folder:WaitForChild("BuildButton")
local wallSpawn = folder:WaitForChild("WallSpawn")

local START_WOOD = 30
local WALL_COST = 10
local nextRow = 0

local function setup_stats(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local wood = Instance.new("IntValue")
    wood.Name = "Wood"
    wood.Value = START_WOOD
    wood.Parent = leaderstats
end

local function build_wall(player)
    local wood = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wood")
    if not wood or wood.Value < WALL_COST then return end

    wood.Value -= WALL_COST
    nextRow += 1

    for index = 1, 8 do
        local block = Instance.new("Part")
        block.Name = player.Name .. "_WallBlock"
        block.Size = Vector3.new(4, 6, 1)
        block.Position = wallSpawn.Position + Vector3.new((index - 4.5) * 4, 3, nextRow * 3)
        block.Anchored = true
        block.Material = Enum.Material.WoodPlanks
        block.BrickColor = BrickColor.new("Reddish brown")
        block.Parent = folder
    end
end

Players.PlayerAdded:Connect(setup_stats)
for _, player in ipairs(Players:GetPlayers()) do setup_stats(player) end
button.ClickDetector.MouseClick:Connect(build_wall)
