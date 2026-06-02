-- Roblox Studio 수업 스크립트 안내
-- 수업: 10_siege_engine - 공성 병기와 원격 발사
-- 역할: 학생용 설정 코드입니다. 공성 탄환 외형과 제한된 발사 수치만 바꾸고 발사 판정은 Common 서버 시스템이 처리합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 StudentAnswer10

local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

local tblSiegeEngineConfig = {
    Cooldown = 2.5,
    ForwardSpeed = 95,
    UpSpeed = 45,
    Lifetime = 8,
    StoneSize = Vector3.new(3, 3, 3),
    StoneMaterial = Enum.Material.Slate,
}

common.installSiegeEngineSystem(workspace, tblSiegeEngineConfig)
