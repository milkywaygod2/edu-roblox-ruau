-- Roblox Studio 수업 스크립트 안내
-- 수업: day05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day05_ranged_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/TrainingBow, Workspace/Day05_TargetRange
-- 안전 운영: 기존 Day05 Tool과 사격장을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: TrainingBow와 목표 사격장이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local serviceStarterPack = game:GetService("StarterPack") -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어 인벤토리에 자동으로 활(Tool)을 장착시켜주기 위함
local serviceWorkspace = game:GetService("Workspace")     -- [의미/의도] Workspace 서비스를 가져옴 ➔ 5일차 과녁 연습장 폴더와 파트를 맵에 추가하기 위함

local folderOldRange = serviceWorkspace:FindFirstChild("Day05_TargetRange") -- [의미/의도] Workspace에서 기존 "Day05_TargetRange" 폴더가 있는지 확인 ➔ 기존 리소스를 제거하기 위함
if folderOldRange then folderOldRange:Destroy() end                         -- [의미/의도] 기존 과녁 연습장 폴더가 존재하면 삭제 ➔ 스크립트 재실행 시 중복 생성을 막고 맵을 깨끗하게 정리하기 위함

local folderDay05TargetRange = Instance.new("Folder") -- [의미/의도] 새로운 폴더(Folder) 객체를 생성함 ➔ 5일차 실습에서 쏠 과녁 판들을 묶어서 편하게 관리하기 위함
folderDay05TargetRange.Name = "Day05_TargetRange"     -- [의미/의도] 폴더 이름을 "Day05_TargetRange"로 설정 ➔ 탐색기(Explorer)에서 5일차 전용 영역임을 쉽게 알아보기 위함
folderDay05TargetRange.Parent = serviceWorkspace      -- [의미/의도] 폴더 부모를 Workspace로 설정 ➔ 폴더가 게임 세상에 반영되도록 만들기 위함

for index = 1, 6 do                                           -- [의미/의도] index 변수를 1부터 6까지 6번 반복 실행 ➔ 쏘아 맞힐 수 있는 6개의 과녁판(Target)을 만들기 위함
    local partTarget = Instance.new("Part")                   -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 투사체를 맞춰 쓰러뜨릴 과녁판 파트를 생성하기 위함
    partTarget.Name = "Target_" .. index                      -- [의미/의도] 과녁판 이름을 인덱스 번호를 붙여 "Target_1" 등으로 설정 ➔ 각 과녁을 개별 번호로 구분하기 위함
    partTarget.Size = Vector3.new(4, 6, 1)                    -- [의미/의도] 과녁판의 크기를 4x6x1의 넙데데한 크기로 설정 ➔ 플레이어가 활을 쏴서 충분히 맞힐 수 있는 적당한 과녁 너비로 만들기 위함
    partTarget.Position = Vector3.new(index * 8 - 28, 3, -40) -- [의미/의도] 과녁들을 X축 8칸 간격으로 정렬하고, 높이 3, 전방 Z축 -40에 배치 ➔ 플레이어의 정면에 거리를 두고 일정한 간격으로 나란히 서 있는 과녁 사격장을 연출하기 위함
    partTarget.Anchored = true                                -- [의미/의도] 과녁 파트를 고정시킴 ➔ 화살에 맞기 전까지 바람이나 중력에 의해 넘어지지 않고 꼿꼿이 서 있게 하기 위함
    partTarget.BrickColor = BrickColor.new("Bright red")      -- [의미/의도] 과녁 파트 색을 밝은 빨간색(Bright red)으로 지정 ➔ 멀리서도 뚜렷하게 표적으로 식별되도록 시각적으로 강조하기 위함
    partTarget.Parent = folderDay05TargetRange                -- [의미/의도] 과녁 파트를 Day05_TargetRange 폴더의 자식으로 등록 ➔ 과녁 연습장 폴더 내에 그룹화하여 관리하기 위함
end                                                           -- [의미/의도] 과녁 생성을 위한 반복문(for)의 종료 ➔ 6개의 과녁 생성을 완료함

local toolOldTool = serviceStarterPack:FindFirstChild("TrainingBow") -- [의미/의도] StarterPack에서 기존 "TrainingBow" 도구가 있는지 확인 ➔ 중복으로 생성되는 것을 방지하기 위함
if toolOldTool then toolOldTool:Destroy() end                        -- [의미/의도] 기존 활 도구가 있다면 제거 ➔ 셋업 재실행 시 중복 활 장비를 깔끔하게 제거하기 위함

local toolTrainingBow = Instance.new("Tool")    -- [의미/의도] 새로운 도구(Tool) 객체를 생성함 ➔ 플레이어가 착용하고 화살을 발사할 수 있는 연습용 활을 만들기 위함
toolTrainingBow.Name = "TrainingBow"            -- [의미/의도] 도구 이름을 "TrainingBow"로 설정 ➔ 탐색기에서 연습용 활임을 알아볼 수 있게 하기 위함
toolTrainingBow.ToolTip = "서버에서 투사체를 만드는 연습용 활" -- [의미/의도] 활 도구의 마우스 툴팁을 설정 ➔ 플레이어에게 서버 사이드에서 투사체를 생성함을 팁으로 설명하기 위함
toolTrainingBow.Parent = serviceStarterPack     -- [의미/의도] 활 도구 부모를 StarterPack으로 설정 ➔ 플레이어가 게임 실행 시 인벤토리에 자동 지급받도록 하기 위함

local partHandle = Instance.new("Part")  -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터가 손에 쥘 활의 중심 부위(Handle)를 만들기 위함
partHandle.Name = "Handle"               -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 탑재 시스템이 캐릭터 손바닥에 부착할 파트로 인식하도록 하기 위함
partHandle.Size = Vector3.new(1, 4, 1)   -- [의미/의도] 핸들 파트 크기를 1x4x1로 얇고 길게 설정 ➔ 캐릭터가 쥘 수 있는 적당한 활대 크기를 구현하기 위함
partHandle.Material = Enum.Material.Wood -- [의미/의도] 재질을 나무(Wood)로 설정 ➔ 활의 자연 친화적인 나무 질감을 표현하기 위함
partHandle.Parent = toolTrainingBow      -- [의미/의도] 핸들 파트를 활 도구의 자식으로 등록 ➔ 도구 착용 시 외형으로 나타나게 하기 위함

print("5일차 준비 완료") -- [의미/의도] 출력창에 완료 메시지를 출력함 ➔ 5일차 사격장 및 활 생성 셋업이 완료되었음을 알려주기 위함
