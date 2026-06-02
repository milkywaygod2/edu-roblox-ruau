-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차의 화염구, 광역 폭발, 서버 통신 마법을 MagicStaff 코드로 구성했습니다.
-- 미션 단계: 빌더=네온 화염구 스폰, 스크립터=거리 계산 AoE, 크리에이터=RemoteEvent로 모두에게 보이는 서버 마법입니다.
-- 강의가이드 연결: "마법 스킬과 RemoteEvent" 예제처럼 입력 요청과 서버 판정을 분리해 멀티플레이를 안전하게 만듭니다.
-- 역할: student_answer.server.lua, 학생용 완성 모범답안 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 MagicServer11
-- 선행 조건: 선생님이 MagicStaff, MagicArena11, ReplicatedStorage/CastMagic을 먼저 만들어야 합니다.
-- 클라이언트 입력: student_answer.client.lua를 StarterPack > MagicStaff > LocalScript로 붙여넣습니다.
-- 학생 목표: 마법 이펙트, 범위 피해, 서버 권한 검사가 하나의 스킬 시스템으로 묶이는 흐름을 이해합니다.
-- 검증 기준: 지팡이 사용 시 화염구/폭발 효과가 보이고, 범위 안 더미에게만 피해가 들어가면 성공입니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 이넘 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton
local ePhysical = common.eEnginePhysicalType
local eLogical = common.eEngineLogicalType

local svcPlayers = game:GetService(eService.PLAYERS)                                             -- [의미/의도] Players 서비스를 가져옴 ➔ 게임을 떠난 플레이어 정보를 감지하고 쿨타임 데이터를 청소하기 위함
local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE)                         -- [의미/의도] ReplicatedStorage 서비스를 가져옴 ➔ 클라이언트와 통신하기 위해 공유된 통신망에서 리모트 이벤트를 참조하기 위함
local eventCastMagic = svcReplicatedStorage:WaitForChild(eLogical.CAST_MAGIC)                  -- [의미/의도] ReplicatedStorage에서 "CastMagic" 리모트 이벤트가 생성될 때까지 대기하여 가져옴 ➔ 클라이언트의 마법 시전 요청 신호를 서버에서 대기하고 수신하기 위함

local MAX_DISTANCE = 80                                                                                       -- [의미/의도] 마법 시전이 가능한 최대 사거리를 80칸으로 제한 ➔ 클라이언트가 너무 먼 위치나 맵 전체에 광역 공격을 핵으로 요청해 타격하는 불공정 행위를 서버에서 차단하기 위함
local RADIUS = 12                                                                                             -- [의미/의도] 마법 폭발의 유효 범위 반경을 12칸으로 설정 ➔ 시전 위치를 기준으로 주변 12칸 내의 적들에게 피해를 입히는 광역 범위(AoE)를 고정하기 위함
local DAMAGE = 25                                                                                             -- [의미/의도] 마법 스킬의 타격 데미지를 25로 설정 ➔ 폭발 범위 내의 적들에게 가할 공격 피해량을 지정하기 위함
local COOLDOWN = 1.8                                                                                          -- [의미/의도] 스킬의 재시전 대기시간(쿨타임)을 1.8초로 설정 ➔ 클라이언트가 마우스를 광클하거나 패킷을 조작하여 폭발을 난사하는 버그 공격을 차단하기 위함
local tableLastCastByPlayer = {}                                                                              -- [의미/의도] 각 플레이어별 가장 최근 스킬 사용 시각을 기록할 테이블(배열) 생성 ➔ 서버 사이드에서 플레이어마다 개별적으로 쿨타임을 추적하고 검사하여 쿨타임 스위치 역할을 수행하기 위함

