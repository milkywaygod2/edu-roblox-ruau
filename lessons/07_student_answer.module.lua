-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 역할: 학생용 설정 코드입니다. 갑옷 외형과 제한된 장착 수치만 바꾸고 생성/획득/장착 규칙은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > StudentLessonConfigs > ModuleScript 이름 StudentAnswer07

local armor = {}
local handle = {}

handle.Size = Vector3.new(2, 2, 1)
handle.Material = Enum.Material.Metal
handle.Color = "Really black"

armor.VariantId = "Armor01"
armor.DisplayName = "전장 갑옷"
armor.SpawnCount = 2
armor.SpawnOffset = Vector3.new(0, 0, 0)
armor.MaxHealth = 180
armor.HealOnEquip = 80
armor.WalkSpeed = 10
armor.JumpPower = 32
armor.AuraRate = 20
armor.Handle = handle

return armor
