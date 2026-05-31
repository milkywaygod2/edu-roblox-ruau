-- Roblox Studio 수업 스크립트 안내
-- 수업: 09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 석조 성벽 결합, 총안구, 부분 파괴 성벽을 준비합니다.
-- 강의가이드 연결: 공성전 맵의 성벽은 한 덩어리가 아니라 구역별로 피해와 붕괴를 추적하는 구조물입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 석조 성벽 결합, 총안구, 부분 파괴 성벽을 준비합니다.
-- 강의가이드 연결: 공성전 맵의 성벽은 한 덩어리가 아니라 구역별로 피해와 붕괴를 추적하는 구조물입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 09_stone_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/StoneWall09
-- 안전 운영: 기존 09 성벽을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 구역별 성벽 파트가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local serviceWorkspace = game:GetService("Workspace")            -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드인 Workspace 상에 9일차 석조 성벽을 생성하기 위함
local folderOld = serviceWorkspace:FindFirstChild("StoneWall09") -- [의미/의도] Workspace에서 기존 "StoneWall09" 폴더가 존재하는지 확인 ➔ 중복으로 생성되는 것을 감지하기 위함
if folderOld then folderOld:Destroy() end                        -- [의미/의도] 기존 성벽 폴더가 존재한다면 파괴 ➔ 9일차 준비 스크립트 재실행 시 성벽들이 겹쳐서 기형적으로 렌더링되거나 물리 에러가 나는 것을 방지하기 위함

local folderStoneWall09 = Instance.new("Folder") -- [의미/의도] 새로운 폴더(Folder) 객체를 생성함 ➔ 9일차 실습에서 제어할 성벽 섹션 모델들을 하나로 그룹화하여 관리하기 위함
folderStoneWall09.Name = "StoneWall09"           -- [의미/의도] 폴더 이름을 "StoneWall09"로 지정 ➔ 탐색기에서 9일차 석조 성벽 프로젝트 영역임을 파악하기 위함
folderStoneWall09.Parent = serviceWorkspace      -- [의미/의도] 폴더 부모를 Workspace로 설정 ➔ 폴더가 게임 세상에 반영되도록 하기 위함

for section = 1, 5 do                                 -- [의미/의도] section 변수를 1부터 5 till 5까지 증가시키며 반복함 ➔ 성벽을 5개의 부분 섹션(Section)으로 나누어 독립적인 파괴가 가능하도록 구조화하기 위함
    local modelWallSection = Instance.new("Model")    -- [의미/의도] 새로운 모델(Model) 객체를 생성함 ➔ 특정 섹션에 쌓여진 돌 블록 파트들을 하나의 성벽 섹션 모델로 결합하기 위함
    modelWallSection.Name = "WallSection_" .. section -- [의미/의도] 모델 이름을 인덱스를 붙여 "1_WallSection" 등으로 설정 ➔ 각각의 성벽 구획을 고유 번호로 쉽게 구분하고 독립 처리하기 위함
    modelWallSection.Parent = folderStoneWall09       -- [의미/의도] 성벽 섹션 모델 부모를 StoneWall09 폴더로 지정 ➔ 9일차 성벽 폴더 내에 가지런히 소속시키기 위함

    for height = 1, 4 do                                                              -- [의미/의도] height 변수를 1부터 4까지 증가시키며 반복함 ➔ 각 성벽 섹션마다 돌 블록을 4층 높이로 쌓아 올리기 위함
        local partStoneBlock = Instance.new("Part")                                   -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 성벽의 뼈대가 될 개별 돌 블록 파트를 만들기 위함
        partStoneBlock.Name = "StoneBlock"                                            -- [의미/의도] 파트 이름을 "StoneBlock"으로 설정 ➔ 탐색기에서 돌 블록 파트임을 구분하게 하기 위함
        partStoneBlock.Size = Vector3.new(6, 2, 2)                                    -- [의미/의도] 돌 블록 크기를 6x2x2로 넙데데하고 두껍게 설정 ➔ 튼튼해 보이는 직사각형 성벽 벽돌 모양을 묘사하기 위함
        partStoneBlock.Position = Vector3.new((section - 3) * 6, height * 2 - 1, -24) -- [의미/의도] X축은 섹션 번호에 따라 가로 정렬하고, Y축 높이는 층수(height)에 맞게 위로 쌓아, Z축 -24 전방에 위치 설정 ➔ 가로로 붙은 5개 섹션이 각각 4층 높이로 빈틈없이 단단하게 이어져 큰 하나의 성벽을 연출하도록 설계된 정밀 좌표 공식임
        partStoneBlock.Anchored = true                                                -- [의미/의도] 돌 블록 파트를 공중에 고정시킴 ➔ 공격을 받아고정이 풀려 무너지기 전까지는 성벽 블록이 제자리에서 든든히 버티도록 고정하기 위함
        partStoneBlock.Material = Enum.Material.Slate                                 -- [의미/의도] 파트 재질을 슬레이트 돌(Slate)로 지정 ➔ 단단한 돌로 쌓아 올린 중세 석조 성벽의 질감을 표현하기 위함
        partStoneBlock.Parent = modelWallSection                                      -- [의미/의도] 돌 블록 파트를 해당 modelWallSection 모델의 자식으로 등록 ➔ 돌 블록들이 성벽의 해당 구획 모델에 올바르게 그룹화되도록 지정함
    end                                                                               -- [의미/의도] 높이 쌓기 반복문(for)의 종료 ➔ 4층짜리 블록 쌓기 처리를 마침
end                                                                                   -- [의미/의도] 섹션 생성 반복문(for)의 종료 ➔ 5개 성벽 섹션 생성을 모두 마침

print("9일차 준비 완료") -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 성공적으로 끝났음을 알리기 위함
