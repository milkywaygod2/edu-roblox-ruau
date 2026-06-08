-- Roblox Studio 수업 스크립트 안내
-- 수업: 06_shield_design - 방패와 방어 규칙
-- 역할: 학생용 설정 코드입니다. 방패 외형과 제한된 방어 수치만 바꾸고 생성/획득/방어 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentShieldDesigns > ModuleScript 이름 06_student_answer

local shield = {}
local handle = {}

handle.Size = Vector3.new(4, 5, 0.6)
handle.Material = Enum.Material.Metal
handle.Color = "Dark stone grey"

shield.VariantId = "Shield01"
shield.DisplayName = "전장 방패"
shield.SpawnCount = 2
shield.SpawnOffset = Vector3.new(0, 0, 0)
shield.BonusHealth = 60
shield.BlockHeal = 5
shield.WalkSpeedPenalty = 2
shield.Handle = handle

return shield
