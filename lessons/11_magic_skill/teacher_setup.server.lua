-- Roblox Studio 수업 스크립트 안내
-- 수업: 11_magic_skill - 마법 스킬과 서버 판정
-- 문서 매핑: 커리큘럼 11회차와 강의가이드 "마법 스킬과 RemoteEvent"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 마우스 입력은 클라이언트가 요청하고, 피해와 범위 검사는 서버가 판정하는 구조를 강조합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 11_magic_skill_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: StarterPack/MagicStaff, Workspace/SiegeWorld/TargetArea/MagicDummy_*, ReplicatedStorage/CastMagic
-- 안전 운영: 기존 공성전 월드를 지우지 않고 마법 Tool, 더미, RemoteEvent만 보강합니다.
-- 검증 기준: MagicStaff, 마법 더미, CastMagic RemoteEvent가 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common")) -- [의미/의도] 공통 모듈 require ➔ 공통 함수와 Enum 상수를 로드하여 중복 코드를 방지하고 재사용하기 위함

local eService = common.eEngineServiceSingleton -- [의미/의도] 서비스 싱글턴 이넘 단축 참조 ➔ game:GetService 키를 짧은 이름으로 쓰기 위함
local ePhysical = common.eEnginePhysicalType -- [의미/의도] 물리 타입 이넘 단축 참조 ➔ .ClassName 상수를 짧은 이름으로 쓰기 위함
local eLogical = common.eEngineLogicalType -- [의미/의도] 논리 타입 이넘 단축 참조 ➔ .Name 도메인 상수를 짧은 이름으로 쓰기 위함



local svcStarterPack = game:GetService(eService.STARTER_PACK)             -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 플레이어 접속 시 마법 지팡이 도구(Tool)를 인벤토리에 자동 배치해주기 위함
local svcReplicatedStorage = game:GetService(eService.REPLICATED_STORAGE) -- [의미/의도] ReplicatedStorage 서비스를 가져옴 ➔ 클라이언트와 서버가 공유하는 저장소에 원격 이벤트를 배치하기 위함
local svcWorkspace = game:GetService(eService.WORKSPACE)                  -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 세상(Workspace)에 11일차 마법 아레나와 연습 더미들을 배치하기 위함

local tblSiegeWorld = common.ensureSiegeWorld(svcWorkspace) -- [의미/의도] 누적 공성전 월드 구조 보장 ➔ 기존 전장 콘텐츠를 유지한 채 마법 실험 대상을 추가하기 위함
local fldTargetArea = tblSiegeWorld.fldTargetArea -- [의미/의도] 타겟 영역 폴더 참조 ➔ 마법 연습 더미를 공통 타겟 영역에 누적 배치하기 위함

common.ensureNamedInstance(ePhysical.REMOTE_EVENT, eLogical.CAST_MAGIC, svcReplicatedStorage) -- [의미/의도] CastMagic RemoteEvent 보장 ➔ 클라이언트 입력과 서버 판정을 연결할 통신 채널을 유지하기 위함

common.ensureToolWithHandle(eLogical.MAGIC_STAFF, "서버 판정 마법을 시전합니다", svcStarterPack, { -- [의미/의도] MagicStaff Tool과 Handle 보장 ➔ 마법 입력 장비를 이후 공성전 회차에서도 유지하기 위함
    Size = Vector3.new(0.6, 5, 0.6),             -- [의미/의도] 파트 크기를 0.6x5x0.6으로 가늘고 긴 막대 모양으로 설정 ➔ 시각적으로 긴 장대 마법 지팡이 형태를 묘사하기 위함
    Material = Enum.Material.Neon,               -- [의미/의도] 파트 재질을 네온(Neon)으로 설정 ➔ 지팡이가 보랏빛 마법 에너지를 내며 화려하게 발광하도록 연출하기 위함
    BrickColor = BrickColor.new("Royal purple"), -- [의미/의도] 파트 색을 고귀한 보라색(Royal purple)으로 지정 ➔ 신비로운 마법 마력이 깃든 지팡이의 색상을 부각시키기 위함
})

for index = 1, 6 do -- [의미/의도] index 변수를 1부터 6까지 6번 반복 실행 ➔ 마법 광역 공격을 맞아줄 연습용 더미 6마리를 만들기 위함
    common.ensureHumanoidDummy(eLogical.MAGIC_DUMMY_PREFIX .. index, fldTargetArea, { -- [의미/의도] 마법 연습 더미 보장 ➔ 공통 타겟 영역에서 광역 스킬 실험 대상을 유지하기 위함
        Size = Vector3.new(3, 5, 2),                      -- [의미/의도] 파트 크기를 3x5x2로 큼직하게 설정 ➔ 넓은 면적의 샌드백처럼 만들기 위함
        Position = Vector3.new(index * 7 - 24, 2.5, -25), -- [의미/의도] 더미 X좌표를 7칸 간격으로 가로 정렬 ➔ 6마리의 더미가 겹치지 않고 일직선상에 간격을 두고 나란히 정렬되도록 위함
    })
end

print("11일차 준비 완료")
