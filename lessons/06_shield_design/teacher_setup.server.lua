-- Roblox Studio 수업 스크립트 안내
-- 수업: 06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가, 투사체 방어벽, 데미지 반사 규칙을 준비합니다.
-- 강의가이드 연결: 전투 수업 통제 원칙을 적용해 공격뿐 아니라 방어와 밸런스도 게임 규칙으로 다룹니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 06_shield_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: StarterPack/PracticeShield
-- 안전 운영: 기존 Tool 내부 학생 커스터마이즈를 지우지 않고 Handle 기준 속성만 보강합니다.
-- 검증 기준: PracticeShield Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType



local svcStarterPack = game:GetService(eService.STARTER_PACK)
common.ensureToolWithHandle(eLogical.PRACTICE_SHIELD, "장착하면 방어하고 체력이 늘어납니다", svcStarterPack, { -- [의미/의도] PracticeShield Tool과 Handle 보장 ➔ 방어 장비가 이후 공성전 회차에서도 유지되도록 하기 위함
    Size = Vector3.new(4, 5, 0.6),                  -- [의미/의도] 파트 크기를 4x5x0.6으로 납작하고 넓게 설정 ➔ 캐릭터 앞을 가릴 수 있는 방패 판 모양을 묘사하기 위함
    Material = Enum.Material.Metal,                 -- [의미/의도] 파트 재질을 금속(Metal)으로 설정 ➔ 튼튼하고 단단한 철제 방패 질감을 표현하기 위함
    BrickColor = BrickColor.new("Dark stone grey"), -- [의미/의도] 파트 색을 어두운 돌 회색(Dark stone grey)으로 설정 ➔ 중후한 철광석 방패 느낌을 강조하기 위함
})

print("6일차 준비 완료")
