-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 중장비와 원격 발사
-- 역할: 학생용 설정 코드입니다. 무거운 탄환 외형과 제한된 발사 수치만 바꾸고 발사 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentSiegeEngineDesigns > ModuleScript 이름 10_student_answer

local siegeEngine = {}

siegeEngine.Cooldown = 2.5
siegeEngine.ForwardSpeed = 95
siegeEngine.UpSpeed = 45
siegeEngine.Lifetime = 8
siegeEngine.StoneSize = Vector3.new(3, 3, 3)
siegeEngine.StoneMaterial = Enum.Material.Slate

return siegeEngine
