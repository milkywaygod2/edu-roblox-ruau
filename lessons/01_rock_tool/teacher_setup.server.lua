-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 Tool 장착, Touched 데미지, Velocity 넉백을 첫 전투 도구로 준비합니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 장면으로, 학생이 눈에 보이는 Part가 실제 공격 규칙이 되는 경험을 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 Tool 장착, Touched 데미지, Velocity 넉백을 첫 전투 도구로 준비합니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 장면으로, 학생이 눈에 보이는 Part가 실제 공격 규칙이 되는 경험을 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 01_rock_tool_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Arena01, StarterPack/PracticeRock
-- 안전 운영: 기존 01 오브젝트와 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Explorer에 연습 아레나와 PracticeRock이 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local serviceStarterPack = game:GetService(common.enumServiceName.STARTER_PACK)                               -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 학생이 시작할 때 가질 툴을 넣어두기 위함
local serviceWorkspace = game:GetService(common.enumServiceName.WORKSPACE)                                    -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵과 더미 등의 물리 공간을 제어하기 위함

local folderArena01 = common.createOrReplaceInstance(common.enumObjectPhysicalType.FOLDER, common.enumObjectLogicalType.ARENA01, serviceWorkspace) -- [의미/의도] Arena01 Folder 대체 생성 ➔ 기존 폴더를 지우고 깨끗한 새 폴더로 1일차 맵 구성을 시작하기 위함

local partPracticeBase = Instance.new(common.enumObjectPhysicalType.PART)                                     -- [의미/의도] 새 파트(블록)를 생성함 ➔ 학생들이 연습할 경기장의 바닥판을 만들기 위함
partPracticeBase.Name = common.enumObjectLogicalType.PRACTICE_BASE                                            -- [의미/의도] 파트 이름을 "PracticeBase"로 설정 ➔ 탐색기에서 바닥판 파트를 구분하기 위함
partPracticeBase.Size = Vector3.new(80, 1, 80)                                                                -- [의미/의도] 파트 크기를 가로 80, 높이 1, 세로 80으로 설정 ➔ 학생들이 충분히 전투를 치를 수 있는 넓은 경기장을 만들기 위함
partPracticeBase.Position = Vector3.new(0, -0.5, 0)                                                           -- [의미/의도] 파트 위치를 (0, -0.5, 0)으로 설정 ➔ 높이를 낮춰 플레이어가 서기 편한 바닥면을 만들기 위함
partPracticeBase.Anchored = true                                                                              -- [의미/의도] 파트를 고정(Anchored) 상태로 만듦 ➔ 바닥이 중력에 의해 떨어지거나 움직이지 않고 고정되도록 함
partPracticeBase.Material = Enum.Material.Grass                                                               -- [의미/의도] 파트 재질을 잔디(Grass)로 설정 ➔ 자연스럽고 시각적으로 예쁜 잔디밭 경기장을 만들기 위함
partPracticeBase.Parent = folderArena01                                                                       -- [의미/의도] 파트 부모를 1일차 폴더로 설정 ➔ 바닥판을 1일차 경기장 폴더 내부에 깔끔하게 정리하기 위함

