# **로블록스 루아: 공성전형 게임 제작 & 코드 라이브러리 (Studio/Team Create 적용)**

**교육 철학:** 로블록스 수업은 "눈에 보이는 물체를 만들고, 바로 플레이 테스트하고, 친구와 규칙을 고치는" 경험을 중심에 둡니다. 마인크래프트 파이썬 수업이 명령어와 한글 함수로 즉각적인 마법을 보여준다면, 로블록스 루아 수업은 **파트(Part), 모델(Model), 도구(Tool), 이벤트(Event), 서버 스크립트(Server Script)**를 조립해 실제 멀티플레이 게임 규칙을 만드는 데 초점을 둡니다.

**네이밍 원칙:** Luau 코드의 변수와 함수는 영문/underscore로 작성하고, Explorer의 오브젝트 이름, 주석, UI 문구, 출력 메시지는 한글을 적극 활용합니다. 아이들이 영어 문법보다 구조를 먼저 이해하도록 `attack_damage`, `build_wall`, `spawn_arrow`처럼 짧고 반복되는 이름을 사용합니다.

## ---

**초기 적응 구간: Roblox Studio 안전지대**

처음부터 복잡한 게임을 만들기보다, Studio 화면과 플레이 테스트 흐름에 익숙해지는 시간을 둡니다. 이 구간의 목표는 "내가 배치한 파트가 게임 규칙이 된다"는 감각을 만드는 것입니다.

* **Studio 화면 읽기:** Explorer, Properties, Toolbox, View 탭을 확인합니다.
* **파트 다루기:** Part 생성, Anchored, CanCollide, Material, Color, Size, Position을 바꿉니다.
* **플레이 테스트:** Play, Stop, Reset Character, Output 창의 오류 메시지를 확인합니다.
* **팀 작업 규칙:** 한 명이 전체 맵을 독점하지 않고, 각자 맡은 폴더 안에서 작업합니다.

## ---

**본격 로블록스 게임 제작 구간 (공성전형 시나리오)**

아래 시나리오는 특정 12주 회차에 강제로 맞추기 위한 목록이 아니라, 로블록스 수업에서 반복해서 꺼내 쓸 수 있는 고유한 미션 라이브러리입니다. 선생님은 수업 시간, 학생 수준, 장비 상태에 따라 필요한 미션을 골라 조합하면 됩니다.

---

### **1. 시작 광장과 팀 스폰 세팅**

**[선생님 Studio 준비 가이드]**

* **권장 위치:** Workspace에 `수업맵` Model을 만들고, 그 안에 `로비`, `성벽`, `전장`, `스폰` 폴더를 만듭니다.
* **팀 구성:** Teams 서비스에 `Blue`, `Red`, `Builder` 팀을 만들고 TeamColor를 다르게 지정합니다.
* **스폰 관리:** 각 팀 색상에 맞는 SpawnLocation을 배치하고 `Neutral`을 false로 둡니다.

**게임 설명:** 학생들이 접속하면 정해진 팀 진영에서 시작하고, 전투 전에는 로비에서 규칙을 확인합니다.

* **수동 운영:** 선생님이 매번 학생을 드래그하거나 명령으로 이동시킵니다.
* **스마트 운영:** PlayerAdded 이벤트로 팀과 시작 위치를 자동 배정합니다.

```lua
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local team_order = {"Blue", "Red"}
local next_index = 1

local function assign_team(player)
    local team_name = team_order[next_index]
    player.Team = Teams:FindFirstChild(team_name)
    next_index += 1

    if next_index > #team_order then
        next_index = 1
    end
end

Players.PlayerAdded:Connect(assign_team)
```

---

### **2. 돌멩이 툴 만들기 (기초 무기)**

**[선생님 Studio 준비 가이드]**

* StarterPack에 Tool을 하나 만들고 이름을 `돌멩이`로 바꿉니다.
* Tool 안에 `Handle` Part를 넣고 손에 잡히는 크기로 줄입니다.
* Tool 안에 Script를 넣어 서버에서 데미지를 처리하게 합니다.

**게임 설명:** 학생은 손에 든 돌멩이를 클릭해 짧은 거리 공격을 합니다.

* **수동 플레이:** 파트를 직접 들고 던지는 흉내만 냅니다.
* **스마트 플레이:** Tool.Activated 이벤트로 투사체를 만들고 데미지를 적용합니다.

