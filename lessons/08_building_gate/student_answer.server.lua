-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 건물과 파괴되는 성문
-- 역할: 학생용 설정 코드입니다. 성문 내구도와 손상 색만 바꾸고 피격/붕괴 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer08

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblGateConfig = {
    Health = 120,
    DamagePerHit = 30,
    WarningHealth = 60,
    WarningColor = "Bright orange",
}

common.installGateDamageSystem(workspace, tblGateConfig)
