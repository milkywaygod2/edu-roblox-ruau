-- Roblox Studio 수업 스크립트 안내
-- 수업: day09_stone_wall - 석조 성벽과 부분 파괴
-- 문서 매핑: 커리큘럼 9회차의 Union 성벽, 총안구, 부분 파괴를 구역별 체력 시스템으로 구성했습니다.
-- 미션 단계: 빌더=튼튼한 성벽 확인, 스크립터=구역별 체력 감소, 크리에이터=맞은 구역만 무너지는 성벽입니다.
-- 강의가이드 연결: 공성전 플레이테스트에서 "어디가 맞았는지"를 코드로 기록해 현실적인 붕괴를 만듭니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 Day09StudentAnswer
-- 선행 조건: 선생님이 Workspace/Day09_StoneWall을 먼저 만들어야 합니다.
-- 학생 목표: 여러 Part를 순회하며 Attribute/체력 값을 이용해 성벽 상태를 관리하는 방식을 이해합니다.
-- 검증 기준: 특정 성벽 구역만 피해를 받고, 체력이 0이 된 구역만 무너지면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local folderDay09StoneWall = workspace:WaitForChild("Day09_StoneWall") -- [의미] Workspace에서 "Day09_StoneWall" 폴더가 생성될 때까지 대기하여 가져옴 / [의도] 9일차 성벽 리소스가 로드된 후에 스크립트를 안정적으로 구동시키기 위함
local SECTION_HEALTH = 90                                              -- [의미] 성벽 각 섹션의 내구도를 90으로 고정 설정 / [의도] 투사체(피해량 30)에 3번 맞은 구역만 무너지도록 밸런스를 잡기 위함
local tableSectionHealth = {}                                          -- [의미] 각 성벽 섹션별 현재 체력을 매핑하여 저장할 빈 테이블(배열) 생성 / [의도] 섹션 전체가 아닌, 투사체가 맞은 해당 부분 성벽의 체력만 개별 차감하기 위해 맵 형태로 활용하기 위함

local function collapse_section(modelSection)                                                                   -- [의미] 무너질 성벽 섹션 모델(modelSection)을 인자로 받아 물리 붕괴를 일으키는 함수 정의 / [의도] 해당 성벽 구획의 돌들을 공중 고정 해제하고 무작위 속도로 흩어지게 연출하기 위함
    for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do                                           -- [의미] 해당 성벽 구획 내부의 모든 하위 파트를 순회함 / [의도] 구획 내의 모든 돌 벽돌을 제어하기 위함
        if partStoneBlock:IsA("BasePart") then                                                                  -- [의미] 순회 객체가 BasePart 계열의 물리 파트인 경우 / [의도] 물리 작동이 가능한 파트만 추려내기 위함
            partStoneBlock.Anchored = false                                                                     -- [의미] 돌 파트의 고정(Anchored)을 해제(false) / [의도] 중력에 의해 돌들이 무너져 내리도록 하기 위함
            partStoneBlock.AssemblyLinearVelocity = Vector3.new(math.random(-15, 15), 25, math.random(-10, 10)) -- [의미] 돌 파트에 무작위의 방사형 파편 속도를 주입함 / [의도] 성벽이 무너질 때 사방으로 돌가루가 튀며 붕괴하는 현상을 실감나게 표현하기 위함
        end                                                                                                     -- [의미] BasePart 조건문 종료 / [의도] 해당 파트 처리 완료
    end                                                                                                         -- [의미] 붕괴 반복문(for)의 종료 / [의도] 해당 구획 전체 돌의 붕괴 속성 주입 마침
end                                                                                                             -- [의미] collapse_section 함수의 종료 / [의도] 구역 붕괴 함수 정의 완료

