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
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldTool = StarterPack:FindFirstChild("BalanceSword")
if oldTool then oldTool:Destroy() end

local tool = Instance.new("Tool")
tool.Name = "BalanceSword"
tool.ToolTip = "Cooldown sword"
tool.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 5, 1)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Medium stone grey")
handle.Parent = tool

local oldDummies = Workspace:FindFirstChild("Day04_Dummies")
if oldDummies then oldDummies:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day04_Dummies"
folder.Parent = Workspace

for index = 1, 5 do
    local dummy = Instance.new("Model")
    dummy.Name = "CooldownDummy_" .. index
    dummy.Parent = folder

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3, 5, 2)
    root.Position = Vector3.new(index * 7 - 21, 2.5, -15)
    root.Anchored = true
    root.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
end

print("Day 04 setup complete")