```lua
local tool = script.Parent
local DAMAGE = 15
local COOLDOWN = 0.8
local ready = true

local function throw_rock()
    if not ready then
        return
    end

    ready = false

    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        ready = true
        return
    end

    local rock = Instance.new("Part")
    rock.Name = "날아가는_돌멩이"
    rock.Shape = Enum.PartType.Ball
    rock.Size = Vector3.new(1, 1, 1)
    rock.Material = Enum.Material.Slate
    rock.Position = root.Position + root.CFrame.LookVector * 3
    rock.Parent = workspace
    rock.AssemblyLinearVelocity = root.CFrame.LookVector * 80 + Vector3.new(0, 10, 0)

    rock.Touched:Connect(function(hit)
        local target = hit.Parent:FindFirstChildOfClass("Humanoid")
        if target and hit.Parent ~= character then
            target:TakeDamage(DAMAGE)
            rock:Destroy()
        end
    end)

    task.wait(COOLDOWN)
    ready = true
end

tool.Activated:Connect(throw_rock)
```

---

### **3. 클릭으로 방벽 소환하기**

**[선생님 Studio 준비 가이드]**

* Workspace에 `방벽버튼` Part를 만들고 ClickDetector를 넣습니다.
* 버튼 주변에 방벽이 생길 위치를 비워 둡니다.
* ServerScriptService에 Script를 만들어 자원과 방벽 생성을 관리합니다.

**게임 설명:** 학생은 자원을 모아 버튼을 누르고, 방벽을 세워 진영을 방어합니다.

* **수동 플레이:** 선생님이 직접 파트를 복사해 방벽을 놓습니다.
* **스마트 플레이:** ClickDetector, 변수, 조건문으로 자원이 충분할 때만 방벽이 생깁니다.

```lua
local Players = game:GetService("Players")
local button = workspace:WaitForChild("방벽버튼")
local COST = 10

local function setup_stats(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local wood = Instance.new("IntValue")
    wood.Name = "Wood"
    wood.Value = 30
    wood.Parent = leaderstats
end

local function build_wall(player)
    local wood = player.leaderstats.Wood
    if wood.Value < COST then
        return
    end

    wood.Value -= COST

    for index = 1, 8 do
        local block = Instance.new("Part")
        block.Name = "소환된_방벽"
        block.Size = Vector3.new(4, 6, 1)
        block.Anchored = true
        block.Material = Enum.Material.WoodPlanks
        block.Position = button.Position + Vector3.new(index * 4, 3, 12)
        block.Parent = workspace
    end
end

Players.PlayerAdded:Connect(setup_stats)
button.ClickDetector.MouseClick:Connect(build_wall)
```

---

### **4. 공격 쿨타임과 디바운스**

**[선생님 Studio 준비 가이드]**

* 기본 검 Tool을 준비하고 Tool 안에 Script를 넣습니다.
* 학생들이 클릭을 빠르게 연타했을 때 데미지가 무한히 들어가는 문제를 일부러 보여줍니다.
* 그 다음 Debounce 변수로 버그를 고치는 흐름을 수업합니다.

**게임 설명:** 무기가 너무 강하면 게임이 재미없어집니다. 코드는 "작동"만 하는 것이 아니라 "공정한 규칙"도 만들어야 합니다.

* **수동 플레이:** 데미지 숫자만 바꾸며 강약을 조절합니다.
* **스마트 플레이:** 쿨타임을 적용해 밸런스를 맞춥니다.

```lua
local tool = script.Parent
local DAMAGE = 20
local COOLDOWN = 1.2
local can_attack = true

local function attack()
    if not can_attack then
        return
    end

    can_attack = false
    tool.Handle.BrickColor = BrickColor.new("Really red")

    local connection
    connection = tool.Handle.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(DAMAGE)
            connection:Disconnect()
        end
    end)

    task.wait(0.25)
    if connection.Connected then
        connection:Disconnect()
    end

    tool.Handle.BrickColor = BrickColor.new("Medium stone grey")
    task.wait(COOLDOWN)
    can_attack = true
end

tool.Activated:Connect(attack)
```

---

### **5. 속도 갑옷과 이동 패널티**

**[선생님 Studio 준비 가이드]**

* StarterPack에 `무거운갑옷` Tool을 준비합니다.
* 장착하면 체력은 늘어나지만 WalkSpeed가 줄어드는 규칙을 넣습니다.
* 학생에게 "강한 장비에는 대가가 있다"는 밸런스 개념을 설명합니다.

