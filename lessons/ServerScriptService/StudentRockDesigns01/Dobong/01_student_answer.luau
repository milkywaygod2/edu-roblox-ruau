-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 돌멩이 디자인 데이터입니다. 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentRockDesigns01 > ModuleScript 이름 01_student_answer

local CM = 1 / 30 -- 센티미터 입력 기준

local appearance = {}
appearance.Material = Enum.Material.Wood
appearance.Size = Vector3.new(84, 66, 72) * CM -- 센티미터 단위 입력
appearance.CollisionShape = Enum.PartType.Ball
appearance.CollisionShapeMode = "Auto"
appearance.LookShape = "105190628650251" -- 외형 모델 템플릿 이름 또는 크리에이터 상점 에셋 ID (예: "17354921094". 크리에이터 상점 링크: https://create.roblox.com/store/asset/17354921094 에서 무료 모델 팩을 [획득(Get)]한 후 에셋 ID를 문자열로 기입하면 자동으로 겉모습을 가져옵니다. 또는 수동으로 ReplicatedStorage > OutpostAssets > RockLooks에 모델들을 넣고 해당 모델명을 기입해도 됩니다.)

-- [고급 옵션 참고]
-- 아래 값들은 Common 뒷단이 읽을 수 있지만, 1일차 수업 기본 흐름에서는 숨겨둔 옵션입니다.
-- 필요할 때 주석(-- )을 지우고 값을 바꾸면 적용됩니다.
-- appearance.CollisionShapeMode = "LookBounds" -- "Auto", "Shape", "LookBounds", "LookMesh"
-- appearance.CollisionSize = Vector3.new(84, 66, 72) * CM -- Size를 생략했을 때 충돌/물리 크기 전용으로 사용
-- appearance.Shape = Enum.PartType.Block -- CollisionShape의 예전 이름입니다. CollisionShape가 있으면 무시됩니다.
-- appearance.Look = "Meteor" -- LookShape의 예전 이름입니다. LookShape가 있으면 무시됩니다.

local rock = {}
rock.DisplayName = "검은 운석"
rock.Appearance = appearance
rock.SpawnCount = 10
-- rock.VariantId = "Student01_Meteor" -- 같은 돌 종류를 구분하고 스폰 랜덤 배치를 고정하는 ID
-- rock.SpawnRadius = 6 -- 스폰 마커 주변에 흩뿌릴 반경입니다. 생략하면 돌 크기 기준으로 자동 계산됩니다.
-- rock.SpawnOffset = Vector3.new(0, 0, 0) -- 전체 스폰 위치를 조금 옮기는 선생님 운영용 옵션입니다.
-- rock.WorldAnchored = false -- true면 월드에 놓인 돌이 고정되어 굴러가지 않습니다.
-- rock.WorldCanCollide = true -- 월드에 놓인 돌이 다른 돌/지형과 물리 충돌할지 정합니다.
-- rock.WorldMassless = false -- true면 월드 물리 계산에서 돌 무게를 거의 무시하게 합니다.

return rock
