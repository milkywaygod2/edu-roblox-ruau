-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/MagicStaff, Workspace/Day11_MagicArena
-- 안전 운영: 기존 Day11 Tool과 아레나를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: MagicStaff와 마법 아레나가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local oldTool = StarterPack:FindFirstChild("MagicStaff")
if oldTool then oldTool:Destroy() end

local staff = Instance.new("Tool")
staff.Name = "MagicStaff"
staff.ToolTip = "Cast server magic"
staff.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.6, 5, 0.6)
handle.Material = Enum.Material.Neon
handle.BrickColor = BrickColor.new("Royal purple")
handle.Parent = staff

local oldArena = Workspace:FindFirstChild("Day11_MagicArena")
if oldArena then oldArena:Destroy() end

local arena = Instance.new("Folder")
arena.Name = "Day11_MagicArena"
arena.Parent = Workspace

for index = 1, 6 do
    local dummy = Instance.new("Model")
    dummy.Name = "MagicDummy_" .. index
    dummy.Parent = arena

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3, 5, 2)
    root.Position = Vector3.new(index * 7 - 24, 2.5, -25)
    root.Anchored = true
    root.Parent = dummy

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
end

print("Day 11 setup complete")
