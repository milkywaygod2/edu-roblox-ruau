-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차의 클릭 소환, 자원 소모, 조건문 방어벽을 서버 코드로 구성했습니다.
-- 미션 단계: 빌더=버튼 클릭, 스크립터=Wood 변수 차감, 크리에이터=Wood가 충분할 때만 방벽 생성입니다.
-- 강의가이드 연결: "클릭으로 방벽 소환하기" 예제를 실제 공성전 자원 규칙으로 확장합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
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

-- --------------------------------------------------------------------------------

local servicePlayers = game:GetService("Players")                            -- [의미] Players 서비스를 가져옴 / [의도] 게임에 입장하는 플레이어 정보를 가져오고 leaderstats를 관리하기 위함
local folderDay03ResourceWall = workspace:WaitForChild("Day03_ResourceWall") -- [의미] Workspace에서 "Day03_ResourceWall" 폴더가 생성될 때까지 대기 후 가져옴 / [의도] 3일차 월드 오브젝트가 확실히 로드된 후 스크립트를 진행하기 위함
local partBuildButton = folderDay03ResourceWall:WaitForChild("BuildButton")  -- [의미] 3일차 폴더 내에서 "BuildButton" 파트가 존재할 때까지 대기하여 가져옴 / [의도] 플레이어의 클릭 이벤트를 받을 버튼 객체를 안전하게 참조하기 위함
local partWallSpawn = folderDay03ResourceWall:WaitForChild("WallSpawn")      -- [의미] 3일차 폴더 내에서 "WallSpawn" 파트가 존재할 때까지 대기하여 가져옴 / [의도] 방벽이 소환될 물리적인 기준 좌표를 사용하기 위함

local START_WOOD = 30 -- [의미] 플레이어가 처음 게임에 들어올 때 가질 기본 나무(Wood) 자원을 30으로 설정 / [의도] 방벽 소환 테스트를 최소 3번 진행해볼 수 있도록 충분한 초기 자원을 주기 위함
local WALL_COST = 10  -- [의미] 방벽을 한 줄 생성할 때 필요한 나무(Wood) 소모 비용을 10으로 설정 / [의도] 자원이 차감되어 소진되었을 때 방벽이 더 이상 생기지 않는 규칙을 테스트하기 위함
local nextRow = 0     -- [의미] 소환할 방벽의 행(Row) 번호를 저장할 변수를 0으로 초기화 / [의도] 버튼을 반복해서 누를 때 방벽이 겹치지 않고 앞쪽으로 밀려나며 겹겹이 소환되도록 하기 위함

local function setup_stats(player)                   -- [의미] 플레이어에게 게임 화면에 보일 점수판(stats)을 등록하는 함수 정의 / [의도] 각 플레이어마다 나무 자원 데이터를 개별 관리하고 화면에 실시간으로 표시하기 위함
    local folderLeaderstats = Instance.new("Folder") -- [의미] 새로운 폴더(Folder) 객체를 생성함 / [의도] 로블록스에서 화면 우측 상단에 스탯을 띄워주는 고유 폴더("leaderstats") 역할을 하기 위함
    folderLeaderstats.Name = "leaderstats"           -- [의미] 폴더 이름을 반드시 소문자 "leaderstats"로 설정 / [의도] 로블록스 내장 스탯 시스템이 인식할 수 있도록 예약어 규칙을 맞추기 위함
    folderLeaderstats.Parent = player                -- [의미] 생성된 폴더의 부모를 플레이어(player) 객체로 설정 / [의도] 플레이어에게 스탯판을 귀속시켜 작동시키기 위함

    local intvalueWood = Instance.new("IntValue") -- [의미] 정수를 저장하는 객체(IntValue)를 생성함 / [의도] 나무(Wood)의 수량을 숫자로 나타내고 보관하기 위함
    intvalueWood.Name = "Wood"                    -- [의미] 객체의 이름을 "Wood"로 설정 / [의도] 화면 스탯판에 "Wood"라는 항목으로 표시되게 하기 위함
    intvalueWood.Value = START_WOOD               -- [의미] 나무 객체의 값을 초기치인 START_WOOD(30)로 설정 / [의도] 초기화된 자원을 주입하기 위함
    intvalueWood.Parent = folderLeaderstats       -- [의미] 나무 객체를 leaderstats 폴더의 자식으로 등록 / [의도] 스탯 화면에 실제 나무 수치가 나타나도록 하기 위함
end                                               -- [의미] setup_stats 함수의 종료 / [의도] 플레이어별 스탯 초기화 처리를 완료함

