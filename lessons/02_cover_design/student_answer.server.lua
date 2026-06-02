-- Roblox Studio 수업 스크립트 안내
-- 수업: 02_cover_design - 기초 엄폐물 디자인
-- 역할: 학생용 에셋 설정 코드입니다. 엄폐물 위치, 재질, 색, 층수만 바꿉니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer02

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblCoverDesign = {
    Covers = {
        {
            Origin = Vector3.new(-14, 1, 8),
            Material = Enum.Material.WoodPlanks,
            Color = "Reddish brown",
            Levels = 3,
        },
        {
            Origin = Vector3.new(0, 1, 8),
            Material = Enum.Material.Slate,
            Color = "Dark stone grey",
            Levels = 3,
        },
        {
            Origin = Vector3.new(14, 1, 8),
            Material = Enum.Material.Metal,
            Color = "Medium blue",
            Levels = 3,
        },
    },
}

common.installStudentCoverDesign(workspace, tblCoverDesign)
