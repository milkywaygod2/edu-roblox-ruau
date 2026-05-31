-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/MagicStaff, Workspace/Day11_MagicArena, ReplicatedStorage/CastMagic
-- 안전 운영: 기존 Day11 Tool과 아레나를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: MagicStaff, 마법 아레나, CastMagic RemoteEvent가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

local serviceStarterPack = game:GetService("StarterPack")             -- [의미] StarterPack 서비스를 가져옴 / [의도] 플레이어 접속 시 마법 지팡이 도구(Tool)를 인벤토리에 자동 배치해주기 위함
local serviceReplicatedStorage = game:GetService("ReplicatedStorage") -- [의미] ReplicatedStorage 서비스를 가져옴 / [의도] 클라이언트와 서버가 공유하는 저장소에 원격 이벤트를 배치하기 위함
local serviceWorkspace = game:GetService("Workspace")                 -- [의미] Workspace 서비스를 가져옴 / [의도] 게임 세상(Workspace)에 11일차 마법 아레나와 연습 더미들을 배치하기 위함

local remoteeventOldRemote = serviceReplicatedStorage:FindFirstChild("CastMagic") -- [의미] ReplicatedStorage에서 기존 "CastMagic" 리모트 이벤트를 찾음 / [의도] 중복으로 등록된 원격 통신 개체가 있는지 확인하기 위함
if remoteeventOldRemote then remoteeventOldRemote:Destroy() end                   -- [의미] 기존 리모트 이벤트가 있다면 제거 / [의도] 셋업 재실행 시 통신 네트워크에 기형적인 채널 꼬임이 없도록 깔끔하게 지우기 위함

local remoteeventCastMagic = Instance.new("RemoteEvent") -- [의미] 새로운 리모트이벤트(RemoteEvent) 객체를 생성함 / [의도] 클라이언트(마우스 입력)에서 서버(데미지 판정)로 데이터를 전송할 통신 채널을 구축하기 위함
remoteeventCastMagic.Name = "CastMagic"                  -- [의미] 리모트이벤트 이름을 "CastMagic"으로 설정 / [의도] 클라이언트 스크립트가 해당 이름의 통신망을 찾아 연결할 수 있게 예약하기 위함
remoteeventCastMagic.Parent = serviceReplicatedStorage   -- [의미] 리모트이벤트 부모를 ReplicatedStorage로 설정 / [의도] 클라이언트와 서버 스크립터 둘 다 통신망에 동시 접근할 수 있도록 공유 공간에 배치하기 위함

local toolOldTool = serviceStarterPack:FindFirstChild("MagicStaff") -- [의미] StarterPack에서 기존 "MagicStaff" 도구를 찾음 / [의도] 기존 지팡이가 존재한다면 제거하기 위함
if toolOldTool then toolOldTool:Destroy() end                       -- [의미] 기존 지팡이 도구가 있으면 삭제 / [의도] 셋업 재실행 시 중복 장비가 인벤토리에 쌓이는 것을 방지하기 위함

local toolMagicStaff = Instance.new("Tool") -- [의미] 새로운 도구(Tool) 객체를 생성함 / [의도] 플레이어가 들고 마법을 시전할 마법 지팡이 장비를 만들기 위함
toolMagicStaff.Name = "MagicStaff"          -- [의미] 도구 이름을 "MagicStaff"으로 설정 / [의도] 탐색기에서 마법 지팡이임을 명확하게 식별하기 위함
toolMagicStaff.ToolTip = "서버 판정 마법을 시전합니다"  -- [의미] 도구 툴팁 설명을 작성 / [의도] 플레이어에게 이 지팡이가 서버 연동식 마법 스킬용 장비임을 안내하기 위함
toolMagicStaff.Parent = serviceStarterPack  -- [의미] 도구를 StarterPack의 자식으로 등록 / [의도] 접속하는 플레이어들에게 지팡이를 기본 장비로 지급하기 위함

local partHandle = Instance.new("Part")                -- [의미] 새로운 파트(Part) 객체를 생성함 / [의도] 지팡이의 손잡이이자 겉보기 외형(Handle)을 만들기 위함
partHandle.Name = "Handle"                             -- [의미] 파트 이름을 반드시 "Handle"로 설정 / [의도] 로블록스 도구 시스템이 캐릭터의 손 위치에 알아서 달라붙게 하기 위함
partHandle.Size = Vector3.new(0.6, 5, 0.6)             -- [의미] 파트 크기를 0.6x5x0.6으로 가늘고 긴 막대 모양으로 설정 / [의도] 시각적으로 긴 장대 마법 지팡이 형태를 묘사하기 위함
partHandle.Material = Enum.Material.Neon               -- [의미] 파트 재질을 네온(Neon)으로 설정 / [의도] 지팡이가 보랏빛 마법 에너지를 내며 화려하게 발광하도록 연출하기 위함
partHandle.BrickColor = BrickColor.new("Royal purple") -- [의미] 파트 색을 고귀한 보라색(Royal purple)으로 지정 / [의도] 신비로운 마법 마력이 깃든 지팡이의 색상을 부각시키기 위함
partHandle.Parent = toolMagicStaff                     -- [의미] 핸들 파트를 MagicStaff 도구의 자식으로 등록 / [의도] 장착 시 이 네온 지팡이 외형이 캐릭터 손에 부착되도록 하기 위함

