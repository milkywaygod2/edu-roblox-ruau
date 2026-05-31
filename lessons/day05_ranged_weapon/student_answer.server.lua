-- Roblox Studio 수업 스크립트 안내
-- 수업: day05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차의 투사체 발사, 포물선 물리, 폭발 화살을 활 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=화살 Part 생성, 스크립터=Vector 속도와 중력 궤적, 크리에이터=닿으면 폭발하는 화살입니다.
-- 강의가이드 연결: "투사체와 포물선 공격" 장면에서 직선 공격과 곡선 공격의 차이를 눈으로 확인합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > TrainingBow > Script 이름 Day05StudentAnswer
-- 선행 조건: 선생님이 TrainingBow와 Day05_TargetRange를 먼저 만들어야 합니다.
-- 학생 목표: CFrame.LookVector, AssemblyLinearVelocity, Debris 자동 삭제가 투사체 규칙을 만드는 방식을 이해합니다.
-- 검증 기준: 활 사용 시 화살이 앞으로 포물선으로 날아가고, 목표에 닿으면 피해/폭발 효과가 보이면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceDebris = game:GetService("Debris")
local toolTrainingBow = script.Parent

local SPEED = 110
local ARC = 28
local DAMAGE = 18
local COOLDOWN = 0.9
local boolReady = true

toolTrainingBow.Activated:Connect(function()
    if not boolReady then return end

    local modelCharacter = toolTrainingBow.Parent
    local partHumanoidRoot = modelCharacter:FindFirstChild("HumanoidRootPart")
    if not partHumanoidRoot then return end

    boolReady = false

    local partArrow = Instance.new("Part")
    partArrow.Name = "TrainingArrow"
    partArrow.Size = Vector3.new(0.4, 0.4, 3)
    partArrow.Material = Enum.Material.Wood
    partArrow.CFrame = partHumanoidRoot.CFrame * CFrame.new(0, 1.5, -4)
    partArrow.Parent = workspace
    partArrow.AssemblyLinearVelocity = partHumanoidRoot.CFrame.LookVector * SPEED + Vector3.new(0, ARC, 0)
    serviceDebris:AddItem(partArrow, 6)

    partArrow.Touched:Connect(function(partHit)
        if partHit:IsDescendantOf(modelCharacter) then return end
        local humanoidTarget = partHit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoidTarget then humanoidTarget:TakeDamage(DAMAGE) end
        if partHit.Name:match("Target") then partHit.BrickColor = BrickColor.new("Lime green") end
        partArrow:Destroy()
    end)

    task.wait(COOLDOWN)
    boolReady = true
end)
