-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns > ModuleScript 이름 01_student_answer

local rock = {}
local appearance = {}

appearance.Material = Enum.Material.Slate
appearance.Size = Vector3.new(1.4, 1.1, 1.2)
appearance.CollisionShape = Enum.PartType.Ball
appearance.LookShape = "" -- 외형 모델 템플릿 이름 또는 크리에이터 상점 에셋 ID (예: "17354921094". 크리에이터 상점 링크: https://create.roblox.com/store/asset/17354921094 에서 무료 모델 팩을 [획득(Get)]한 후 에셋 ID를 문자열로 기입하면 자동으로 겉모습을 가져옵니다. 또는 수동으로 ReplicatedStorage > OutpostAssets > RockLooks에 모델들을 넣고 해당 모델명을 기입해도 됩니다.)

rock.DisplayName = "검은 운석"
rock.Appearance = appearance
rock.SpawnCount = 10

return rock
