-- Roblox Studio 수업 스크립트 안내
-- 수업: 04_melee_weapon - 근접 무기와 디바운스
-- 역할: 학생용 설정 코드입니다. 검 외형과 제한된 밸런스 값만 바꾸고 생성/획득/타격 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentSwordDesigns > ModuleScript 이름 04_student_answer

local sword = {}
local handle = {}

handle.Size = Vector3.new(1, 5, 1)
handle.Material = Enum.Material.Metal
handle.Color = "Medium stone grey"

sword.VariantId = "Sword01"
sword.DisplayName = "전장 검"
sword.SpawnCount = 2
sword.SpawnOffset = Vector3.new(0, 0, 0)
sword.Damage = 20
sword.ActiveTime = 0.25
sword.Cooldown = 1.2
sword.ActiveColor = "Really red"
sword.IdleColor = "Medium stone grey"
sword.Handle = handle

return sword
