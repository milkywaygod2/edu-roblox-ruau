-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차의 랜덤 스폰, 최종 밸런싱, 실시간 에자일 핫픽스를 라운드 코드로 구성했습니다.
-- 미션 단계: 빌더=랜덤 스폰/무기 확인, 스크립터=라운드와 승리 조건, 크리에이터=전투 중 버그를 고쳐 재테스트하는 핫픽스입니다.
-- 강의가이드 연결: "최종 대전 운영과 실시간 핫픽스"처럼 완성 발표보다 플레이 테스트와 개선이 핵심입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차의 랜덤 스폰, 최종 밸런싱, 실시간 에자일 핫픽스를 라운드 코드로 구성했습니다.
-- 미션 단계: 빌더=랜덤 스폰/무기 확인, 스크립터=라운드와 승리 조건, 크리에이터=전투 중 버그를 고쳐 재테스트하는 핫픽스입니다.
-- 강의가이드 연결: "최종 대전 운영과 실시간 핫픽스"처럼 완성 발표보다 플레이 테스트와 개선이 핵심입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer12
-- 선행 조건: 선생님이 FinalBattle12 전장과 Blue/Red 팀을 먼저 만들어야 합니다.
-- 학생 목표: 팀 배정, 랜덤 스폰, 라운드 타이머, 밸런스 값을 하나의 최종 공성전 규칙으로 연결합니다.
-- 검증 기준: Play 후 팀/스폰이 배정되고, RoundState와 TimeLeft가 바뀌며, 라운드가 정상 종료되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local servicePlayers = game:GetService("Players")                                 -- [의미/의도] Players 서비스를 가져옴 ➔ 접속해 있는 플레이어 리스트를 조회하고 텔레포트시키기 위함
local folderFinalBattle12 = workspace:WaitForChild("FinalBattle12")               -- [의미/의도] Workspace에서 "FinalBattle12" 폴더가 생성될 때까지 대기하여 가져옴 ➔ 12일차 셋업 오브젝트가 완전히 로드된 후 스크립트를 동작시키기 위함
local partRoundStartButton = folderFinalBattle12:WaitForChild("RoundStartButton") -- [의미/의도] 12일차 폴더 내부에서 "RoundStartButton" 파트가 생성될 때까지 대기하여 가져옴 ➔ 클릭 감지기 클릭 이벤트를 연결하기 위함

local ROUND_TIME = 180         -- [의미/의도] 한 매치 라운드 진행 제한시간을 180초(3분)로 설정 ➔ 공성 대대전 한 판이 너무 길어지지 않고 긴장감 있게 끝나도록 시간 규칙을 정하기 위함
local RESPAWN_HEIGHT = 4       -- [의미/의도] 텔레포트 부활 시 추가로 높여줄 Y축 간격을 4칸으로 설정 ➔ 스폰 패드 위치로 이동할 때 바닥에 끼이거나 충돌 오류가 나지 않도록 위로 넉넉하게 띄워 스폰시키기 위함
local boolRoundRunning = false -- [의미/의도] 라운드가 현재 실행 중인지를 기록할 불리언 변수를 false로 초기화 ➔ 이미 매치가 진행 중인데 버튼을 중복으로 눌러 라운드 타이머가 오작동하는 버그를 차단하기 위함

