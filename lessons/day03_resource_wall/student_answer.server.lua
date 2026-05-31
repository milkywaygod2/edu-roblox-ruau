-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차의 클릭 소환, 자원 소모, 조건문 방어벽을 서버 코드로 구성했습니다.
-- 미션 단계: 빌더=버튼 클릭, 스크립터=Wood 변수 차감, 크리에이터=Wood가 충분할 때만 방벽 생성입니다.
-- 강의가이드 연결: "클릭으로 방벽 소환하기" 예제를 실제 공성전 자원 규칙으로 확장합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day03StudentAnswer
-- 선행 조건: 선생님이 BuildButton과 WallSpawn을 먼저 만들어야 합니다.
-- 학생 목표: ClickDetector 이벤트, leaderstats 자원, if 조건문이 하나의 방어 시스템으로 묶이는 흐름을 이해합니다.
-- 검증 기준: 버튼 클릭 시 Wood가 줄고, 자원이 충분할 때만 방벽이 생성되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local servicePlayers = game:GetService("Players")
local folderDay03ResourceWall = workspace:WaitForChild("Day03_ResourceWall")
local partBuildButton = folderDay03ResourceWall:WaitForChild("BuildButton")
local partWallSpawn = folderDay03ResourceWall:WaitForChild("WallSpawn")

local START_WOOD = 30
local WALL_COST = 10
local nextRow = 0

local function setup_stats(player)
    local folderLeaderstats = Instance.new("Folder")
    folderLeaderstats.Name = "leaderstats"
    folderLeaderstats.Parent = player

    local intvalueWood = Instance.new("IntValue")
    intvalueWood.Name = "Wood"
    intvalueWood.Value = START_WOOD
    intvalueWood.Parent = folderLeaderstats
end

local function build_wall(player)
    local intvalueWood = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wood")
    if not intvalueWood or intvalueWood.Value < WALL_COST then return end

    intvalueWood.Value -= WALL_COST
    nextRow += 1

    for index = 1, 8 do
        local partWallBlock = Instance.new("Part")
        partWallBlock.Name = player.Name .. "_WallBlock"
        partWallBlock.Size = Vector3.new(4, 6, 1)
        partWallBlock.Position = partWallSpawn.Position + Vector3.new((index - 4.5) * 4, 3, nextRow * 3)
        partWallBlock.Anchored = true
        partWallBlock.Material = Enum.Material.WoodPlanks
        partWallBlock.BrickColor = BrickColor.new("Reddish brown")
        partWallBlock.Parent = folderDay03ResourceWall
    end
end

servicePlayers.PlayerAdded:Connect(setup_stats)
for _, player in ipairs(servicePlayers:GetPlayers()) do setup_stats(player) end
partBuildButton.ClickDetector.MouseClick:Connect(build_wall)
