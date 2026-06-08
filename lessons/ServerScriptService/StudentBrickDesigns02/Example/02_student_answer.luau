-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_brick_stack - 물리 벽돌 쌓기와 엄폐물 만들기
-- 역할: 학생용 벽돌 디자인 데이터입니다. 생성/줍기/내려놓기/피해 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentBrickDesigns02 > ModuleScript 이름 02_student_answer

local CM = 1 / 30 -- 센티미터 입력 기준

local brick = {}
local appearance = {}

appearance.Material = Enum.Material.Brick
appearance.Size = Vector3.new(60, 24, 24) * CM -- 센티미터 단위 입력
appearance.CollisionShape = Enum.PartType.Block
appearance.CollisionShapeMode = "Auto"
appearance.LookShape = "" -- 1일차 돌멩이와 동일하게 외형 모델 템플릿 이름 또는 에셋 ID를 넣을 수 있습니다.

-- [고급 옵션 참고]
-- 아래 값들은 Common 뒷단이 읽을 수 있지만, 2일차 수업 기본 흐름에서는 숨겨둔 옵션입니다.
-- 필요할 때 주석(-- )을 지우고 값을 바꾸면 적용됩니다.
-- appearance.CollisionShapeMode = "LookBounds" -- "Auto", "Shape", "LookBounds", "LookMesh"
-- appearance.CollisionSize = Vector3.new(60, 24, 24) * CM -- Size를 생략했을 때 충돌/물리 크기 전용으로 사용
-- appearance.Shape = Enum.PartType.Block -- CollisionShape의 예전 이름입니다. CollisionShape가 있으면 무시됩니다.
-- appearance.Look = "BrickLook" -- LookShape의 예전 이름입니다. LookShape가 있으면 무시됩니다.

brick.DisplayName = "쌓기 벽돌"
brick.Appearance = appearance
brick.SpawnCount = 10
-- brick.VariantId = "Student01_Brick" -- 같은 벽돌 종류를 구분하고 스폰 랜덤 배치를 고정하는 ID
-- brick.SpawnRadius = 6 -- 스폰 마커 주변에 흩뿌릴 반경입니다. 생략하면 벽돌 크기 기준으로 자동 계산됩니다.
-- brick.SpawnOffset = Vector3.new(0, 0, 0) -- 전체 스폰 위치를 조금 옮기는 선생님 운영용 옵션입니다.
-- brick.WorldAnchored = false -- true면 월드에 놓인 벽돌이 고정되어 굴러가지 않습니다.
-- brick.WorldCanCollide = true -- 월드에 놓인 벽돌이 다른 벽돌/지형과 물리 충돌할지 정합니다.
-- brick.WorldMassless = false -- true면 월드 물리 계산에서 벽돌 무게를 거의 무시하게 합니다.

return brick
