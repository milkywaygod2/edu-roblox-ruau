-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns > ModuleScript 이름 01_student_answer_student13

local CM = 1 / 30

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.Pebble
appearance.Size = Vector3.new(48, 40, 48) * CM
appearance.CollisionShape = Enum.PartType.Cylinder
appearance.LookShape = "13324601605"

rock.DisplayName = "조약돌 폭풍탄"
rock.Appearance = appearance
rock.SpawnCount = 10

return rock
