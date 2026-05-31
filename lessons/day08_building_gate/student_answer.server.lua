-- Roblox Studio 수업 스크립트 안내
-- 수업: day08_building_gate - 건물과 파괴되는 성문
-- 문서 매핑: 커리큘럼 8회차의 기지 뼈대, 계단/지붕, 파괴되는 문을 성문 체력 코드로 구성했습니다.
-- 미션 단계: 빌더=성문 구조 확인, 스크립터=체력 값 감소, 크리에이터=0이 되면 Anchored를 풀고 무너지는 문입니다.
-- 강의가이드 연결: "파괴되는 성문 만들기" 장면처럼 한 번에 사라지지 않고 맞을수록 무너지는 건물을 만듭니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day08StudentAnswer
-- 선행 조건: 선생님이 Workspace/Day08_Castle/Gate를 먼저 만들어야 합니다.
-- 학생 목표: Model 내부 Part 순회, 체력 변수, 파괴 시 물리 해제가 건물 규칙을 만드는 방식을 이해합니다.
-- 검증 기준: 대포알 또는 데미지 이벤트 후 성문 체력이 줄고, 0 이하에서 파트가 흩어지면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local folderDay08Castle = workspace:WaitForChild("Day08_Castle") -- [의미] Workspace 내에서 "Day08_Castle" 폴더가 생성될 때까지 대기하여 가져옴 / [의도] 8일차 성 오브젝트가 로드된 후 스크립트를 안정적으로 진행하기 위함
local modelGate = folderDay08Castle:WaitForChild("Gate")         -- [의미] 8일차 성 폴더 내부에서 "Gate" 성문 모델이 생성될 때까지 대기하여 가져옴 / [의도] 성문에 타격 및 파괴 판정을 걸 대상 모델을 확실히 참조하기 위함
local health = 120                                               -- [의미] 성문의 총 내구도(체력) 변수를 120으로 설정 / [의도] 공격 투사체(피해량 30)에 4번 맞아야 문이 파괴되는 구조를 맞추기 위함
local boolBroken = false                                         -- [의미] 성문이 현재 파괴되었는지를 기록하는 불리언 변수를 false로 초기화 / [의도] 이미 문이 부서진 후에도 중복으로 파괴 처리가 일어나는 현상을 막기 위함

local function set_gate_color(color)                                                               -- [의미] 성문 모델 내 모든 파트의 색을 지정한 color로 변경하는 함수 정의 / [의도] 성문이 손상됨에 따라 시각적인 경고 색상으로 변화를 주기 위함
    for _, partGatePlank in ipairs(modelGate:GetDescendants()) do                                  -- [의미] modelGate 모델 내부의 모든 하위 자식(Descendants)들을 순회하며 하나씩 partGatePlank에 담음 / [의도] 성문을 구성하는 모든 나무판자 파트들을 누락 없이 제어하기 위함
        if partGatePlank:IsA("BasePart") then partGatePlank.BrickColor = BrickColor.new(color) end -- [의미] 순회 중인 객체가 물리적인 파트(BasePart) 계열이라면 색상을 지정된 color로 변경 / [의도] 성문 판자 파트들만 골라내어 깔끔하게 도색을 일괄 변경하기 위함
    end                                                                                            -- [의미] 성문 색상 변경 반복문(for)의 종료 / [의도] 모든 판자 파트의 도색 처리를 마침
end                                                                                                -- [의미] set_gate_color 함수의 종료 / [의도] 성문 색상 변경 함수 정의 완료

local function break_gate()                                                                                    -- [의미] 성문 파괴를 실행하는 함수 정의 / [의도] 성문의 고정을 해제하고 물리적으로 흩날리며 무너지는 파괴 효과를 주어 장엄하게 부서지는 모습을 연출하기 위함
    boolBroken = true                                                                                          -- [의미] 파괴 상태 불리언 값을 참(true)으로 변경 / [의도] 성문이 이미 부서진 상태임을 선언하기 위함
    for _, partGatePlank in ipairs(modelGate:GetDescendants()) do                                              -- [의미] 성문 모델 내부의 모든 하위 파트를 순회함 / [의도] 5개의 판자 모두 물리 효과를 적용하여 붕괴시키기 위함
        if partGatePlank:IsA("BasePart") then                                                                  -- [의미] 순회 객체가 BasePart 유형의 물리 파트인 경우 / [의도] 물리 고정을 풀고 힘을 가할 수 있는 물리 오브젝트를 분류하기 위함
            partGatePlank.Anchored = false                                                                     -- [의미] 파트의 공중 고정(Anchored)을 해제(false)시킴 / [의도] 중력과 충돌에 의해 파트들이 자유롭게 굴러 떨어지도록 물리 법칙을 적용하기 위함
            partGatePlank.AssemblyLinearVelocity = Vector3.new(math.random(-25, 25), 35, math.random(-20, 20)) -- [의미] 파트에 X(-25~25), Y(35), Z(-20~20) 범위의 무작위 속도를 폭발적으로 가함 / [의도] 성문이 그냥 털썩 떨어지는 게 아니라 폭발하듯 솟구치며 사방으로 화려하게 흩어지도록 물리 파괴력을 가하기 위함
        end                                                                                                    -- [의미] BasePart 조건문 종료 / [의도] 해당 판자 처리 마침
    end                                                                                                        -- [의미] 붕괴 처리 반복문(for)의 종료 / [의도] 모든 판자 파트에 붕괴 물리 적용 완료