**게임 설명:** 빠르지만 약한 캐릭터, 느리지만 튼튼한 캐릭터를 비교합니다.

* **수동 플레이:** Properties에서 Humanoid 값을 직접 바꿉니다.
* **스마트 플레이:** Equipped/Unequipped 이벤트로 장비 효과를 켜고 끕니다.

```lua
local tool = script.Parent
local normal_health = 100
local normal_speed = 16

local function equipped()
    local character = tool.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    normal_health = humanoid.MaxHealth
    normal_speed = humanoid.WalkSpeed

    humanoid.MaxHealth = 160
    humanoid.Health = math.min(humanoid.Health + 60, humanoid.MaxHealth)
    humanoid.WalkSpeed = 10
end

local function unequipped()
    local character = tool.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.MaxHealth = normal_health
    humanoid.Health = math.min(humanoid.Health, normal_health)
    humanoid.WalkSpeed = normal_speed
end

tool.Equipped:Connect(equipped)
tool.Unequipped:Connect(unequipped)
```

---

### **6. 투사체와 포물선 공격**

**[선생님 Studio 준비 가이드]**

* Workspace에 넓은 전장을 만들고, 중간에 엄폐물을 배치합니다.
* 학생들이 직선 공격과 포물선 공격의 차이를 눈으로 볼 수 있게 합니다.
* 발사체는 서버에서 생성하고, 일정 시간이 지나면 자동 삭제합니다.

**게임 설명:** 활, 돌, 대포알처럼 날아가는 물체를 직접 만듭니다.

* **수동 플레이:** 파트를 복사해서 앞으로 밀어 봅니다.
* **스마트 플레이:** LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산합니다.

```lua
local tool = script.Parent
local Debris = game:GetService("Debris")

local function fire_projectile()
    local character = tool.Parent
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local projectile = Instance.new("Part")
    projectile.Name = "대포알"
    projectile.Shape = Enum.PartType.Ball
    projectile.Size = Vector3.new(1.5, 1.5, 1.5)
    projectile.Material = Enum.Material.Metal
    projectile.Position = root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 2, 0)
    projectile.Parent = workspace

    projectile.AssemblyLinearVelocity = root.CFrame.LookVector * 90 + Vector3.new(0, 35, 0)
    Debris:AddItem(projectile, 5)
end

tool.Activated:Connect(fire_projectile)
```

---

### **7. 파괴되는 성문 만들기**

**[선생님 Studio 준비 가이드]**

* Workspace에 `성문` Model을 만들고 여러 개의 Part로 나누어 둡니다.
* 각 Part에 `Health` IntValue를 넣거나, Model 전체에 체력을 둡니다.
* 전투 중 성문이 서서히 무너지는 장면을 목표로 합니다.

**게임 설명:** 한 번에 사라지는 문보다, 맞을수록 흔들리고 결국 무너지는 문이 훨씬 게임답습니다.

* **수동 플레이:** 선생님이 성문을 직접 삭제합니다.
* **스마트 플레이:** 체력 값이 0이 되면 Anchored를 풀고 무너지게 만듭니다.

```lua
local gate = workspace:WaitForChild("성문")
local health = 100

local function break_gate()
    for _, part in gate:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-15, 15))
        end
    end
end

local function damage_gate(amount)
    health -= amount
    if health <= 0 then
        break_gate()
    end
end

for _, part in gate:GetDescendants() do
    if part:IsA("BasePart") then
        part.Touched:Connect(function(hit)
            if hit.Name == "대포알" then
                hit:Destroy()
                damage_gate(25)
            end
        end)
    end
end
```

---

### **8. 마법 스킬과 RemoteEvent**

**[선생님 Studio 준비 가이드]**

* ReplicatedStorage에 RemoteEvent를 만들고 이름을 `CastMagic`으로 둡니다.
* StarterPack의 Tool 안에는 LocalScript를 넣어 마우스 위치를 서버로 보냅니다.
* ServerScriptService의 Script에서 실제 데미지와 이펙트를 처리합니다.

**게임 설명:** 클라이언트는 "어디에 쓰고 싶다"고 요청하고, 서버는 "정말 가능한 요청인지" 검사한 뒤 마법을 실행합니다.

* **수동 플레이:** 파티클을 직접 배치합니다.
* **스마트 플레이:** RemoteEvent로 입력과 판정을 분리합니다.

