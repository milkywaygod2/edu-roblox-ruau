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
local folderDay08Castle = workspace:WaitForChild("Day08_Castle")
local modelGate = folderDay08Castle:WaitForChild("Gate")
local health = 120
local boolBroken = false

local function set_gate_color(color)
    for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
        if partGatePlank:IsA("BasePart") then partGatePlank.BrickColor = BrickColor.new(color) end
    end
end

local function break_gate()
    boolBroken = true
    for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
        if partGatePlank:IsA("BasePart") then
            partGatePlank.Anchored = false
            partGatePlank.AssemblyLinearVelocity = Vector3.new(math.random(-25, 25), 35, math.random(-20, 20))
        end
    end
end

local function damage_gate(amount)
    if boolBroken then return end
    health -= amount
    if health <= 60 then set_gate_color("Bright orange") end
    if health <= 0 then break_gate() end
end

for _, partGatePlank in ipairs(modelGate:GetDescendants()) do
    if partGatePlank:IsA("BasePart") then
        partGatePlank.Touched:Connect(function(partHit)
            if partHit.Name == "TrainingArrow" or partHit.Name == "SiegeStone" then
                partHit:Destroy()
                damage_gate(30)
            end
        end)
    end
end
