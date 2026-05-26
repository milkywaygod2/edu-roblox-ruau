-- Roblox Studio 수업 스크립트 안내
-- 수업: day07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day07_armor_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/HeavyArmor
-- 안전 운영: 기존 Day07 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: HeavyArmor Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local StarterPack = game:GetService("StarterPack")
local oldTool = StarterPack:FindFirstChild("HeavyArmor")
if oldTool then oldTool:Destroy() end

local armor = Instance.new("Tool")
armor.Name = "HeavyArmor"
armor.RequiresHandle = true
armor.ToolTip = "Equip for armor stats"
armor.Parent = StarterPack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(2, 2, 1)
handle.Material = Enum.Material.Metal
handle.BrickColor = BrickColor.new("Really black")
handle.Parent = armor

print("Day 07 setup complete")