```lua
-- LocalScript inside Tool
local tool = script.Parent
local player = game.Players.LocalPlayer
local remote = game.ReplicatedStorage:WaitForChild("CastMagic")

local mouse

tool.Equipped:Connect(function()
    mouse = player:GetMouse()
end)

tool.Activated:Connect(function()
    if mouse then
        remote:FireServer(mouse.Hit.Position)
    end
end)
```

```lua
-- ServerScriptService Script
local remote = game.ReplicatedStorage:WaitForChild("CastMagic")
local MAX_DISTANCE = 80

remote.OnServerEvent:Connect(function(player, target_position)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local distance = (target_position - root.Position).Magnitude
    if distance > MAX_DISTANCE then
        return
    end

    local explosion = Instance.new("Explosion")
    explosion.Position = target_position
    explosion.BlastRadius = 10
    explosion.BlastPressure = 0
    explosion.Parent = workspace
end)
```

---

### **9. 투석기 버튼과 원격 발사**

**[선생님 Studio 준비 가이드]**

* 전장 뒤쪽에 투석기 Model을 만들고, 발사 버튼 Part를 배치합니다.
* 투석기 팔은 처음에는 장식으로 두고, 실제 공격은 서버 스크립트가 대포알을 생성하게 합니다.
* 학생 수준이 높으면 HingeConstraint, SpringConstraint로 물리 투석기를 확장합니다.

**게임 설명:** 안전한 곳에서 버튼을 누르면 성문을 향해 공성 탄환이 날아갑니다.

* **수동 플레이:** 선생님이 대포알을 복사해 던집니다.
* **스마트 플레이:** 버튼 클릭으로 목표 방향 탄환을 생성합니다.

```lua
local button = workspace:WaitForChild("투석기버튼")
local launch_point = workspace:WaitForChild("발사지점")
local target = workspace:WaitForChild("성문목표")

local function launch()
    local stone = Instance.new("Part")
    stone.Name = "대포알"
    stone.Shape = Enum.PartType.Ball
    stone.Size = Vector3.new(3, 3, 3)
    stone.Material = Enum.Material.Rock
    stone.Position = launch_point.Position
    stone.Parent = workspace

    local direction = (target.Position - launch_point.Position).Unit
    stone.AssemblyLinearVelocity = direction * 95 + Vector3.new(0, 45, 0)
end

button.ClickDetector.MouseClick:Connect(launch)
```

---

### **10. 최종 대전 운영과 실시간 핫픽스**

**[선생님 Studio 준비 가이드]**

* 전투 시작 전에는 모든 학생의 무기, 스폰, 팀 배정을 점검합니다.
* ServerScriptService에 `RoundManager` Script를 두고 라운드 시작/종료를 관리합니다.
* 버그가 발생하면 즉시 멈추기보다, Output 창을 함께 보고 원인을 찾아 고칩니다.

**게임 설명:** 마지막 수업은 완성 발표가 아니라 "플레이 테스트와 개선"입니다. 너무 강한 무기, 막히는 스폰, 이상한 충돌을 찾아 고치는 과정 자체가 수업입니다.

* **수동 운영:** 선생님이 말로 시작/종료를 통제합니다.
* **스마트 운영:** 라운드 타이머와 승리 조건을 코드로 관리합니다.

```lua
local ROUND_TIME = 180
local round_running = false

local function start_round()
    if round_running then
        return
    end

    round_running = true
    workspace:SetAttribute("RoundState", "Playing")

    for time_left = ROUND_TIME, 0, -1 do
        workspace:SetAttribute("TimeLeft", time_left)
        task.wait(1)
    end

    workspace:SetAttribute("RoundState", "Finished")
    round_running = false
end

workspace:WaitForChild("라운드시작버튼").ClickDetector.MouseClick:Connect(start_round)
```

## ---

**주요 이벤트 함수 패턴**

1. **Tool 클릭 이벤트**

```lua
local tool = script.Parent

tool.Activated:Connect(function()
    print("도구 사용")
end)
```

2. **Touched 충돌 이벤트**

```lua
local part = script.Parent
local debounce = false

part.Touched:Connect(function(hit)
    if debounce then
        return
    end

    debounce = true
    print(hit.Name .. " 충돌")
    task.wait(1)
    debounce = false
end)
```

3. **ClickDetector 버튼 이벤트**