end                                                                                                            -- [의미] break_gate 함수의 종료 / [의도] 성문 붕괴 함수 정의 완료

local function damage_gate(amount)                           -- [의미] 성문에 피해를 주는 함수 정의 (피해량 amount를 매개변수로 받음) / [의도] 입력된 만큼 내구도를 깎고 남은 체력에 따라 색 변경 및 파괴를 유도하기 위함
    if boolBroken then return end                            -- [의미] 이미 문이 부서진 상태라면 함수 실행을 중단 / [의도] 이미 부서진 문에 무의미한 데미지 처리가 반복되는 것을 차단하기 위함
    health -= amount                                         -- [의미] 성문 체력(health)을 amount만큼 차감 / [의도] 가해진 피해량만큼 문에 상처를 입힘
    if health <= 60 then set_gate_color("Bright orange") end -- [의미] 체력이 60(절반) 이하로 떨어지면 성문 파트들을 주황색(Bright orange)으로 변경 / [의도] 성문이 부서지기 일보 직전이라는 위급한 경고 신호를 시각적으로 주기 위함
    if health <= 0 then break_gate() end                     -- [의미] 체력이 0 이하가 되면 break_gate 함수를 호출해 무너뜨림 / [의도] 내구도가 다 한 성문을 붕괴시키기 위함
end                                                          -- [의미] damage_gate 함수의 종료 / [의도] 데미지 처리 함수 정의 완료

for _, partGatePlank in ipairs(modelGate:GetDescendants()) do                       -- [의미] 성문 모델 내부의 모든 하위 파트들을 순회함 / [의도] 각각의 판자 파트마다 투사체 충돌(Touched) 이벤트를 일일이 연결해 주기 위함
    if partGatePlank:IsA("BasePart") then                                           -- [의미] 파트가 BasePart 타입이면 / [의도] 충돌 감지(Touched) 이벤트를 가질 수 있는 물리적 객체에만 연결을 시도하기 위함
        partGatePlank.Touched:Connect(function(partHit)                             -- [의미] 개별 성문 판자에 무언가 닿았을 때(Touched) 충돌한 파트(partHit)를 매개변수로 함수 실행 / [의도] 공격 투사체가 문에 부딪혔는지 실시간으로 검사하기 위함
            if partHit.Name == "TrainingArrow" or partHit.Name == "SiegeStone" then -- [의미] 부딪힌 파트 이름이 화살("TrainingArrow") 또는 공성돌("SiegeStone")이라면 / [의도] 아군 캐릭터의 몸이 부딪힌 것은 무시하고 오직 공격용 투사체에 맞았을 때만 피격 판정을 내리기 위함
                partHit:Destroy()                                                   -- [의미] 부딪힌 투사체 파트를 즉시 맵에서 파괴함 / [의도] 맞은 투사체를 소멸시켜 추가 충돌을 막고 맵을 깔끔하게 치우기 위함
                damage_gate(30)                                                     -- [의미] damage_gate 함수를 호출하여 성문에 30만큼의 데미지를 가함 / [의도] 투사체 타격 당 30의 내구도를 차감하기 위함
            end                                                                     -- [의미] 투사체 종류 판별 조건문의 종료 / [의도] 개별 판자 피격 조건 처리 완료
        end)                                                                        -- [의미] Touched 이벤트 콜백 함수의 종료 / [의도] 해당 판자 충돌 이벤트 연결 완료
    end                                                                             -- [의미] BasePart 판별 조건문의 종료 / [의도] 조건 검사 완료
end                                                                                 -- [의미] 전체 성문 파트 이벤트 연결 반복문(for)의 종료 / [의도] 모든 성문 판자 파트에 개별 충돌 리스너 등록을 완료함
