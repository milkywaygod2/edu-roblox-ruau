-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 초기 적응 구간의 Part/Properties 실습을 공성전 엄폐물 필드로 구체화했습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 초기 적응 구간의 Part/Properties 실습을 공성전 엄폐물 필드로 구체화했습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 02_cover_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/CoverField02
-- 안전 운영: 기존 02 오브젝트를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Explorer에 엄폐물 필드가 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local serviceWorkspace = game:GetService("Workspace")             -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드 공간(Workspace)에 접근하여 파트 및 폴더를 제어하기 위함
local folderOld = serviceWorkspace:FindFirstChild("CoverField02") -- [의미/의도] Workspace 내에서 "CoverField02" 이름을 가진 자식 객체를 찾음 ➔ 기존에 만들어진 폴더가 있는지 검사하기 위함
if folderOld then folderOld:Destroy() end                         -- [의미/의도] 기존 폴더가 존재한다면 제거함 ➔ 수업이 중복 실행되어 맵이 겹치는 현상을 방지하기 위함

local folderCoverField02 = Instance.new("Folder") -- [의미/의도] 새로운 폴더(Folder) 객체를 생성함 ➔ 2일차 수업에 필요한 파트들을 하나로 묶어 관리하기 위함
folderCoverField02.Name = "CoverField02"          -- [의미/의도] 폴더의 이름을 "CoverField02"로 설정 ➔ 게임 탐색기(Explorer)에서 폴더를 찾기 쉽게 지정함
folderCoverField02.Parent = serviceWorkspace      -- [의미/의도] 폴더의 부모를 Workspace로 설정 ➔ 폴더가 게임 세상에 실제로 추가되도록 함

local partGridBase = Instance.new("Part")       -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 엄폐물 실습을 진행할 바닥(GridBase)을 만들기 위함
partGridBase.Name = "GridBase"                  -- [의미/의도] 파트 이름을 "GridBase"로 설정 ➔ 바닥 구역임을 탐색기에서 구분할 수 있게 지정함
partGridBase.Size = Vector3.new(90, 1, 70)      -- [의미/의도] 바닥 파트의 가로, 세로, 높이 크기를 설정 ➔ 엄폐물 배치 실습을 진행할 수 있는 넉넉한 공간을 확보하기 위함
partGridBase.Position = Vector3.new(0, -0.5, 0) -- [의미/의도] 바닥 파트의 중심 좌표 위치를 설정 ➔ 맵의 중심부에 위치시키기 위함
partGridBase.Anchored = true                    -- [의미/의도] 파트를 공중에 고정시킴 ➔ 물리 중력에 의해 떨어지거나 밀리지 않고 맵에 단단히 고정되도록 함
partGridBase.Material = Enum.Material.Concrete  -- [의미/의도] 파트의 재질을 콘크리트(Concrete)로 설정 ➔ 엄폐 실습장 바닥의 재질을 시각적으로 나타내기 위함
partGridBase.Parent = folderCoverField02        -- [의미/의도] 바닥 파트를 CoverField02 폴더의 자식으로 등록 ➔ 해당 폴더 안에서 깔끔하게 관리하기 위함

for index = 1, 5 do                                                  -- [의미/의도] index 변수를 1부터 5까지 증가시키며 반복함 ➔ 총 5개의 엄폐물 배치 기준 표시판(Marker)을 만들기 위함
    local partCoverMarker = Instance.new("Part")                     -- [의미/의도] 새로운 파트(Part)를 생성함 ➔ 엄폐물을 배치할 기준 위치 마커를 만들기 위함
    partCoverMarker.Name = "CoverMarker_" .. index                   -- [의미/의도] 마커의 이름을 번호를 붙여 "1_CoverMarker" 등으로 설정 ➔ 각각의 마커를 이름으로 쉽게 구분하기 위함
    partCoverMarker.Size = Vector3.new(2, 0.2, 2)                    -- [의미/의도] 마커 파트의 크기를 2x0.2x2로 얇게 설정 ➔ 바닥에 밀착되는 얇은 표시판 형태로 만들기 위함
    partCoverMarker.Position = Vector3.new(index * 8 - 24, 0.1, -10) -- [의미/의도] 마커 파트의 위치 좌표를 인덱스별로 다르게 계산하여 배치 ➔ 5개의 마커가 일정 간격(8칸)으로 나란히 정렬되도록 위함
    partCoverMarker.Anchored = true                                  -- [의미/의도] 마커 파트를 고정시킴 ➔ 플레이어가 밟아도 움직이지 않도록 고정하기 위함
    partCoverMarker.BrickColor = BrickColor.new("Bright yellow")     -- [의미/의도] 마커 파트의 색상을 밝은 노란색(Bright yellow)으로 설정 ➔ 바닥에서 눈에 잘 띄게 표현하기 위함
    partCoverMarker.Parent = folderCoverField02                      -- [의미/의도] 마커 파트를 CoverField02 폴더의 자식으로 등록 ➔ 2일차 폴더 내부에서 엄폐물 마커들을 한데 모아 관리하기 위함
end                                                                  -- [의미/의도] 반복문(for)의 종료 ➔ 5번의 마커 생성 및 설정을 마침

print("2일차 준비 완료") -- [의미/의도] 출력창에 "2일차 준비 완료" 메시지를 출력함 ➔ 스크립트가 정상적으로 끝까지 실행되었음을 알리기 위함