local function get_spawn_points()                                                -- [의미/의도] 맵에 배치된 스폰 패드 리스트를 반환하는 함수 정의 ➔ 폴더 내에서 동적으로 스폰 패드들을 수집하여 플레이어 이동 처리에 유연하게 대처하기 위함
    local tableSpawnPoints = {}                                                  -- [의미/의도] 스폰 패드 파트들을 수집할 빈 테이블 생성 ➔ 찾은 스폰 패드들을 인덱스 순서대로 저장하기 위함
    for _, partChild in ipairs(folderFinalBattle12:GetChildren()) do             -- [의미/의도] FinalBattle12 폴더의 모든 1단계 자식 객체들을 순회 ➔ 폴더 내부의 스폰 패드들을 전부 찾아내기 위함
        if partChild.Name:match("SpawnPoint") and partChild:IsA("BasePart") then -- [의미/의도] 이름에 "SpawnPoint"가 포함되어 있고 물리 파트(BasePart) 타입이라면 ➔ 다른 장식용 파트나 스크립트를 제외하고 실제 스폰 패드 역할 파트만 정확히 걸러내기 위함
            table.insert(tableSpawnPoints, partChild)                            -- [의미/의도] tableSpawnPoints 테이블에 해당 스폰 파트를 추가 ➔ 수집된 스폰 패드를 리스트에 차례대로 누적하기 위함
        end                                                                      -- [의미/의도] 스폰 파트 검출 조건문 종료 ➔ 처리 마침
    end                                                                          -- [의미/의도] 자식 순회 반복문(for)의 종료 ➔ 폴더 내 모든 오브젝트 검사를 완료함
    return tableSpawnPoints                                                      -- [의미/의도] 최종 수집된 스폰 패드 리스트 테이블을 반환 ➔ 함수 호출자에게 스폰 패드 목록을 넘겨주기 위함
end                                                                              -- [의미/의도] get_spawn_points 함수의 종료 ➔ 스폰 수집 함수 정의 완료

local function move_players_to_spawns()                                                              -- [의미/의도] 모든 접속 중인 플레이어를 팀 스폰 거점으로 순간 이동시키는 함수 정의 ➔ 라운드 개시와 동시에 대전 현장으로 양 팀 플레이어들을 팀별로 분산 배치시키기 위함
    local tableSpawns = get_spawn_points()                                                           -- [의미/의도] get_spawn_points 함수를 호출하여 맵에 깔린 스폰 패드 목록을 가져옴 ➔ 이동 목표지가 될 스폰 패드들을 확보하기 위함
    for index, playerPlayer in ipairs(servicePlayers:GetPlayers()) do                                -- [의미/의도] 현재 서버에 접속한 모든 플레이어들을 리스트로 받아 순회함 ➔ 전원 한 명도 빠짐없이 텔레포트시키기 위함
        local modelCharacter = playerPlayer.Character or playerPlayer.CharacterAdded:Wait()          -- [의미/의도] 플레이어의 현재 캐릭터를 가져오되, 로드되지 않았다면 새로 스폰될 때까지 대기(Wait) ➔ 캐릭터가 아직 생성되지 않은 상태에서 발생할 순간 이동 좌표 지정 널 에러를 철저히 방지하기 위함
        local partHumanoidRoot = modelCharacter:WaitForChild("HumanoidRootPart")                     -- [의미/의도] 캐릭터 내부에서 중심 몸통 파트(HumanoidRootPart)가 생성될 때까지 안전하게 대기하여 가져옴 ➔ 텔레포트의 기준이 될 물리 몸바닥 중심 부위를 획득하기 위함
        local partSpawn = tableSpawns[((index - 1) % #tableSpawns) + 1]                              -- [의미/의도] 플레이어 순서 인덱스를 스폰 패드 개수로 나눈 나머지 연산을 적용해 스폰 패드를 순차 매칭 ➔ 플레이어들을 청팀/홍팀 스폰 구역으로 반반씩 지그재그로 분배하여 균등하게 순간 이동 목적지를 정하기 위함
        partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, RESPAWN_HEIGHT, 0)) -- [의미/의도] 캐릭터 몸통의 CFrame 좌표를 스폰 패드 위치의 4칸 위(RESPAWN_HEIGHT)로 갱신 적용 ➔ 플레이어 캐릭터를 해당 스폰 거점으로 물리 끼임 에러 없이 깔끔하게 텔레포트시키기 위함
    end                                                                                              -- [의미/의도] 플레이어 순회 이동 반복문(for)의 종료 ➔ 모든 플레이어의 순간 이동 배치를 완료함
end                                                                                                  -- [의미/의도] move_players_to_spawns 함수의 종료 ➔ 순간 이동 함수 정의 완료

