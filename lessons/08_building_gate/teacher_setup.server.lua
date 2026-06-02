-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 건물과 파괴되는 성문
-- 문서 매핑: 커리큘럼 8회차와 강의가이드 "파괴되는 성문 만들기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 건물은 장식이 아니라 전투 중 체력과 파괴 상태를 갖는 게임 오브젝트가 됩니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 08_building_gate_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/Castle/Gate
-- 안전 운영: 기존 성 영역을 지우지 않고 성문 모델과 판자 기준 속성만 보강합니다.
-- 검증 기준: SiegeWorld/Castle/Gate 모델이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE) -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵 상에 8일차 성문 폴더와 관련 파트들을 생성하고 배치하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 성문을 추가하기 위함
local fldCastle = tblSiegeWorld.fldCastle -- [의미/의도] 성 영역 폴더 참조 ➔ 성문과 성벽을 같은 성 구조 안에서 관리하기 위함

local modelGate = common.ensureNamedInstance(ePhysical.MODEL, eLogical.GATE, fldCastle) -- [의미/의도] 성문 Model 보장 ➔ 성문이 다음 회차에도 유지되도록 성 영역 안에 누적하기 위함

for index = 1, 5 do -- [의미/의도] index 변수를 1부터 5까지 5번 반복 실행 ➔ 성문을 이루는 5개의 개별 나무판자 파트를 나란히 배치하기 위함
    common.ensureStaticPart(eLogical.GATE_PLANK_PREFIX .. index, modelGate, { -- [의미/의도] 성문 판자 Part 보장 ➔ 성문을 이루는 개별 판자가 재실행 때 중복 생성되지 않게 하기 위함
        Size = Vector3.new(2, 10, 1),                    -- [의미/의도] 판자 파트 크기를 2x10x1로 좁고 높은 세로 판자 모양으로 설정 ➔ 5개를 붙여서 거대한 중세 성문 문짝 모양을 연출하기 위함
        Position = Vector3.new((index - 3) * 2, 5, -20), -- [의미/의도] 각 판자의 X좌표를 계산하여 나란히 횡정렬 ➔ 판자들이 빈틈없이 큰 성문 모양으로 정렬되도록 위함
        Material = Enum.Material.WoodPlanks,             -- [의미/의도] 파트 재질을 나무판자(WoodPlanks)로 설정 ➔ 나무로 조립된 질감의 대문 느낌을 연출하기 위함
        BrickColor = BrickColor.new("Reddish brown"),    -- [의미/의도] 파트 색상을 나무 톤의 적갈색(Reddish brown)으로 지정 ➔ 시각적으로 전통적인 성문 뼈대 느낌을 주기 위함
    })
end

print("8일차 준비 완료")
