-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 빌더/스크립터/크리에이터 단계를 엄폐물 생성과 속성 변경으로 나눴습니다.
-- 미션 단계: 빌더=파트 배치/Anchored, 스크립터=재질과 물리 속성 변경, 크리에이터=여러 파트를 모델처럼 묶어 정리입니다.
-- 강의가이드 연결: Studio 안전지대의 Part, Material, Color, Size, Position 조작을 코드로 반복 생성합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer02
-- 선행 조건: 선생님이 teacher_setup.server.lua를 먼저 실행해 Workspace/CoverField02를 만들어야 합니다.
-- 학생 목표: 눈에 보이는 Part 속성이 게임 플레이의 엄폐/충돌 규칙으로 바뀌는 과정을 이해합니다.
-- 검증 기준: Play 후 나무/돌 느낌의 엄폐물이 정해진 위치에 생성되고 Output 오류가 없으면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local folderCoverField02 = workspace:WaitForChild(common.enumObjectLogicalType.COVER_FIELD02)                 -- [의미/의도] Workspace에서 "CoverField02" 폴더가 생성될 때까지 대기 후 가져옴 ➔ 선생님 스크립트가 폴더를 생성할 때까지 대기하여 에러를 방지하기 위함
local materials = {Enum.Material.WoodPlanks, Enum.Material.Slate, Enum.Material.Metal}                        -- [의미/의도] 나무판자, 돌, 금속 재질을 담은 배열 리스트 생성 ➔ 다양한 질감의 엄폐물을 생성할 수 있도록 후보군을 저장함
local colors = {"Reddish brown", "Dark stone grey", "Medium blue"}                                            -- [의미/의도] 갈색, 회색, 청색 색상 이름을 담은 배열 리스트 생성 ➔ 재질에 어울리는 색상들을 매칭하기 위함

local function create_cover(name, vectorOrigin, material, colorName)                                          -- [의미/의도] 엄폐물을 생성하는 함수 정의 (이름, 기준위치, 재질, 색상명 입력) ➔ 반복적인 엄폐물 생성 코드를 함수로 묶어 재사용하기 위함
    local modelCover = Instance.new(common.enumObjectPhysicalType.MODEL)                                      -- [의미/의도] 새로운 모델(Model) 객체를 생성함 ➔ 여러 개의 엄폐용 파트들을 하나의 의미 있는 덩어리로 묶어 관리하기 위함
    modelCover.Name = name                                                                                    -- [의미/의도] 모델의 이름을 매개변수로 받은 name으로 설정 ➔ 생성되는 엄폐물의 번호를 붙여 구분하기 위함
    modelCover.Parent = folderCoverField02                                                                    -- [의미/의도] 모델의 부모를 CoverField02 폴더로 설정 ➔ 2일차 엄폐물 폴더 내부에 깔끔하게 위치시키기 위함

    for level = 1, 3 do                                                                                       -- [의미/의도] level 변수를 1부터 3까지 증가시키며 반복함 ➔ 아래에서 위로 3층 높이의 엄폐물 블록을 쌓아 올리기 위함
        local partCoverBlock = Instance.new(common.enumObjectPhysicalType.PART)                               -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 엄폐물을 구성하는 개별 벽돌 블록을 만들기 위함
        partCoverBlock.Name = common.enumObjectLogicalType.COVER_BLOCK_PREFIX .. level                        -- [의미/의도] 파트 이름을 "1_CoverBlock" 등으로 층수를 붙여 설정 ➔ 각 층의 벽돌 블록임을 쉽게 구분하기 위함
        partCoverBlock.Size = Vector3.new(8 - level, 2, 2)                                                    -- [의미/의도] 파트 크기를 설정하되 가로 길이는 층수가 높을수록 좁아지게(8-level) 설정 ➔ 위로 갈수록 좁아지는 안정적인 피라미드 모양의 엄폐물을 디자인하기 위함
        partCoverBlock.Position = vectorOrigin + Vector3.new(0, level, 0)                                     -- [의미/의도] 기준 위치에서 Y(높이) 값을 층수만큼 더한 위치로 설정 ➔ 파트들이 겹치지 않고 1층, 2층, 3층으로 차곡차곡 쌓이도록 배치하기 위함
        partCoverBlock.Anchored = true                                                                        -- [의미/의도] 파트를 공중에 고정시킴 ➔ 엄폐물이 무너지거나 플레이어에 의해 밀려나지 않도록 고정하기 위함
        partCoverBlock.CanCollide = true                                                                      -- [의미/의도] 충돌 여부(CanCollide)를 참(true)으로 설정 ➔ 플레이어나 발사체가 통과하지 못하고 벽에 걸리는 물리 효과를 구현하기 위함
        partCoverBlock.Material = material                                                                    -- [의미/의도] 파트 재질을 매개변수로 받은 material로 설정 ➔ 블록에 어울리는 시각적 질감(나무/돌/금속)을 적용하기 위함
        partCoverBlock.BrickColor = BrickColor.new(colorName)                                                 -- [의미/의도] 파트 색상을 매개변수로 받은 colorName으로 설정 ➔ 시각적으로 재질에 매칭되는 적절한 색깔을 입히기 위함
        partCoverBlock.Parent = modelCover                                                                    -- [의미/의도] 생성된 파트를 앞서 만든 modelCover 모델의 자식으로 등록 ➔ 3개의 블록이 하나의 엄폐물 모델에 묶여 속하도록 함
    end                                                                                                       -- [의미/의도] 3층 블록 생성을 위한 반복문(for)의 종료 ➔ 3층 구조의 엄폐물 생성을 마침
end                                                                                                           -- [의미/의도] create_cover 함수의 종료 ➔ 엄폐물 생성 함수 정의를 완료함

for index = 1, 3 do                                                                                           -- [의미/의도] index 변수를 1부터 3까지 증가시키며 반복함 ➔ 총 3개의 엄폐물 모델을 나란히 생성하기 위함
    create_cover(common.enumObjectLogicalType.COVER_STUDENT_PREFIX .. index, Vector3.new(index * 14 - 28, 1, 8), materials[index], colors[index]) -- [의미/의도] create_cover 함수를 호출하여 3개의 엄폐물을 서로 다른 위치, 재질, 색상으로 생성 ➔ 14칸 간격으로 배치 마커 근처에 서로 다른 엄폐 구조물을 세우기 위함
end                                                                                                           -- [의미/의도] 반복문(for)의 종료 ➔ 3개의 엄폐물 생성을 완료함

print("02 answer complete")                                                                                   -- [의미/의도] 출력창에 완료 메시지를 출력함 ➔ 스크립트 실행이 정상적으로 끝났음을 확인하기 위함
