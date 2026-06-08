-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns01 > ModuleScript 이름 01_student_answer_student02

local CM = 1 / 30

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.Rock
appearance.Size = Vector3.new(1000, 800, 800) * CM
appearance.CollisionShape = Enum.PartType.Ball
appearance.CollisionShapeMode = "Auto"
appearance.LookShape = "282758654"

rock.DisplayName = "돌멩이"
rock.Appearance = appearance
rock.SpawnCount = 10

return rock
