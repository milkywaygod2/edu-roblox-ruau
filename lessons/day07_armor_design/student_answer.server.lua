-- Roblox Studio 수업 스크립트 안내
-- 수업: day07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차의 이동 속도 조절, 점프력 패널티, 파티클 오라를 갑옷 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=WalkSpeed 감소, 스크립터=갑옷 종류별 JumpPower 조건, 크리에이터=ParticleEmitter 오라 연출입니다.
-- 강의가이드 연결: "속도 갑옷과 이동 패널티" 장면처럼 강함과 느림의 교환 관계를 플레이테스트합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > HeavyArmor > Script 이름 Day07StudentAnswer
-- 선행 조건: 선생님이 HeavyArmor Tool을 먼저 만들어야 합니다.
-- 학생 목표: Humanoid 속성 변경과 장비 해제 시 원상복구가 게임 밸런스에 왜 필요한지 이해합니다.
-- 검증 기준: 갑옷 장착 시 체력은 늘고 속도/점프는 줄며, 해제 시 원래 능력치로 돌아오면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local toolHeavyArmor = script.Parent
local modelEquippedCharacter = nil
local tableSavedStats = nil

toolHeavyArmor.Equipped:Connect(function()
    modelEquippedCharacter = toolHeavyArmor.Parent
    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")
    local partHumanoidRoot = modelEquippedCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoidPlayer or not partHumanoidRoot then return end

    tableSavedStats = {MaxHealth = humanoidPlayer.MaxHealth, WalkSpeed = humanoidPlayer.WalkSpeed, JumpPower = humanoidPlayer.JumpPower}
    humanoidPlayer.MaxHealth = 180
    humanoidPlayer.Health = math.min(humanoidPlayer.Health + 80, humanoidPlayer.MaxHealth)
    humanoidPlayer.WalkSpeed = 10
    humanoidPlayer.JumpPower = 32

    local particleemitterArmorAura = Instance.new("ParticleEmitter")
    particleemitterArmorAura.Name = "ArmorAura"
    particleemitterArmorAura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particleemitterArmorAura.Rate = 20
    particleemitterArmorAura.Lifetime = NumberRange.new(0.5, 1.2)
    particleemitterArmorAura.Speed = NumberRange.new(1, 3)
    particleemitterArmorAura.Parent = partHumanoidRoot
end)

toolHeavyArmor.Unequipped:Connect(function()
    if not modelEquippedCharacter or not tableSavedStats then return end

    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")
    local partHumanoidRoot = modelEquippedCharacter:FindFirstChild("HumanoidRootPart")
    if humanoidPlayer then
        humanoidPlayer.MaxHealth = tableSavedStats.MaxHealth
        humanoidPlayer.Health = math.min(humanoidPlayer.Health, tableSavedStats.MaxHealth)
        humanoidPlayer.WalkSpeed = tableSavedStats.WalkSpeed
        humanoidPlayer.JumpPower = tableSavedStats.JumpPower
    end

    local particleemitterArmorAura = partHumanoidRoot and partHumanoidRoot:FindFirstChild("ArmorAura")
    if particleemitterArmorAura then particleemitterArmorAura:Destroy() end

    modelEquippedCharacter = nil
    tableSavedStats = nil
end)
