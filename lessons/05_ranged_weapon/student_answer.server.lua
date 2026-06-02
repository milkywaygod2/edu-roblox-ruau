-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차의 투사체 발사, 포물선 물리, 폭발 화살을 활 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=화살 Part 생성, 스크립터=Vector 속도와 중력 궤적, 크리에이터=닿으면 폭발하는 화살입니다.
-- 강의가이드 연결: "투사체와 포물선 공격" 장면에서 직선 공격과 곡선 공격의 차이를 눈으로 확인합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > TrainingBow > Script 이름 StudentAnswer05
-- 선행 조건: 선생님이 TrainingBow와 TargetRange05를 먼저 만들어야 합니다.
-- 학생 목표: CFrame.LookVector, AssemblyLinearVelocity, Debris 자동 삭제가 투사체 규칙을 만드는 방식을 이해합니다.
-- 검증 기준: 활 사용 시 화살이 앞으로 포물선으로 날아가고, 목표에 닿으면 피해/폭발 효과가 보이면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eEngineServiceSingleton = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcDebris = game:GetService(eEngineServiceSingleton.DEBRIS)                                               -- [의미/의도] Debris 서비스를 가져옴 ➔ 월드에 발사된 화살이 무한히 남아 서버에 부하를 주지 않도록 일정 시간 후 자동 소멸시키기 위함
local toolTrainingBow = script.Parent                                                                         -- [의미/의도] 이 스크립트가 들어있는 활 도구(TrainingBow)를 가져옴 ➔ 플레이어의 마우스 활성화(Activated) 이벤트를 연결하기 위함

local SPEED = 110                                                                                             -- [의미/의도] 화살의 비행 속도 상수를 110으로 설정 ➔ 시원하고 빠르게 화살이 날아가는 속도감을 주기 위함
local ARC = 28                                                                                                -- [의미/의도] 화살이 위로 향하는 발사 속도(곡선 아크)를 28로 설정 ➔ 화살이 포물선을 그리며 떨어지는 사실적인 물리 비행 궤적을 묘사하기 위함
local DAMAGE = 18                                                                                             -- [의미/의도] 화살 타격 데미지를 18로 설정 ➔ 과녁이나 목표물에 가할 피해량을 고정하기 위함
local COOLDOWN = 0.9                                                                                          -- [의미/의도] 사격 대기시간(쿨타임)을 0.9초로 설정 ➔ 화살을 무제한으로 빠르게 연사하지 못하도록 밸런스를 조절하기 위함
local boolReady = true                                                                                        -- [의미/의도] 현재 활을 쏠 준비가 되었는지를 기록할 불리언 변수를 참(true)으로 초기화 ➔ 쿨타임 중에 중복 발사(Debounce)를 방지하기 위함

