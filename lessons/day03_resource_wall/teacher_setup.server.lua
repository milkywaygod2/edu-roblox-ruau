-- Roblox Studio Lesson Script Guide
-- Lesson: day03_resource_wall - 자원 기반 방벽 소환
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day03_resource_wall_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day03_ResourceWall/BuildButton, WallSpawn
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day03_ResourceWall")
if old then old:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day03_ResourceWall"
folder.Parent = Workspace

local button = Instance.new("Part")
button.Name = "BuildButton"
button.Size = Vector3.new(6, 1, 6)
button.Position = Vector3.new(0, 0.5, 0)
button.Anchored = true
button.BrickColor = BrickColor.new("Bright green")
button.Parent = folder

local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 24
detector.Parent = button

local marker = Instance.new("Part")
marker.Name = "WallSpawn"
marker.Size = Vector3.new(2, 0.2, 2)
marker.Position = Vector3.new(0, 0.1, 12)
marker.Anchored = true
marker.Transparency = 0.35
marker.BrickColor = BrickColor.new("Bright yellow")
marker.Parent = folder

print("Day 03 setup complete")
