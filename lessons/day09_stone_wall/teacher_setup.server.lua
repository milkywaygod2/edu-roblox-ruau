-- Roblox Studio 수업 스크립트 안내
-- 수업: day09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 석조 성벽 결합, 총안구, 부분 파괴 성벽을 준비합니다.
-- 강의가이드 연결: 공성전 맵의 성벽은 한 덩어리가 아니라 구역별로 피해와 붕괴를 추적하는 구조물입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day09_stone_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day09_StoneWall
-- 안전 운영: 기존 Day09 성벽을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 구역별 성벽 파트가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day09_StoneWall")
if old then old:Destroy() end

local wall = Instance.new("Folder")
wall.Name = "Day09_StoneWall"
wall.Parent = Workspace

for section = 1, 5 do
    local model = Instance.new("Model")
    model.Name = "WallSection_" .. section
    model.Parent = wall

    for height = 1, 4 do
        local block = Instance.new("Part")
        block.Name = "StoneBlock"
        block.Size = Vector3.new(6, 2, 2)
        block.Position = Vector3.new((section - 3) * 6, height * 2 - 1, -24)
        block.Anchored = true
        block.Material = Enum.Material.Slate
        block.Parent = model
    end
end

print("Day 09 setup complete")
