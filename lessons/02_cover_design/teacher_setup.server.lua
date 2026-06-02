-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 전초기지 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 중앙 교전로와 양 팀 코어 사이에 엄폐물 배치 후보지를 만드는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 02_cover_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/Battlefield/CoverMarker_*
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 엄폐물 배치 마커만 보강합니다.
-- 검증 기준: Battlefield 아래에 엄폐물 마커가 보이고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 1회차 목표물을 유지한 채 엄폐물 학습 요소만 추가하기 위함
local fldBattlefield = tblOutpostWorld.fldBattlefield -- [의미/의도] 전투 공간 폴더 참조 ➔ 엄폐물 마커와 학생 엄폐물을 같은 전장에 배치하기 위함

for index, vectorPosition in ipairs({
    Vector3.new(-28, 0.1, 0),
    Vector3.new(-14, 0.1, -4),
    Vector3.new(0, 0.1, 0),
    Vector3.new(14, 0.1, 4),
    Vector3.new(28, 0.1, 0),
}) do
    common.ensureStaticPart(eLogical.COVER_MARKER_PREFIX .. index, fldBattlefield, {
        Size = Vector3.new(2, 0.2, 2),
        Position = vectorPosition,
        BrickColor = BrickColor.new("Bright yellow"),
    })
end

print("2일차 준비 완료")
