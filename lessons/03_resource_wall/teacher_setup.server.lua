-- Roblox Studio 수업 스크립트 안내
-- 수업: 03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 방벽이 생기는 공성 방어 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 03_resource_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/BuildArea/BuildButton, WallSpawn
-- 안전 운영: 기존 공성전 월드를 지우지 않고 건설 버튼과 방벽 생성 기준점을 보강합니다.
-- 검증 기준: 방벽 버튼과 WallSpawn 위치가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE)                                         -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵 상에 3일차 폴더와 버튼을 생성하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace)                                      -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장과 엄폐물을 유지한 채 자원 방벽 요소를 추가하기 위함
local fldBuildArea = tblSiegeWorld.fldBuildArea                                                  -- [의미/의도] 건설 영역 폴더 참조 ➔ 방벽 버튼과 소환 위치를 공통 건설 영역에 배치하기 위함

local partBuildButton = common.ensureStaticPart(eLogical.BUILD_BUTTON, fldBuildArea, { -- [의미/의도] 방벽 설치 버튼 보장 ➔ 공통 건설 영역에서 방벽 소환 입력 장치를 유지하기 위함
    Size = Vector3.new(6, 1, 6),                                                            -- [의미/의도] 버튼 파트의 크기를 6x1x6으로 설정 ➔ 플레이어가 올라타거나 쉽게 마우스로 클릭할 수 있도록 넓은 크기로 만듦
    Position = Vector3.new(0, 0.5, 0),                                                       -- [의미/의도] 버튼 파트의 중심 좌표를 설정 ➔ 맵 중심 근처 바닥에 버튼을 위치시키기 위함
    BrickColor = BrickColor.new("Bright green"),                                             -- [의미/의도] 버튼 파트의 색을 밝은 초록색(Bright green)으로 지정 ➔ 눌렀을 때 긍정적인 반응이 올 것 같은 색상으로 디자인하기 위함
})
common.ensureClickDetector(partBuildButton, 24)                                              -- [의미/의도] 클릭 감지기 보장 ➔ 버튼 파트에 마우스 클릭 감지 기능을 유지하기 위함

common.ensureStaticPart(eLogical.WALL_SPAWN, fldBuildArea, {                                  -- [의미/의도] 방벽 소환 위치 마커 보장 ➔ 공통 건설 영역에서 방벽 생성 기준점을 유지하기 위함
    Size = Vector3.new(2, 0.2, 2),                                                            -- [의미/의도] 마커의 크기를 2x0.2x2로 얇게 설정 ➔ 바닥에 가볍게 깔린 가이드 타일처럼 보이게 만들기 위함
    Position = Vector3.new(0, 0.1, 12),                                                       -- [의미/의도] 버튼으로부터 Z축 기준 앞으로 12칸 떨어진 곳에 마커 위치를 설정 ➔ 버튼 바로 위가 아니라 약간 앞에 방벽이 생겨 플레이어를 밀어내지 않게 하기 위함
    Transparency = 0.35,                                                                      -- [의미/의도] 투명도를 0.35(약간 반투명)로 설정 ➔ 소환 예비 위치라는 표시를 유령처럼 시각적으로 연출하기 위함
    BrickColor = BrickColor.new("Bright yellow"),                                             -- [의미/의도] 마커 파트 색을 밝은 노란색(Bright yellow)으로 지정 ➔ 경고나 주의 위치임을 시각적으로 부각시키기 위함
})

print("3일차 준비 완료")                                                                                            -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 과정이 에러 없이 끝남을 확인하기 위함
