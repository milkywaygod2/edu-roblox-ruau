-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 역할: 학생용 설정 코드입니다. 활/화살 외형과 제한된 발사 수치만 바꾸고 생성/획득/투사체 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentBowDesigns05 > ModuleScript 이름 05_student_answer

local bow = {}
local handle = {}

handle.Size = Vector3.new(1, 4, 1)
handle.Material = Enum.Material.Wood
handle.Color = "Reddish brown"

bow.VariantId = "Bow01"
bow.DisplayName = "전장 활"
bow.SpawnCount = 2
bow.SpawnOffset = Vector3.new(0, 0, 0)
bow.Speed = 110
bow.Arc = 28
bow.Damage = 18
bow.Cooldown = 0.9
bow.Lifetime = 6
bow.ArrowSize = Vector3.new(0.4, 0.4, 3)
bow.ArrowMaterial = Enum.Material.Wood
bow.TargetHitColor = "Lime green"
bow.Handle = handle

return bow
