-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 빌더/스크립터/크리에이터 단계를 도구 장착, 데미지, 넉백으로 나눴습니다.
-- 미션 단계: 빌더=PracticeRock 장착, 스크립터=Touched 데미지, 크리에이터=AssemblyLinearVelocity 넉백입니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 예제를 수업용 완성 답안으로 정리한 파일입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > PracticeRock > Script 이름 StudentAnswer01
-- 선행 조건: 선생님이 teacher_setup.server.lua를 먼저 실행해 Workspace/Arena01와 StarterPack/PracticeRock을 만들어야 합니다.
-- 학생 목표: Tool.Activated와 Touched 이벤트가 서버에서 실제 전투 규칙으로 이어지는 흐름을 이해합니다.
-- 검증 기준: Play 후 돌멩이를 사용하면 투사체가 날아가고, 더미에게 피해와 넉백이 적용되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eEngineServiceSingleton = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcDebris = game:GetService(eEngineServiceSingleton.DEBRIS)                                               -- [의미/의도] Debris 서비스를 가져옴 ➔ 생성된 투사체를 일정 시간 뒤 자동으로 삭제하기 위함
local toolPracticeRock = script.Parent                                                                        -- [의미/의도] 이 스크립트가 포함된 도구(Tool)를 가져옴 ➔ 마우스 클릭(Activated) 이벤트를 감지하기 위함

local DAMAGE = 15                                                                                             -- [의미/의도] 타격 데미지 상수를 15로 설정 ➔ 적에게 입힐 기본 피해량을 지정하기 위함
local COOLDOWN = 0.8                                                                                          -- [의미/의도] 공격 대기시간(쿨타임) 상수를 0.8초로 설정 ➔ 무분별한 연타 공격을 막기 위함
local SPEED = 90                                                                                              -- [의미/의도] 투사체 속도 상수를 90으로 설정 ➔ 돌멩이가 날아가는 속도를 지정하기 위함
local boolReady = true                                                                                        -- [의미/의도] 현재 공격 가능 여부를 저장하는 변수 ➔ 쿨타임 중 중복 시전을 방지(Debounce)하기 위함

