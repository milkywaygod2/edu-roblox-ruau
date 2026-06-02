-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차와 강의가이드 "투석기 버튼과 원격 발사"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 안전한 위치의 버튼 클릭으로 성문 목표를 향해 공성 탄환을 발사하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차와 강의가이드 "투석기 버튼과 원격 발사"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 안전한 위치의 버튼 클릭으로 성문 목표를 향해 공성 탄환을 발사하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 10_siege_engine_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/SiegeEngine10/LaunchButton, LaunchPoint, TargetPoint
-- 안전 운영: 기존 10 공성 병기를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 발사 버튼, 발사지점, 목표지점이 생성되고 Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType     -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcWorkspace = game:GetService(eService.WORKSPACE)                                         -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 월드 Workspace에 10일차 공성 병기 및 발사대 오브젝트를 배치하기 위함
local fldSiegeEngine10 = common.createOrReplaceInstance(ePhysical.FOLDER, eLogical.SIEGE_ENGINE10, svcWorkspace) -- [의미/의도] SiegeEngine10 Folder 대체 생성 ➔ 기존 공성 맵 폴더를 지우고 새로운 10일차 공성 병기 맵을 구성하기 위함

local partLaunchButton = Instance.new(ePhysical.PART)                                       -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 투석기를 작동시킬 물리적 발사 버튼(LaunchButton)을 만들기 위함
partLaunchButton.Name = eLogical.LAUNCH_BUTTON                                              -- [의미/의도] 파트 이름을 "LaunchButton"으로 설정 ➔ 성문 공격을 시작할 발사 스위치 파트임을 구분하기 위함
partLaunchButton.Size = Vector3.new(6, 1, 6)                                                                    -- [의미/의도] 버튼 크기를 6x1x6으로 널찍하게 설정 ➔ 플레이어가 올라가거나 마우스로 편하게 누를 수 있는 크기로 만들기 위함
partLaunchButton.Position = Vector3.new(0, 0.5, 0)                                                              -- [의미/의도] 버튼 좌표를 맵 바닥 중심(0, 0.5, 0)에 위치 설정 ➔ 플레이어가 스폰 근처에서 쉽게 접근할 수 있게 하기 위함
partLaunchButton.Anchored = true                                                                                -- [의미/의도] 파트를 공중에 고정시킴 ➔ 버튼이 이탈하여 굴러다니지 않고 제자리에 고정되도록 하기 위함
partLaunchButton.BrickColor = BrickColor.new("Bright blue")                                                     -- [의미/의도] 파트 색을 밝은 파란색(Bright blue)으로 설정 ➔ 작동 준비 상태의 장치 버튼 느낌을 시각화하기 위함
partLaunchButton.Parent = fldSiegeEngine10                                                                        -- [의미/의도] 버튼 파트를 SiegeEngine10 폴더의 자식으로 등록 ➔ 10일차 폴더 내부에서 버튼을 관리하기 위함

local clickButton = Instance.new(ePhysical.CLICK_DETECTOR)                                  -- [의미/의도] 새로운 클릭 감지기(ClickDetector) 컴포넌트를 생성함 ➔ 마우스로 이 파트를 누를 수 있는 인터랙션 기능을 부여하기 위함
clickButton.MaxActivationDistance = 24                                                                          -- [의미/의도] 마우스 클릭 작동 한계 거리를 24칸으로 설정 ➔ 지나치게 멀리서 저격하듯 스위치를 작동시키는 꼼수 플레이를 차단하기 위함
clickButton.Parent = partLaunchButton                                                                             -- [의미/의도] 클릭 감지기의 부모를 LaunchButton 파트로 설정 ➔ 해당 버튼 파트에 클릭 리스너 기능을 심기 위함

local partLaunchPoint = Instance.new(ePhysical.PART)                                        -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 공성 돌이 발사되어 출발하는 물리적 위치 마커(LaunchPoint)를 만들기 위함
partLaunchPoint.Name = eLogical.LAUNCH_POINT                                                -- [의미/의도] 파트 이름을 "LaunchPoint"로 지정 ➔ 스크립트가 돌 탄환을 스폰시킬 지점으로 참조하게 하기 위함
partLaunchPoint.Size = Vector3.new(2, 2, 2)                                                                     -- [의미/의도] 파트 크기를 2x2x2로 설정 ➔ 탄환이 부딪히지 않고 나갈 수 있는 통로 공간의 기준점 크기로 지정함
partLaunchPoint.Position = Vector3.new(0, 4, -6)                                                                -- [의미/의도] 버튼보다 Z축 기준 6칸 앞, 높이 4칸 위치에 마커 배치 ➔ 안전하게 플레이어 시야 앞쪽 공중에서 돌이 소환되어 발사되게 하기 위함
partLaunchPoint.Anchored = true                                                                                 -- [의미/의도] 마커 파트를 고정시킴 ➔ 탄환 스폰 지점이 땅으로 떨어지지 않고 공중에 고정되어 있게 하기 위함
partLaunchPoint.Transparency = 0.4                                                                              -- [의미/의도] 파트 투명도를 0.4(반투명)로 설정 ➔ 투사체 소환 위치를 유령 가이드 타일처럼 보이게 묘사하기 위함
partLaunchPoint.Parent = fldSiegeEngine10                                                                         -- [의미/의도] 마커 파트를 SiegeEngine10 폴더의 자식으로 등록 ➔ 10일차 폴더 내에서 관리하기 위함

local partTargetPoint = Instance.new(ePhysical.PART)                                        -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 탄환이 날아가 떨어질 목표물 위치 마커(TargetPoint)를 만들기 위함
partTargetPoint.Name = eLogical.TARGET_POINT                                                -- [의미/의도] 파트 이름을 "TargetPoint"로 설정 ➔ 탄환 발사 궤적을 계산할 종점 타겟 좌표로 쓰기 위함
partTargetPoint.Size = Vector3.new(4, 4, 4)                                                                     -- [의미/의도] 파트 크기를 4x4x4로 큼직하게 설정 ➔ 멀리서도 쏘아 맞힐 수 있는 타겟 영역임을 부각시키기 위함
partTargetPoint.Position = Vector3.new(0, 4, -42)                                                               -- [의미/의도] 발사대로부터 Z축 기준 36칸 더 전방에 배치 ➔ 공성 돌이 시원하게 날아갈 충분히 먼 전방 궤적을 확보하기 위함
partTargetPoint.Anchored = true                                                                                 -- [의미/의도] 타겟 파트를 고정시킴 ➔ 타겟 지점이 굴러다니거나 떨어지지 않고 공중에 표식으로 고정되어 있게 함
partTargetPoint.Transparency = 0.4                                                                              -- [의미/의도] 파트 투명도를 0.4(반투명)로 설정 ➔ 표적 가이드 영역을 유령처럼 반투명하게 묘사하기 위함
partTargetPoint.BrickColor = BrickColor.new("Bright red")                                                       -- [의미/의도] 타겟 파트 색상을 빨간색(Bright red)으로 지정 ➔ 위험 혹은 타격해야 할 공격 대상 표적임을 빨간색으로 경고하기 위함
partTargetPoint.Parent = fldSiegeEngine10                                                                         -- [의미/의도] 타겟 파트를 SiegeEngine10 폴더의 자식으로 등록 ➔ 10일차 폴더 내에 함께 묶어 관리하기 위함

print("10일차 준비 완료")                                                                                           -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 성공적으로 끝났음을 확인하기 위함