local function cast_magic(player, targetPosition)                                                             -- [의미/의도] 클라이언트의 요청을 받아 마법을 실행하는 서버 함수 정의 (요청 플레이어, 마우스 좌표 전달 받음) ➔ 보안이 유지되는 서버에서 실제 폭발을 소환하고 범위를 연산하기 위함
    if typeof(targetPosition) ~= "Vector3" then return end                                                    -- [의미/의도] 전달받은 targetPosition 변수가 3차원 위치(Vector3) 자료형이 아니라면 함수 실행 중단 ➔ 해커가 잘못된 인자(텍스트나 거짓 데이터)를 패킷으로 주입해 서버 스크립트 에러를 유발하는 현상을 사전 방지하기 위함

    local now = os.clock()                                                                                    -- [의미/의도] 현재 서버의 정밀 시스템 시간(초 단위)을 구하여 now 변수에 저장 ➔ 현재 시간을 기준으로 쿨타임 경과를 정량 계산하기 위함
    local lastCast = tableLastCastByPlayer[player] or -COOLDOWN                                               -- [의미/의도] 해당 플레이어의 마지막 시전 시각을 가져오되, 기록이 없다면 -COOLDOWN 시각으로 대체 ➔ 게임 시작 후 첫 번째 시전 시에는 쿨타임 대기 없이 즉시 시전이 되도록 보장하기 위함
    if now - lastCast < COOLDOWN then return end                                                              -- [의미/의도] 지난 시전 시각으로부터 흘러간 시간이 쿨타임(1.8초) 미만이라면 실행 즉시 중단 ➔ 쿨타임이 지나지 않은 상태에서의 시전 요청을 서버 단에서 확실히 차단(보안 핵 방지)하기 위함

    local modelCharacter = player.Character                                                                   -- [의미/의도] 플레이어의 현재 캐릭터 모델을 가져옴 ➔ 시전자 몸통과의 거리를 계산하기 위함
    local partHumanoidRoot = modelCharacter and modelCharacter:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART) -- [의미/의도] 캐릭터 몸통의 중심 파트(HumanoidRootPart)를 찾음 ➔ 사거리 검증을 위한 플레이어의 현재 실제 월드 좌표를 확인하기 위함
    if not partHumanoidRoot then return end                                                                     -- [의미/의도] 캐릭터 중심 파트가 존재하지 않으면 실행 중단 ➔ 캐릭터가 사망했거나 유효하지 않은 비정상적 상태일 때 널 에러를 예방하기 위함

    if (targetPosition - partHumanoidRoot.Position).Magnitude > MAX_DISTANCE then return end                    -- [의미/의도] 시전 목표 지점과 플레이어 캐릭터 중심 위치 간의 실제 3D 거리가 MAX_DISTANCE(80)를 초과한다면 실행 중단 ➔ 클라이언트가 사거리 핵을 사용해 너무 먼 거리에 폭발을 지르는 치트를 서버에서 최종 필터링하기 위함

    tableLastCastByPlayer[player] = now                                                                       -- [의미/의도] 해당 플레이어의 마지막 시전 시각을 현재 시각인 now로 갱신 저장 ➔ 다음 1.8초 동안의 시전을 잠그기 위해 시각을 업데이트함

    local explMagic = Instance.new(ePhysical.EXPLOSION)                                    -- [의미/의도] 새로운 폭발(Explosion) 객체를 생성함 ➔ 시각적으로 멋지게 터지는 폭풍 이펙트와 물리 충격을 보여주기 위함
    explMagic.Position = targetPosition                                                                        -- [의미/의도] 폭발이 일어날 위치를 클라이언트가 지정한 targetPosition으로 설정 ➔ 마우스를 조준하고 클릭한 정확한 좌표에 폭발 효과가 생기게 하기 위함
    explMagic.BlastRadius = RADIUS                                                                             -- [의미/의도] 폭발의 물리력 반경을 RADIUS(12)로 설정 ➔ 폭발 바람이 가해지는 가시 영역을 맞추기 위함
    explMagic.BlastPressure = 0                                                                                -- [의미/의도] 폭발의 물리적 밀쳐내는 압력(BlastPressure)을 0으로 설정 ➔ 로블록스 내장 폭발은 캐릭터를 사방으로 너무 강하게 날려 분해시키므로, 넉백을 차단하고 얌전히 이펙트만 쓰기 위함
    explMagic.DestroyJointRadiusPercent = 0                                                                    -- [의미/의도] 폭발 반경 내 관절 파괴율(DestroyJointRadiusPercent)을 0%로 설정 ➔ 폭발에 닿은 캐릭터 관절이 조각조각 해체되어 즉사하는 기본 물리 성질을 완전히 제거하여 수동 데미지만 들어가도록 하기 위함
    explMagic.Parent = workspace                                                                               -- [의미/의도] 폭발 객체를 workspace의 자식으로 등록 ➔ 월드 상에 실제로 마법 폭발 불꽃이 번쩍이며 터지도록 이펙트를 실행하기 위함

    for _, object in ipairs(workspace:GetDescendants()) do                                                    -- [의미/의도] 게임 내의 모든 하위 오브젝트들을 전부 순회함 ➔ 폭발 반경 내에 들어온 타격 대상을 일일이 감지하기 위함
        if object:IsA(ePhysical.HUMANOID) then                                            -- [의미/의도] 순회 객체가 생명체 속성(Humanoid)인 경우 ➔ 폭발 범위 데미지를 입을 생명체를 식별하기 위함
            local humanoidTarget = object                                                                     -- [의미/의도] 찾은 객체를 humanoidTarget 변수에 할당 ➔ 코드 가독성을 위한 타입 재설정
            local modelTarget = humanoidTarget.Parent                                                         -- [의미/의도] 대상 Humanoid의 부모 캐릭터 모델을 가져옴 ➔ 대상의 몸통 파트를 확인하기 위함
            local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART) -- [의미/의도] 대상의 중심 몸통 파트(HumanoidRootPart)를 찾음 ➔ 폭발 중심점과의 실제 거리를 계산해내기 위함
            if partTargetRoot and (partTargetRoot.Position - targetPosition).Magnitude <= RADIUS and modelTarget ~= modelCharacter then -- [의미/의도] 대상 중심 파트가 존재하고, 폭발 중심점과의 거리가 RADIUS(12) 이하이며, 나 자신(modelCharacter)이 아닌 경우 ➔ 폭발 범위 12칸 내의 적에게만 데미지를 가하고 본인의 자폭 피해는 막기 위한 삼중 안전 검사를 진행함
                humanoidTarget:TakeDamage(DAMAGE)                                                             -- [의미/의도] 타격 대상의 체력을 DAMAGE(25)만큼 깎음 ➔ 마법 폭발의 광역 피해량을 정확히 가하기 위함
            end                                                                                               -- [의미/의도] 타격 판정 조건문의 종료 ➔ 개별 대상의 데미지 처리 완료
        end                                                                                                   -- [의미/의도] Humanoid 판정 조건문의 종료 ➔ 처리 마침
    end                                                                                                       -- [의미/의도] 전체 오브젝트 순회 반복문(for)의 종료 ➔ 범위 내 모든 대상에게 광역 데미지 적용을 마침
