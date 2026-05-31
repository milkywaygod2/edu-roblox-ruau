-- Roblox Studio 수업 스크립트 안내
-- 수업: day02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 초기 적응 구간의 Part/Properties 실습을 공성전 엄폐물 필드로 구체화했습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day02_cover_design - 기초 엄폐물 디자인
-- 문서 매핑: 커리큘럼 2회차의 Part 배치, Anchored 고정, Material/물리 속성, 모델 정리를 준비합니다.
-- 강의가이드 연결: 초기 적응 구간의 Part/Properties 실습을 공성전 엄폐물 필드로 구체화했습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day02_cover_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day02_CoverField
-- 안전 운영: 기존 Day02 오브젝트를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Explorer에 엄폐물 필드가 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceWorkspace = game:GetService("Workspace")
local folderOld = serviceWorkspace:FindFirstChild("Day02_CoverField")
if folderOld then folderOld:Destroy() end

local folderDay02CoverField = Instance.new("Folder")
folderDay02CoverField.Name = "Day02_CoverField"
folderDay02CoverField.Parent = serviceWorkspace

local partGridBase = Instance.new("Part")
partGridBase.Name = "GridBase"
partGridBase.Size = Vector3.new(90, 1, 70)
partGridBase.Position = Vector3.new(0, -0.5, 0)
partGridBase.Anchored = true
partGridBase.Material = Enum.Material.Concrete
partGridBase.Parent = folderDay02CoverField

for index = 1, 5 do
    local partCoverMarker = Instance.new("Part")
    partCoverMarker.Name = "CoverMarker_" .. index
    partCoverMarker.Size = Vector3.new(2, 0.2, 2)
    partCoverMarker.Position = Vector3.new(index * 8 - 24, 0.1, -10)
    partCoverMarker.Anchored = true
    partCoverMarker.BrickColor = BrickColor.new("Bright yellow")
    partCoverMarker.Parent = folderDay02CoverField
end

print("2일차 준비 완료")
