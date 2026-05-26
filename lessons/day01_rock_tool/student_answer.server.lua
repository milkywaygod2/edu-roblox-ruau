-- Roblox Studio 수업 스크립트 안내
-- 수업: day01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 빌더/스크립터/크리에이터 단계를 도구 장착, 데미지, 넉백으로 나눴습니다.
-- 미션 단계: 빌더=PracticeRock 장착, 스크립터=Touched 데미지, 크리에이터=AssemblyLinearVelocity 넉백입니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 예제를 수업용 완성 답안으로 정리한 파일입니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > PracticeRock > Script 이름 Day01StudentAnswer
-- 선행 조건: 선생님이 teacher_setup.server.lua를 먼저 실행해 Workspace/Day01_Arena와 StarterPack/PracticeRock을 만들어야 합니다.
-- 학생 목표: Tool.Activated와 Touched 이벤트가 서버에서 실제 전투 규칙으로 이어지는 흐름을 이해합니다.
-- 검증 기준: Play 후 돌멩이를 사용하면 투사체가 날아가고, 더미에게 피해와 넉백이 적용되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local Debris = game:GetService("Debris")
local tool = script.Parent

local DAMAGE = 15
local COOLDOWN = 0.8
local SPEED = 90
local ready = true

tool.Activated:Connect(function()
    if not ready then return end

    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    ready = false

    local rock = Instance.new("Part")
    rock.Name = "ThrownPracticeRock"
    rock.Shape = Enum.PartType.Ball
    rock.Size = Vector3.new(1.2, 1.2, 1.2)
    rock.Material = Enum.Material.Slate
    rock.Position = root.Position + root.CFrame.LookVector * 3 + Vector3.new(0, 1.5, 0)
    rock.Parent = workspace
    rock.AssemblyLinearVelocity = root.CFrame.LookVector * SPEED + Vector3.new(0, 12, 0)
    Debris:AddItem(rock, 5)

    local hitOnce = false
    rock.Touched:Connect(function(hit)
        if hitOnce then return end

        local targetModel = hit:FindFirstAncestorOfClass("Model")
        local humanoid = targetModel and targetModel:FindFirstChildOfClass("Humanoid")
        local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
        if not humanoid or targetModel == character then return end

        hitOnce = true
        humanoid:TakeDamage(DAMAGE)
        if targetRoot then
            targetRoot.AssemblyLinearVelocity = root.CFrame.LookVector * 45 + Vector3.new(0, 18, 0)
        end
        rock:Destroy()
    end)

    task.wait(COOLDOWN)
    ready = true
end)
