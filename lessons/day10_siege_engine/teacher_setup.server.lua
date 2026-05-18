-- Roblox Studio Lesson Script Guide
-- Lesson: day10_siege_engine - 공성 병기와 원격 발사
-- Role: teacher_setup.server.lua, 선생님 전용 수업 준비 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named day10_siege_engine_TeacherSetup
-- Execution order: 1) paste this setup script 2) press Play 3) confirm generated objects 4) press Stop 5) disable/delete setup script before class playtest
-- Creates/Resets: Workspace/Day10_SiegeEngine/LaunchButton, LaunchPoint, TargetPoint
-- Safety: setup scripts may delete and recreate DayXX objects or lesson Tools. Run them only in a saved class copy, not in an unbacked production place.
-- Verification: Explorer should show the generated objects above, and Output should print the setup complete message without red errors.
-- Troubleshooting: if objects are missing, rerun Play after checking that this Script is enabled and placed in ServerScriptService.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day10_SiegeEngine")
if old then old:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day10_SiegeEngine"
folder.Parent = Workspace

local button = Instance.new("Part")
button.Name = "LaunchButton"
button.Size = Vector3.new(6, 1, 6)
button.Position = Vector3.new(0, 0.5, 0)
button.Anchored = true
button.BrickColor = BrickColor.new("Bright blue")
button.Parent = folder

local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 24
detector.Parent = button

local launch = Instance.new("Part")
launch.Name = "LaunchPoint"
launch.Size = Vector3.new(2, 2, 2)
launch.Position = Vector3.new(0, 4, -6)
launch.Anchored = true
launch.Transparency = 0.4
launch.Parent = folder

local target = Instance.new("Part")
target.Name = "TargetPoint"
target.Size = Vector3.new(4, 4, 4)
target.Position = Vector3.new(0, 4, -42)
target.Anchored = true
target.Transparency = 0.4
target.BrickColor = BrickColor.new("Bright red")
target.Parent = folder

print("Day 10 setup complete")
