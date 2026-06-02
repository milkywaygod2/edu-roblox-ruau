-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 무기가 작동하는 것에서 끝나지 않고, 연타 방지와 밸런스가 필요하다는 점을 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 04_melee_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: StarterPack/BalanceSword, Workspace/SiegeWorld/TargetArea/CooldownDummy_*
-- 안전 운영: 기존 공성전 월드를 지우지 않고 무기와 쿨타임 연습 더미만 보강합니다.
-- 검증 기준: BalanceSword와 연습 더미가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcStarterPack = game:GetService(eService.STARTER_PACK) -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 플레이어가 게임 시작 시 인벤토리에 자동으로 지급받을 도구를 관리하기 위함
local svcWorkspace = game:GetService(eService.WORKSPACE)      -- [의미/의도] Workspace 서비스를 가져옴 ➔ 월드 상에 4일차 더미 폴더와 마커를 관리하기 위함

local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 검과 추가 더미를 배치하기 위함
local fldTargetArea = tblSiegeWorld.fldTargetArea -- [의미/의도] 타겟 영역 폴더 참조 ➔ 쿨타임 실험 더미를 공통 타겟 영역에 누적 배치하기 위함

common.ensureToolWithHandle(eLogical.BALANCE_SWORD, "쿨타임이 있는 연습용 검", svcStarterPack, { -- [의미/의도] BalanceSword Tool과 Handle 보장 ➔ 근접 무기 실험 장비를 유지하기 위함
    Size = Vector3.new(1, 5, 1),                      -- [의미/의도] 핸들 파트의 크기를 1x5x1의 얇고 긴 크기로 설정 ➔ 플레이어가 손에 쥐는 검 모양의 긴 형태로 묘사하기 위함
    Material = Enum.Material.Metal,                   -- [의미/의도] 파트 재질을 금속(Metal)으로 지정 ➔ 강철로 만들어진 날카로운 무기 느낌을 주기 위함
    BrickColor = BrickColor.new("Medium stone grey"), -- [의미/의도] 파트 색을 중간 회색(Medium stone grey)으로 설정 ➔ 쇠칼의 금속 색상을 표현하기 위함
})

for index = 1, 5 do -- [의미/의도] index 변수를 1부터 5까지 증가시키며 반복함 ➔ 총 5마리의 연습용 공격 대상 더미를 정렬하여 소환하기 위함
    common.ensureHumanoidDummy(eLogical.COOLDOWN_DUMMY_PREFIX .. index, fldTargetArea, { -- [의미/의도] 쿨타임 연습 더미 보장 ➔ 공통 타겟 영역에서 무기 밸런스 실험 대상을 유지하기 위함
        Size = Vector3.new(3, 5, 2),                      -- [의미/의도] 몸통 파트의 크기를 3x5x2로 널찍하게 설정 ➔ 공격자가 검으로 때릴 때 타겟 범위가 넉넉한 샌드백처럼 만들기 위함
        Position = Vector3.new(index * 7 - 21, 2.5, -15), -- [의미/의도] 더미의 X좌표 위치를 일정 간격으로 정렬 ➔ 5마리의 더미가 겹치지 않고 일직선 상에 가지런히 정렬되도록 위함
    })
end

print("4일차 준비 완료")
