-- Roblox Studio 수업 스크립트 안내
-- 수업: day06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가, 투사체 방어벽, 데미지 반사 규칙을 준비합니다.
-- 강의가이드 연결: 전투 수업 통제 원칙을 적용해 공격뿐 아니라 방어와 밸런스도 게임 규칙으로 다룹니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day06_shield_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/PracticeShield
-- 안전 운영: 기존 Day06 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: PracticeShield Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local oldTool = StarterPack:FindFirstChild("PracticeShield")
if oldTool then oldTool:Destroy() end

local shield = Instance.new("Tool")
shield.Name = "PracticeShield"
shield.ToolTip = "장착하면 방어하고 체력이 늘어납니다"
shield.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(4, 5, 0.6)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Dark stone grey")
handle.Parent = shield

print("6일차 준비 완료")
