-- Roblox Studio 수업 스크립트 안내
-- 수업: day09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 Union 성벽, 총안구, 부분 파괴를 구역별 체력 시스템으로 구성했습니다.
-- 미션 단계: 빌더=튼튼한 성벽 확인, 스크립터=구역별 체력 감소, 크리에이터=맞은 구역만 무너지는 성벽입니다.
-- 강의가이드 연결: 공성전 플레이테스트에서 "어디가 맞았는지"를 코드로 기록해 현실적인 붕괴를 만듭니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day09StudentAnswer
-- 선행 조건: 선생님이 Workspace/Day09_StoneWall을 먼저 만들어야 합니다.
-- 학생 목표: 여러 Part를 순회하며 Attribute/체력 값을 이용해 성벽 상태를 관리하는 방식을 이해합니다.
-- 검증 기준: 특정 성벽 구역만 피해를 받고, 체력이 0이 된 구역만 무너지면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local wall = workspace:WaitForChild("Day09_StoneWall")
local SECTION_HEALTH = 90
local sectionHealth = {}

local function collapse_section(section)
    for _, part in ipairs(section:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-10, 10))
        end
    end
end

local function register_section(section)
    sectionHealth[section] = SECTION_HEALTH
    for _, part in ipairs(section:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if hit.Name ~= "SiegeStone" and hit.Name ~= "TrainingArrow" then return end
                hit:Destroy()
                sectionHealth[section] -= 30
                part.BrickColor = BrickColor.new("Dark stone grey")
                if sectionHealth[section] <= 0 then collapse_section(section) end
            end)
        end
    end
end

for _, section in ipairs(wall:GetChildren()) do
    if section:IsA("Model") then register_section(section) end
end