for index = 1, 4 do                                                                                           -- [의미/의도] 1부터 4까지 반복 루프를 실행 ➔ 타격 연습용 더미 4개를 일정한 위치에 자동 생성하기 위함
    local modelPracticeDummy = Instance.new(common.enumObjectPhysicalType.MODEL)                              -- [의미/의도] 새 모델(Model)을 생성함 ➔ 더미의 파트와 인간 형태(Humanoid)를 하나로 묶기 위함
    modelPracticeDummy.Name = common.enumObjectLogicalType.PRACTICE_DUMMY_PREFIX .. index                     -- [의미/의도] 모델 이름을 번호에 맞게 설정 ➔ 각 더미를 고유 번호로 구분하기 위함
    modelPracticeDummy.Parent = folderArena01                                                                 -- [의미/의도] 모델 부모를 경기장 폴더로 설정 ➔ 더미를 경기장 폴더 내부에 깔끔하게 정렬하기 위함

    local partHumanoidRoot = Instance.new(common.enumObjectPhysicalType.PART)                                 -- [의미/의도] 새 파트를 생성함 ➔ 더미의 물리적 몸통 역할을 할 HumanoidRootPart를 만들기 위함
    partHumanoidRoot.Name = common.enumObjectLogicalType.RESERVED_HUMANOID_ROOT_PART                          -- [의미/의도] 파트 이름을 "HumanoidRootPart"로 설정 ➔ 캐릭터가 움직이고 타격받는 중심 물리 파트로 선언하기 위함
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)                                                              -- [의미/의도] 파트 크기를 3x5x2로 설정 ➔ 사람 몸집 크기만한 몸통을 구현하기 위함
    partHumanoidRoot.Position = Vector3.new(index * 8 - 20, 2.5, -18)                                         -- [의미/의도] 파트 위치를 가로로 정렬해 설정 ➔ 4개의 더미가 나란히 줄 서서 배치되도록 하기 위함
    partHumanoidRoot.Anchored = true                                                                          -- [의미/의도] 파트를 고정 상태로 만듦 ➔ 공격을 받아도 더미가 쓰러지거나 제멋대로 날아가지 않고 제자리에 고정되도록 함
    partHumanoidRoot.BrickColor = BrickColor.new("Bright red")                                                -- [의미/의도] 파트 색상을 밝은 빨간색으로 설정 ➔ 적으로 식별하기 쉽도록 시각적으로 강조하기 위함
    partHumanoidRoot.Parent = modelPracticeDummy                                                              -- [의미/의도] 파트 부모를 해당 더미 모델로 설정 ➔ 파트가 더미의 신체 부위가 되도록 묶기 위함

    local humanoidPractice = Instance.new(common.enumObjectPhysicalType.HUMANOID)                             -- [의미/의도] 새 Humanoid 객체를 생성함 ➔ 더미에게 체력과 데미지를 입을 수 있는 생명체 특성을 부여하기 위함
    humanoidPractice.MaxHealth = 100                                                                          -- [의미/의도] 최대 체력을 100으로 설정 ➔ 표준 캐릭터 스펙의 최대 체력을 지정하기 위함
    humanoidPractice.Health = 100                                                                             -- [의미/의도] 현재 체력을 100으로 설정 ➔ 더미가 처음 생겨날 때 꽉 찬 체력을 갖게 하기 위함
    humanoidPractice.Parent = modelPracticeDummy                                                              -- [의미/의도] Humanoid의 부모를 더미 모델로 설정 ➔ 모델이 인간형 생명체로 작동되도록 최종 완성하기 위함
end

local toolPracticeRock = common.createOrReplaceInstance(common.enumObjectPhysicalType.TOOL, common.enumObjectLogicalType.PRACTICE_ROCK, serviceStarterPack) -- [의미/의도] PracticeRock Tool 대체 생성 ➔ 기존 무기를 지우고 기본 지급용 무기를 초기화하기 위함
toolPracticeRock.ToolTip = "클릭하면 연습용 돌멩이를 던집니다"                                                               -- [의미/의도] 말풍선 설명을 설정 ➔ 마우스를 올렸을 때 사용법 힌트를 띄우기 위함

local partHandle = Instance.new(common.enumObjectPhysicalType.PART)                                           -- [의미/의도] 새 파트를 생성함 ➔ 플레이어의 손에 직접 닿는 손잡이(Handle)를 구현하기 위함
partHandle.Name = common.enumObjectLogicalType.RESERVED_HANDLE                                                -- [의미/의도] 파트 이름을 "Handle"로 설정 ➔ 로블록스 툴 시스템이 이 파트를 손잡이로 자동 인식하도록 약속된 이름을 쓰기 위함
partHandle.Shape = Enum.PartType.Ball                                                                         -- [의미/의도] 파트 모양을 구체(Ball) 모양으로 설정 ➔ 무기 컨셉인 '돌멩이' 비주얼에 맞추기 위함
partHandle.Size = Vector3.new(1, 1, 1)                                                                        -- [의미/의도] 파트 크기를 1x1x1로 설정 ➔ 캐릭터가 손에 쥐기 알맞은 아담한 크기로 만들기 위함
partHandle.Material = Enum.Material.Slate                                                                     -- [의미/의도] 파트 재질을 돌(Slate) 재질로 설정 ➔ 무기 컨셉인 돌멩이 질감을 사실적으로 연출하기 위함
partHandle.Parent = toolPracticeRock                                                                          -- [의미/의도] 손잡이 파트 부모를 PracticeRock 도구로 설정 ➔ 도구 안에 손잡이를 장착하여 플레이어가 잡을 수 있게 완성하기 위함

print("1일차 준비 완료")                                                                                            -- [의미/의도] 콘솔에 완료 메시지를 출력 ➔ 셋업 코드가 에러 없이 정상적으로 끝났음을 교사에게 확인시켜 주기 위함
