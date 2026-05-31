-- Roblox Studio 수업 스크립트 안내
-- 수업: day12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차의 랜덤 스폰, 최종 밸런싱, 실시간 에자일 핫픽스를 라운드 코드로 구성했습니다.
-- 미션 단계: 빌더=랜덤 스폰/무기 확인, 스크립터=라운드와 승리 조건, 크리에이터=전투 중 버그를 고쳐 재테스트하는 핫픽스입니다.
-- 강의가이드 연결: "최종 대전 운영과 실시간 핫픽스"처럼 완성 발표보다 플레이 테스트와 개선이 핵심입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차의 랜덤 스폰, 최종 밸런싱, 실시간 에자일 핫픽스를 라운드 코드로 구성했습니다.
-- 미션 단계: 빌더=랜덤 스폰/무기 확인, 스크립터=라운드와 승리 조건, 크리에이터=전투 중 버그를 고쳐 재테스트하는 핫픽스입니다.
-- 강의가이드 연결: "최종 대전 운영과 실시간 핫픽스"처럼 완성 발표보다 플레이 테스트와 개선이 핵심입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day12StudentAnswer
-- 선행 조건: 선생님이 Day12_FinalBattle 전장과 Blue/Red 팀을 먼저 만들어야 합니다.
-- 학생 목표: 팀 배정, 랜덤 스폰, 라운드 타이머, 밸런스 값을 하나의 최종 공성전 규칙으로 연결합니다.
-- 검증 기준: Play 후 팀/스폰이 배정되고, RoundState와 TimeLeft가 바뀌며, 라운드가 정상 종료되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local servicePlayers = game:GetService("Players")
local folderDay12FinalBattle = workspace:WaitForChild("Day12_FinalBattle")
local partRoundStartButton = folderDay12FinalBattle:WaitForChild("RoundStartButton")

local ROUND_TIME = 180
local RESPAWN_HEIGHT = 4
local boolRoundRunning = false

local function get_spawn_points()
    local tableSpawnPoints = {}
    for _, partChild in ipairs(folderDay12FinalBattle:GetChildren()) do
        if partChild.Name:match("SpawnPoint") and partChild:IsA("BasePart") then
            table.insert(tableSpawnPoints, partChild)
        end
    end
    return tableSpawnPoints
end

local function move_players_to_spawns()
    local tableSpawns = get_spawn_points()
    for index, playerPlayer in ipairs(servicePlayers:GetPlayers()) do
        local modelCharacter = playerPlayer.Character or playerPlayer.CharacterAdded:Wait()
        local partHumanoidRoot = modelCharacter:WaitForChild("HumanoidRootPart")
        local partSpawn = tableSpawns[((index - 1) % #tableSpawns) + 1]
        partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, RESPAWN_HEIGHT, 0))
    end
end

local function start_round(playerPlayer)
    if boolRoundRunning then return end

    boolRoundRunning = true
    workspace:SetAttribute("RoundStarter", playerPlayer.Name)
    workspace:SetAttribute("RoundState", "Preparing")
    move_players_to_spawns()

    workspace:SetAttribute("RoundState", "Playing")
    for intTimeLeft = ROUND_TIME, 0, -1 do
        workspace:SetAttribute("TimeLeft", intTimeLeft)
        task.wait(1)
    end

    workspace:SetAttribute("RoundState", "Finished")
    boolRoundRunning = false
end

partRoundStartButton.ClickDetector.MouseClick:Connect(start_round)
