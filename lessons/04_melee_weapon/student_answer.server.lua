-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 근접 무기와 디바운스
-- 역할: 학생용 설정 코드입니다. 검 외형과 제한된 밸런스 값만 바꾸고 생성/획득/타격 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer04

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblSwordConfig = {
    VariantId = "Sword01",
    DisplayName = "전장 검",
    SpawnCount = 2,
    SpawnOffset = Vector3.new(0, 0, 0),
    Damage = 20,
    ActiveTime = 0.25,
    Cooldown = 1.2,
    ActiveColor = "Really red",
    IdleColor = "Medium stone grey",
    Handle = {
        Size = Vector3.new(1, 5, 1),
        Material = Enum.Material.Metal,
        Color = "Medium stone grey",
    },
}

common.installFieldSwordPickups(game:GetService("Workspace"), tblSwordConfig)
