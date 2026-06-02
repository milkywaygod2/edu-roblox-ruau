-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비를 맵에 배치해 얻는 대신 느려지는 선택지를 플레이어가 직접 판단하게 합니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 07_armor_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/보장 대상: Workspace/OutpostBattleWorld/ItemSpawns/ItemSpawn_FieldArmor_*
-- 안전 운영: 기존 전초기지 공방전 월드를 지우지 않고 갑옷 스폰 위치만 보강합니다.
-- 검증 기준: ItemSpawn_FieldArmor_*가 생성되고, Output에 준비 완료 메시지가 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local eService = common.eEngineServiceSingleton
local eLogical = common.eEngineLogicalType

local svcWorkspace = game:GetService(eService.WORKSPACE)
local tblOutpostWorld = common.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 구조 보장 ➔ 기존 전장을 유지한 채 갑옷 파밍 위치만 추가하기 위함
local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea -- [의미/의도] 아이템 스폰 영역 참조 ➔ 학생 튜닝 갑옷을 맵에서 파밍하게 하기 위함

common.ensureFieldItemSpawnMarkers(fldItemSpawnArea, eLogical.FIELD_ARMOR, {
    Vector3.new(-30, 0.1, 22),
    Vector3.new(30, 0.1, -22),
}, "Really black")

print("7일차 준비 완료")
