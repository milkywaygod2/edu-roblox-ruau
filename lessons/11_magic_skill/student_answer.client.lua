-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차의 서버 통신 마법을 Tool LocalScript 입력으로 구성했습니다.
-- 미션 단계: 크리에이터=마우스 위치를 RemoteEvent로 서버에 보내고 서버가 거리와 쿨타임을 검사합니다.
-- 강의가이드 연결: "마법 스킬과 RemoteEvent" 예제의 클라이언트 입력 부분입니다.
-- 역할: student_answer.client.lua, 학생용 클라이언트 입력 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: StarterPack > MagicStaff > LocalScript 이름 MagicClient11
-- 선행 조건: 선생님이 MagicStaff와 ReplicatedStorage/CastMagic을 먼저 만들어야 합니다.
-- 학생 목표: Tool.Activated 입력은 클라이언트가 받고, 실제 피해 판정은 서버가 처리하는 구조를 이해합니다.
-- 검증 기준: 지팡이를 장착하고 클릭하면 마우스 위치가 서버로 전달되어 폭발 마법이 실행되면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local servicePlayers = game:GetService("Players")                     -- [의미/의도] Players 서비스를 가져옴 ➔ 로컬 플레이어(LocalPlayer) 개체를 조회하기 위함
local serviceReplicatedStorage = game:GetService("ReplicatedStorage") -- [의미/의도] ReplicatedStorage 서비스를 가져옴 ➔ 서버와 통신할 리모트 이벤트를 공유 공간에서 찾기 위함

local playerLocal = servicePlayers.LocalPlayer                                  -- [의미/의도] 현재 게임을 플레이 중인 로컬 플레이어 개체를 가져옴 ➔ 클라이언트 측 마우스 입력을 감지할 마우스 개체를 얻기 위함
local toolMagicStaff = script.Parent                                            -- [의미/의도] 이 로컬 스크립트가 포함된 지팡이 도구(MagicStaff)를 가져옴 ➔ 도구의 장착(Equipped), 해제(Unequipped), 사용(Activated) 이벤트를 연결하기 위함
local remoteeventCastMagic = serviceReplicatedStorage:WaitForChild("CastMagic") -- [의미/의도] ReplicatedStorage에서 "CastMagic" 리모트 이벤트가 준비될 때까지 대기하여 가져옴 ➔ 마우스 클릭 위치를 서버에 안전하게 원격 전송하기 위함
local mousePlayer = nil                                                         -- [의미/의도] 마우스 정보를 보관할 변수를 빈 값(nil)으로 생성 ➔ 장착 중일 때만 플레이어의 마우스 개체를 담아 활용하기 위함

toolMagicStaff.Equipped:Connect(function() -- [의미/의도] 지팡이를 장착(Equipped)했을 때 아래 함수를 실행 ➔ 장착하는 시점에 플레이어의 실시간 마우스 조작 인터페이스를 가져오기 위함
    mousePlayer = playerLocal:GetMouse()   -- [의미/의도] 로컬 플레이어의 마우스(Mouse) 개체를 얻어 mousePlayer 변수에 할당 ➔ 실시간 마우스 클릭 위치나 포인터 좌표를 추적할 수 있도록 하기 위함
end)                                       -- [의미/의도] Equipped 이벤트 콜백 함수의 종료 ➔ 마우스 연결 처리를 마침

toolMagicStaff.Unequipped:Connect(function() -- [의미/의도] 지팡이 장착을 해제(Unequipped)했을 때 아래 함수를 실행 ➔ 마우스 캐시 데이터를 청소하여 해제 후 오작동을 막기 위함
    mousePlayer = nil                        -- [의미/의도] 마우스 변수를 초기화(nil) ➔ 지팡이를 해제한 상태에서는 클릭 조준 위치가 서버로 전송되지 않도록 차단하기 위함
end)                                         -- [의미/의도] Unequipped 이벤트 콜백 함수의 종료 ➔ 마우스 리셋 처리를 마침

toolMagicStaff.Activated:Connect(function()                   -- [의미/의도] 지팡이를 들고 클릭(Activated)했을 때 아래 함수를 실행 ➔ 마법 시전을 요청하기 위함
    if not mousePlayer then return end                        -- [의미/의도] 마우스 개체가 없다면 실행 중단 ➔ 장착하지 않았거나 정상적으로 마우스 참조가 되지 않은 예외적 오류 상황을 차단하기 위함
    remoteeventCastMagic:FireServer(mousePlayer.Hit.Position) -- [의미/의도] 리모트 이벤트를 통해 마우스가 가리킨 3D 좌표(mousePlayer.Hit.Position)를 서버로 전송(FireServer) ➔ 마법이 시전될 조준 좌표를 서버에 실시간으로 요청하고, 실제 연산 처리를 위임하기 위함
end)                                                          -- [의미/의도] Activated 이벤트 콜백 함수의 종료 ➔ 마법 시전 요청 프로세스를 마침
