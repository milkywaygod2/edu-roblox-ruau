-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 12_final_battle_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/Battlefield/RoundStartButton, SpawnPoint_*, Teams/Blue, Teams/Red
-- 안전 운영: 기존 공성전 월드를 지우지 않고 라운드 버튼, 스폰 지점, 팀만 보강합니다.
-- 검증 기준: 누적 전장과 Blue/Red 팀이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcTeams = game:GetService(eService.TEAMS)         -- [의미/의도] Teams 서비스를 가져옴 ➔ 공성전 전투를 치를 Blue/Red 두 진영(팀)을 등록하고 관리하기 위함
local svcWorkspace = game:GetService(eService.WORKSPACE) -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 세상(Workspace)에 12일차 라운드 버튼과 스폰지점 폴더를 생성하기 위함
local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 모든 이전 회차 콘텐츠가 남아 있는 전장에서 최종전을 시작하기 위함
local fldBattlefield = tblSiegeWorld.fldBattlefield -- [의미/의도] 전투 공간 폴더 참조 ➔ 라운드 버튼과 스폰 지점을 공통 전장에 배치하기 위함

for _, teamName in ipairs({eLogical.TEAM_BLUE, eLogical.TEAM_RED}) do -- [의미/의도] "Blue", "Red" 두 문자열을 가지고 2번 반복을 실행 ➔ 청팀과 홍팀 두 개의 진영 오브젝트를 생성하기 위함
    local teamInstance = svcTeams:FindFirstChild(teamName) or Instance.new(ePhysical.TEAM) -- [의미/의도] Teams 서비스 내에서 해당 이름의 팀을 찾거나, 없으면 새로운 팀(Team) 객체를 생성 ➔ 기존 팀이 있다면 중복 생성을 막고 재사용하며, 없으면 새로 만들기 위함
    teamInstance.Name = teamName -- [의미/의도] 팀의 이름을 teamName("Blue" 혹은 "Red")으로 설정 ➔ 게임 내에서 청팀/홍팀을 텍스트로 쉽게 구분하기 위함
    teamInstance.TeamColor = BrickColor.new(teamName == eLogical.TEAM_BLUE and "Bright blue" or "Bright red") -- [의미/의도] Blue 팀이면 파란색(Bright blue), Red 팀이면 빨간색(Bright red)을 팀 색상(TeamColor)으로 지정 ➔ 팀 간의 구분을 시각적으로 뚜렷하게 지원하기 위함
    teamInstance.AutoAssignable = true -- [의미/의도] 새로 들어오는 플레이어를 무작위로 팀에 균등 자동 배정(AutoAssignable)되도록 설정 ➔ 플레이어들이 공성전에 들어올 때 팀 밸런스에 맞춰 자동으로 반반씩 나눠 들어가게 하기 위함
    teamInstance.Parent = svcTeams     -- [의미/의도] 팀 객체를 Teams 서비스의 자식으로 등록 ➔ 로블록스 팀 시스템에 정식 팀으로 작동하도록 활성화하기 위함
end

local partRoundStartButton = common.ensureStaticPart(eLogical.ROUND_START_BUTTON, fldBattlefield, { -- [의미/의도] 라운드 시작 버튼 Part 보장 ➔ 누적 전장 안에서 최종전 시작 입력 장치를 유지하기 위함
    Size = Vector3.new(8, 1, 8),               -- [의미/의도] 버튼 크기를 8x1x8로 매우 널찍하게 설정 ➔ 플레이어들이 올라가서 누르기 쉽고 멀리서도 돋보이는 시작 버튼을 묘사하기 위함
    Position = Vector3.new(0, 0.5, 0),         -- [의미/의도] 버튼 위치를 맵 중앙 원점 바닥으로 설정 ➔ 맵 중심부의 통제 타워나 제어 스위치 위치에 맞추기 위함
    BrickColor = BrickColor.new("Lime green"), -- [의미/의도] 파트 색을 라임색(Lime green)으로 설정 ➔ 대결 매치를 안전하게 활성화하라는 신호를 표현하기 위함
})
common.ensureClickDetector(partRoundStartButton, 30) -- [의미/의도] 클릭 감지기 보장 ➔ 해당 버튼에 마우스 클릭 리스너 역할을 유지하기 위함

for index, x in ipairs({-28, 28}) do -- [의미/의도] -28과 28 두 X좌표 값을 가지고 index 1, 2로 나누어 2번 반복 실행 ➔ 성의 양 측면에 각각 청팀과 홍팀이 부활할 스폰 거점 위치를 다르게 계산하여 소환하기 위함
    common.ensureStaticPart(eLogical.SPAWN_POINT_PREFIX .. index, fldBattlefield, { -- [의미/의도] 팀 스폰 패드 Part 보장 ➔ 누적 전장 안에서 양 팀 시작 위치를 유지하기 위함
        Size = Vector3.new(6, 1, 6),                                               -- [의미/의도] 스폰 패드 크기를 6x1x6으로 널찍하게 설정 ➔ 플레이어가 안전하게 올라설 발판 크기로 지정함
        Position = Vector3.new(x, 0.5, -20),                                       -- [의미/의도] X축은 -28(청팀)과 28(홍팀)로 벌려 배치 ➔ 양 팀이 대칭 구조의 거리에 서서 대결하도록 구성함
        BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red"), -- [의미/의도] 팀별 스폰 패드 색상 설정 ➔ 해당 위치가 어느 팀 본진인지 한눈에 알게 하기 위함
    })
end

print("12일차 준비 완료")
