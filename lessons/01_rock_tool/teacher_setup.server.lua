-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 문서 매핑: 1회차부터 성 없는 연습장이 아니라 양쪽 전초기지 코어를 둔 소규모 목표전을 시작합니다.
-- 강의가이드 연결: 학생이 튜닝한 돌을 직접 지급받지 않고 전장에서 찾아 주워 목표물을 공격하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 01_rock_tool_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/Battlefield, ObjectiveArea, ItemSpawns
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 누락된 기본 전장과 목표물만 보강합니다.
-- 검증 기준: Explorer에 OutpostBattleWorld, OutpostCore_*, ItemSpawn_ThrowingStone_*가 보이면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)

local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 1회차부터 12회차까지 같은 목표전 전장을 이어 쓰기 위함
local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea -- [의미/의도] 목표물 영역 참조 ➔ 양 팀 코어와 전초기지 가드를 같은 규칙으로 배치하기 위함
local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea -- [의미/의도] 아이템 스폰 영역 참조 ➔ 학생 튜닝 돌을 직접 지급하지 않고 맵에서 파밍하게 하기 위함

for _, tblCoreConfig in ipairs({
    {Name = eLogical.TEAM_BLUE, Position = Vector3.new(0, 3, 32), Color = "Bright blue"},
    {Name = eLogical.TEAM_RED, Position = Vector3.new(0, 3, -32), Color = "Bright red"},
}) do
    common.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. tblCoreConfig.Name, fldObjectiveArea, {
        Size = Vector3.new(6, 6, 4),
        Position = tblCoreConfig.Position,
        BrickColor = BrickColor.new(tblCoreConfig.Color),
    }, {
        MaxHealth = 160,
        Health = 160,
    })
end

for index, vectorPosition in ipairs({
    Vector3.new(-16, 2.5, 24),
    Vector3.new(16, 2.5, 24),
    Vector3.new(-16, 2.5, -24),
    Vector3.new(16, 2.5, -24),
}) do
    common.ensureHumanoidTarget(eLogical.OUTPOST_GUARD_PREFIX .. index, fldObjectiveArea, {
        Size = Vector3.new(3, 5, 2),
        Position = vectorPosition,
        BrickColor = BrickColor.new(index <= 2 and "Bright blue" or "Bright red"),
    }, {
        MaxHealth = 100,
        Health = 100,
    })
end

common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.THROWING_STONE, {
    Vector3.new(-24, 0.1, 8),
    Vector3.new(0, 0.1, 4),
    Vector3.new(24, 0.1, 8),
}, "Bright yellow")

print("1일차 준비 완료")
