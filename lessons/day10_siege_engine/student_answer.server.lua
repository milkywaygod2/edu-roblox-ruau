-- Roblox Studio 수업 스크립트 안내
-- 수업: day10_siege_engine - 공성 병기와 원격 발사
-- 문서 매핑: 커리큘럼 10회차의 Hinge 조립, Spring 장력, 원격 발사 로직을 서버 투석기 코드로 구성했습니다.
-- 미션 단계: 빌더=발사 장치 구조 확인, 스크립터=탄환 속도 계산, 크리에이터=버튼으로 안전한 원격 발사입니다.
-- 강의가이드 연결: "투석기 버튼과 원격 발사" 예제로 목표 방향 벡터와 위쪽 속도를 조합합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day10StudentAnswer
-- 선행 조건: 선생님이 LaunchButton, LaunchPoint, TargetPoint를 먼저 만들어야 합니다.
-- 학생 목표: ClickDetector 입력과 벡터 방향 계산이 공성 탄환 발사 규칙으로 이어지는 흐름을 이해합니다.
-- 검증 기준: 버튼 클릭 시 대포알이 발사지점에서 목표 방향으로 날아가면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local serviceDebris = game:GetService("Debris")
local folderDay10SiegeEngine = workspace:WaitForChild("Day10_SiegeEngine")
local partLaunchButton = folderDay10SiegeEngine:WaitForChild("LaunchButton")
local partLaunchPoint = folderDay10SiegeEngine:WaitForChild("LaunchPoint")
local partTargetPoint = folderDay10SiegeEngine:WaitForChild("TargetPoint")

local COOLDOWN = 2.5
local boolReady = true

local function launch_stone(player)
    if not boolReady then return end
    boolReady = false

    local partSiegeStone = Instance.new("Part")
    partSiegeStone.Name = "SiegeStone"
    partSiegeStone.Shape = Enum.PartType.Ball
    partSiegeStone.Size = Vector3.new(3, 3, 3)
    partSiegeStone.Material = Enum.Material.Slate
    partSiegeStone.Position = partLaunchPoint.Position
    partSiegeStone.Parent = workspace

    local vectorDirection = (partTargetPoint.Position - partLaunchPoint.Position).Unit
    partSiegeStone.AssemblyLinearVelocity = vectorDirection * 95 + Vector3.new(0, 45, 0)
    serviceDebris:AddItem(partSiegeStone, 8)

    task.wait(COOLDOWN)
    boolReady = true
end

partLaunchButton.ClickDetector.MouseClick:Connect(launch_stone)