local folderOldArena = serviceWorkspace:FindFirstChild("Day11_MagicArena") -- [의미] Workspace에서 기존 "Day11_MagicArena" 폴더가 있는지 확인 / [의도] 중복 생성을 방지하기 위함
if folderOldArena then folderOldArena:Destroy() end                        -- [의미] 기존 마법 아레나 폴더를 삭제 / [의도] 11일차 셋업 재실행 시 연습용 더미 아레나가 겹쳐 생성되는 현상을 차단하기 위함

local folderDay11MagicArena = Instance.new("Folder") -- [의미] 새로운 폴더(Folder) 객체를 생성함 / [의도] 11일차 실습에서 쏠 마법 연습 대상 더미들을 묶어서 관리하기 위함
folderDay11MagicArena.Name = "Day11_MagicArena"      -- [의미] 폴더 이름을 "Day11_MagicArena"로 설정 / [의도] 탐색기에서 11일차 전용 아레나 영역임을 식별하기 위함
folderDay11MagicArena.Parent = serviceWorkspace      -- [의미] 폴더 부모를 Workspace로 설정 / [의도] 월드 상에 마법 아레나 폴더가 존재하게 하기 위함

for index = 1, 6 do                                   -- [의미] index 변수를 1부터 6까지 6번 반복 실행 / [의도] 마법 광역 공격을 맞아줄 연습용 더미 6마리를 만들기 위함
    local modelPracticeDummy = Instance.new("Model")  -- [의미] 새로운 모델(Model) 객체를 생성함 / [의도] 캐릭터 역할을 할 파트와 Humanoid를 하나로 결합하기 위함
    modelPracticeDummy.Name = "MagicDummy_" .. index  -- [의미] 모델 이름을 인덱스 번호를 붙여 "MagicDummy_1" 등으로 설정 / [의도] 각 더미를 고유 번호로 쉽게 구분하기 위함
    modelPracticeDummy.Parent = folderDay11MagicArena -- [의미] 모델의 부모를 Day11_MagicArena 폴더로 지정 / [의도] 11일차 아레나 폴더 내에 묶어 보관하기 위함

    local partHumanoidRoot = Instance.new("Part")                     -- [의미] 새로운 파트(Part) 객체를 생성함 / [의도] 캐릭터 중심 몸통(HumanoidRootPart) 역할을 할 파트를 만들기 위함
    partHumanoidRoot.Name = "HumanoidRootPart"                        -- [의미] 파트 이름을 반드시 "HumanoidRootPart"로 지정 / [의도] Humanoid 시스템이 이 파트를 캐릭터의 물리 기준 좌표로 자동 연결하도록 하기 위함
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)                      -- [의미] 파트 크기를 3x5x2로 큼직하게 설정 / [의도] 넓은 면적의 샌드백처럼 만들기 위함
    partHumanoidRoot.Position = Vector3.new(index * 7 - 24, 2.5, -25) -- [의미] 더미 X좌표를 7칸 간격으로 가로 정렬하고, 높이 2.5, 전방 -25에 배치 / [의도] 6마리의 더미가 겹치지 않고 일직선상에 간격을 두고 나란히 정렬되도록 위함
    partHumanoidRoot.Anchored = true                                  -- [의미] 몸통 파트를 공중에 고정시킴 / [의도] 마법 폭발이나 충격 물리에도 흔들리거나 자빠지지 않고 샌드백처럼 고정되도록 하기 위함
    partHumanoidRoot.Parent = modelPracticeDummy                      -- [의미] 몸통 파트를 더미 모델의 자식으로 등록 / [의도] 더미 캐릭터의 중심 구조물로 귀속시키기 위함

    local humanoidPractice = Instance.new("Humanoid") -- [의미] 새로운 Humanoid 객체를 생성함 / [의도] 캐릭터에게 HP 및 TakeDamage 연산 등 생명체 기능을 부여하기 위함
    humanoidPractice.Parent = modelPracticeDummy      -- [의미] Humanoid를 더미 모델의 자식으로 등록 / [의도] 더미 모델이 HP 바가 표시되는 실제 생명체가 되도록 활성화하기 위함
end                                                   -- [의미] 더미 생성 반복문(for)의 종료 / [의도] 6마리의 연습용 더미 생성을 모두 마침

print("11일차 준비 완료") -- [의미] 출력창에 메시지 출력 / [의도] 셋업 과정이 성공적으로 마무리되었음을 확인하기 위함
