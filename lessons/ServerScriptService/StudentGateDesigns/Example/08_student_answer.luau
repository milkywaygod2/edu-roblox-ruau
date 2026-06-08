-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 전초기지 문과 파괴 규칙
-- 역할: 학생용 설정 코드입니다. 문 내구도와 손상 색만 바꾸고 피격/붕괴 판정은 Common 서버 시스템이 처리합니다.
-- Script Sync 위치: ServerScriptService > StudentGateDesigns > ModuleScript 이름 08_student_answer

local gate = {}

gate.Health = 120
gate.DamagePerHit = 30
gate.WarningHealth = 60
gate.WarningColor = "Bright orange"

return gate
