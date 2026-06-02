-- Roblox Studio 수업 스크립트 안내
-- 수업: 09_stone_wall - 전초기지 석벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 석조 벽 결합, 총안구, 부분 파괴 구조를 준비합니다.
-- 강의가이드 연결: 5v5 목표전의 벽은 한 덩어리가 아니라 구역별 피해와 붕괴를 추적하는 구조물입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 09_stone_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/Fortification/StoneWall
-- 안전 운영: 기존 방어 구조물 영역을 지우지 않고 벽 섹션과 석조 블록 기준 속성만 보강합니다.
-- 검증 기준: 구역별 벽 파트가 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장과 문을 유지한 채 석벽을 추가하기 위함
local fldFortification = tblOutpostWorld.fldFortification -- [의미/의도] 방어 구조물 영역 참조 ➔ 문과 벽을 같은 기지 방어 구조 안에서 관리하기 위함
local modelStoneWall = common.ensureNamedInstance(ePhysical.MODEL, eLogical.STONE_WALL, fldFortification) -- [의미/의도] 석벽 Model 보장 ➔ 부분 파괴 벽을 방어 구조물 영역에 누적 배치하기 위함

for section = 1, 5 do
    local modelWallSection = common.ensureNamedInstance(ePhysical.MODEL, eLogical.WALL_SECTION_PREFIX .. section, modelStoneWall)

    for height = 1, 4 do
        common.ensureStaticPart(eLogical.STONE_BLOCK_PREFIX .. height, modelWallSection, {
            Size = Vector3.new(6, 2, 2),
            Position = Vector3.new((section - 3) * 6, height * 2 - 1, -30),
            Material = Enum.Material.Slate,
            BrickColor = BrickColor.new("Dark stone grey"),
        })
    end
end

print("9일차 준비 완료")
