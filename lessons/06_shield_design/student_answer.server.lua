-- Roblox Studio 수업 스크립트 안내
-- 수업: 06_shield_design - 방패와 방어 규칙
-- 역할: 학생용 설정 코드입니다. 방패 외형과 제한된 방어 수치만 바꾸고 방어 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: StarterPack > PracticeShield > Script 이름 StudentAnswer06

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblShieldConfig = {
    BonusHealth = 60,
    BlockHeal = 5,
    WalkSpeedPenalty = 2,
    Handle = {
        Size = Vector3.new(4, 5, 0.6),
        Material = Enum.Material.Metal,
        Color = "Dark stone grey",
    },
}

common.installPracticeShieldTool(script.Parent, tblShieldConfig)
