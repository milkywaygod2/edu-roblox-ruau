-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: 활을 직접 지급하지 않고 측면 파밍 지점에서 찾아 원거리 견제를 실험합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 05_ranged_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/ObjectiveArea/RangeTarget_*, ItemSpawns/ItemSpawn_FieldBow_*
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 원거리 표적과 활 스폰 위치만 보강합니다.
-- 검증 기준: RangeTarget_*와 ItemSpawn_FieldBow_*가 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)

local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 원거리 표적과 활 파밍 위치를 추가하기 위함
local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea -- [의미/의도] 목표물 영역 참조 ➔ 원거리 표적을 공통 목표 영역에 누적 배치하기 위함
local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea -- [의미/의도] 아이템 스폰 영역 참조 ➔ 학생 튜닝 활을 맵에서 파밍하게 하기 위함

for index, vectorPosition in ipairs({
    Vector3.new(-32, 3, -30),
    Vector3.new(-20, 3, -34),
    Vector3.new(-8, 3, -38),
    Vector3.new(8, 3, -38),
    Vector3.new(20, 3, -34),
    Vector3.new(32, 3, -30),
}) do
    common.ensureStaticPart(eLogical.RANGE_TARGET_PREFIX .. index, fldObjectiveArea, {
        Size = Vector3.new(4, 6, 1),
        Position = vectorPosition,
        BrickColor = BrickColor.new("Bright red"),
    })
end

common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_BOW, {
    Vector3.new(-34, 0.1, -6),
    Vector3.new(34, 0.1, -6),
}, "Bright blue")

print("5일차 준비 완료")
