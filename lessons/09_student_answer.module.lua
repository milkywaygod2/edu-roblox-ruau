-- Roblox Studio 수업 스크립트 안내
-- 수업: 09_stone_wall - 전초기지 석벽과 부분 파괴
-- 역할: 학생용 설정 코드입니다. 석벽 내구도와 손상 색만 바꾸고 구역별 붕괴 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > StudentLessonConfigs > ModuleScript 이름 StudentAnswer09

local stoneWall = {}

stoneWall.SectionHealth = 90
stoneWall.DamagePerHit = 30
stoneWall.DamagedColor = "Dark stone grey"

return stoneWall
