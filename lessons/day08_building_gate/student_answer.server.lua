-- Roblox Studio Lesson Script Guide
-- Lesson: day08_building_gate - 건물과 파괴되는 성문
-- Role: student_answer.server.lua, 학생용 완성 모범답안 코드
-- Editor: Roblox Studio with Explorer, Properties, Output panels visible
-- Paste path: ServerScriptService > Script named Day08StudentAnswer
-- Precondition: run the matching teacher_setup.server.lua first so required Workspace/StarterPack/Teams objects exist.
-- Required objects: Workspace/Day08_Castle/Gate
-- Completion policy: this file is a fully implemented answer sheet. Keep class copies complete and runnable.
-- Verification: press Play, use the lesson Tool/button/system, then check visible behavior and Output for errors.
-- Troubleshooting: Tool lessons must be placed inside the Tool, while map/button/round lessons go in ServerScriptService.
-- Safety: damage, projectile, and round logic run on the server so students can test multiplayer behavior consistently.
-- Reference: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local castle = workspace:WaitForChild("Day08_Castle")
local gate = castle:WaitForChild("Gate")
local health = 120
local broken = false

local function set_gate_color(color)
    for _, part in ipairs(gate:GetDescendants()) do
        if part:IsA("BasePart") then part.BrickColor = BrickColor.new(color) end
    end
end

local function break_gate()
    broken = true
    for _, part in ipairs(gate:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.AssemblyLinearVelocity = Vector3.new(math.random(-25, 25), 35, math.random(-20, 20))
        end
    end
end

local function damage_gate(amount)
    if broken then return end
    health -= amount
    if health <= 60 then set_gate_color("Bright orange") end
    if health <= 0 then break_gate() end
end

for _, part in ipairs(gate:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Touched:Connect(function(hit)
            if hit.Name == "TrainingArrow" or hit.Name == "SiegeStone" then
                hit:Destroy()
                damage_gate(30)
            end
        end)
    end
end
