-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 07_armor_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: StarterPack/HeavyArmor
-- 안전 운영: 기존 Tool 내부 학생 커스터마이즈를 지우지 않고 Handle 기준 속성만 보강합니다.
-- 검증 기준: HeavyArmor Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcStarterPack = game:GetService(eService.STARTER_PACK)                                     -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어에게 자동으로 무거운 갑옷(Tool)을 장비 인벤토리에 지급하기 위함
common.ensureToolWithHandle(eLogical.HEAVY_ARMOR, "장착하면 갑옷 능력치가 적용됩니다", svcStarterPack, { -- [의미/의도] HeavyArmor Tool과 Handle 보장 ➔ 갑옷 장비가 이후 공성전 회차에서도 유지되도록 하기 위함
    Size = Vector3.new(2, 2, 1),                                                                                          -- [의미/의도] 파트 크기를 2x2x1로 널찍하고 두껍게 설정 ➔ 무겁고 두꺼운 방패나 흉갑 같은 강인한 디자인을 연출하기 위함
    Material = Enum.Material.Metal,                                                                                       -- [의미/의도] 파트 재질을 금속(Metal)으로 설정 ➔ 철제 중갑옷의 튼튼하고 차가운 금속 질감을 묘사하기 위함
    BrickColor = BrickColor.new("Really black"),                                                                          -- [의미/의도] 파트 색을 완전 검은색(Really black)으로 설정 ➔ 묵직하고 강렬한 블랙 중갑옷 느낌을 시각화하기 위함
})

print("7일차 준비 완료")                                                                                            -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 무사히 끝났음을 확인하기 위함
