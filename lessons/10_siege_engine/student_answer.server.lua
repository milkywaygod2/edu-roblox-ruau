-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차의 Hinge 조립, Spring 장력, 원격 발사 로직을 서버 투석기 코드로 구성했습니다.
-- 미션 단계: 빌더=발사 장치 구조 확인, 스크립터=탄환 속도 계산, 크리에이터=버튼으로 안전한 원격 발사입니다.
-- 강의가이드 연결: "투석기 버튼과 원격 발사" 예제로 목표 방향 벡터와 위쪽 속도를 조합합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer10
-- 선행 조건: 선생님이 LaunchButton, LaunchPoint, TargetPoint를 먼저 만들어야 합니다.
-- 학생 목표: ClickDetector 입력과 벡터 방향 계산이 공성 탄환 발사 규칙으로 이어지는 흐름을 이해합니다.
-- 검증 기준: 버튼 클릭 시 대포알이 발사지점에서 목표 방향으로 날아가면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType     -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함

local svcDebris = game:GetService(eService.DEBRIS)                                               -- [의미/의도] Debris 서비스를 가져옴 ➔ 월드 상에 발사된 공성돌 탄환이 일정 시간 후에 알아서 소멸되도록 예약하고 관리하기 위함
local fldSiegeEngine10 = workspace:WaitForChild(eLogical.SIEGE_ENGINE10)                    -- [의미/의도] Workspace에서 "SiegeEngine10" 폴더가 생성될 때까지 대기하여 가져옴 ➔ 10일차 투석기 오브젝트들이 완전히 로드된 후 스크립트를 수행하기 위함
local partLaunchButton = fldSiegeEngine10:WaitForChild(eLogical.LAUNCH_BUTTON)                -- [의미/의도] 10일차 폴더 내부에서 "LaunchButton" 파트가 생성될 때까지 대기하여 가져옴 ➔ 발사를 작동시킬 입력 장치(버튼)를 정확하게 셋업하기 위함
local partLaunchPoint = fldSiegeEngine10:WaitForChild(eLogical.LAUNCH_POINT)                  -- [의미/의도] 10일차 폴더 내부에서 "LaunchPoint" 파트가 생성될 때까지 대기하여 가져옴 ➔ 공성 돌이 소환되는 공중 시작 위치 좌표를 가져오기 위함
local partTargetPoint = fldSiegeEngine10:WaitForChild(eLogical.TARGET_POINT)                  -- [의미/의도] 10일차 폴더 내부에서 "TargetPoint" 파트가 생성될 때까지 대기하여 가져옴 ➔ 투사체가 날아가 부딪힐 정면 목표물 위치 좌표를 가져오기 위함

local COOLDOWN = 2.5                                                                                          -- [의미/의도] 투석기의 발사 쿨타임을 2.5초로 설정 ➔ 버튼을 난사하여 무한대로 대포알을 발사해 맵이 꼬이거나 서버에 렉을 거는 행동을 방지하기 위함
local boolReady = true                                                                                        -- [의미/의도] 발사 가능 여부 플래그를 true로 설정 ➔ 쿨타임 대기(Debounce) 상태를 걸어 중복 발사를 차단하기 위함

