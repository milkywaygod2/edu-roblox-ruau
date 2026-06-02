-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 07_armor_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/HeavyArmor
-- 안전 운영: 기존 07 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: HeavyArmor Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eEngineServiceSingleton = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType



local svcStarterPack = game:GetService(eEngineServiceSingleton.STARTER_PACK)                                     -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어에게 자동으로 무거운 갑옷(Tool)을 장비 인벤토리에 지급하기 위함
local toolHeavyArmor = common.createOrReplaceInstance(ePhysical.TOOL, eLogical.HEAVY_ARMOR, svcStarterPack) -- [의미/의도] HeavyArmor Tool 대체 생성 ➔ 기존 갑옷 장비를 정리하고 새로운 기본 갑옷 툴을 생성하기 위함
toolHeavyArmor.RequiresHandle = true                                                                            -- [의미/의도] 도구 작동 시 물리적인 핸들 파트가 필요하도록 참(true)으로 설정 ➔ 캐릭터가 손에 쥘 수 있는 파트가 손잡이 규격으로 필요함을 활성화하기 위함
toolHeavyArmor.ToolTip = "장착하면 갑옷 능력치가 적용됩니다"                                                                   -- [의미/의도] 장비의 설명 툴팁을 작성 ➔ 플레이어에게 갑옷 장착에 따른 스탯 변화 효과를 안내하기 위함

local partHandle = Instance.new(ePhysical.PART)                                            -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터가 쥘 갑옷의 중심 핸들이자 외형(Handle)을 만들기 위함
partHandle.Name = eLogical.RESERVED_HANDLE                                                 -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 시스템이 캐릭터의 손 위치에 알아서 부착하도록 하기 위함
partHandle.Size = Vector3.new(2, 2, 1)                                                                         -- [의미/의도] 파트 크기를 2x2x1로 널찍하고 두껍게 설정 ➔ 무겁고 두꺼운 방패나 흉갑 같은 강인한 디자인을 연출하기 위함
partHandle.Material = Enum.Material.Metal                                                                      -- [의미/의도] 파트 재질을 금속(Metal)으로 설정 ➔ 철제 중갑옷의 튼튼하고 차가운 금속 질감을 묘사하기 위함
partHandle.BrickColor = BrickColor.new("Really black")                                                         -- [의미/의도] 파트 색을 완전 검은색(Really black)으로 설정 ➔ 묵직하고 강렬한 블랙 중갑옷 느낌을 시각화하기 위함
partHandle.Parent = toolHeavyArmor                                                                               -- [의미/의도] 핸들 파트를 갑옷 도구의 자식으로 등록 ➔ 장착 시 캐릭터 손에 이 검은 금속 덩어리 외형이 부착되도록 하기 위함

print("7일차 준비 완료")                                                                                            -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 무사히 끝났음을 확인하기 위함
