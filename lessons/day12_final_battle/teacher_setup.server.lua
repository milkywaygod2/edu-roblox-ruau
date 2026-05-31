-- Roblox Studio 수업 스크립트 안내
-- 수업: day12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day12_final_battle_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day12_FinalBattle, Teams/Blue, Teams/Red
-- 안전 운영: 기존 Day12 전장과 Teams를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 최종 전장과 Blue/Red 팀이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceTeams = game:GetService("Teams")
local serviceWorkspace = game:GetService("Workspace")

for _, teamName in ipairs({"Blue", "Red"}) do
    local teamInstance = serviceTeams:FindFirstChild(teamName) or Instance.new("Team")
    teamInstance.Name = teamName
    teamInstance.TeamColor = BrickColor.new(teamName == "Blue" and "Bright blue" or "Bright red")
    teamInstance.AutoAssignable = true
    teamInstance.Parent = serviceTeams
end

local folderOld = serviceWorkspace:FindFirstChild("Day12_FinalBattle")
if folderOld then folderOld:Destroy() end

local folderDay12FinalBattle = Instance.new("Folder")
folderDay12FinalBattle.Name = "Day12_FinalBattle"
folderDay12FinalBattle.Parent = serviceWorkspace

local partRoundStartButton = Instance.new("Part")
partRoundStartButton.Name = "RoundStartButton"
partRoundStartButton.Size = Vector3.new(8, 1, 8)
partRoundStartButton.Position = Vector3.new(0, 0.5, 0)
partRoundStartButton.Anchored = true
partRoundStartButton.BrickColor = BrickColor.new("Lime green")
partRoundStartButton.Parent = folderDay12FinalBattle

local clickdetectorButton = Instance.new("ClickDetector")
clickdetectorButton.MaxActivationDistance = 30
clickdetectorButton.Parent = partRoundStartButton

for index, x in ipairs({-28, 28}) do
    local partSpawnPoint = Instance.new("Part")
    partSpawnPoint.Name = "SpawnPoint_" .. index
    partSpawnPoint.Size = Vector3.new(6, 1, 6)
    partSpawnPoint.Position = Vector3.new(x, 0.5, -20)
    partSpawnPoint.Anchored = true
    partSpawnPoint.BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red")
    partSpawnPoint.Parent = folderDay12FinalBattle
end

print("12일차 준비 완료")