end                                                                                                           -- [의미/의도] cast_magic 함수의 종료 ➔ 마법 시전 함수 정의 완료

eventCastMagic.OnServerEvent:Connect(cast_magic)                                                                 -- [의미/의도] 클라이언트가 리모트 이벤트를 전송(FireServer)했을 때 서버 측(OnServerEvent)에서 cast_magic 함수를 실행하도록 이벤트를 연동 ➔ 클라이언트의 시전 요청에 반응하여 서버에서 마법을 안전하게 가동하게 만들기 위함

svcPlayers.PlayerRemoving:Connect(function(player)                                                             -- [의미/의도] 플레이어가 서버에서 나갈 때(PlayerRemoving) 아래 함수를 호출 ➔ 퇴장한 플레이어의 데이터를 즉각 지워 서버 메모리를 보호하기 위함
    tableLastCastByPlayer[player] = nil                                                                       -- [의미/의도] 나간 플레이어의 쿨타임 기록을 테이블에서 지움(nil) ➔ 서버 테이블에 나간 플레이어 데이터 찌꺼기가 영구히 남아 메모리가 낭비되는 누수 현상을 방지하기 위함
end)                                                                                                          -- [의미/의도] PlayerRemoving 이벤트 콜백 함수의 종료 ➔ 플레이어 데이터 청소 프로세스 마침
