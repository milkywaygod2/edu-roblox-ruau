-- Roblox Studio 수업 스크립트 안내
-- 수업: 03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 우리 전초기지 코어를 지키는 방벽을 세웁니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 03_resource_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/BuildArea/BuildButton, WallSpawn
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 건설 버튼과 방벽 생성 기준점을 보강합니다.
-- 검증 기준: 방벽 버튼과 WallSpawn 위치가 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장과 엄폐물을 유지한 채 자원 방벽 요소를 추가하기 위함
local fldBuildArea = tblOutpostWorld.fldBuildArea -- [의미/의도] 건설 영역 폴더 참조 ➔ 방벽 버튼과 소환 위치를 공통 건설 영역에 배치하기 위함

local partBuildButton = common.ensureStaticPart(eLogical.BUILD_BUTTON, fldBuildArea, {
    Size = Vector3.new(6, 1, 6),
    Position = Vector3.new(0, 0.5, 18),
    BrickColor = BrickColor.new("Bright green"),
})
common.ensureClickDetector(partBuildButton, 24)

common.ensureStaticPart(eLogical.WALL_SPAWN, fldBuildArea, {
    Size = Vector3.new(2, 0.2, 2),
    Position = Vector3.new(0, 0.1, 24),
    Transparency = 0.35,
    BrickColor = BrickColor.new("Bright yellow"),
})

print("3일차 준비 완료")
