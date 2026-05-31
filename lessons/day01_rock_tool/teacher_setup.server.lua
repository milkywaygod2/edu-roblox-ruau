-- Roblox Studio 수업 스크립트 안내
-- 수업: day01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 Tool 장착, Touched 데미지, Velocity 넉백을 첫 전투 도구로 준비합니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 장면으로, 학생이 눈에 보이는 Part가 실제 공격 규칙이 되는 경험을 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 Tool 장착, Touched 데미지, Velocity 넉백을 첫 전투 도구로 준비합니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 장면으로, 학생이 눈에 보이는 Part가 실제 공격 규칙이 되는 경험을 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day01_rock_tool_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day01_Arena, StarterPack/PracticeRock
-- 안전 운영: 기존 Day01 오브젝트와 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Explorer에 연습 아레나와 PracticeRock이 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceStarterPack = game:GetService("StarterPack")
local serviceWorkspace = game:GetService("Workspace")

local folderOldArena = serviceWorkspace:FindFirstChild("Day01_Arena")
if folderOldArena then folderOldArena:Destroy() end

local folderDay01Arena = Instance.new("Folder")
folderDay01Arena.Name = "Day01_Arena"
folderDay01Arena.Parent = serviceWorkspace

local partPracticeBase = Instance.new("Part")
partPracticeBase.Name = "PracticeBase"
partPracticeBase.Size = Vector3.new(80, 1, 80)
partPracticeBase.Position = Vector3.new(0, -0.5, 0)
partPracticeBase.Anchored = true
partPracticeBase.Material = Enum.Material.Grass
partPracticeBase.Parent = folderDay01Arena

for index = 1, 4 do
    local modelPracticeDummy = Instance.new("Model")
    modelPracticeDummy.Name = "PracticeDummy_" .. index
    modelPracticeDummy.Parent = folderDay01Arena

    local partHumanoidRoot = Instance.new("Part")
    partHumanoidRoot.Name = "HumanoidRootPart"
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)
    partHumanoidRoot.Position = Vector3.new(index * 8 - 20, 2.5, -18)
    partHumanoidRoot.Anchored = true
    partHumanoidRoot.BrickColor = BrickColor.new("Bright red")
    partHumanoidRoot.Parent = modelPracticeDummy

    local humanoidPractice = Instance.new("Humanoid")
    humanoidPractice.MaxHealth = 100
    humanoidPractice.Health = 100
    humanoidPractice.Parent = modelPracticeDummy
end

local toolOldTool = serviceStarterPack:FindFirstChild("PracticeRock")
if toolOldTool then toolOldTool:Destroy() end

local toolPracticeRock = Instance.new("Tool")
toolPracticeRock.Name = "PracticeRock"
toolPracticeRock.ToolTip = "클릭하면 연습용 돌멩이를 던집니다"
toolPracticeRock.Parent = serviceStarterPack

local partHandle = Instance.new("Part")
partHandle.Name = "Handle"
partHandle.Shape = Enum.PartType.Ball
partHandle.Size = Vector3.new(1, 1, 1)
partHandle.Material = Enum.Material.Slate
partHandle.Parent = toolPracticeRock

print("1일차 준비 완료")
