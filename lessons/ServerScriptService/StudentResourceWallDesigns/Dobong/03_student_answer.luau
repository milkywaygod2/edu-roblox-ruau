-- Roblox Studio 수업 스크립트 안내
-- 수업: 03_resource_wall - 자원 기반 방벽 소환
-- 역할: 학생용 설정 코드입니다. 자원량, 비용, 방벽 외형만 바꾸고 자원 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentResourceWallDesigns > ModuleScript 이름 03_student_answer

local resourceWall = {}

resourceWall.StartWood = 30
resourceWall.WallCost = 10
resourceWall.BlockCount = 8
resourceWall.BlockSize = Vector3.new(4, 6, 1)
resourceWall.BlockMaterial = Enum.Material.WoodPlanks
resourceWall.BlockColor = "Reddish brown"

return resourceWall
