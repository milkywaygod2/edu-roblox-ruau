-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 역할: 학생용 설정 코드입니다. 활/화살 외형과 제한된 발사 수치만 바꾸고 생성/획득/투사체 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer05

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblBowConfig = {
    VariantId = "Bow01",
    DisplayName = "전장 활",
    SpawnCount = 2,
    SpawnOffset = Vector3.new(0, 0, 0),
    Speed = 110,
    Arc = 28,
    Damage = 18,
    Cooldown = 0.9,
    Lifetime = 6,
    ArrowSize = Vector3.new(0.4, 0.4, 3),
    ArrowMaterial = Enum.Material.Wood,
    TargetHitColor = "Lime green",
    Handle = {
        Size = Vector3.new(1, 4, 1),
        Material = Enum.Material.Wood,
        Color = "Reddish brown",
    },
}

common.installFieldBowPickups(game:GetService("Workspace"), tblBowConfig)
