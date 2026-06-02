-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 전초기지 돌 투척과 첫 파밍
-- 역할: 학생용 설정 코드입니다. 돌 외형과 제한된 전투 수치만 바꾸고 생성/획득/피해 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer01

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblRockConfig = {
    VariantId = "Stone01",
    DisplayName = "전장 돌멩이",
    SpawnCount = 3,
    SpawnOffset = Vector3.new(0, 0, 0),
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

common.installThrowingStonePickups(game:GetService("Workspace"), tblRockConfig)
