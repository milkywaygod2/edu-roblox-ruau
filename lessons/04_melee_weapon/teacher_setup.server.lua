-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 근접 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 중앙 교전 구역에서 파밍한 검으로 연타 방지와 밸런스를 실험합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 04_melee_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/ObjectiveArea/DuelGuard_*, ItemSpawns/ItemSpawn_FieldSword_*
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 근접 교전 목표와 검 스폰 위치만 보강합니다.
-- 검증 기준: DuelGuard_*와 ItemSpawn_FieldSword_*가 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)

local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 검 파밍과 교전 목표를 추가하기 위함
local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea -- [의미/의도] 목표물 영역 참조 ➔ 근접 교전 가드를 공통 목표 영역에 누적 배치하기 위함
local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea -- [의미/의도] 아이템 스폰 영역 참조 ➔ 학생 튜닝 검을 맵에서 파밍하게 하기 위함

for index, vectorPosition in ipairs({
    Vector3.new(-18, 2.5, -8),
    Vector3.new(-9, 2.5, -8),
    Vector3.new(0, 2.5, -8),
    Vector3.new(9, 2.5, -8),
    Vector3.new(18, 2.5, -8),
}) do
    common.ensureHumanoidTarget(eLogical.DUEL_GUARD_PREFIX .. index, fldObjectiveArea, {
        Size = Vector3.new(3, 5, 2),
        Position = vectorPosition,
        BrickColor = BrickColor.new("Bright orange"),
    }, {
        MaxHealth = 120,
        Health = 120,
    })
end

common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_SWORD, {
    Vector3.new(-18, 0.1, -2),
    Vector3.new(18, 0.1, -2),
}, "Really red")

print("4일차 준비 완료")
