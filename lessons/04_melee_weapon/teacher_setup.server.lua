-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 무기가 작동하는 것에서 끝나지 않고, 연타 방지와 밸런스가 필요하다는 점을 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 무기가 작동하는 것에서 끝나지 않고, 연타 방지와 밸런스가 필요하다는 점을 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 04_melee_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/BalanceSword, Workspace/Dummies04
-- 안전 운영: 기존 04 Tool과 더미를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: BalanceSword와 연습 더미가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함



local serviceStarterPack = game:GetService(common.enumServiceName.STARTER_PACK)                               -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 플레이어가 게임 시작 시 인벤토리에 자동으로 지급받을 도구를 관리하기 위함
local serviceWorkspace = game:GetService(common.enumServiceName.WORKSPACE)                                    -- [의미/의도] Workspace 서비스를 가져옴 ➔ 월드 상에 4일차 더미 폴더와 마커를 관리하기 위함

local toolBalanceSword = common.createOrReplaceInstance(common.enumObjectPhysicalType.TOOL, common.enumObjectLogicalType.BALANCE_SWORD, serviceStarterPack) -- [의미/의도] BalanceSword Tool 대체 생성 ➔ 기존 근접 검 무기를 지우고 새로운 연습용 검을 배치하기 위함
toolBalanceSword.ToolTip = "쿨타임이 있는 연습용 검"                                                                    -- [의미/의도] 도구의 마우스 오버 툴팁 텍스트를 설정 ➔ 플레이어에게 해당 검이 어떤 장비인지 시각적인 팁을 제공하기 위함

local partHandle = Instance.new(common.enumObjectPhysicalType.PART)                                           -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 도구가 손에 쥐어질 때 기준점이 되는 부위(Handle)를 만들기 위함
partHandle.Name = common.enumObjectLogicalType.RESERVED_HANDLE                                                -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 시스템이 캐릭터의 손에 붙이는 부위로 자동 인식하게 하기 위함
partHandle.Size = Vector3.new(1, 5, 1)                                                                        -- [의미/의도] 핸들 파트의 크기를 1x5x1의 얇고 긴 크기로 설정 ➔ 플레이어가 손에 쥐는 검 모양의 긴 형태로 묘사하기 위함
partHandle.Material = Enum.Material.Metal                                                                     -- [의미/의도] 파트 재질을 금속(Metal)으로 지정 ➔ 강철로 만들어진 날카로운 무기 느낌을 주기 위함
partHandle.BrickColor = BrickColor.new("Medium stone grey")                                                   -- [의미/의도] 파트 색을 중간 회색(Medium stone grey)으로 설정 ➔ 쇠칼의 금속 색상을 표현하기 위함
partHandle.Parent = toolBalanceSword                                                                          -- [의미/의도] 핸들 파트를 BalanceSword 도구의 자식으로 등록 ➔ 도구를 집었을 때 이 핸들 파트가 도구 외형으로 표시되게 하기 위함

local folderDummies04 = common.createOrReplaceInstance(common.enumObjectPhysicalType.FOLDER, common.enumObjectLogicalType.DUMMIES04, serviceWorkspace) -- [의미/의도] Dummies04 Folder 대체 생성 ➔ 기존 더미 그룹 폴더를 삭제하고 연습용 더미들을 새로 준비하기 위함

for index = 1, 5 do                                                                                           -- [의미/의도] index 변수를 1부터 5까지 증가시키며 반복함 ➔ 총 5마리의 연습용 공격 대상 더미를 정렬하여 소환하기 위함
    local modelPracticeDummy = Instance.new(common.enumObjectPhysicalType.MODEL)                              -- [의미/의도] 새로운 모델(Model) 객체를 생성함 ➔ 캐릭터 역할을 수행할 파트와 Humanoid를 하나로 그룹화하기 위함
    modelPracticeDummy.Name = common.enumObjectLogicalType.COOLDOWN_DUMMY_PREFIX .. index                     -- [의미/의도] 모델 이름을 인덱스 번호를 붙여 "1_CooldownDummy" 등으로 설정 ➔ 여러 더미들을 각각 고유 번호로 쉽게 구분하기 위함
    modelPracticeDummy.Parent = folderDummies04                                                               -- [의미/의도] 모델 부모를 Dummies04 폴더로 설정 ➔ 4일차 더미 폴더 내에 배치하여 소속을 정리하기 위함

    local partHumanoidRoot = Instance.new(common.enumObjectPhysicalType.PART)                                 -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 더미 캐릭터의 중심 몸통(HumanoidRootPart) 역할을 할 파트를 만들기 위함
    partHumanoidRoot.Name = common.enumObjectLogicalType.RESERVED_HUMANOID_ROOT_PART                          -- [의미/의도] 파트 이름을 반드시 "HumanoidRootPart"로 설정 ➔ 로블록스 Humanoid 시스템이 캐릭터 모델의 중심 기준점으로 자동 인식하게 하기 위함
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)                                                              -- [의미/의도] 몸통 파트의 크기를 3x5x2로 널찍하게 설정 ➔ 공격자가 검으로 때릴 때 타겟 범위가 넉넉한 샌드백처럼 만들기 위함
    partHumanoidRoot.Position = Vector3.new(index * 7 - 21, 2.5, -15)                                         -- [의미/의도] 더미의 X좌표 위치를 일정 간격(7칸씩) 정렬하고 바닥(높이 2.5)에 맞게 셋팅하여 앞쪽(Z축 -15)에 배치 ➔ 5마리의 더미가 겹치지 않고 일직선 상에 가지런히 정렬되도록 위함
    partHumanoidRoot.Anchored = true                                                                          -- [의미/의도] 몸통 파트를 공중에 고정시킴 ➔ 넉백이나 공격을 받아도 더미가 넘어지거나 밀려나지 않고 샌드백처럼 그 자리에 버티도록 고정하기 위함
    partHumanoidRoot.Parent = modelPracticeDummy                                                              -- [의미/의도] 몸통 파트를 modelPracticeDummy 모델의 자식으로 등록 ➔ 더미 모델의 핵심 구성물로 지정하기 위함

    local humanoidPractice = Instance.new(common.enumObjectPhysicalType.HUMANOID)                             -- [의미/의도] 새로운 Humanoid 객체를 생성함 ➔ 일반 파트에 생명력(HP)과 피해(TakeDamage)를 입을 수 있는 생명체 특성을 부여하기 위함
    humanoidPractice.Parent = modelPracticeDummy                                                              -- [의미/의도] Humanoid 객체를 더미 모델의 자식으로 등록 ➔ 더미 모델이 실제 HP 바를 가진 살아있는 타겟 dummy가 되도록 활성화하기 위함
end                                                                                                           -- [의미/의도] 더미 생성을 위한 반복문(for)의 종료 ➔ 5마리 더미 소환 및 속성 설정을 마침

print("4일차 준비 완료")                                                                                            -- [의미/의도] 출력창에 "4일차 준비 완료" 메시지를 출력함 ➔ 준비 과정이 오류 없이 마무리되었음을 확인하기 위함
