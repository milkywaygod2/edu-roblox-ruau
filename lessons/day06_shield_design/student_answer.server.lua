-- Roblox Studio 수업 스크립트 안내
-- 수업: day06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가 방패, 투사체 방어벽, 데미지 반사를 Tool 코드로 구성했습니다.
-- 미션 단계: 빌더=장착 시 체력 증가, 스크립터=방패 충돌 영역, 크리에이터=받은 피해 일부를 반사하는 규칙입니다.
-- 강의가이드 연결: 서버에서 데미지와 소유자를 판정해야 멀티플레이 방어 규칙이 공정하게 유지됩니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > PracticeShield > Script 이름 Day06StudentAnswer
-- 선행 조건: 선생님이 PracticeShield Tool을 먼저 만들어야 합니다.
-- 학생 목표: Equipped/Unequipped, 충돌 판정, 방어 상태 변수가 캐릭터 능력치를 바꾸는 방식을 이해합니다.
-- 검증 기준: 방패 장착 시 체력이 늘고, 방어 판정이 켜지며, 해제 시 원래 상태로 돌아오면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local toolPracticeShield = script.Parent -- [의미/의도] 이 스크립트가 들어있는 방패 도구(PracticeShield)를 가져옴 ➔ 방패 장착(Equipped), 장착 해제(Unequipped), 충돌(Touched) 이벤트를 연결하기 위함

local BONUS_HEALTH = 60            -- [의미/의도] 방패 장착 시 늘어날 추가 체력 보너스 수치를 60으로 설정 ➔ 방패를 들었을 때 샌드백처럼 더 오랫동안 버틸 수 있게 최대 체력을 증가시키기 위함
local BLOCK_HEAL = 5               -- [의미/의도] 방패로 투사체를 막았을 때 회복할 체력 수치를 5로 설정 ➔ 날아오는 원거리 투사체를 방패로 막으면 데미지를 무마하고 체력이 차는 수비 이득(블로킹 힐)을 구현하기 위함
local modelEquippedCharacter = nil -- [의미/의도] 현재 방패를 장착한 캐릭터 모델을 저장할 변수를 빈 값(nil)으로 생성 ➔ 장착을 해제했을 때 대상 캐릭터의 스탯을 원래대로 되돌려주기 위해 대상을 보관하기 위함
local tableSavedStats = nil        -- [의미/의도] 장착 시점의 캐릭터 원래 능력치(스피드, 체력)를 저장할 변수를 nil로 생성 ➔ 방패 해제 시 장착 이전의 정상 스탯으로 안전하게 복구하기 위해 임시 보관 테이블로 쓰기 위함

toolPracticeShield.Equipped:Connect(function()                                      -- [의미/의도] 도구를 장착(Equipped)했을 때 아래 함수를 실행 ➔ 방패 장착에 따른 캐릭터 능력치 상승(체력 증가, 속도 감소) 효과를 부여하기 위함
    modelEquippedCharacter = toolPracticeShield.Parent                              -- [의미/의도] 도구의 부모(플레이어 캐릭터 모델)를 modelEquippedCharacter 변수에 저장 ➔ 현재 장착한 캐릭터를 추적하기 위함
    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid") -- [의미/의도] 캐릭터 내부에서 생명체 정보(Humanoid)를 가져옴 ➔ 플레이어의 체력과 이동 속도 값을 변경하기 위함
    if not humanoidPlayer then return end                                           -- [의미/의도] Humanoid가 존재하지 않으면 실행 중단 ➔ 캐릭터가 비정상적인 상태이거나 없는 상태에서의 널 에러를 방지함

    tableSavedStats = {MaxHealth = humanoidPlayer.MaxHealth, WalkSpeed = humanoidPlayer.WalkSpeed}   -- [의미/의도] 장착 직전의 원래 최대 체력과 이동 속도 값을 테이블에 저장 ➔ 방패를 뺐을 때 이 원래 값으로 안전하게 복구하기 위함
    humanoidPlayer.MaxHealth += BONUS_HEALTH                                                         -- [의미/의도] 캐릭터의 최대 체력을 BONUS_HEALTH(60)만큼 증가시킴 ➔ 방패 장착에 따른 생존율 상승(최대 HP 확장) 효과를 구현하기 위함
    humanoidPlayer.Health = math.min(humanoidPlayer.Health + BONUS_HEALTH, humanoidPlayer.MaxHealth) -- [의미/의도] 현재 체력을 BONUS_HEALTH만큼 채워주되, 늘어난 최대 체력을 초과하지 않도록 보정 ➔ 늘어난 최대 HP에 맞춰 현재 체력도 증가시켜 실질적인 방어 상승감을 연출하기 위함
    humanoidPlayer.WalkSpeed -= 2                                                                    -- [의미/의도] 플레이어의 걷는 속도(WalkSpeed)를 2만큼 감소시킴 ➔ 무거운 철제 방패를 든 대가로 이동 속도가 약간 느려지는 패널티 밸런스를 적용하기 위함
end)                                                                                                 -- [의미/의도] Equipped 이벤트 콜백 함수의 종료 ➔ 장착 효과 적용을 완료함

