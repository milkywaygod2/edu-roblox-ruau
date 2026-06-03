-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns > ModuleScript 이름 01_student_answer

local rock = {}
local appearance = {}

appearance.BrickColor = BrickColor.new("Really black")
appearance.Material = "Rock"
appearance.Size = Vector3.new(1.4, 1.1, 1.2)
appearance.CollisionShape = Enum.PartType.Ball
appearance.LookShape = ""

rock.DisplayName = "검은 운석"
rock.Appearance = appearance
rock.Trait = "Heavy"
rock.SpawnCount = 10

return rock
