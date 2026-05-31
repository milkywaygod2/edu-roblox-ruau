-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/MagicStaff, Workspace/Day11_MagicArena, ReplicatedStorage/CastMagic
-- 안전 운영: 기존 Day11 Tool과 아레나를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: MagicStaff, 마법 아레나, CastMagic RemoteEvent가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceStarterPack = game:GetService("StarterPack")
local serviceReplicatedStorage = game:GetService("ReplicatedStorage")
local serviceWorkspace = game:GetService("Workspace")

local remoteeventOldRemote = serviceReplicatedStorage:FindFirstChild("CastMagic")
if remoteeventOldRemote then remoteeventOldRemote:Destroy() end

local remoteeventCastMagic = Instance.new("RemoteEvent")
remoteeventCastMagic.Name = "CastMagic"
remoteeventCastMagic.Parent = serviceReplicatedStorage

local toolOldTool = serviceStarterPack:FindFirstChild("MagicStaff")
if toolOldTool then toolOldTool:Destroy() end

local toolMagicStaff = Instance.new("Tool")
toolMagicStaff.Name = "MagicStaff"
toolMagicStaff.ToolTip = "서버 판정 마법을 시전합니다"
toolMagicStaff.Parent = serviceStarterPack

local partHandle = Instance.new("Part")
partHandle.Name = "Handle"
partHandle.Size = Vector3.new(0.6, 5, 0.6)
partHandle.Material = Enum.Material.Neon
partHandle.BrickColor = BrickColor.new("Royal purple")
partHandle.Parent = toolMagicStaff

local folderOldArena = serviceWorkspace:FindFirstChild("Day11_MagicArena")
if folderOldArena then folderOldArena:Destroy() end

local folderDay11MagicArena = Instance.new("Folder")
folderDay11MagicArena.Name = "Day11_MagicArena"
folderDay11MagicArena.Parent = serviceWorkspace

for index = 1, 6 do
    local modelPracticeDummy = Instance.new("Model")
    modelPracticeDummy.Name = "MagicDummy_" .. index
    modelPracticeDummy.Parent = folderDay11MagicArena

    local partHumanoidRoot = Instance.new("Part")
    partHumanoidRoot.Name = "HumanoidRootPart"
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)
    partHumanoidRoot.Position = Vector3.new(index * 7 - 24, 2.5, -25)
    partHumanoidRoot.Anchored = true
    partHumanoidRoot.Parent = modelPracticeDummy

    local humanoidPractice = Instance.new("Humanoid")
    humanoidPractice.Parent = modelPracticeDummy
end

print("11일차 준비 완료")
