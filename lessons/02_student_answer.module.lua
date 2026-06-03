-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 역할: 학생용 에셋 설정 코드입니다. 엄폐물 위치, 재질, 색, 층수만 바꿉니다.
-- 붙여넣기 위치: ServerScriptService > StudentLessonConfigs > ModuleScript 이름 StudentAnswer02

local coverDesign = {}
local coverLeft = {}
local coverCenter = {}
local coverRight = {}

coverLeft.Origin = Vector3.new(-14, 1, 8)
coverLeft.Material = Enum.Material.WoodPlanks
coverLeft.Color = "Reddish brown"
coverLeft.Levels = 3

coverCenter.Origin = Vector3.new(0, 1, 8)
coverCenter.Material = Enum.Material.Slate
coverCenter.Color = "Dark stone grey"
coverCenter.Levels = 3

coverRight.Origin = Vector3.new(14, 1, 8)
coverRight.Material = Enum.Material.Metal
coverRight.Color = "Medium blue"
coverRight.Levels = 3

coverDesign.Covers = {
	coverLeft,
	coverCenter,
	coverRight,
}

return coverDesign
