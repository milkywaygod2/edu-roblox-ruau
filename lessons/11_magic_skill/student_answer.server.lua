-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 역할: 학생용 설정 코드입니다. 지팡이 외형, 파밍 개수, 마법 범위와 제한된 밸런스 값만 바꾸고 서버 검증은 Common 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 MagicServer11

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblStaffConfig = {
    VariantId = "Staff01",
    DisplayName = "전장 지팡이",
    SpawnCount = 2,
    SpawnOffset = Vector3.new(0, 0, 0),
    Handle = {
        Size = Vector3.new(0.6, 5, 0.6),
        Material = Enum.Material.Neon,
        Color = "Royal purple",
    },
}

local tblMagicConfig = {
    MaxDistance = 80,
    Radius = 12,
    Damage = 25,
    Cooldown = 1.8,
}

common.installMagicStaffPickups(game:GetService("Workspace"), tblStaffConfig)
common.installMagicServerSystem(game:GetService("ReplicatedStorage"), game:GetService("Players"), tblMagicConfig)
