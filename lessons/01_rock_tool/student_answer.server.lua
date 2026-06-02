-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 돌멩이 디자인과 기초 무기
-- 역할: 학생용 설정 코드입니다. 아래 tblRockConfig 값만 바꾸고, 실제 공격 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: StarterPack > PracticeRock > Script 이름 StudentAnswer01

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblRockConfig = {
    Damage = 15,
    Cooldown = 0.8,
    Speed = 90,
    Arc = 12,
    KnockbackForward = 45,
    KnockbackUp = 18,
    Lifetime = 5,
    ProjectileSize = Vector3.new(1.2, 1.2, 1.2),
    ProjectileMaterial = Enum.Material.Slate,
    ProjectileColor = "Dark stone grey",
    Handle = {
        Size = Vector3.new(1, 1, 1),
        Material = Enum.Material.Slate,
        Color = "Dark stone grey",
    },
}

common.installPracticeRockTool(script.Parent, tblRockConfig)
