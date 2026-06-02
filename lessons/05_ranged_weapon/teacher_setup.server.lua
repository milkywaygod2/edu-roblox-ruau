-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 05_ranged_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: StarterPack/TrainingBow, Workspace/SiegeWorld/TargetArea/Target_*
-- 안전 운영: 기존 공성전 월드를 지우지 않고 활과 과녁만 보강합니다.
-- 검증 기준: TrainingBow와 목표 과녁이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcStarterPack = game:GetService(eService.STARTER_PACK) -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어 인벤토리에 자동으로 활(Tool)을 장착시켜주기 위함
local svcWorkspace = game:GetService(eService.WORKSPACE)      -- [의미/의도] Workspace 서비스를 가져옴 ➔ 5일차 과녁 연습장 폴더와 파트를 맵에 추가하기 위함

local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 원거리 과녁과 활을 추가하기 위함
local fldTargetArea = tblSiegeWorld.fldTargetArea -- [의미/의도] 타겟 영역 폴더 참조 ➔ 과녁을 공통 타겟 영역에 누적 배치하기 위함

for index = 1, 6 do -- [의미/의도] index 변수를 1부터 6까지 6번 반복 실행 ➔ 쏘아 맞힐 수 있는 6개의 과녁판(Target)을 만들기 위함
    common.ensureStaticPart(eLogical.TARGET_PREFIX .. index, fldTargetArea, { -- [의미/의도] 과녁판 Part 보장 ➔ 원거리 무기 타겟이 다음 회차에도 유지되도록 하기 위함
        Size = Vector3.new(4, 6, 1),                    -- [의미/의도] 과녁판의 크기를 4x6x1의 넙데데한 크기로 설정 ➔ 플레이어가 활을 쏴서 충분히 맞힐 수 있는 적당한 과녁 너비로 만들기 위함
        Position = Vector3.new(index * 8 - 28, 3, -40), -- [의미/의도] 과녁들을 X축 8칸 간격으로 정렬하고, 높이 3, 전방 Z축 -40에 배치 ➔ 일정한 간격의 과녁 사격장을 연출하기 위함
        BrickColor = BrickColor.new("Bright red"),      -- [의미/의도] 과녁 파트 색을 밝은 빨간색(Bright red)으로 지정 ➔ 멀리서도 뚜렷하게 표적으로 식별되도록 시각적으로 강조하기 위함
    })
end

common.ensureToolWithHandle(eLogical.TRAINING_BOW, "서버에서 투사체를 만드는 연습용 활", svcStarterPack, { -- [의미/의도] TrainingBow Tool과 Handle 보장 ➔ 원거리 무기 실험 장비를 유지하기 위함
    Size = Vector3.new(1, 4, 1),   -- [의미/의도] 핸들 파트 크기를 1x4x1로 얇고 길게 설정 ➔ 캐릭터가 쥘 수 있는 적당한 활대 크기를 구현하기 위함
    Material = Enum.Material.Wood, -- [의미/의도] 재질을 나무(Wood)로 설정 ➔ 활의 자연 친화적인 나무 질감을 표현하기 위함
})

print("5일차 준비 완료")
