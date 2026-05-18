-- Roblox Studio Lesson Script Guide
-- Lesson: day07_armor_design - 갑옷과 이동 패널티
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: StarterPack > HeavyArmor > Script named Day07StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: StarterPack/HeavyArmor
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local tool = script.Parent
local equippedCharacter = nil
local saved = nil

tool.Equipped:Connect(function()
    equippedCharacter = tool.Parent
    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    local root = equippedCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    saved = {MaxHealth = humanoid.MaxHealth, WalkSpeed = humanoid.WalkSpeed, JumpPower = humanoid.JumpPower}
    humanoid.MaxHealth = 180
    humanoid.Health = math.min(humanoid.Health + 80, humanoid.MaxHealth)
    humanoid.WalkSpeed = 10
    humanoid.JumpPower = 32

    local aura = Instance.new("ParticleEmitter")
    aura.Name = "ArmorAura"
    aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    aura.Rate = 20
    aura.Lifetime = NumberRange.new(0.5, 1.2)
    aura.Speed = NumberRange.new(1, 3)
    aura.Parent = root
end)

tool.Unequipped:Connect(function()
    if not equippedCharacter or not saved then return end

    local humanoid = equippedCharacter:FindFirstChildOfClass("Humanoid")
    local root = equippedCharacter:FindFirstChild("HumanoidRootPart")
    if humanoid then
        humanoid.MaxHealth = saved.MaxHealth
        humanoid.Health = math.min(humanoid.Health, saved.MaxHealth)
        humanoid.WalkSpeed = saved.WalkSpeed
        humanoid.JumpPower = saved.JumpPower
    end

    local aura = root and root:FindFirstChild("ArmorAura")
    if aura then aura:Destroy() end

    equippedCharacter = nil
    saved = nil
end)
