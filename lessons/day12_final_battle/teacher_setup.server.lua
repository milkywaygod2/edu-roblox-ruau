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
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

for _, teamName in ipairs({"Blue", "Red"}) do
    local team = Teams:FindFirstChild(teamName) or Instance.new("Team")
    team.Name = teamName
    team.TeamColor = BrickColor.new(teamName == "Blue" and "Bright blue" or "Bright red")
    team.AutoAssignable = true
    team.Parent = Teams
end

local old = Workspace:FindFirstChild("Day12_FinalBattle")
if old then old:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day12_FinalBattle"
folder.Parent = Workspace

local button = Instance.new("Part")
button.Name = "RoundStartButton"
button.Size = Vector3.new(8, 1, 8)
button.Position = Vector3.new(0, 0.5, 0)
button.Anchored = true
button.BrickColor = BrickColor.new("Lime green")
button.Parent = folder

local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 30
detector.Parent = button

for index, x in ipairs({-28, 28}) do
    local spawn = Instance.new("Part")
    spawn.Name = "SpawnPoint_" .. index
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(x, 0.5, -20)
    spawn.Anchored = true
    spawn.BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red")
    spawn.Parent = folder
end

print("12일차 준비 완료")
