-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 5v5 전초기지 공방전
-- 역할: 학생용 설정 코드입니다. 라운드 시간과 스폰 높이만 바꾸고 라운드 진행은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer12

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblFinalBattleConfig = {
    RoundTime = 180,
    RespawnHeight = 4,
    MaxPlayersPerTeam = 5,
    CoreHealth = 160,
}

common.installFinalBattleSystem(workspace, game:GetService("Players"), tblFinalBattleConfig)
