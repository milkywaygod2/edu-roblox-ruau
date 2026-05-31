-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 방벽이 생기는 공성 방어 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 방벽이 생기는 공성 방어 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day03_resource_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day03_ResourceWall/BuildButton, WallSpawn
-- 안전 운영: 기존 Day03 오브젝트를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 방벽 버튼과 WallSpawn 위치가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local serviceWorkspace = game:GetService("Workspace")                   -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵 상에 3일차 폴더와 버튼을 생성하기 위함
local folderOld = serviceWorkspace:FindFirstChild("Day03_ResourceWall") -- [의미/의도] Workspace 내에서 "Day03_ResourceWall" 이름을 가진 자식 객체를 찾음 ➔ 기존 생성된 폴더가 있는지 검사하기 위함
if folderOld then folderOld:Destroy() end                               -- [의미/의도] 기존 폴더가 존재한다면 제거함 ➔ 수업 재시작 시 오브젝트가 중복으로 겹쳐서 생기는 버그를 막기 위함

local folderDay03ResourceWall = Instance.new("Folder") -- [의미/의도] 새로운 폴더(Folder) 객체를 생성함 ➔ 3일차 수업용 자원 버튼과 방벽 소환판을 한곳에 묶기 위함
folderDay03ResourceWall.Name = "Day03_ResourceWall"    -- [의미/의도] 폴더 이름을 "Day03_ResourceWall"로 설정 ➔ 탐색기에서 다른 일차의 프로젝트와 구분하기 위함
folderDay03ResourceWall.Parent = serviceWorkspace      -- [의미/의도] 폴더 부모를 Workspace로 설정 ➔ 폴더가 게임 세상에 존재하게 만들기 위함

local partBuildButton = Instance.new("Part")                -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 플레이어가 눌러서 방벽을 생성할 물리적인 버튼(BuildButton)을 만들기 위함
partBuildButton.Name = "BuildButton"                        -- [의미/의도] 파트 이름을 "BuildButton"으로 설정 ➔ 탐색기에서 방벽 설치 버튼임을 구분하기 위함
partBuildButton.Size = Vector3.new(6, 1, 6)                 -- [의미/의도] 버튼 파트의 크기를 6x1x6으로 설정 ➔ 플레이어가 올라타거나 쉽게 마우스로 클릭할 수 있도록 넓은 크기로 만듦
partBuildButton.Position = Vector3.new(0, 0.5, 0)           -- [의미/의도] 버튼 파트의 중심 좌표를 설정 ➔ 맵 중심 근처 바닥에 버튼을 위치시키기 위함
partBuildButton.Anchored = true                             -- [의미/의도] 파트를 공중에 고정시킴 ➔ 중력에 떨어지거나 굴러다니지 않고 버튼 위치를 고정하기 위함
partBuildButton.BrickColor = BrickColor.new("Bright green") -- [의미/의도] 버튼 파트의 색을 밝은 초록색(Bright green)으로 지정 ➔ 눌렀을 때 긍정적인 반응이 올 것 같은 색상으로 디자인하기 위함
partBuildButton.Parent = folderDay03ResourceWall            -- [의미/의도] 버튼 파트를 Day03_ResourceWall 폴더의 자식으로 등록 ➔ 3일차 폴더 내부에서 관리하기 위함

local clickdetectorButton = Instance.new("ClickDetector") -- [의미/의도] 새로운 클릭 감지기(ClickDetector) 컴포넌트를 생성함 ➔ 플레이어가 버튼 파트를 마우스로 클릭할 수 있게 기능적으로 연결하기 위함
clickdetectorButton.MaxActivationDistance = 24            -- [의미/의도] 클릭할 수 있는 최대 반경을 24칸으로 제한 ➔ 너무 멀리서 부당하게 버튼을 눌러 소환하는 플레이를 제한하기 위함
clickdetectorButton.Parent = partBuildButton              -- [의미/의도] 클릭 감지기의 부모를 앞서 만든 버튼 파트로 설정 ➔ 버튼 파트에 마우스 클릭 감지 기능을 활성화하기 위함

local partWallSpawn = Instance.new("Part")                 -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 방벽이 실제로 생성될 예상 위치를 나타낼 마커(WallSpawn)를 만들기 위함
partWallSpawn.Name = "WallSpawn"                           -- [의미/의도] 파트 이름을 "WallSpawn"으로 설정 ➔ 방벽 소환판임을 구분하기 위함
partWallSpawn.Size = Vector3.new(2, 0.2, 2)                -- [의미/의도] 마커의 크기를 2x0.2x2로 얇게 설정 ➔ 바닥에 가볍게 깔린 가이드 타일처럼 보이게 만들기 위함
partWallSpawn.Position = Vector3.new(0, 0.1, 12)           -- [의미/의도] 버튼으로부터 Z축 기준 앞으로 12칸 떨어진 곳에 마커 위치를 설정 ➔ 버튼 바로 위가 아니라 약간 앞에 방벽이 생겨 플레이어를 밀어내지 않게 하기 위함
partWallSpawn.Anchored = true                              -- [의미/의도] 마커 파트를 고정시킴 ➔ 마커의 물리적 고정을 위함
partWallSpawn.Transparency = 0.35                          -- [의미/의도] 투명도를 0.35(약간 반투명)로 설정 ➔ 소환 예비 위치라는 표시를 유령처럼 시각적으로 연출하기 위함
partWallSpawn.BrickColor = BrickColor.new("Bright yellow") -- [의미/의도] 마커 파트 색을 밝은 노란색(Bright yellow)으로 지정 ➔ 경고나 주의 위치임을 시각적으로 부각시키기 위함
partWallSpawn.Parent = folderDay03ResourceWall             -- [의미/의도] 마커 파트를 Day03_ResourceWall 폴더의 자식으로 등록 ➔ 3일차 폴더 내부에서 함께 관리하기 위함

print("3일차 준비 완료") -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 과정이 에러 없이 끝남을 확인하기 위함
