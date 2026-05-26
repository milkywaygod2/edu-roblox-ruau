-- Roblox Studio 수업 스크립트 안내
-- 수업: day02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 빌더/스크립터/크리에이터 단계를 엄폐물 생성과 속성 변경으로 나눴습니다.
-- 미션 단계: 빌더=파트 배치/Anchored, 스크립터=재질과 물리 속성 변경, 크리에이터=여러 파트를 모델처럼 묶어 정리입니다.
-- 강의가이드 연결: Studio 안전지대의 Part, Material, Color, Size, Position 조작을 코드로 반복 생성합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day02StudentAnswer
-- 선행 조건: 선생님이 teacher_setup.server.lua를 먼저 실행해 Workspace/Day02_CoverField를 만들어야 합니다.
-- 학생 목표: 눈에 보이는 Part 속성이 게임 플레이의 엄폐/충돌 규칙으로 바뀌는 과정을 이해합니다.
-- 검증 기준: Play 후 나무/돌 느낌의 엄폐물이 정해진 위치에 생성되고 Output 오류가 없으면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local field = workspace:WaitForChild("Day02_CoverField")
local materials = {Enum.Material.WoodPlanks, Enum.Material.Slate, Enum.Material.Metal}
local colors = {"Reddish brown", "Dark stone grey", "Medium blue"}

local function create_cover(name, origin, material, colorName)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = field

    for level = 1, 3 do
        local block = Instance.new("Part")
        block.Name = "CoverBlock_" .. level
        block.Size = Vector3.new(8 - level, 2, 2)
        block.Position = origin + Vector3.new(0, level, 0)
        block.Anchored = true
        block.CanCollide = true
        block.Material = material
        block.BrickColor = BrickColor.new(colorName)
        block.Parent = model
    end
end

for index = 1, 3 do
    create_cover("StudentCover_" .. index, Vector3.new(index * 14 - 28, 1, 8), materials[index], colors[index])
end

print("Day 02 answer complete")
