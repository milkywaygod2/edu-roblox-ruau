-- Roblox Studio 수업 스크립트 안내
-- 수업: day06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가 방패, 투사체 방어벽, 데미지 반사를 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=장착 시 체력 증가, 스크립터=방패 충돌 영역, 크리에이터=받은 피해 일부를 반사하는 규칙입니다.
-- 강의가이드 연결: 서버에서 데미지와 소유자를 판정해야 멀티플레이 방어 규칙이 공정하게 유지됩니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > PracticeShield > Script 이름 Day06StudentAnswer
-- 선행 조건: 선생님이 PracticeShield Tool을 먼저 만들어야 합니다.
-- 학생 목표: Equipped/Unequipped, 충돌 판정, 방어 상태 변수가 캐릭터 능력치를 바꾸는 방식을 이해합니다.
-- 검증 기준: 방패 장착 시 체력이 늘고, 방어 판정이 켜지며, 해제 시 원래 상태로 돌아오면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local tool = script.Parent

local BONUS_HEALTH = 60
local BLOCK_HEAL = 5
local equippedCharacter = nil
local savedStats = nil

tool.Equipped:Connect(function()
    equippedCharacter = tool.Parent
    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    savedStats = {MaxHealth = humanoid.MaxHealth, WalkSpeed = humanoid.WalkSpeed}
    humanoid.MaxHealth += BONUS_HEALTH
    humanoid.Health = math.min(humanoid.Health + BONUS_HEALTH, humanoid.MaxHealth)
    humanoid.WalkSpeed -= 2
end)

tool.Unequipped:Connect(function()
    if not equippedCharacter or not savedStats then return end

    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = savedStats.MaxHealth
        humanoid.Health = math.min(humanoid.Health, savedStats.MaxHealth)
        humanoid.WalkSpeed = savedStats.WalkSpeed
    end

    equippedCharacter = nil
    savedStats = nil
end)

tool.Handle.Touched:Connect(function(hit)
    if not hit.Name:match("Arrow") and not hit.Name:match("Projectile") then return end
    if not equippedCharacter then return end

    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.Health = math.min(humanoid.Health + BLOCK_HEAL, humanoid.MaxHealth) end
    hit:Destroy()
end)
