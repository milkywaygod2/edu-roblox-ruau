-- Roblox Studio 수업 스크립트 안내
-- 수업: day11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차의 서버 통신 마법을 Tool LocalScript 입력으로 구성했습니다.
-- 미션 단계: 크리에이터=마우스 위치를 RemoteEvent로 서버에 보내고 서버가 거리와 쿨타임을 검사합니다.
-- 강의가이드 연결: "마법 스킬과 RemoteEvent" 예제의 클라이언트 입력 부분입니다.
-- 역할: student_answer.client.lua, 학생용 클라이언트 입력 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > MagicStaff > LocalScript 이름 Day11MagicClient
-- 선행 조건: 선생님이 MagicStaff와 ReplicatedStorage/CastMagic을 먼저 만들어야 합니다.
-- 학생 목표: Tool.Activated 입력은 클라이언트가 받고, 실제 피해 판정은 서버가 처리하는 구조를 이해합니다.
-- 검증 기준: 지팡이를 장착하고 클릭하면 마우스 위치가 서버로 전달되어 폭발 마법이 실행되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local tool = script.Parent
local remote = ReplicatedStorage:WaitForChild("CastMagic")
local mouse = nil

tool.Equipped:Connect(function()
    mouse = player:GetMouse()
end)

tool.Unequipped:Connect(function()
    mouse = nil
end)

tool.Activated:Connect(function()
    if not mouse then return end
    remote:FireServer(mouse.Hit.Position)
end)
