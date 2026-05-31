-- Roblox Studio 수업 스크립트 안내
-- 수업: day07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차의 이동 속도 조절, 점프력 패널티, 파티클 오라를 갑옷 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=WalkSpeed 감소, 스크립터=갑옷 종류별 JumpPower 조건, 크리에이터=ParticleEmitter 오라 연출입니다.
-- 강의가이드 연결: "속도 갑옷과 이동 패널티" 장면처럼 강함과 느림의 교환 관계를 플레이테스트합니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > HeavyArmor > Script 이름 Day07StudentAnswer
-- 선행 조건: 선생님이 HeavyArmor Tool을 먼저 만들어야 합니다.
-- 학생 목표: Humanoid 속성 변경과 장비 해제 시 원상복구가 게임 밸런스에 왜 필요한지 이해합니다.
-- 검증 기준: 갑옷 장착 시 체력은 늘고 속도/점프는 줄며, 해제 시 원래 능력치로 돌아오면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md
local toolHeavyArmor = script.Parent -- [의미] 이 스크립트가 들어있는 갑옷 도구(HeavyArmor)를 가져옴 / [의도] 갑옷 장착(Equipped) 및 해제(Unequipped) 시의 이벤트를 연결하기 위함
local modelEquippedCharacter = nil   -- [의미] 현재 갑옷을 착용한 플레이어 캐릭터 모델을 임시 저장할 변수를 빈 값(nil)으로 생성 / [의도] 해제 시점에 원래 스탯으로 안전하게 되돌릴 캐릭터 타겟을 보관하기 위함
local tableSavedStats = nil          -- [의미] 갑옷 장착 전 원래 능력치(체력, 이속, 점프력)를 백업해둘 변수를 nil로 생성 / [의도] 갑옷을 벗었을 때 캐릭터 스탯을 정확하게 롤백하기 위한 보관함으로 사용하기 위함

toolHeavyArmor.Equipped:Connect(function()                                             -- [의미] 갑옷을 장착(Equipped)했을 때 아래 함수를 실행 / [의도] 무거운 중갑옷 장착에 따른 스탯 버프(체력 증가) 및 패널티(이속/점프 저하)를 처리하기 위함
    modelEquippedCharacter = toolHeavyArmor.Parent                                     -- [의미] 도구의 부모(플레이어 캐릭터 모델)를 modelEquippedCharacter 변수에 대입 / [의도] 갑옷 장착자 캐릭터를 추적하기 위함
    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")    -- [의미] 캐릭터 내부에서 생명체 컴포넌트(Humanoid)를 가져옴 / [의도] 캐릭터의 물리 체력, 이동 속도, 점프 높이를 조작하기 위함
    local partHumanoidRoot = modelEquippedCharacter:FindFirstChild("HumanoidRootPart") -- [의미] 캐릭터 몸통의 중심 파트(HumanoidRootPart)를 찾음 / [의도] 파티클 이펙트(이펙트 오라)를 캐릭터 중심에 부착하여 연출하기 위함
    if not humanoidPlayer or not partHumanoidRoot then return end                      -- [의미] Humanoid 혹은 중심 파트가 존재하지 않는 비정상 상태라면 실행 중단 / [의도] 널(Null) 에러로 인해 스크립트가 중단되는 사고를 차단하기 위함

    tableSavedStats = {MaxHealth = humanoidPlayer.MaxHealth, WalkSpeed = humanoidPlayer.WalkSpeed, JumpPower = humanoidPlayer.JumpPower} -- [의미] 장착 시점의 원래 최대 체력, 걷는 속도, 점프력을 테이블에 백업 / [의도] 갑옷을 해제할 때 플레이어 원래 능력치 상태로 되돌리기 위함
    humanoidPlayer.MaxHealth = 180                                                                                                       -- [의미] 최대 체력을 180으로 대폭 상승 설정 / [의도] 갑옷 장착으로 인해 캐릭터가 맷집이 매우 강해지도록 최대 피통을 늘려주기 위함
    humanoidPlayer.Health = math.min(humanoidPlayer.Health + 80, humanoidPlayer.MaxHealth)                                               -- [의미] 현재 체력을 80 채워주되, 최대 체력을 넘지 못하게 보정 / [의도] 최대 HP 버프와 동시에 실시간 HP 보충 효과를 가하여 튼튼해지는 재미를 주기 위함
    humanoidPlayer.WalkSpeed = 10                                                                                                        -- [의미] 걷는 속도를 10으로 저하 설정 (기본은 보통 16) / [의도] 무거운 쇳덩이 갑옷을 입어 몸이 크게 둔해진 패널티 밸런스를 체감시키기 위함
    humanoidPlayer.JumpPower = 32                                                                                                        -- [의미] 점프 속도(JumpPower)를 32로 낮게 설정 (기본은 보통 50) / [의도] 무거운 중량으로 인해 기본 점프조차 제대로 하지 못하는 밸런스적 한계를 구현하기 위함

    local particleemitterArmorAura = Instance.new("ParticleEmitter")                     -- [의미] 새로운 파티클 생성기(ParticleEmitter) 객체를 생성함 / [의도] 무거운 갑옷을 입고 있음을 보여줄 시각적인 마법 오라 이펙트를 연출하기 위함
    particleemitterArmorAura.Name = "ArmorAura"                                          -- [의미] 파티클 생성기 이름을 "ArmorAura"로 설정 / [의도] 탐색기에서 오라 효과임을 식별하고 차후 해제 시 쉽게 찾아 지우기 위함
    particleemitterArmorAura.Texture = "rbxasset://textures/particles/sparkles_main.dds" -- [의미] 파티클에 쓰일 반짝이는 텍스처 이미지 경로를 설정 / [의도] 반짝반짝 빛나는 신성한 오라 효과를 표현하기 위함
    particleemitterArmorAura.Rate = 20                                                   -- [의미] 초당 파티클 생성 개수(Rate)를 20개로 설정 / [의도] 끊임없이 부드럽게 뿜어져 나오는 밀도의 오라를 표현하기 위함
    particleemitterArmorAura.Lifetime = NumberRange.new(0.5, 1.2)                        -- [의미] 개별 파티클이 공중에 살아있는 수명을 0.5초에서 1.2초 사이로 무작위 설정 / [의도] 자연스럽게 사그라드는 이펙트 불규칙성을 연출하기 위함
    particleemitterArmorAura.Speed = NumberRange.new(1, 3)                               -- [의미] 파티클이 퍼져나가는 방사 속도를 1에서 3 사이로 설정 / [의도] 은은하고 부드럽게 퍼지는 아우라 기운을 묘사하기 위함
    particleemitterArmorAura.Parent = partHumanoidRoot                                   -- [의미] 파티클 생성기를 캐릭터 중심 파트의 자식으로 지정 / [의도] 캐릭터 몸 주변 전체에 반짝이는 오라 효과가 활성화되어 나타나도록 하기 위함
end)                                                                                     -- [의미] Equipped 이벤트 콜백 함수의 종료 / [의도] 갑옷 장착에 따른 전체 능력치 버프/디버프 및 오라 장착 처리를 마침