local function register_section(modelSection)                                                       -- [의미] 성벽 섹션 모델을 매개변수로 받아 등록하는 함수 정의 / [의도] 각 섹션마다 초기 체력을 할당하고 투사체 충돌(Touched) 이벤트를 감지하도록 리스너를 연동하기 위함
    tableSectionHealth[modelSection] = SECTION_HEALTH                                               -- [의미] 테이블에 해당 성벽 섹션 모델을 키(Key)로 삼아 초기 체력(90)을 할당 / [의도] 성벽의 초기 내구도를 섹션별로 개별 부여하기 위함
    for _, partStoneBlock in ipairs(modelSection:GetDescendants()) do                               -- [의미] 해당 성벽 섹션 내부의 모든 돌 파트를 순회 / [의도] 각 돌 파트마다 개별 Touched 이벤트 감지기를 부착하기 위함
        if partStoneBlock:IsA("BasePart") then                                                      -- [의미] 파트가 물리 파트 계열인 경우 / [의도] 충돌 이벤트를 붙일 수 있는 물리적 개체에만 등록하기 위함
            partStoneBlock.Touched:Connect(function(partHit)                                        -- [의미] 개별 돌에 무언가 닿았을 때(Touched) 충돌 파트(partHit)를 가져와 함수 실행 / [의도] 투사체 가 돌에 적중했는지 여부를 파악하기 위함
                if partHit.Name ~= "SiegeStone" and partHit.Name ~= "TrainingArrow" then return end -- [의미] 충돌한 파트명이 공성돌("SiegeStone") 혹은 화살("TrainingArrow")이 아니라면 무시 / [의도] 캐릭터가 지나가다 비비는 충돌은 성벽 피해로 연산하지 않고 오직 투사체 공격만 피해로 받기 위함
                partHit:Destroy()                                                                   -- [의미] 부딪힌 투사체 파트를 즉시 삭제 / [의도] 충돌 판정이 끝난 화살이나 돌을 맵에서 소멸시키기 위함
                tableSectionHealth[modelSection] -= 30                                              -- [의미] 해당 성벽 구획의 체력을 30만큼 차감 / [의도] 투사체 타격 피해를 내구도에 적용하기 위함
                partStoneBlock.BrickColor = BrickColor.new("Dark stone grey")                       -- [의미] 맞은 돌 파트 색상을 어두운 돌 회색(Dark stone grey)으로 변경 / [의도] 돌이 깨지고 검게 그을려 손상된 상태를 시각적으로 강하게 나타내기 위함
                if tableSectionHealth[modelSection] <= 0 then collapse_section(modelSection) end    -- [의미] 해당 섹션의 체력이 0 이하가 되었다면 collapse_section 함수를 호출해 무너뜨림 / [의도] 내구도가 바닥난 성벽 섹션만 물리적으로 붕괴시키기 위함
            end)                                                                                    -- [의미] Touched 이벤트 콜백 함수의 종료 / [의도] 개별 돌 충돌 연산 마침
        end                                                                                         -- [의미] BasePart 판별 조건문 종료 / [의도] 처리 마침
    end                                                                                             -- [의미] 섹션 돌 순회 반복문(for)의 종료 / [의도] 섹션 내 모든 돌에 이벤트 부착 마침
end                                                                                                 -- [의미] register_section 함수의 종료 / [의도] 섹션 스탯 등록 함수 정의 완료

for _, modelSection in ipairs(folderDay09StoneWall:GetChildren()) do     -- [의미] Day09_StoneWall 폴더 내부의 1단계 자식 객체들을 순회함 / [의도] 폴더 안의 성벽 섹션 모델들을 하나씩 탐색하기 위함
    if modelSection:IsA("Model") then register_section(modelSection) end -- [의미] 순회 객체가 모델(Model) 타입이면 register_section 함수에 넣어 스탯 및 충돌을 등록 / [의도] 5개의 성벽 섹션 모델들을 시스템에 등록하여 정상 동작하게 만들기 위함
end                                                                      -- [의미] 성벽 섹션 순회 반복문의 종료 / [의도] 모든 성벽 구획의 초기화 및 이벤트 연결을 완료함
