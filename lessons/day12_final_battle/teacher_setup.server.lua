-- Roblox Studio Lesson Script Guide
-- Lesson: day12_final_battle - 최종 공성 대대전
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day12_final_battle_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day12_FinalBattle, Teams/Blue, Teams/Red
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

for _, teamName in ipairs({"Blue", "Red"}) do
    local team = Teams:FindFirstChild(teamName) or Instance.new("Team")
    team.Name = teamName
    team.TeamColor = BrickColor.new(teamName == "Blue" and "Bright blue" or "Bright red")
    team.AutoAssignable = true
    team.Parent = Teams
end

local old = Workspace:FindFirstChild("Day12_FinalBattle")
if old then old:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day12_FinalBattle"
folder.Parent = Workspace

local button = Instance.new("Part")
button.Name = "RoundStartButton"
button.Size = Vector3.new(8, 1, 8)
button.Position = Vector3.new(0, 0.5, 0)
button.Anchored = true
button.BrickColor = BrickColor.new("Lime green")
button.Parent = folder

local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 30
detector.Parent = button

for index, x in ipairs({-28, 28}) do
    local spawn = Instance.new("Part")
    spawn.Name = "SpawnPoint_" .. index
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(x, 0.5, -20)
    spawn.Anchored = true
    spawn.BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red")
    spawn.Parent = folder
end

print("Day 12 setup complete")
