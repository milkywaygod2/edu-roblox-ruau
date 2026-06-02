-- Roblox Studio 수업 스크립트 안내
-- 수업: 09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 석조 성벽 결합, 총안구, 부분 파괴 성벽을 준비합니다.
-- 강의가이드 연결: 공성전 맵의 성벽은 한 덩어리가 아니라 구역별로 피해와 붕괴를 추적하는 구조물입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 09_stone_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/Castle/StoneWall
-- 안전 운영: 기존 성 영역을 지우지 않고 성벽 섹션과 석조 블록 기준 속성만 보강합니다.
-- 검증 기준: 구역별 성벽 파트가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE) -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드인 Workspace 상에 9일차 석조 성벽을 생성하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장과 성문을 유지한 채 석조 성벽을 추가하기 위함
local fldCastle = tblSiegeWorld.fldCastle -- [의미/의도] 성 영역 폴더 참조 ➔ 성문과 성벽을 같은 성 구조 안에서 관리하기 위함
local modelStoneWall = common.ensureNamedInstance(ePhysical.MODEL, eLogical.STONE_WALL, fldCastle) -- [의미/의도] 석조 성벽 Model 보장 ➔ 부분 파괴 성벽을 성 영역에 누적 배치하기 위함

for section = 1, 5 do -- [의미/의도] section 변수를 1부터 5까지 증가시키며 반복함 ➔ 성벽을 5개의 부분 섹션(Section)으로 나누어 독립적인 파괴가 가능하도록 구조화하기 위함
    local modelWallSection = common.ensureNamedInstance(ePhysical.MODEL, eLogical.WALL_SECTION_PREFIX .. section, modelStoneWall) -- [의미/의도] 성벽 섹션 Model 보장 ➔ 각 구역이 재실행 때 중복 생성되지 않게 하기 위함

    for height = 1, 4 do -- [의미/의도] height 변수를 1부터 4까지 증가시키며 반복함 ➔ 각 성벽 섹션마다 돌 블록을 4층 높이로 쌓아 올리기 위함
        common.ensureStaticPart(eLogical.STONE_BLOCK_PREFIX .. height, modelWallSection, { -- [의미/의도] 석조 성벽 블록 Part 보장 ➔ 각 층 블록이 재실행 때 중복 생성되지 않게 하기 위함
            Size = Vector3.new(6, 2, 2),                                    -- [의미/의도] 돌 블록 크기를 6x2x2로 넙데데하고 두껍게 설정 ➔ 튼튼해 보이는 직사각형 성벽 벽돌 모양을 묘사하기 위함
            Position = Vector3.new((section - 3) * 6, height * 2 - 1, -24), -- [의미/의도] X축은 섹션 번호, Y축은 층수에 맞춰 배치 ➔ 5개 섹션과 4층 높이의 성벽을 정밀하게 구성하기 위함
            Material = Enum.Material.Slate,                                 -- [의미/의도] 파트 재질을 슬레이트 돌(Slate)로 지정 ➔ 단단한 돌로 쌓아 올린 중세 석조 성벽의 질감을 표현하기 위함
        })
    end
end

print("9일차 준비 완료")
