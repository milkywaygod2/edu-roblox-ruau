-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 5v5 전초기지 공방전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 파밍 장비, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 12_final_battle_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/Battlefield/RoundStartButton, SpawnPoint_*, Teams/Blue, Teams/Red
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 라운드 버튼, 스폰 지점, 팀만 보강합니다.
-- 검증 기준: 누적 전장과 Blue/Red 팀이 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcTeams = game:GetService(eService.TEAMS)
local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 모든 이전 회차 콘텐츠가 남아 있는 전장에서 최종전을 시작하기 위함
local fldBattlefield = tblOutpostWorld.fldBattlefield -- [의미/의도] 전투 공간 폴더 참조 ➔ 라운드 버튼과 스폰 지점을 공통 전장에 배치하기 위함
local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea

for _, teamName in ipairs({eLogical.TEAM_BLUE, eLogical.TEAM_RED}) do
    local teamInstance = svcTeams:FindFirstChild(teamName) or Instance.new(ePhysical.TEAM)
    teamInstance.Name = teamName
    teamInstance.TeamColor = BrickColor.new(teamName == eLogical.TEAM_BLUE and "Bright blue" or "Bright red")
    teamInstance.AutoAssignable = false
    teamInstance.Parent = svcTeams
end

local partRoundStartButton = common.ensureStaticPart(eLogical.ROUND_START_BUTTON, fldBattlefield, {
    Size = Vector3.new(8, 1, 8),
    Position = Vector3.new(0, 0.5, 0),
    BrickColor = BrickColor.new("Lime green"),
})
common.ensureClickDetector(partRoundStartButton, 30)

for _, tblSpawnConfig in ipairs({
    {Team = eLogical.TEAM_BLUE, Position = Vector3.new(0, 0.5, 38), Color = "Bright blue"},
    {Team = eLogical.TEAM_RED, Position = Vector3.new(0, 0.5, -38), Color = "Bright red"},
}) do
    common.ensureStaticPart(eLogical.SPAWN_POINT_PREFIX .. tblSpawnConfig.Team, fldBattlefield, {
        Size = Vector3.new(8, 1, 8),
        Position = tblSpawnConfig.Position,
        BrickColor = BrickColor.new(tblSpawnConfig.Color),
        Material = Enum.Material.Neon,
    })
end

for _, tblCoreConfig in ipairs({
    {Team = eLogical.TEAM_BLUE, Position = Vector3.new(0, 3, 32), Color = "Bright blue"},
    {Team = eLogical.TEAM_RED, Position = Vector3.new(0, 3, -32), Color = "Bright red"},
}) do
    common.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. tblCoreConfig.Team, fldObjectiveArea, {
        Size = Vector3.new(6, 6, 4),
        Position = tblCoreConfig.Position,
        BrickColor = BrickColor.new(tblCoreConfig.Color),
    }, {
        MaxHealth = 160,
        Health = 160,
    })
end

print("12일차 준비 완료")
