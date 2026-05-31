-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 방벽이 생기는 공성 방어 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: day03_resource_wall - 자원 기반 방벽 소환
-- 문서 매핑: 커리큘럼 3회차와 강의가이드 "클릭으로 방벽 소환하기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: ClickDetector, leaderstats 자원 변수, 조건문으로 방벽이 생기는 공성 방어 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day03_resource_wall_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day03_ResourceWall/BuildButton, WallSpawn
-- 안전 운영: 기존 Day03 오브젝트를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 방벽 버튼과 WallSpawn 위치가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceWorkspace = game:GetService("Workspace")
local folderOld = serviceWorkspace:FindFirstChild("Day03_ResourceWall")
if folderOld then folderOld:Destroy() end

local folderDay03ResourceWall = Instance.new("Folder")
folderDay03ResourceWall.Name = "Day03_ResourceWall"
folderDay03ResourceWall.Parent = serviceWorkspace

local partBuildButton = Instance.new("Part")
partBuildButton.Name = "BuildButton"
partBuildButton.Size = Vector3.new(6, 1, 6)
partBuildButton.Position = Vector3.new(0, 0.5, 0)
partBuildButton.Anchored = true
partBuildButton.BrickColor = BrickColor.new("Bright green")
partBuildButton.Parent = folderDay03ResourceWall

local clickdetectorButton = Instance.new("ClickDetector")
clickdetectorButton.MaxActivationDistance = 24
clickdetectorButton.Parent = partBuildButton

local partWallSpawn = Instance.new("Part")
partWallSpawn.Name = "WallSpawn"
partWallSpawn.Size = Vector3.new(2, 0.2, 2)
partWallSpawn.Position = Vector3.new(0, 0.1, 12)
partWallSpawn.Anchored = true
partWallSpawn.Transparency = 0.35
partWallSpawn.BrickColor = BrickColor.new("Bright yellow")
partWallSpawn.Parent = folderDay03ResourceWall

print("3일차 준비 완료")
