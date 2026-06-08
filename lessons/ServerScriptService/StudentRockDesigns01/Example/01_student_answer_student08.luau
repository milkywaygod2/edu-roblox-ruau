-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns01 > ModuleScript 이름 01_student_answer_student08

local CM = 1 / 30

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.WoodPlanks
appearance.Size = Vector3.new(80, 64, 80) * CM
appearance.CollisionShape = Enum.PartType.Cylinder
appearance.CollisionShapeMode = "Auto"
appearance.LookShape = "136277359596870"

rock.DisplayName = "나무 회오리돌"
rock.Appearance = appearance
rock.SpawnCount = 10

return rock
