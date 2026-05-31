-- Roblox Studio 수업 스크립트 안내
-- 수업: day05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day05_ranged_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/TrainingBow, Workspace/Day05_TargetRange
-- 안전 운영: 기존 Day05 Tool과 사격장을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: TrainingBow와 목표 사격장이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceStarterPack = game:GetService("StarterPack")
local serviceWorkspace = game:GetService("Workspace")

local folderOldRange = serviceWorkspace:FindFirstChild("Day05_TargetRange")
if folderOldRange then folderOldRange:Destroy() end

local folderDay05TargetRange = Instance.new("Folder")
folderDay05TargetRange.Name = "Day05_TargetRange"
folderDay05TargetRange.Parent = serviceWorkspace

for index = 1, 6 do
    local partTarget = Instance.new("Part")
    partTarget.Name = "Target_" .. index
    partTarget.Size = Vector3.new(4, 6, 1)
    partTarget.Position = Vector3.new(index * 8 - 28, 3, -40)
    partTarget.Anchored = true
    partTarget.BrickColor = BrickColor.new("Bright red")
    partTarget.Parent = folderDay05TargetRange
end

local toolOldTool = serviceStarterPack:FindFirstChild("TrainingBow")
if toolOldTool then toolOldTool:Destroy() end

local toolTrainingBow = Instance.new("Tool")
toolTrainingBow.Name = "TrainingBow"
toolTrainingBow.ToolTip = "서버에서 투사체를 만드는 연습용 활"
toolTrainingBow.Parent = serviceStarterPack

local partHandle = Instance.new("Part")
partHandle.Name = "Handle"
partHandle.Size = Vector3.new(1, 4, 1)
partHandle.Material = Enum.Material.Wood
partHandle.Parent = toolTrainingBow

print("5일차 준비 완료")
