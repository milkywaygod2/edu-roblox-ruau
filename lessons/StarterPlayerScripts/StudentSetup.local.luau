-- Roblox Studio 수업 스크립트 안내
-- 역할: 학생 클라이언트 공통 입력 런타임을 켭니다.

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

common.installPlayerCombatClientControls()
