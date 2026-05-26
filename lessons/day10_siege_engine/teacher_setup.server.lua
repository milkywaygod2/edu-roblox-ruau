-- Roblox Studio 수업 스크립트 안내
-- 수업: day10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차와 강의가이드 "투석기 버튼과 원격 발사"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 안전한 위치의 버튼 클릭으로 성문 목표를 향해 공성 탄환을 발사하는 장면입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 day10_siege_engine_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Day10_SiegeEngine/LaunchButton, LaunchPoint, TargetPoint
-- 안전 운영: 기존 Day10 공성 병기를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 발사 버튼, 발사지점, 목표지점이 생성되고 Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Day10_SiegeEngine")
if old then old:Destroy() end

local folder = Instance.new("Folder")
folder.Name = "Day10_SiegeEngine"
folder.Parent = Workspace

local button = Instance.new("Part")
button.Name = "LaunchButton"
button.Size = Vector3.new(6, 1, 6)
button.Position = Vector3.new(0, 0.5, 0)
button.Anchored = true
button.BrickColor = BrickColor.new("Bright blue")
button.Parent = folder

local detector = Instance.new("ClickDetector")
detector.MaxActivationDistance = 24
detector.Parent = button

local launch = Instance.new("Part")
launch.Name = "LaunchPoint"
launch.Size = Vector3.new(2, 2, 2)
launch.Position = Vector3.new(0, 4, -6)
launch.Anchored = true
launch.Transparency = 0.4
launch.Parent = folder

local target = Instance.new("Part")
target.Name = "TargetPoint"
target.Size = Vector3.new(4, 4, 4)
target.Position = Vector3.new(0, 4, -42)
target.Anchored = true
target.Transparency = 0.4
target.BrickColor = BrickColor.new("Bright red")
target.Parent = folder

print("Day 10 setup complete")