local function build_wall(player)                                                                           -- [의미] 방벽을 소환하는 함수 정의 (누른 플레이어 정보를 입력받음) / [의도] 클릭한 플레이어의 자원 유무에 따라 물리 방벽을 생성하기 위함
    local intvalueWood = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wood") -- [의미] 플레이어의 leaderstats 폴더 안에서 "Wood" 값을 찾음 / [의도] 플레이어가 현재 가진 나무의 수량을 확인하기 위함
    if not intvalueWood or intvalueWood.Value < WALL_COST then return end                                   -- [의미] 나무 데이터가 없거나, 현재 가진 나무의 양이 WALL_COST(10) 미만이면 함수 실행 중단 / [의도] 자원이 부족할 경우 방벽이 소환되는 것을 방어하기 위함

    intvalueWood.Value -= WALL_COST -- [의미] 나무 자원에서 WALL_COST(10)만큼을 뺌 / [의도] 방벽 소환 비용으로 자원을 소모시키기 위함
    nextRow += 1                    -- [의미] 방벽 행 인덱스(nextRow)를 1만큼 증가시킴 / [의도] 다음에 생성될 방벽이 겹치지 않고 더 먼 거리에 생성되도록 행을 밀어주기 위함

    for index = 1, 8 do                                                                                  -- [의미] index 변수를 1부터 8까지 증가시키며 반복함 / [의도] 8개의 벽돌 파트를 한 줄로 묶어 긴 횡형 방벽을 완성하기 위함
        local partWallBlock = Instance.new("Part")                                                       -- [의미] 새로운 파트(Part) 객체를 생성함 / [의도] 방벽을 이루는 개별 벽돌 블록을 만들기 위함
        partWallBlock.Name = player.Name .. "_WallBlock"                                                 -- [의미] 파트 이름을 "플레이어이름_WallBlock"으로 설정 / [의도] 어떤 플레이어가 만든 방벽 블록인지 이름을 통해 추적 가능하도록 위함
        partWallBlock.Size = Vector3.new(4, 6, 1)                                                        -- [의미] 벽돌 파트의 크기를 4x6x1로 설정 / [의도] 한 줄로 이어붙여서 실제로 적을 막아내는 두꺼운 벽돌 판 형태로 만들기 위함
        partWallBlock.Position = partWallSpawn.Position + Vector3.new((index - 4.5) * 4, 3, nextRow * 3) -- [의미] 방벽 생성 위치 마커를 기준으로 가로(X축) 방향으로 일정 간격 정렬하고, 다음 행(nextRow)에 따라 앞(Z축)으로 3칸씩 띄워서 배치 / [의도] 8개의 파트가 빈틈없이 길게 붙고, 누를 때마다 한 줄씩 한 단계 앞에 안정적으로 정렬되어 쌓이도록 정교한 배치식을 작성함
        partWallBlock.Anchored = true                                                                    -- [의미] 파트를 공중에 고정시킴 / [의도] 생성된 방벽 블록이 무너지거나 밀리지 않도록 고정하기 위함
        partWallBlock.Material = Enum.Material.WoodPlanks                                                -- [의미] 파트의 재질을 나무판자(WoodPlanks)로 설정 / [의도] 나무 자원으로 지은 방벽임을 시각적으로 표현하기 위함
        partWallBlock.BrickColor = BrickColor.new("Reddish brown")                                       -- [의미] 파트 색상을 나무 느낌의 적갈색(Reddish brown)으로 설정 / [의도] 나무로 지어진 인상을 강하게 연출하기 위함
        partWallBlock.Parent = folderDay03ResourceWall                                                   -- [의미] 생성된 벽돌 파트를 Day03_ResourceWall 폴더의 자식으로 등록 / [의도] 3일차 폴더 내부에서 방벽 파트들을 묶어 관리하기 위함
    end                                                                                                  -- [의미] 반복문(for)의 종료 / [의도] 8개의 벽돌 파트를 모두 소환하여 한 줄짜리 방벽 생성을 끝냄
end                                                                                                      -- [의미] build_wall 함수의 종료 / [의도] 방벽 빌드 함수 정의를 완료함

servicePlayers.PlayerAdded:Connect(setup_stats)                                 -- [의미] 새로 접속하는 플레이어(PlayerAdded)에게 setup_stats 함수를 실행하도록 이벤트를 연결 / [의도] 서버 실행 후 들어오는 모든 플레이어에게 점수판을 자동 생성해주기 위함
for _, player in ipairs(servicePlayers:GetPlayers()) do setup_stats(player) end -- [의미] 현재 접속해 있는 모든 플레이어들을 리스트로 가져와 각각 setup_stats 함수를 즉시 호출 / [의도] 스크립트 실행 시점에 이미 접속해 있던 플레이어들에게도 점수판을 누락 없이 만들어주기 위함
partBuildButton.ClickDetector.MouseClick:Connect(build_wall)                    -- [의미] 버튼 파트의 마우스 클릭 감지 시(MouseClick) build_wall 함수를 실행하도록 이벤트를 연결 / [의도] 플레이어가 버튼을 클릭하면 나무 자원이 차감되며 방벽을 건설하게 만들기 위함
