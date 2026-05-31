-- Roblox Studio 수업 스크립트 안내
-- 수업: day04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차의 데미지 조절, 공격 쿨타임, 무게와 속도 비례 규칙을 검 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=검 데미지 값 확인, 스크립터=Debounce 쿨타임, 크리에이터=무게가 큰 검은 강하지만 느린 밸런스입니다.
-- 강의가이드 연결: "공격 쿨타임과 디바운스" 예제로 연타 버그를 공정한 규칙으로 고칩니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > BalanceSword > Script 이름 Day04StudentAnswer
-- 선행 조건: 선생님이 BalanceSword와 Day04_Dummies를 먼저 만들어야 합니다.
-- 학생 목표: Tool.Activated, Touched, debounce 변수가 전투 밸런스를 제어하는 방식을 이해합니다.
-- 검증 기준: 검을 사용하면 짧은 공격 판정만 켜지고, 쿨타임 동안 연속 피해가 막히면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local toolBalanceSword = script.Parent

local DAMAGE = 20
local ACTIVE_TIME = 0.25
local COOLDOWN = 1.2
local boolCanAttack = true

toolBalanceSword.Activated:Connect(function()
    if not boolCanAttack then return end

    boolCanAttack = false
    local tableAlreadyHit = {}
    toolBalanceSword.Handle.BrickColor = BrickColor.new("Really red")

    local connectionTouched = toolBalanceSword.Handle.Touched:Connect(function(partHit)
        local modelTarget = partHit:FindFirstAncestorOfClass("Model")
        local humanoidTarget = modelTarget and modelTarget:FindFirstChildOfClass("Humanoid")
        if not humanoidTarget or modelTarget == toolBalanceSword.Parent or tableAlreadyHit[humanoidTarget] then return end

        tableAlreadyHit[humanoidTarget] = true
        humanoidTarget:TakeDamage(DAMAGE)
    end)

    task.wait(ACTIVE_TIME)
    connectionTouched:Disconnect()
    toolBalanceSword.Handle.BrickColor = BrickColor.new("Medium stone grey")
    task.wait(COOLDOWN)
    boolCanAttack = true
end)
