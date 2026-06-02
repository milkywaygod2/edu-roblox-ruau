-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차의 데미지 조절, 공격 쿨타임, 무게와 속도 비례 규칙을 검 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=검 데미지 값 확인, 스크립터=Debounce 쿨타임, 크리에이터=무게가 큰 검은 강하지만 느린 밸런스입니다.
-- 강의가이드 연결: "공격 쿨타임과 디바운스" 예제로 연타 버그를 공정한 규칙으로 고칩니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > BalanceSword > Script 이름 StudentAnswer04
-- 선행 조건: 선생님이 BalanceSword와 Dummies04를 먼저 만들어야 합니다.
-- 학생 목표: Tool.Activated, Touched, debounce 변수가 전투 밸런스를 제어하는 방식을 이해합니다.
-- 검증 기준: 검을 사용하면 짧은 공격 판정만 켜지고, 쿨타임 동안 연속 피해가 막히면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local ePhysical = common.eEnginePhysicalType  -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함

local toolBalanceSword = script.Parent                                                                        -- [의미/의도] 이 스크립트가 포함된 검 도구(BalanceSword)를 가져옴 ➔ 검의 활성화(Activated) 및 핸들의 충돌(Touched) 이벤트를 연결하기 위함

local DAMAGE = 20                                                                                             -- [의미/의도] 검의 한 방 데미지 상수를 20으로 설정 ➔ 적에게 입힐 공격력을 고정 수치로 지정하기 위함
local ACTIVE_TIME = 0.25                                                                                      -- [의미/의도] 검을 휘둘렀을 때 타격 판정이 유지되는 유효 시간을 0.25초로 설정 ➔ 공격 동작 중에만 데미지를 입히고 평상시에는 닿아도 안 아프도록 판정 시간을 제한하기 위함
local COOLDOWN = 1.2                                                                                          -- [의미/의도] 다음 공격까지 기다려야 하는 대기 시간(쿨타임)을 1.2초로 설정 ➔ 빠른 속도로 연타하여 데미지를 중복 주입하는 치트를 예방하기 위함
local boolCanAttack = true                                                                                    -- [의미/의도] 공격 가능 여부를 나타내는 불리언 변수를 true로 설정 ➔ 공격 실행 후 쿨타임이 도는 중(Debounce)임을 추적하여 공격을 제한하기 위함

toolBalanceSword.Activated:Connect(function()                                                                 -- [의미/의도] 플레이어가 마우스로 검을 활성화(클릭)했을 때 아래 함수를 실행 ➔ 공격 행동 개시 시점의 로직을 연동하기 위함
    if not boolCanAttack then return end                                                                      -- [의미/의도] boolCanAttack이 참(true)이 아니면(쿨타임 중이면) 즉시 실행을 중단 ➔ 쿨타임 중에 들어온 추가 클릭 신호를 무시(Debounce 처리)하기 위함

    boolCanAttack = false                                                                                     -- [의미/의도] 공격 가능 여부 변수를 거짓(false)으로 변경 ➔ 쿨타임 대기 상태가 시작되었음을 체크하기 위함
    local tableAlreadyHit = {}                                                                                -- [의미/의도] 한 번 때린 적들을 기록하기 위한 빈 테이블(배열) 생성 ➔ 한 번 휘두를 때 동일한 적이 여러 번 중복으로 칼날에 스쳐서 폭발적인 누적 데미지를 입는 버그를 차단하기 위함
    toolBalanceSword.Handle.BrickColor = BrickColor.new("Really red")                                         -- [의미/의도] 칼날 파트(Handle)의 색을 빨간색(Really red)으로 변경 ➔ 현재 검을 휘둘러서 타격 판정이 활성화되었음을 플레이어에게 시각적으로 강력하게 알려주기 위함

    local connectionTouched = toolBalanceSword.Handle.Touched:Connect(function(partHit)                       -- [의미/의도] 칼날 파트(Handle)에 무언가 부딪혔을 때(Touched) 아래의 충돌 판정 함수를 실행하고 이를 변수에 담아 관리함 ➔ 공격 진행 중에 부딪힌 대상이 적인지 파악하고 타격하기 위함
        local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)              -- [의미/의도] 충돌한 파트의 상위 부모 중 모델(Model) 클래스를 찾아 가져옴 ➔ 부딪힌 대상이 플레이어나 더미 같은 캐릭터 모델인지 확인하기 위함
        local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID) -- [의미/의도] 대상 모델 내부에서 생명체 속성(Humanoid)을 가진 컴포넌트를 가져옴 ➔ 체력을 깎을 수 있는 체력 바가 있는 대상인지 식별하기 위함
        if not humTarget or modelTarget == toolBalanceSword.Parent or tableAlreadyHit[humTarget] then return end -- [의미/의도] 생명체가 없거나, 부딪힌 주체가 나 자신(검의 부모 캐릭터)이거나, 이미 이번 휘두르기에 타격받은 적이면 실행 중단 ➔ 물건 충돌 무시, 나 자신의 자해 방지, 한 번 휘두를 때 동일 대상에게 다단히트가 들어가는 현상을 차단하기 위함

        tableAlreadyHit[humTarget] = true                                                                      -- [의미/의도] 타격당한 적의 Humanoid 정보를 tableAlreadyHit 테이블에 기록함 ➔ 이번 공격 턴에서는 이 대상에게 추가 피해가 가지 않도록 중복 타격을 방지하기 위함
        humTarget:TakeDamage(DAMAGE)                                                                           -- [의미/의도] 대상의 체력을 DAMAGE(20)만큼 깎음 ➔ 무기의 기본 피해를 가하기 위함
    end)                                                                                                      -- [의미/의도] Touched 이벤트 콜백 함수의 종료 ➔ 개별 타격 판정 처리를 마침

    task.wait(ACTIVE_TIME)                                                                                    -- [의미/의도] ACTIVE_TIME(0.25초)만큼 실행을 일시 지연시킴 ➔ 검을 휘두르는 시각적 판정 시간 동안만 타격 이벤트를 유지하기 위함
    connectionTouched:Disconnect()                                                                            -- [의미/의도] 칼날에 충돌 이벤트를 연결했던 접속을 해제(Disconnect)함 ➔ 0.25초가 지나 검을 다 휘두르고 거둘 때부터는 더 이상 적에게 부딪혀도 데미지가 들어가지 않도록 공격 판정을 끄기 위함
    toolBalanceSword.Handle.BrickColor = BrickColor.new("Medium stone grey")                                  -- [의미/의도] 칼날 파트의 색을 원래의 회색(Medium stone grey)으로 되돌림 ➔ 공격 유효 시간이 끝나 안전한 상태가 되었음을 플레이어에게 시각적으로 보여주기 위함
    task.wait(COOLDOWN)                                                                                       -- [의미/의도] COOLDOWN(1.2초)만큼 실행을 추가로 지연시킴 ➔ 쿨타임 대기 시간 동안 플레이어가 다음 공격을 하지 못하게 락(Lock)을 걸어두기 위함
    boolCanAttack = true                                                                                      -- [의미/의도] 공격 가능 여부 변수를 참(true)으로 복구함 ➔ 쿨타임이 끝났으니 다시 공격할 수 있도록 잠금을 해제하기 위함
end)                                                                                                          -- [의미/의도] Activated 이벤트 콜백 함수의 종료 ➔ 검 휘두르기 전체 프로세스 처리를 마침