toolHeavyArmor.Unequipped:Connect(function()                             -- [의미] 갑옷 도구 장착을 해제(Unequipped)했을 때 아래 함수를 실행 / [의도] 갑옷으로 변경된 스탯을 복구하고 장식 파티클을 지우기 위함
    if not modelEquippedCharacter or not tableSavedStats then return end -- [의미] 대상 캐릭터나 백업된 능력치 정보가 존재하지 않으면 실행 중단 / [의도] 비정상적인 상태에서 원래 스탯 데이터가 깨져 꼬이는 현상을 막기 위함

    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")        -- [의미] 캐릭터 내부의 Humanoid를 가져옴 / [의도] 스탯을 복원하기 위함
    local partHumanoidRoot = modelEquippedCharacter:FindFirstChild("HumanoidRootPart")     -- [의미] 캐릭터 몸통의 중심 파트를 가져옴 / [의도] 부착되어 돌고 있던 파티클 오라를 파괴하기 위함
    if humanoidPlayer then                                                                 -- [의미] Humanoid가 정상적으로 존재한다면 / [의도] 복원 처리가 가능할 때만 안전하게 실행하기 위함
        humanoidPlayer.MaxHealth = tableSavedStats.MaxHealth                               -- [의미] 최대 체력을 백업해두었던 원래 값으로 복구 / [의도] 갑옷 추가 체력 보너스를 회수하기 위함
        humanoidPlayer.Health = math.min(humanoidPlayer.Health, tableSavedStats.MaxHealth) -- [의미] 현재 체력이 원래 최대 체력을 넘지 않도록 조정 / [의도] 갑옷을 벗은 후 최대 체력이 줄었는데 현재 피통은 여전히 180인 오버스탯 버그를 차단하기 위함
        humanoidPlayer.WalkSpeed = tableSavedStats.WalkSpeed                               -- [의미] 걷는 속도를 백업된 원래 스피드로 복구 / [의도] 이동 속도 디버프를 해제하기 위함
        humanoidPlayer.JumpPower = tableSavedStats.JumpPower                               -- [의미] 점프력을 백업된 원래 점프력으로 복구 / [의도] 점프력 저하 디버프를 해제하기 위함
    end                                                                                    -- [의미] Humanoid 복원 조건문 종료 / [의도] 스탯 복원 완료

    local particleemitterArmorAura = partHumanoidRoot and partHumanoidRoot:FindFirstChild("ArmorAura") -- [의미] 캐릭터 중심 파트 내에서 "ArmorAura" 파티클 생성기를 찾음 / [의도] 장착 중일 때 작동하던 오라 효과를 제거하기 위함
    if particleemitterArmorAura then particleemitterArmorAura:Destroy() end                            -- [의미] 파티클 생성기가 존재한다면 제거 / [의도] 갑옷을 벗었으므로 더 이상 몸에서 오라 효과가 나지 않도록 이펙트를 소멸시키기 위함

    modelEquippedCharacter = nil -- [의미] 캐릭터 저장 변수를 초기화(nil) / [의도] 다음 장착 프로세스를 위해 캐시를 비워둠
    tableSavedStats = nil        -- [의미] 백업 스탯 변수를 초기화(nil) / [의도] 다음 장착 프로세스를 위해 캐시를 비워둠
end)                             -- [의미] Unequipped 이벤트 콜백 함수의 종료 / [의도] 갑옷 탈착에 따른 리셋 프로세스를 마침