local function start_round(playerPlayer) -- [의미/의도] 라운드를 가동하는 메인 함수 정의 (버튼을 누른 플레이어 정보를 인자로 받음) ➔ 라운드의 상태와 남은 시간 타이머를 관리하고 텔레포트 및 종료 신호를 서버 전역에 설정하기 위함
    if boolRoundRunning then return end  -- [의미/의도] 이미 라운드가 진행 중(boolRoundRunning이 true)이라면 즉시 실행 중단 ➔ 중복으로 매치를 시작해 타이머가 꼬이는 충돌을 원천 차단하기 위함

    boolRoundRunning = true                                   -- [의미/의도] 라운드 실행 변수를 참(true)으로 선언 ➔ 라운드 진행 중 상태 락을 걸기 위함
    workspace:SetAttribute("RoundStarter", playerPlayer.Name) -- [의미/의도] Workspace 전역 속성(Attribute)에 "RoundStarter" 이름으로 버튼을 누른 플레이어 이름을 저장 ➔ 누가 이 판을 시작했는지 서버 내 모든 스크립터가 볼 수 있도록 전역 기록하기 위함
    workspace:SetAttribute("RoundState", "Preparing")         -- [의미/의도] Workspace 전역 속성 "RoundState"를 "Preparing"(준비 중)으로 설정 ➔ 매치 시작 신호를 보내기 전에 준비 단계 상태임을 클라이언트와 서버가 공유하게 하기 위함
    move_players_to_spawns()                                  -- [의미/의도] move_players_to_spawns 함수를 호출 ➔ 플레이어들을 각자 팀 스폰지로 강제 텔레포트시켜 정렬하기 위함

    workspace:SetAttribute("RoundState", "Playing")     -- [의미/의도] Workspace 전역 속성 "RoundState"를 "Playing"(게임 중)으로 변경 ➔ 이제 전투가 본궤도에 올랐음을 알려 UI 및 스크립터들이 스위치되게 하기 위함
    for intTimeLeft = ROUND_TIME, 0, -1 do              -- [의미/의도] intTimeLeft 변수를 ROUND_TIME(180초)부터 0초까지 -1씩 감소시키며 루프 실행 ➔ 실시간 남은 시간(초) 타이머 카운트다운을 처리하기 위함
        workspace:SetAttribute("TimeLeft", intTimeLeft) -- [의미/의도] Workspace 전역 속성 "TimeLeft"에 현재 남은 초 단위 시간을 대입 ➔ 플레이어들의 화면(UI)에 실시간 남은 타이머 시간 숫자가 정확하게 업데이트되어 갱신되도록 하기 위함
        task.wait(1)                                    -- [의미/의도] 정확히 1초 동안 스크립트 실행을 일시 지연시킴 ➔ 현실 시간 1초 간격으로 타임아웃을 안전하게 카운트다운하기 위함
    end                                                 -- [의미/의도] 타이머 카운트다운 반복문의 종료 ➔ 180초 타이머 완료

    workspace:SetAttribute("RoundState", "Finished") -- [의미/의도] Workspace 전역 속성 "RoundState"를 "Finished"(종료됨)로 변경 ➔ 제한시간 종료로 인해 공성 매치가 끝났음을 시스템에 전달하기 위함
    boolRoundRunning = false                         -- [의미/의도] 라운드 가동 변수를 다시 거짓(false)으로 해제 ➔ 매치가 완전히 끝났으므로 버튼을 다시 눌러 다음 판을 쏠 수 있게 준비 상태로 열어두기 위함
end                                                  -- [의미/의도] start_round 함수의 종료 ➔ 라운드 제어 함수 정의 완료

partRoundStartButton.ClickDetector.MouseClick:Connect(start_round) -- [의미/의도] 시작 버튼의 클릭 감지 시(MouseClick) start_round 함수를 실행하도록 이벤트를 연결 ➔ 플레이어가 버튼을 클릭하면 최종 대대전 라운드 시스템이 작동을 시작하도록 만들기 위함
