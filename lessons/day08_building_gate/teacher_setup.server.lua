-- Roblox Studio 수업 스크립트 안내
-- 수업: day08_building_gate - 건물과 파괴되는 성문
-- 문서 매핑: 커리큘럼 8회차와 강의가이드 "파괴되는 성문 만들기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 건물은 장식이 아니라 전투 중 체력과 파괴 상태를 갖는 게임 오브젝트가 됩니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day08_building_gate_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day08_Castle/Gate
-- 안전 운영: 기존 Day08 성문을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Castle/Gate 모델이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day08_Castle")
if old then old:Destroy() end

local castle = Instance.new("Folder")
castle.Name = "Day08_Castle"
castle.Parent = Workspace

local gate = Instance.new("Model")
gate.Name = "Gate"
gate.Parent = castle

for index = 1, 5 do
    local plank = Instance.new("Part")
    plank.Name = "GatePlank_" .. index
    plank.Size = Vector3.new(2, 10, 1)
    plank.Position = Vector3.new((index - 3) * 2, 5, -20)
    plank.Anchored = true
    plank.Material = Enum.Material.WoodPlanks
    plank.BrickColor = BrickColor.new("Reddish brown")
    plank.Parent = gate
end

print("Day 08 setup complete")
