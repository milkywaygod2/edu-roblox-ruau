-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 전초기지 문과 파괴 규칙
-- 문서 매핑: 커리큘럼 8회차와 강의가이드 "파괴되는 문 만들기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 건물은 장식이 아니라 전투 중 체력과 파괴 상태를 갖는 기지 오브젝트가 됩니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 08_building_gate_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/Fortification/Gate
-- 안전 운영: 기존 방어 구조물 영역을 지우지 않고 문 모델과 판자 기준 속성만 보강합니다.
-- 검증 기준: OutpostBattleWorld/Fortification/Gate 모델이 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 기지 문을 추가하기 위함
local fldFortification = tblOutpostWorld.fldFortification -- [의미/의도] 방어 구조물 영역 참조 ➔ 문과 벽을 같은 기지 방어 구조 안에서 관리하기 위함

local modelGate = common.ensureNamedInstance(ePhysical.MODEL, eLogical.GATE, fldFortification) -- [의미/의도] 문 Model 보장 ➔ 문이 다음 회차에도 유지되도록 방어 구조물 영역 안에 누적하기 위함

for index = 1, 5 do
    common.ensureStaticPart(eLogical.GATE_PLANK_PREFIX .. index, modelGate, {
        Size = Vector3.new(2, 10, 1),
        Position = Vector3.new((index - 3) * 2, 5, -26),
        Material = Enum.Material.WoodPlanks,
        BrickColor = BrickColor.new("Reddish brown"),
    })
end

print("8일차 준비 완료")
