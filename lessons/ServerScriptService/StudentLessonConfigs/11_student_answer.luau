-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 역할: 학생용 설정 코드입니다. 지팡이 외형, 파밍 개수, 마법 범위와 제한된 밸런스 값만 바꾸고 서버 검증은 Common 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentLessonConfigs > ModuleScript 이름 11_student_answer

local staff = {}
local staffHandle = {}
local magic = {}
local effect = {}
local magicLesson = {}

staffHandle.Size = Vector3.new(0.6, 5, 0.6)
staffHandle.Material = Enum.Material.Neon
staffHandle.Color = "Royal purple"

staff.VariantId = "Staff01"
staff.DisplayName = "전장 지팡이"
staff.SpawnCount = 2
staff.SpawnOffset = Vector3.new(0, 0, 0)
staff.Handle = staffHandle

effect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
effect.Rate = 24
effect.Color = Color3.fromRGB(255, 112, 36)
effect.LightEmission = 0.4
effect.LightInfluence = 0
effect.Lifetime = NumberRange.new(0.25, 0.7)
effect.Speed = NumberRange.new(0.5, 2)
effect.Size = NumberSequence.new(0.35)
effect.SpreadAngle = Vector2.new(20, 20)
effect.Shape = Enum.ParticleEmitterShape.Sphere
effect.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
effect.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
effect.EmissionDirection = Enum.NormalId.Top
effect.Orientation = Enum.ParticleOrientation.FacingCamera

magic.MaxDistance = 80
magic.Radius = 12
magic.Damage = 25
magic.Cooldown = 1.8
magic.EffectLifetime = 2
magic.Effect = effect

magicLesson.Staff = staff
magicLesson.Magic = magic

return magicLesson
