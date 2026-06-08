-- Roblox Studio 수업 스크립트 안내
-- 역할: ActiveLessonDay까지의 누적 수업 월드와 기준 오브젝트를 보장하는 선생님용 부트스트랩입니다.
-- Script Sync 위치: ServerScriptService > Script 이름 TeacherSetup
-- 실행 순서: Common 배치 > 이 Script 배치 > Play 실행 > 생성물 확인
-- 생성/보장 대상: OutpostBattleWorld, OutpostAssets, Student*Designs, CastMagic, 진도별 스폰 마커, 목표물, 버튼, 방어 구조물
-- 안전 운영: Play마다 OutpostBattleWorld를 새로 만들고 설정 회차까지 누적 생성합니다.

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

-- 오늘 실행할 회차만 이 숫자로 바꿉니다. 1~12 밖의 값은 Common에서 보정됩니다.
local ACTIVE_LESSON_DAY = 2

-- 오늘 수업할 반: "Dobong"(도봉) / "Nowon"(노원) / "Example"(예시)
local ACTIVE_CLASS = "Example"

common.setupCurriculumWorld(game, { ActiveLessonDay = ACTIVE_LESSON_DAY, ActiveClass = ACTIVE_CLASS })
