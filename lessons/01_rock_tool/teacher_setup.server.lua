-- Roblox Studio 수업 스크립트 안내
-- 수업: 01_rock_tool - 돌멩이 디자인과 기초 무기
-- 문서 매핑: 커리큘럼 1회차의 Tool 장착, Touched 데미지, Velocity 넉백을 첫 전투 도구로 준비합니다.
-- 강의가이드 연결: "돌멩이 툴 만들기" 장면으로, 학생이 눈에 보이는 Part가 실제 공격 규칙이 되는 경험을 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 01_rock_tool_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/SiegeWorld/Battlefield, Workspace/SiegeWorld/TargetArea, StarterPack/PracticeRock
-- 안전 운영: 기존 공성전 월드를 지우지 않고 누락된 기본 전장과 Tool만 보장합니다.
-- 검증 기준: Explorer에 SiegeWorld와 PracticeRock이 보이고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))                           -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton  -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType       -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함

local svcStarterPack = game:GetService(eService.STARTER_PACK)                                     -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 학생이 시작할 때 가질 툴을 넣어두기 위함
local svcWorkspace = game:GetService(eService.WORKSPACE)                                         -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵과 더미 등의 물리 공간을 제어하기 위함

local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace)                                             -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 1회차부터 12회차까지 같은 전장을 이어 쓰기 위함
local fldTargetArea = tblSiegeWorld.fldTargetArea                                                        -- [의미/의도] 타겟 영역 폴더 참조 ➔ 연습 더미를 공통 전장 타겟 영역에 누적 배치하기 위함

for index = 1, 4 do                                                                                           -- [의미/의도] 1부터 4까지 반복 루프를 실행 ➔ 타격 연습용 더미 4개를 일정한 위치에 자동 생성하기 위함
    common.ensureHumanoidDummy(eLogical.PRACTICE_DUMMY_PREFIX .. index, fldTargetArea, {                      -- [의미/의도] 연습 더미 보장 ➔ 기본 타격 대상이 다음 회차에도 유지되도록 공통 타겟 영역에 배치하기 위함
        Size = Vector3.new(3, 5, 2),                                                                           -- [의미/의도] 파트 크기를 3x5x2로 설정 ➔ 사람 몸집 크기만한 몸통을 구현하기 위함
        Position = Vector3.new(index * 8 - 20, 2.5, -18),                                                      -- [의미/의도] 파트 위치를 가로로 정렬해 설정 ➔ 4개의 더미가 나란히 줄 서서 배치되도록 하기 위함
        BrickColor = BrickColor.new("Bright red"),                                                            -- [의미/의도] 파트 색상을 밝은 빨간색으로 설정 ➔ 적으로 식별하기 쉽도록 시각적으로 강조하기 위함
    }, {
        MaxHealth = 100,                                                                                       -- [의미/의도] 최대 체력을 100으로 설정 ➔ 표준 캐릭터 스펙의 최대 체력을 지정하기 위함
        Health = 100,                                                                                          -- [의미/의도] 현재 체력을 100으로 설정 ➔ 더미가 처음 생겨날 때 꽉 찬 체력을 갖게 하기 위함
    })
end                                                                                                             -- [의미/의도] 더미 생성 반복문(for) 종료 ➔ 지정한 개수의 연습 더미 생성을 마침

common.ensureToolWithHandle(eLogical.PRACTICE_ROCK, "클릭하면 연습용 돌멩이를 던집니다", svcStarterPack, { -- [의미/의도] PracticeRock Tool과 Handle 보장 ➔ 첫 회차 기본 무기를 이후 회차에서도 유지하기 위함
    Shape = Enum.PartType.Ball,                                                                                -- [의미/의도] 파트 모양을 구체(Ball) 모양으로 설정 ➔ 무기 컨셉인 '돌멩이' 비주얼에 맞추기 위함
    Size = Vector3.new(1, 1, 1),                                                                               -- [의미/의도] 파트 크기를 1x1x1로 설정 ➔ 캐릭터가 손에 쥐기 알맞은 아담한 크기로 만들기 위함
    Material = Enum.Material.Slate,                                                                            -- [의미/의도] 파트 재질을 돌(Slate) 재질로 설정 ➔ 무기 컨셉인 돌멩이 질감을 사실적으로 연출하기 위함
})

print("1일차 준비 완료")                                                                                            -- [의미/의도] 콘솔에 완료 메시지를 출력 ➔ 셋업 코드가 에러 없이 정상적으로 끝났음을 교사에게 확인시켜 주기 위함