toolPracticeRock.Activated:Connect(function()                                                                 -- [의미/의도] 도구를 클릭(활성화)했을 때 아래 함수를 실행 ➔ 마우스 클릭 시 무기가 동작하도록 이벤트를 연결함
    if not boolReady then return end                                                                          -- [의미/의도] 공격 가능 상태가 아니라면 실행 중단 ➔ 쿨타임이 도는 중에는 공격이 무시되도록 함

    local modelCharacter = toolPracticeRock.Parent                                                            -- [의미/의도] 도구의 부모(플레이어 캐릭터) 모델을 가져옴 ➔ 캐릭터의 중심 위치를 기준으로 발사하기 위함
    local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART) -- [의미/의도] 캐릭터 몸통의 중심 파트를 찾음 ➔ 발사 위치와 시선을 알아내기 위함
    if not partHumanoidRoot then return end                                                                     -- [의미/의도] 중심 파트가 없다면 실행 중단 ➔ 비정상적인 상황에서 오류가 나는 것을 방지함

    boolReady = false                                                                                         -- [의미/의도] 공격 상태를 불가능(false)으로 변경 ➔ 쿨타임이 시작되었음을 설정함

    local partRock = Instance.new(ePhysical.PART)                                          -- [의미/의도] 날아갈 파트(돌멩이)를 생성함 ➔ 물리적으로 날아가는 투사체 객체를 생성함
    partRock.Name = eLogical.THROWN_PRACTICE_ROCK                                          -- [의미/의도] 파트 이름을 "ThrownPracticeRock"으로 설정 ➔ 충돌 시 이름으로 구분할 수 있도록 함
    partRock.Shape = Enum.PartType.Ball                                                                        -- [의미/의도] 파트 모양을 동그란 구체 모양으로 설정 ➔ 돌멩이처럼 보이게 연출하기 위함
    partRock.Size = Vector3.new(1.2, 1.2, 1.2)                                                                 -- [의미/의도] 크기를 1.2x1.2x1.2로 설정 ➔ 날아가는 게 눈에 잘 띄는 적절한 부피로 설정함
    partRock.Material = Enum.Material.Slate                                                                    -- [의미/의도] 재질을 돌 재질로 설정 ➔ 시각적으로 사실적인 돌 질감을 표현하기 위함
    partRock.Position = partHumanoidRoot.Position + partHumanoidRoot.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0) -- [의미/의도] 플레이어 몸통 기준 앞방향으로 3칸, 위로 1.5칸 떨어진 곳에 생성 ➔ 캐릭터 몸 속에서 생성되어 이상하게 충돌하는 현상을 막기 위함
    partRock.Parent = workspace                                                                                -- [의미/의도] 돌멩이 파트를 게임 세상(workspace)에 배치 ➔ 맵 상에 실재하여 렌더링되고 날아가도록 함
    partRock.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * SPEED + Vector3.new(0, 12, 0)         -- [의미/의도] 플레이어 시선 방향 속도(SPEED)와 공중 곡선(위로 12)을 속도로 부여 ➔ 돌멩이가 포물선을 그리며 자연스럽게 날아가도록 함
    svcDebris:AddItem(partRock, 5)                                                                              -- [의미/의도] 돌멩이 파트를 5초 뒤 자동 삭제하도록 예약 ➔ 빗나간 돌멩이가 맵에 쌓여 렉이 걸리지 않도록 방지함

    local boolHitOnce = false                                                                                 -- [의미/의도] 한 번만 타격되었는지를 나타내는 변수 ➔ 한 번 날아간 돌멩이가 여러 번 중복 타격 판정되는 버그를 막기 위함
    partRock.Touched:Connect(function(partHit)                                                                 -- [의미/의도] 돌멩이가 어딘가에 부딪혔을 때(Touched) 아래 함수를 실행 ➔ 적과 부딪혔는지 감지하기 위함
        if boolHitOnce then return end                                                                        -- [의미/의도] 이미 타격이 성공했다면 실행 중단 ➔ 중복 피해 방지

        local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)              -- [의미/의도] 충돌한 파트가 속한 최상위 모델을 찾음 ➔ 부딪힌 대상이 캐릭터(Model)인지 검사하기 위함
        local humTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID) -- [의미/의도] 그 모델 안에 생명체(Humanoid)가 있는지 찾음 ➔ 체력을 깎을 수 있는 대상인지 식별하기 위함
        local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART) -- [의미/의도] 타격 대상의 중심 파트를 찾음 ➔ 넉백을 주기 위해 몸통을 찾기 위함
        if not humTarget or modelTarget == modelCharacter then return end                                       -- [의미/의도] 생명체가 없거나 자기 자신과 충돌한 경우 무시 ➔ 적군에게만 타격을 입히고 본인 자해를 막기 위함

        boolHitOnce = true                                                                                    -- [의미/의도] 타격 성공으로 변수 설정 ➔ 더 이상의 추가 타격을 차단함
        humTarget:TakeDamage(DAMAGE)                                                                           -- [의미/의도] 대상을 DAMAGE만큼 공격 ➔ 무기 공격 데미지를 적용하기 위함
        if partTargetRoot then                                                                                  -- [의미/의도] 대상의 몸통 파트가 존재한다면 ➔ 안전하게 물리적 힘을 가할 수 있을 때만 넉백을 주기 위함
            partTargetRoot.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * 45 + Vector3.new(0, 18, 0) -- [의미/의도] 발사 방향 기준 수평으로 45, 공중으로 18만큼 속도를 강제 주입 ➔ 공격에 맞은 적이 뒤로 시원하게 날아가는 넉백 효과를 연출하기 위함
        end
        partRock:Destroy()                                                                                     -- [의미/의도] 돌멩이 파트를 즉시 파괴 ➔ 타격이 끝난 무기를 맵에서 지워 깔끔하게 정리하기 위함
    end)

    task.wait(COOLDOWN)                                                                                       -- [의미/의도] COOLDOWN 시간만큼 대기 ➔ 지정된 쿨타임 동안 다음 공격이 나가지 않도록 지연함
    boolReady = true                                                                                          -- [의미/의도] 공격 가능 상태로 환원 ➔ 쿨타임이 완료되어 다시 공격할 수 있게 열어둠
end)
