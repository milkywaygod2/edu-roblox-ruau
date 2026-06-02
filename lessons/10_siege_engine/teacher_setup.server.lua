-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 중장비와 원격 발사
-- 문서 매핑: 커리큘럼 10회차와 강의가이드 "투석기 버튼과 원격 발사"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 안전한 위치의 버튼 클릭으로 기지 방어 구조물을 향해 무거운 탄환을 발사하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 10_siege_engine_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/SiegeEngine/LaunchButton, LaunchPoint, TargetPoint
-- 안전 운영: 기존 중장비 영역을 지우지 않고 발사 버튼과 기준점만 보강합니다.
-- 검증 기준: 발사 버튼, 발사지점, 목표지점이 생성되고 Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장과 방어 구조를 유지한 채 중장비를 추가하기 위함
local fldSiegeEngine = tblOutpostWorld.fldSiegeEngine -- [의미/의도] 중장비 폴더 참조 ➔ 발사 버튼과 기준점을 같은 장비 영역에서 관리하기 위함

local partLaunchButton = common.ensureStaticPart(eLogical.LAUNCH_BUTTON, fldSiegeEngine, {
    Size = Vector3.new(6, 1, 6),
    Position = Vector3.new(0, 0.5, 12),
    BrickColor = BrickColor.new("Bright blue"),
})
common.ensureClickDetector(partLaunchButton, 24)

common.ensureStaticPart(eLogical.LAUNCH_POINT, fldSiegeEngine, {
    Size = Vector3.new(2, 2, 2),
    Position = Vector3.new(0, 4, 4),
    Transparency = 0.4,
})

common.ensureStaticPart(eLogical.TARGET_POINT, fldSiegeEngine, {
    Size = Vector3.new(4, 4, 4),
    Position = Vector3.new(0, 4, -34),
    Transparency = 0.4,
    BrickColor = BrickColor.new("Bright red"),
})

print("10일차 준비 완료")
