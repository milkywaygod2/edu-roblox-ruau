-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/MagicStaff, Workspace/MagicArena11, ReplicatedStorage/CastMagic
-- 안전 운영: 기존 11 Tool과 아레나를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: MagicStaff, 마법 아레나, CastMagic RemoteEvent가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                                    -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eEngineServiceSingleton = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType



local svcStarterPack = game:GetService(eEngineServiceSingleton.STARTER_PACK)                                              -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 플레이어 접속 시 마법 지팡이 도구(Tool)를 인벤토리에 자동 배치해주기 위함
local svcReplicatedStorage = game:GetService(eEngineServiceSingleton.REPLICATED_STORAGE)                                  -- [의미/의도] ReplicatedStorage 서비스를 가져옴 ➔ 클라이언트와 서버가 공유하는 저장소에 원격 이벤트를 배치하기 위함
local svcWorkspace = game:GetService(eEngineServiceSingleton.WORKSPACE)                                                  -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 세상(Workspace)에 11일차 마법 아레나와 연습 더미들을 배치하기 위함

local eventCastMagic = common.createOrReplaceInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage) -- [의미/의도] CastMagic RemoteEvent 대체 생성 ➔ 기존 마법 시전 리모트이벤트를 지우고 통신 채널을 새로 구축하기 위함

local toolMagicStaff = common.createOrReplaceInstance(ePhysical.TOOL, eLogical.MAGIC_STAFF, svcStarterPack) -- [의미/의도] MagicStaff Tool 대체 생성 ➔ 기존 마법 지팡이를 정리하고 새로운 마법 무기를 초기화하기 위함
toolMagicStaff.ToolTip = "서버 판정 마법을 시전합니다"                                                                               -- [의미/의도] 도구 툴팁 설명을 작성 ➔ 플레이어에게 이 지팡이가 서버 연동식 마법 스킬용 장비임을 안내하기 위함

local partHandle = Instance.new(ePhysical.PART)                                                     -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 지팡이의 손잡이이자 겉보기 외형(Handle)을 만들기 위함
partHandle.Name = eLogical.RESERVED_HANDLE                                                          -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 시스템이 캐릭터의 손 위치에 알아서 달라붙게 하기 위함
partHandle.Size = Vector3.new(0.6, 5, 0.6)                                                                              -- [의미/의도] 파트 크기를 0.6x5x0.6으로 가늘고 긴 막대 모양으로 설정 ➔ 시각적으로 긴 장대 마법 지팡이 형태를 묘사하기 위함
partHandle.Material = Enum.Material.Neon                                                                                -- [의미/의도] 파트 재질을 네온(Neon)으로 설정 ➔ 지팡이가 보랏빛 마법 에너지를 내며 화려하게 발광하도록 연출하기 위함
partHandle.BrickColor = BrickColor.new("Royal purple")                                                                  -- [의미/의도] 파트 색을 고귀한 보라색(Royal purple)으로 지정 ➔ 신비로운 마법 마력이 깃든 지팡이의 색상을 부각시키기 위함
partHandle.Parent = toolMagicStaff                                                                                        -- [의미/의도] 핸들 파트를 MagicStaff 도구의 자식으로 등록 ➔ 장착 시 이 네온 지팡이 외형이 캐릭터 손에 부착되도록 하기 위함

local fldMagicArena11 = common.createOrReplaceInstance(ePhysical.FOLDER, eLogical.MAGIC_ARENA11, svcWorkspace) -- [의미/의도] MagicArena11 Folder 대체 생성 ➔ 기존 마법 아레나 폴더를 삭제하고 11일차 마법 연습장을 구성하기 위함

for index = 1, 6 do                                                                                                    -- [의미/의도] index 변수를 1부터 6까지 6번 반복 실행 ➔ 마법 광역 공격을 맞아줄 연습용 더미 6마리를 만들기 위함
    local modelPracticeDummy = Instance.new(ePhysical.MODEL)                                         -- [의미/의도] 새로운 모델(Model) 객체를 생성함 ➔ 캐릭터 역할을 할 파트와 Humanoid를 하나로 결합하기 위함
    modelPracticeDummy.Name = eLogical.MAGIC_DUMMY_PREFIX .. index                                   -- [의미/의도] 모델 이름을 인덱스 번호를 붙여 "1_MagicDummy" 등으로 설정 ➔ 각 더미를 고유 번호로 쉽게 구분하기 위함
    modelPracticeDummy.Parent = fldMagicArena11                                                                            -- [의미/의도] 모델의 부모를 MagicArena11 폴더로 지정 ➔ 11일차 아레나 폴더 내에 묶어 보관하기 위함

    local partHumanoidRoot = Instance.new(ePhysical.PART)                                            -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터 중심 몸통(HumanoidRootPart) 역할을 할 파트를 만들기 위함
    partHumanoidRoot.Name = eLogical.RESERVED_HUMANOID_ROOT_PART                                     -- [의미/의도] 파트 이름을 반드시 "HumanoidRootPart"로 지정 ➔ Humanoid 시스템이 이 파트를 캐릭터의 물리 기준 좌표로 자동 연결하도록 하기 위함
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)                                                                         -- [의미/의도] 파트 크기를 3x5x2로 큼직하게 설정 ➔ 넓은 면적의 샌드백처럼 만들기 위함
    partHumanoidRoot.Position = Vector3.new(index * 7 - 24, 2.5, -25)                                                    -- [의미/의도] 더미 X좌표를 7칸 간격으로 가로 정렬하고, 높이 2.5, 전방 -25에 배치 ➔ 6마리의 더미가 겹치지 않고 일직선상에 간격을 두고 나란히 정렬되도록 위함
    partHumanoidRoot.Anchored = true                                                                                     -- [의미/의도] 몸통 파트를 공중에 고정시킴 ➔ 마법 폭발이나 충격 물리에도 흔들리거나 자빠지지 않고 샌드백처럼 고정되도록 하기 위함
    partHumanoidRoot.Parent = modelPracticeDummy                                                                           -- [의미/의도] 몸통 파트를 더미 모델의 자식으로 등록 ➔ 더미 캐릭터의 중심 구조물로 귀속시키기 위함

    local humPractice = Instance.new(ePhysical.HUMANOID)                                            -- [의미/의도] 새로운 Humanoid 객체를 생성함 ➔ 캐릭터에게 HP 및 TakeDamage 연산 등 생명체 기능을 부여하기 위함
    humPractice.Parent = modelPracticeDummy                                                                               -- [의미/의도] Humanoid를 더미 모델의 자식으로 등록 ➔ 더미 모델이 HP 바가 표시되는 실제 생명체가 되도록 활성화하기 위함
end                                                                                                                    -- [의미/의도] 더미 생성 반복문(for)의 종료 ➔ 6마리의 연습용 더미 생성을 모두 마침

print("11일차 준비 완료")                                                                                                    -- [의미/의도] 출력창에 메시지 출력 ➔ 셋업 과정이 성공적으로 마무리되었음을 확인하기 위함
