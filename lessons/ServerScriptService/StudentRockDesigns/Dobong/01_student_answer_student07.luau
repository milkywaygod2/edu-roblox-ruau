-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns > ModuleScript 이름 01_student_answer_student07

local CM = 1 / 30

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.Marble
appearance.Size = Vector3.new(46, 44, 46) * CM
appearance.CollisionShape = Enum.PartType.Block
appearance.LookShape = "11240927504"

rock.DisplayName = "대리석 방패돌"
rock.Appearance = appearance
rock.SpawnCount = 10

return rock
