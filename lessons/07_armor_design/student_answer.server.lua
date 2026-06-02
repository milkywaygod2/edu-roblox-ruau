-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 역할: 학생용 설정 코드입니다. 갑옷 외형과 제한된 장착 수치만 바꾸고 생성/획득/장착 규칙은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer07

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblArmorConfig = {
    VariantId = "Armor01",
    DisplayName = "전장 갑옷",
    SpawnCount = 2,
    SpawnOffset = Vector3.new(0, 0, 0),
    MaxHealth = 180,
    HealOnEquip = 80,
    WalkSpeed = 10,
    JumpPower = 32,
    AuraRate = 20,
    Handle = {
        Size = Vector3.new(2, 2, 1),
        Material = Enum.Material.Metal,
        Color = "Really black",
    },
}

common.installFieldArmorPickups(game:GetService("Workspace"), tblArmorConfig)
