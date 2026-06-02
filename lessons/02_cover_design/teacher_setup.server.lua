-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 초기 적응 구간의 Part/Properties 실습을 공성전 엄폐물 필드로 구체화했습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 02_cover_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/Battlefield/CoverMarker_*
-- 안전 운영: 기존 공성전 월드를 지우지 않고 엄폐물 배치 마커만 보강합니다.
-- 검증 기준: Explorer에 SiegeWorld/Battlefield와 엄폐물 마커가 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE) -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드 공간(Workspace)에 접근하여 파트 및 폴더를 제어하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 1회차 전장을 유지한 채 엄폐물 학습 요소만 추가하기 위함
local fldBattlefield = tblSiegeWorld.fldBattlefield -- [의미/의도] 전투 공간 폴더 참조 ➔ 엄폐물 마커와 학생 엄폐물을 같은 전장에 배치하기 위함

for index = 1, 5 do -- [의미/의도] index 변수를 1부터 5까지 증가시키며 반복함 ➔ 총 5개의 엄폐물 배치 기준 표시판(Marker)을 만들기 위함
    common.ensureStaticPart(eLogical.COVER_MARKER_PREFIX .. index, fldBattlefield, { -- [의미/의도] 엄폐물 배치 마커 보장 ➔ 공통 전장 안에서 학생 건축 위치 힌트를 유지하기 위함
        Size = Vector3.new(2, 0.2, 2),                    -- [의미/의도] 마커 파트의 크기를 2x0.2x2로 얇게 설정 ➔ 바닥에 밀착되는 얇은 표시판 형태로 만들기 위함
        Position = Vector3.new(index * 8 - 24, 0.1, -10), -- [의미/의도] 마커 파트의 위치 좌표를 인덱스별로 다르게 계산하여 배치 ➔ 5개의 마커가 일정 간격(8칸)으로 나란히 정렬되도록 위함
        BrickColor = BrickColor.new("Bright yellow"),     -- [의미/의도] 마커 파트의 색상을 밝은 노란색(Bright yellow)으로 설정 ➔ 바닥에서 눈에 잘 띄게 표현하기 위함
    })
end

print("2일차 준비 완료")