local function launch_stone(player)                                                                           -- [의미/의도] 공성 돌을 소환하여 발사하는 함수 정의 (버튼을 누른 플레이어 정보를 인자로 받음) ➔ 버튼 입력 시 정교한 비행 궤적을 가지는 돌 투사체를 생성하기 위함
    if not boolReady then return end                                                                          -- [의미/의도] boolReady가 참(true)이 아니면(쿨타임 도는 중이면) 실행 즉시 중단 ➔ 쿨타임 중에 들어온 추가 클릭들을 무시하기 위함
    boolReady = false                                                                                         -- [의미/의도] 발사 가능 상태 플래그를 거짓(false)으로 변경 ➔ 발사가 실행되었으니 즉시 쿨타임 잠금을 가하기 위함

    local partSiegeStone = Instance.new(ePhysical.PART)                                     -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 성문에 타격을 가할 무거운 공성 탄환(SiegeStone) 객체를 만들기 위함
    partSiegeStone.Name = eLogical.SIEGE_STONE                                              -- [의미/의도] 탄환 파트 이름을 "SiegeStone"으로 설정 ➔ 성벽이나 성문이 부딪혔을 때 공성 탄환에 의한 충돌인지 식별할 수 있게 하기 위함
    partSiegeStone.Shape = Enum.PartType.Ball                                                                   -- [의미/의도] 파트 모양을 동그란 구체(Ball) 모양으로 설정 ➔ 굴러가는 둥글둥글한 대포알이나 공성 돌맹이 외형을 묘사하기 위함
    partSiegeStone.Size = Vector3.new(3, 3, 3)                                                                  -- [의미/의도] 파트 크기를 3x3x3으로 크게 설정 ➔ 묵직하고 거대한 바윗덩어리 탄환 크기를 구현하여 맞았을 때 피격감을 연출하기 위함
    partSiegeStone.Material = Enum.Material.Slate                                                               -- [의미/의도] 파트 재질을 슬레이트 돌(Slate) 재질로 지정 ➔ 투박한 바위 표면의 질감을 사실적으로 묘사하기 위함
    partSiegeStone.Position = partLaunchPoint.Position                                                            -- [의미/의도] 돌 파트의 생성 위치를 앞서 구한 발사점(partLaunchPoint) 좌표로 지정 ➔ 공성 돌이 허공이 아닌, 지정된 공성 발사대 위에서 생성되어 날아가게 하기 위함
    partSiegeStone.Parent = workspace                                                                           -- [의미/의도] 돌 파트를 게임 세상(workspace)의 자식으로 등록 ➔ 맵에 돌이 나타나 물리 법칙(중력, 비행)을 받고 비행하도록 하기 위함

    local vectorDirection = (partTargetPoint.Position - partLaunchPoint.Position).Unit                            -- [의미/의도] 목표 위치에서 발사 위치를 뺀 차이 벡터를 구하고, 이를 크기 1의 단위 벡터(Unit)로 변경 ➔ 발사지점에서 목표물 지점을 바라보는 정확한 방향(크기 1인 방향 벡터)을 수학적으로 계산해내기 위함
    partSiegeStone.AssemblyLinearVelocity = vectorDirection * 95 + Vector3.new(0, 45, 0)                        -- [의미/의도] 산출된 방향 벡터에 전방 추적 힘(95)을 곱하고 공중으로 뜨는 수직 힘(45)을 보정하여 속도로 대입 ➔ 돌 탄환이 중력에 의해 떨어지지 않고 포물선을 그리며 정밀하게 성문을 향해 날아가 처박히도록 유도하기 위함
    svcDebris:AddItem(partSiegeStone, 8)                                                                         -- [의미/의도] 돌 탄환을 Debris 서비스에 등록하여 8초 후에 자동으로 소멸하도록 예약 ➔ 타격을 못하고 맵 밖에 떨어진 대포알이 영구히 남아 렉을 거는 현상을 방지하기 위함

    task.wait(COOLDOWN)                                                                                       -- [의미/의도] COOLDOWN(2.5초)만큼 실행을 지연시킴 ➔ 다음 투사체 발사까지 대기 시간을 보장하여 연사 치트를 막기 위함
    boolReady = true                                                                                          -- [의미/의도] 발사 가능 상태 플래그를 다시 참(true)으로 복구 ➔ 대기 시간이 완료되어 다시 대포알을 쏠 수 있도록 잠금을 해제하기 위함
end                                                                                                           -- [의미/의도] launch_stone 함수의 종료 ➔ 공성 돌 발사 로직 처리를 마침

partLaunchButton.ClickDetector.MouseClick:Connect(launch_stone)                                                 -- [의미/의도] 발사 버튼 파트의 마우스 클릭 감지 시(MouseClick) launch_stone 함수를 호출하도록 연동 ➔ 플레이어가 버튼을 클릭하면 투석기가 작용해 탄환을 날리도록 만들기 위함
