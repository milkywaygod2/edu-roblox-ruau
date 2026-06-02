-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차와 강의가이드 "투석기 버튼과 원격 발사"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 안전한 위치의 버튼 클릭으로 성문 목표를 향해 공성 탄환을 발사하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 10_siege_engine_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/SiegeEngine/LaunchButton, LaunchPoint, TargetPoint
-- 안전 운영: 기존 공성 병기 영역을 지우지 않고 발사 버튼과 기준점만 보강합니다.
-- 검증 기준: 발사 버튼, 발사지점, 목표지점이 생성되고 Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType     -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE)                                         -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드 Workspace에 10일차 공성 병기 및 발사대 오브젝트를 배치하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace)                                      -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장과 성 구조를 유지한 채 공성 병기를 추가하기 위함
local fldSiegeEngine = tblSiegeWorld.fldSiegeEngine                                              -- [의미/의도] 공성 병기 폴더 참조 ➔ 발사 버튼과 기준점을 같은 병기 영역에서 관리하기 위함

local partLaunchButton = common.ensureStaticPart(eLogical.LAUNCH_BUTTON, fldSiegeEngine, { -- [의미/의도] 발사 버튼 Part 보장 ➔ 공성 병기 입력 장치가 다음 회차에도 유지되도록 하기 위함
    Size = Vector3.new(6, 1, 6),                                                           -- [의미/의도] 버튼 크기를 6x1x6으로 널찍하게 설정 ➔ 플레이어가 올라가거나 마우스로 편하게 누를 수 있는 크기로 만들기 위함
    Position = Vector3.new(0, 0.5, 0),                                                      -- [의미/의도] 버튼 좌표를 맵 바닥 중심에 위치 설정 ➔ 플레이어가 스폰 근처에서 쉽게 접근할 수 있게 하기 위함
    BrickColor = BrickColor.new("Bright blue"),                                             -- [의미/의도] 파트 색을 밝은 파란색(Bright blue)으로 설정 ➔ 작동 준비 상태의 장치 버튼 느낌을 시각화하기 위함
})
common.ensureClickDetector(partLaunchButton, 24)                                            -- [의미/의도] 클릭 감지기 보장 ➔ 해당 버튼 파트에 클릭 리스너 기능을 유지하기 위함

common.ensureStaticPart(eLogical.LAUNCH_POINT, fldSiegeEngine, {                            -- [의미/의도] 발사 위치 마커 보장 ➔ 탄환 생성 시작 좌표가 계속 유지되도록 하기 위함
    Size = Vector3.new(2, 2, 2),                                                             -- [의미/의도] 파트 크기를 2x2x2로 설정 ➔ 탄환이 부딪히지 않고 나갈 수 있는 통로 공간의 기준점 크기로 지정함
    Position = Vector3.new(0, 4, -6),                                                        -- [의미/의도] 버튼보다 Z축 기준 6칸 앞, 높이 4칸 위치에 마커 배치 ➔ 안전하게 돌이 소환되어 발사되게 하기 위함
    Transparency = 0.4,                                                                      -- [의미/의도] 파트 투명도를 0.4(반투명)로 설정 ➔ 투사체 소환 위치를 유령 가이드 타일처럼 보이게 묘사하기 위함
})

common.ensureStaticPart(eLogical.TARGET_POINT, fldSiegeEngine, {                            -- [의미/의도] 목표 위치 마커 보장 ➔ 공성 탄환이 향할 기준 좌표가 계속 유지되도록 하기 위함
    Size = Vector3.new(4, 4, 4),                                                             -- [의미/의도] 파트 크기를 4x4x4로 큼직하게 설정 ➔ 멀리서도 쏘아 맞힐 수 있는 타겟 영역임을 부각시키기 위함
    Position = Vector3.new(0, 4, -42),                                                       -- [의미/의도] 발사대로부터 Z축 기준 36칸 더 전방에 배치 ➔ 공성 돌이 날아갈 충분히 먼 전방 궤적을 확보하기 위함
    Transparency = 0.4,                                                                      -- [의미/의도] 파트 투명도를 0.4(반투명)로 설정 ➔ 표적 가이드 영역을 유령처럼 반투명하게 묘사하기 위함
    BrickColor = BrickColor.new("Bright red"),                                               -- [의미/의도] 타겟 파트 색상을 빨간색(Bright red)으로 지정 ➔ 타격해야 할 표적임을 빨간색으로 경고하기 위함
})

print("10일차 준비 완료")                                                                                           -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 성공적으로 끝났음을 확인하기 위함
