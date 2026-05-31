-- Roblox Studio 수업 스크립트 안내
-- 수업: day04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 무기가 작동하는 것에서 끝나지 않고, 연타 방지와 밸런스가 필요하다는 점을 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day04_melee_weapon - 일반 무기와 디바운스
-- 문서 매핑: 커리큘럼 4회차와 강의가이드 "공격 쿨타임과 디바운스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 무기가 작동하는 것에서 끝나지 않고, 연타 방지와 밸런스가 필요하다는 점을 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day04_melee_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/BalanceSword, Workspace/Day04_Dummies
-- 안전 운영: 기존 Day04 Tool과 더미를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: BalanceSword와 연습 더미가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceStarterPack = game:GetService("StarterPack")
local serviceWorkspace = game:GetService("Workspace")

local toolOldTool = serviceStarterPack:FindFirstChild("BalanceSword")
if toolOldTool then toolOldTool:Destroy() end

local toolBalanceSword = Instance.new("Tool")
toolBalanceSword.Name = "BalanceSword"
toolBalanceSword.ToolTip = "쿨타임이 있는 연습용 검"
toolBalanceSword.Parent = serviceStarterPack

local partHandle = Instance.new("Part")
partHandle.Name = "Handle"
partHandle.Size = Vector3.new(1, 5, 1)
partHandle.Material = Enum.Material.Metal
partHandle.BrickColor = BrickColor.new("Medium stone grey")
partHandle.Parent = toolBalanceSword

local folderOldDummies = serviceWorkspace:FindFirstChild("Day04_Dummies")
if folderOldDummies then folderOldDummies:Destroy() end

local folderDay04Dummies = Instance.new("Folder")
folderDay04Dummies.Name = "Day04_Dummies"
folderDay04Dummies.Parent = serviceWorkspace

for index = 1, 5 do
    local modelPracticeDummy = Instance.new("Model")
    modelPracticeDummy.Name = "CooldownDummy_" .. index
    modelPracticeDummy.Parent = folderDay04Dummies

    local partHumanoidRoot = Instance.new("Part")
    partHumanoidRoot.Name = "HumanoidRootPart"
    partHumanoidRoot.Size = Vector3.new(3, 5, 2)
    partHumanoidRoot.Position = Vector3.new(index * 7 - 21, 2.5, -15)
    partHumanoidRoot.Anchored = true
    partHumanoidRoot.Parent = modelPracticeDummy

    local humanoidPractice = Instance.new("Humanoid")
    humanoidPractice.Parent = modelPracticeDummy
end

print("4일차 준비 완료")
