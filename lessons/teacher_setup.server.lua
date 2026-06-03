-- Roblox Studio 수업 스크립트 안내
-- 역할: 1~12일차 전체 수업 월드와 기준 오브젝트를 한 번에 보장하는 선생님용 부트스트랩입니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 TeacherSetup
-- 실행 순서: Common 배치 > 이 Script 배치 > Play 실행 > 생성물 확인
-- 생성/보장 대상: OutpostBattleWorld, OutpostAssets, StudentRockDesigns, Teams, CastMagic, 스폰 마커, 목표물, 버튼, 방어 구조물
-- 안전 운영: 기존 오브젝트를 지우지 않고 누락된 기준 구조만 보강합니다. 학생별 실험값은 student_answer 쪽에서 관리합니다.

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

common.setupCurriculumWorld(game)