toolTrainingBow.Activated:Connect(function()                                                                  -- [의미/의도] 활을 클릭(활성화)했을 때 아래 함수를 실행 ➔ 활 쏘기 발사 로직을 연동하기 위함
    if not boolReady then return end                                                                          -- [의미/의도] boolReady가 참(true)이 아니면 실행을 즉시 중단 ➔ 쿨타임이 진행 중일 때는 추가적인 화살 생성을 차단하기 위함

    local modelCharacter = toolTrainingBow.Parent                                                             -- [의미/의도] 도구의 부모인 플레이어 캐릭터(Model)를 가져옴 ➔ 화살이 내 캐릭터 중심에서 발사되도록 위치를 계산하기 위함
    local partHumanoidRoot = modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART) -- [의미/의도] 캐릭터 몸통의 중심 파트(HumanoidRootPart)를 찾음 ➔ 화살 발사의 기준점과 바라보는 시선 방향(CFrame)을 구하기 위함
    if not partHumanoidRoot then return end                                                                     -- [의미/의도] 캐릭터 중심 파트가 존재하지 않으면 실행 중단 ➔ 비정상적인 캐릭터 상태에서 생길 수 있는 스크립트 널(Null) 에러를 방지하기 위함

    boolReady = false                                                                                         -- [의미/의도] 발사 불가 상태(false)로 스위치를 전환 ➔ 화살을 쏘았으므로 다음 쿨타임 잠금을 걸기 위함

    local partArrow = Instance.new(ePhysical.PART)                                         -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 물리적으로 날아가는 투사체인 화살 객체를 만들기 위함
    partArrow.Name = eLogical.PROJECTILE_ARROW_TRAINING                                    -- [의미/의도] 화살 파트 이름을 "TrainingArrow"로 설정 ➔ 충돌 시 이름 비교를 통해 화살인지 식별할 수 있도록 위함
    partArrow.Size = Vector3.new(0.4, 0.4, 3)                                                                  -- [의미/의도] 화살 파트 크기를 0.4x0.4x3으로 가늘고 길쭉하게 설정 ➔ 날아가는 화살 모양의 실루엣을 표현하기 위함
    partArrow.Material = Enum.Material.Wood                                                                    -- [의미/의도] 파트 재질을 나무(Wood)로 지정 ➔ 나무로 깎아 만든 화살 느낌의 시각적 재질을 적용하기 위함
    partArrow.CFrame = partHumanoidRoot.CFrame * CFrame.new(0, 1.5, -4)                                          -- [의미/의도] 화살의 시작 위치와 각도를 캐릭터 몸통 앞 4칸, 위로 1.5칸 떨어진 곳으로 설정 ➔ 발사자가 활을 겨누는 앞방향에서 화살이 깔끔하게 스폰되도록 배치하기 위함
    partArrow.Parent = workspace                                                                               -- [의미/의도] 생성된 화살을 게임 세상(workspace)에 배치 ➔ 맵에 실존하여 렌더링되고 물리 물리 법칙이 적용되게 하기 위함
    partArrow.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * SPEED + Vector3.new(0, ARC, 0)       -- [의미/의도] 캐릭터 시선 방향 힘(SPEED)과 위로 뜨는 힘(ARC)을 속도로 주입 ➔ 중력의 영향을 받아 자연스럽게 아래로 떨어지는 포물선(곡선) 비행을 유도하기 위함
    svcDebris:AddItem(partArrow, 6)                                                                             -- [의미/의도] Debris 서비스에 화살을 등록하여 6초 후에 자동 삭제되도록 예약 ➔ 표적에 맞지 않고 허공으로 날아가 떨어진 화살이 맵에 쌓여 렉이 유발되는 것을 방지하기 위함

    partArrow.Touched:Connect(function(partHit)                                                                -- [의미/의도] 날아가는 화살이 어딘가에 충돌(Touched)했을 때 아래 함수를 실행 ➔ 충돌된 물체를 검사하고 타격 효과를 주거나 화살을 처리하기 위함
        if partHit:IsDescendantOf(modelCharacter) then return end                                             -- [의미/의도] 부딪힌 파트가 내 캐릭터의 일부분이면 무시 ➔ 내가 쏜 화살에 내 몸통이 맞아 자폭하는 현상을 막기 위함
        local humTarget = partHit.Parent:FindFirstChildOfClass(ePhysical.HUMANOID)         -- [의미/의도] 부딪힌 대상 부모에서 생명체 속성(Humanoid)을 찾음 ➔ 체력이 존재하는 플레이어나 몬스터인지 판정하기 위함
        if humTarget then humTarget:TakeDamage(DAMAGE) end                                                      -- [의미/의도] 생명체가 맞으면 DAMAGE(18)만큼 체력을 깎음 ➔ 원거리 공격 피해를 정량적으로 적용하기 위함
        if common.hasEngineLogicalNamePrefix(partHit.Name, eLogical.TARGET_PREFIX) then partHit.BrickColor = BrickColor.new("Lime green") end -- [의미/의도] 맞은 파트 이름이 과녁판 enum 접두사("Target_")로 시작한다면 파트 색상을 라임색(Lime green)으로 변경 ➔ TargetPoint 같은 다른 logical type을 오인하지 않고 과녁판 명중만 시각적으로 피드백하기 위함
        partArrow:Destroy()                                                                                    -- [의미/의도] 충돌된 화살을 맵에서 파괴함 ➔ 무언가에 닿아 소명이 다한 화살을 즉시 월드에서 지우기 위함
    end)                                                                                                      -- [의미/의도] Touched 이벤트 콜백 함수의 종료 ➔ 화살 충돌 처리 로직을 마침

    task.wait(COOLDOWN)                                                                                       -- [의미/의도] COOLDOWN(0.9초) 동안 실행을 일시 지연함 ➔ 쿨타임이 도는 동안 다시 활을 쏘지 못하도록 지연시간을 주는 장치
    boolReady = true                                                                                          -- [의미/의도] 준비 상태 스위치를 참(true)으로 원복 ➔ 쿨타임이 끝나 다시 화살을 쏠 수 있도록 활성화하기 위함
end)                                                                                                          -- [의미/의도] Activated 이벤트 콜백 함수의 종료 ➔ 활 시위 당김 프로세스를 마침
