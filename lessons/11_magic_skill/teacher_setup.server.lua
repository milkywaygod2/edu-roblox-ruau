-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마법 지팡이도 직접 지급하지 않고 전장에서 파밍하며, 피해와 범위 검사는 서버가 판정합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/ObjectiveArea/ArcaneGuard_*, ItemSpawns/ItemSpawn_MagicStaff_*, ReplicatedStorage/CastMagic
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 마법 목표, 지팡이 스폰 위치, RemoteEvent만 보강합니다.
-- 검증 기준: ArcaneGuard_*, ItemSpawn_MagicStaff_*, CastMagic RemoteEvent가 생성되고 Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)
local svcWorkspace = game:GetService(eService.WORKSPACE)

local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 마법 요소를 추가하기 위함
local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea -- [의미/의도] 목표물 영역 참조 ➔ 마법 교전 가드를 공통 목표 영역에 누적 배치하기 위함
local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea -- [의미/의도] 아이템 스폰 영역 참조 ➔ 학생 튜닝 지팡이를 맵에서 파밍하게 하기 위함

common.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage) -- [의미/의도] CastMagic RemoteEvent 보장 ➔ 클라이언트 입력과 서버 판정을 연결할 통신 채널을 유지하기 위함

for index, vectorPosition in ipairs({
    Vector3.new(-21, 2.5, -26),
    Vector3.new(-14, 2.5, -30),
    Vector3.new(-7, 2.5, -34),
    Vector3.new(7, 2.5, -34),
    Vector3.new(14, 2.5, -30),
    Vector3.new(21, 2.5, -26),
}) do
    common.ensureHumanoidTarget(eLogical.ARCANE_GUARD_PREFIX .. index, fldObjectiveArea, {
        Size = Vector3.new(3, 5, 2),
        Position = vectorPosition,
        BrickColor = BrickColor.new("Royal purple"),
    }, {
        MaxHealth = 100,
        Health = 100,
    })
end

common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.MAGIC_STAFF, {
    Vector3.new(-8, 0.1, -30),
    Vector3.new(8, 0.1, -30),
}, "Royal purple")

print("11일차 준비 완료")