```lua
local button = script.Parent

button.ClickDetector.MouseClick:Connect(function(player)
    print(player.Name .. " 버튼 클릭")
end)
```

4. **ProximityPrompt 상호작용 이벤트**

```lua
local prompt = script.Parent.ProximityPrompt

prompt.Triggered:Connect(function(player)
    print(player.Name .. " 상호작용")
end)
```

5. **RemoteEvent 서버 통신**

```lua
-- Client
remote:FireServer("Attack")

-- Server
remote.OnServerEvent:Connect(function(player, action)
    print(player.Name, action)
end)
```

## ---

**맵 기술과 폴더 구조**

수업용 Roblox 프로젝트는 Explorer 구조를 처음부터 정리해 두면 학생들이 길을 덜 잃습니다.

```text
Workspace
  수업맵
    로비
    전장
    성벽
    스폰
    버튼
ReplicatedStorage
  Remotes
  SharedModules
ServerScriptService
  RoundManager
  DamageService
  BuildService
StarterPack
  돌멩이
  마법지팡이
StarterGui
  RoundHud
```

* **Workspace:** 실제 맵과 눈에 보이는 오브젝트를 둡니다.
* **ReplicatedStorage:** 클라이언트와 서버가 함께 알아야 하는 RemoteEvent, ModuleScript를 둡니다.
* **ServerScriptService:** 데미지, 자원, 라운드, 승리 조건처럼 신뢰가 필요한 코드를 둡니다.
* **StarterPack:** 학생이 손에 들 Tool을 둡니다.
* **StarterGui:** 점수판, 타이머, 안내 UI를 둡니다.

## ---

**수업 운영 루프**

로블록스 수업은 짧은 에자일 루프로 운영하면 집중력이 유지됩니다.

1. **5분:** 오늘 만들 기능을 플레이 장면으로 먼저 설명합니다.
2. **15분:** 선생님이 최소 기능을 라이브 코딩합니다.
3. **20분:** 학생이 자기 맵/도구에 적용합니다.
4. **10분:** 모두 Play 테스트를 하며 버그를 찾습니다.
5. **10분:** 밸런스 값을 바꾸고 다시 테스트합니다.

중요한 점은 "한 번에 완성"이 아니라 "작동하는 작은 규칙을 만들고, 친구가 써 보게 하고, 바로 고치는 것"입니다.

## ---

**권한과 안전 운영**

**1. Team Create 운영**

* 학생별 작업 구역을 `학생_이름` 폴더로 나눕니다.
* 공통 시스템은 선생님 또는 담당 학생만 수정하게 합니다.
* 전투 테스트 전에는 반드시 Publish 또는 Save to File로 백업합니다.

**2. Toolbox 사용 제한**

* 무료 모델은 수업 초반에는 최소화합니다.
* 모델을 가져오면 Script가 숨어 있는지 Explorer에서 확인합니다.
* 가능하면 파트와 기본 스크립트로 직접 만드는 경험을 우선합니다.

**3. 서버/클라이언트 분리**

* 데미지, 자원, 점수, 승리 조건은 서버에서 처리합니다.
* 마우스 위치, 버튼 입력, 화면 UI는 클라이언트에서 처리할 수 있습니다.
* RemoteEvent는 항상 서버에서 거리, 쿨타임, 소유자를 검사합니다.

**4. 전투 수업 통제**

* PVP 테스트 전에는 라운드 시작/종료 신호를 명확히 합니다.
* 너무 강한 무기는 금지하지 말고 `DAMAGE`, `COOLDOWN`, `RANGE` 값을 바꾸며 토론합니다.
* 버그가 나면 실패가 아니라 플레이 테스트 결과로 다룹니다.

## ---

**선생님 팁**

* 로블록스는 "코드가 맞다/틀리다"보다 "게임이 재미있고 공정한가"를 함께 봐야 합니다.
* 학생이 만든 무기가 너무 강하면 칭찬 후 금지하지 말고, 쿨타임과 사거리 개념으로 연결합니다.
* Script 위치가 가장 흔한 오류입니다. 서버 코드인지, Tool 코드인지, LocalScript인지 먼저 확인하게 하세요.
* Output 창의 빨간 줄을 무서워하지 않게 만드세요. 오류 메시지는 로블록스가 알려주는 힌트입니다.
* 최종 결과물은 발표 영상보다 실제 친구가 플레이해 본 피드백이 더 중요합니다.