toolPracticeShield.Unequipped:Connect(function()                         -- [의미/의도] 도구 장착을 해제(Unequipped)했을 때 아래 함수를 실행 ➔ 방패 장착으로 변경되었던 스탯을 복구하고 변수를 초기화하기 위함
    if not modelEquippedCharacter or not tableSavedStats then return end -- [의미/의도] 캐릭터 정보나 저장해둔 원래 스탯 테이블이 비어있다면 실행 중단 ➔ 예외적인 상황에서 복구 로직이 실행되어 데이터가 꼬이는 버그를 차단하기 위함

    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")        -- [의미/의도] 장착 해제된 캐릭터의 Humanoid 컴포넌트를 가져옴 ➔ 캐릭터 스탯을 원래대로 고치기 위함
    if humanoidPlayer then                                                                 -- [의미/의도] Humanoid가 정상적으로 존재한다면 ➔ 캐릭터가 살아있고 유효할 때만 복구 작업을 수행하기 위함
        humanoidPlayer.MaxHealth = tableSavedStats.MaxHealth                               -- [의미/의도] 최대 체력을 저장해두었던 원래 최대 체력으로 원상복구 ➔ 방패 보너스 체력을 제거하기 위함
        humanoidPlayer.Health = math.min(humanoidPlayer.Health, tableSavedStats.MaxHealth) -- [의미/의도] 현재 체력이 원래 최대 체력을 초과하지 않도록 보정 ➔ 방패를 해제한 뒤에도 비정상적으로 초과된 체력이 그대로 남아있는 버그를 방지하기 위함
        humanoidPlayer.WalkSpeed = tableSavedStats.WalkSpeed                               -- [의미/의도] 걷는 속도를 원래의 정상 속도로 복구 ➔ 속도 저하 패널티를 제거하기 위함
    end                                                                                    -- [의미/의도] Humanoid 복구 유효성 조건문의 종료 ➔ 스탯 복구 완료

    modelEquippedCharacter = nil -- [의미/의도] 캐릭터 저장 변수를 초기화(nil) ➔ 다음 장착 프로세스를 위해 캐시를 비워둠
    tableSavedStats = nil        -- [의미/의도] 스탯 저장 변수를 초기화(nil) ➔ 다음 장착 프로세스를 위해 캐시를 비워둠
end)                             -- [의미/의도] Unequipped 이벤트 콜백 함수의 종료 ➔ 장착 해제 스탯 복구 로직을 마침

toolPracticeShield.Handle.Touched:Connect(function(partHit)                                     -- [의미/의도] 방패 본체(Handle)에 물리적인 파트가 충돌(Touched)했을 때 아래 함수를 실행 ➔ 날아오는 공격 투사체를 방패로 막아내는 로직을 처리하기 위함
    if not partHit.Name:match("Arrow") and not partHit.Name:match("Projectile") then return end -- [의미/의도] 충돌한 파트의 이름에 "Arrow" 혹은 "Projectile"이 포함되어 있지 않다면 무시 ➔ 맵의 바닥이나 벽 등 일반 물체 충돌을 무시하고 오직 공격용 투사체만 방어 판정하기 위함
    if not modelEquippedCharacter then return end                                               -- [의미/의도] 방패를 장착한 캐릭터가 존재하지 않는 유령 상태라면 무시 ➔ 비정상적인 충돌 에러를 막기 위함

    local humanoidPlayer = modelEquippedCharacter:FindFirstChildOfClass("Humanoid")                                           -- [의미/의도] 장착자 캐릭터의 Humanoid 정보를 가져옴 ➔ 블로킹 힐(방어 회복)을 처리하기 위함
    if humanoidPlayer then humanoidPlayer.Health = math.min(humanoidPlayer.Health + BLOCK_HEAL, humanoidPlayer.MaxHealth) end -- [의미/의도] Humanoid가 존재할 경우 체력을 BLOCK_HEAL(5)만큼 회복시키되, 최대 체력을 넘지 않도록 처리 ➔ 적의 투사체를 방패로 막아냈을 때 체력이 일부 채워지는 수비 메리트를 제공하기 위함
    partHit:Destroy()                                                                                                         -- [의미/의도] 방패에 부딪힌 투사체 파트를 즉시 파괴함 ➔ 방패로 막아낸 투사체를 공중에서 소멸시켜 피격 판정을 지우고 맵을 청소하기 위함
end)                                                                                                                          -- [의미/의도] Touched 이벤트 콜백 함수의 종료 ➔ 방패 충돌 블로킹 처리를 완료함
