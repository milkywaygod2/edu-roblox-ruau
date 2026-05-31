-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 건물과 파괴되는 성문
-- 문서 매핑: 커리큘럼 8회차와 강의가이드 "파괴되는 성문 만들기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 건물은 장식이 아니라 전투 중 체력과 파괴 상태를 갖는 게임 오브젝트가 됩니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 08_building_gate - 건물과 파괴되는 성문
-- 문서 매핑: 커리큘럼 8회차와 강의가이드 "파괴되는 성문 만들기"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 건물은 장식이 아니라 전투 중 체력과 파괴 상태를 갖는 게임 오브젝트가 됩니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 08_building_gate_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/Castle08/Gate
-- 안전 운영: 기존 08 성문을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: Castle/Gate 모델이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local enumClassName = { -- [의미/의도] 클래스 이름 이넘 정의 ➔ 오타 방지 및 생성할 인스턴스 종류를 한곳에서 안전하게 관리하기 위함
	Folder      = "Folder",
	Tool        = "Tool",
	RemoteEvent = "RemoteEvent",
}

local function createOrReplaceInstance(strClassName, strName, instanceParent) -- [의미/의도] 기존 인스턴스 대체 생성 함수 정의 ➔ 중복 오브젝트를 자동 정리하고 새 오브젝트를 만들기 위함
	local instanceOld = instanceParent:FindFirstChild(strName)                   -- [의미/의도] 부모 아래에서 동일한 이름의 기존 객체를 검색함 ➔ 중복 생성을 방지하기 위함
	if instanceOld then                                                          -- [의미/의도] 기존 객체가 존재한다면 ➔ 구버전 찌꺼기가 충돌하지 않도록 처리하기 위함
		instanceOld:Destroy()                                                       -- [의미/의도] 기존 객체를 삭제함 ➔ 맵이 꼬이거나 이전 데이터가 남는 것을 막기 위함
	end                                                                          -- [의미/의도] 기존 객체 정리 조건문 종료 ➔ 다음 생성 단계로 진행하기 위함

	local instanceNew = Instance.new(strClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성함 ➔ 새 구성 요소를 만들기 위함
	instanceNew.Name = strName                     -- [의미/의도] 인스턴스의 이름을 지정함 ➔ 탐색기에서 구분 가능하도록 이름을 설정하기 위함
	instanceNew.Parent = instanceParent            -- [의미/의도] 인스턴스의 부모를 지정함 ➔ 게임 세상의 올바른 위치에 배치하기 위함
	return instanceNew                             -- [의미/의도] 새로 만들어진 인스턴스를 반환함 ➔ 호출한 곳에서 이어서 속성을 조작할 수 있도록 하기 위함
end

local serviceWorkspace = game:GetService("Workspace")                                              -- [의미/의도] Workspace 서비스를 가져옴 ➔ 맵 상에 8일차 성문 폴더와 관련 파트들을 생성하고 배치하기 위함
local folderCastle08 = createOrReplaceInstance(enumClassName.Folder, "Castle08", serviceWorkspace) -- [의미/의도] Castle08 Folder 대체 생성 ➔ 기존 성벽/성문 폴더를 지우고 새로운 8일차 성문 실습장을 구성하기 위함

local modelGate = Instance.new("Model") -- [의미/의도] 새로운 모델(Model) 객체를 생성함 ➔ 성문을 구성하는 여러 개의 나무판자 파트들을 하나의 성문 모델로 그룹화하기 위함
modelGate.Name = "Gate"                 -- [의미/의도] 모델 이름을 "Gate"로 설정 ➔ 학생 스크립트가 해당 이름("Gate")으로 성문 모델을 찾아 작동시키게 하기 위함
modelGate.Parent = folderCastle08       -- [의미/의도] 성문 모델의 부모를 Castle08 폴더로 지정 ➔ 8일차 성 폴더 내부에 가지런히 위치시키기 위함

for index = 1, 5 do                                               -- [의미/의도] index 변수를 1부터 5까지 5번 반복 실행 ➔ 성문을 이루는 5개의 개별 나무판자 파트를 나란히 배치하기 위함
    local partGatePlank = Instance.new("Part")                    -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 성문의 한 칸을 구성할 세로형 나무판자 파트를 만들기 위함
    partGatePlank.Name = "GatePlank_" .. index                    -- [의미/의도] 파트 이름을 인덱스 번호를 붙여 "1_GatePlank" 등으로 설정 ➔ 각 판자 파트를 고유 번호로 쉽게 구분하기 위함
    partGatePlank.Size = Vector3.new(2, 10, 1)                    -- [의미/의도] 판자 파트 크기를 2x10x1로 좁고 높은 세로 판자 모양으로 설정 ➔ 5개를 붙여서 거대한 중세 성문 문짝 모양을 연출하기 위함
    partGatePlank.Position = Vector3.new((index - 3) * 2, 5, -20) -- [의미/의도] 각 판자의 X좌표를 계산하여 나란히 횡정렬하고, 높이 5, 전방 -20 위치에 배치 ➔ 판자들이 빈틈없이 꽉 맞물려 평평하고 큰 하나의 성문 모양으로 나란히 정렬되도록 위함
    partGatePlank.Anchored = true                                 -- [의미/의도] 판자 파트를 공중에 고정시킴 ➔ 처음부터 무너지지 않고 성문 기둥 사이에 꼿꼿이 서 있게 하기 위함
    partGatePlank.Material = Enum.Material.WoodPlanks             -- [의미/의도] 파트 재질을 나무판자(WoodPlanks)로 설정 ➔ 나무로 조립된 질감의 대문 느낌을 연출하기 위함
    partGatePlank.BrickColor = BrickColor.new("Reddish brown")    -- [의미/의도] 파트 색상을 나무 톤의 적갈색(Reddish brown)으로 지정 ➔ 시각적으로 전통적인 성문 뼈대 느낌을 주기 위함
    partGatePlank.Parent = modelGate                              -- [의미/의도] 성문 판자 파트를 Gate 모델의 자식으로 등록 ➔ 5개의 판자가 하나의 성문 모델에 속하도록 묶기 위함
end                                                               -- [의미/의도] 반복문(for)의 종료 ➔ 5개의 성문 판자 생성을 마침

print("8일차 준비 완료") -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 성공적으로 수행되었음을 파악하기 위함
