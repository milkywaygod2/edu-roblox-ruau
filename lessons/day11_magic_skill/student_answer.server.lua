-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차의 화염구, 광역 폭발, 서버 통신 마법을 MagicStaff 코드로 구성했습니다.
-- 미션 단계: 빌더=네온 화염구 스폰, 스크립터=거리 계산 AoE, 크리에이터=RemoteEvent로 모두에게 보이는 서버 마법입니다.
-- 강의가이드 연결: "마법 스킬과 RemoteEvent" 예제처럼 입력 요청과 서버 판정을 분리해 멀티플레이를 안전하게 만듭니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day11MagicServer
-- 선행 조건: 선생님이 MagicStaff, Day11_MagicArena, ReplicatedStorage/CastMagic을 먼저 만들어야 합니다.
-- 클라이언트 입력: student_answer.client.lua를 StarterPack > MagicStaff > LocalScript로 붙여넣습니다.
-- 학생 목표: 마법 이펙트, 범위 피해, 서버 권한 검사가 하나의 스킬 시스템으로 묶이는 흐름을 이해합니다.
-- 검증 기준: 지팡이 사용 시 화염구/폭발 효과가 보이고, 범위 안 더미에게만 피해가 들어가면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("CastMagic")

local MAX_DISTANCE = 80
local RADIUS = 12
local DAMAGE = 25
local COOLDOWN = 1.8
local lastCastByPlayer = {}

local function cast_magic(player, targetPosition)
    if typeof(targetPosition) ~= "Vector3" then return end

    local now = os.clock()
    local lastCast = lastCastByPlayer[player] or -COOLDOWN
    if now - lastCast < COOLDOWN then return end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if (targetPosition - root.Position).Magnitude > MAX_DISTANCE then return end

    lastCastByPlayer[player] = now

    local explosion = Instance.new("Explosion")
    explosion.Position = targetPosition
    explosion.BlastRadius = RADIUS
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Humanoid") then
            local targetModel = object.Parent
            local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
            if targetRoot and (targetRoot.Position - targetPosition).Magnitude <= RADIUS and targetModel ~= character then
                object:TakeDamage(DAMAGE)
            end
        end
    end
end

remote.OnServerEvent:Connect(cast_magic)

Players.PlayerRemoving:Connect(function(player)
    lastCastByPlayer[player] = nil
end)
