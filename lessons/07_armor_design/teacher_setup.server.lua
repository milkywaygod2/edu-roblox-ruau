-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 07_armor_design - 갑옷과 이동 패널티
-- 문서 매핑: 커리큘럼 7회차와 강의가이드 "속도 갑옷과 이동 패널티"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 강한 장비에는 대가가 있다는 밸런스 개념을 체력, 속도, 점프력으로 보여줍니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 07_armor_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/HeavyArmor
-- 안전 운영: 기존 07 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: HeavyArmor Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
-- 참고 문서: lessons/README.md, docs/curriculum_12_weeks.md, docs/roblox_luau_lecture_guide.md

-- --------------------------------------------------------------------------------

local function createOrReplaceInstance(stringClassName, stringName, instanceParent) -- [의미/의도] 기존 인스턴스 대체 생성 함수 정의 ➔ 중복 오브젝트를 자동 정리하고 새 오브젝트를 만들기 위함
	local instanceOld = instanceParent:FindFirstChild(stringName)                      -- [의미/의도] 부모 아래에서 동일한 이름의 기존 객체를 검색함 ➔ 중복 생성을 방지하기 위함
	if instanceOld then                                                                -- [의미/의도] 기존 객체가 존재한다면 ➔ 구버전 찌꺼기가 충돌하지 않도록 처리하기 위함
		instanceOld:Destroy()                                                             -- [의미/의도] 기존 객체를 삭제함 ➔ 맵이 꼬이거나 이전 데이터가 남는 것을 막기 위함
	end                                                                                -- [의미/의도] 기존 객체 정리 조건문 종료 ➔ 다음 생성 단계로 진행하기 위함

	local instanceNew = Instance.new(stringClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성함 ➔ 새 구성 요소를 만들기 위함
	instanceNew.Name = stringName                     -- [의미/의도] 인스턴스의 이름을 지정함 ➔ 탐색기에서 구분 가능하도록 이름을 설정하기 위함
	instanceNew.Parent = instanceParent               -- [의미/의도] 인스턴스의 부모를 지정함 ➔ 게임 세상의 올바른 위치에 배치하기 위함
	return instanceNew                                -- [의미/의도] 새로 만들어진 인스턴스를 반환함 ➔ 호출한 곳에서 이어서 속성을 조작할 수 있도록 하기 위함
end

local serviceStarterPack = game:GetService("StarterPack")                                -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어에게 자동으로 무거운 갑옷(Tool)을 장비 인벤토리에 지급하기 위함
local toolHeavyArmor = createOrReplaceInstance("Tool", "HeavyArmor", serviceStarterPack) -- [의미/의도] HeavyArmor Tool 대체 생성 ➔ 기존 갑옷 장비를 정리하고 새로운 기본 갑옷 툴을 생성하기 위함
toolHeavyArmor.RequiresHandle = true                                                     -- [의미/의도] 도구 작동 시 물리적인 핸들 파트가 필요하도록 참(true)으로 설정 ➔ 캐릭터가 손에 쥘 수 있는 파트가 손잡이 규격으로 필요함을 활성화하기 위함
toolHeavyArmor.ToolTip = "장착하면 갑옷 능력치가 적용됩니다"                                            -- [의미/의도] 장비의 설명 툴팁을 작성 ➔ 플레이어에게 갑옷 장착에 따른 스탯 변화 효과를 안내하기 위함

local partHandle = Instance.new("Part")                -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터가 쥘 갑옷의 중심 핸들이자 외형(Handle)을 만들기 위함
partHandle.Name = "Handle"                             -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 시스템이 캐릭터의 손 위치에 알아서 부착하도록 하기 위함
partHandle.Size = Vector3.new(2, 2, 1)                 -- [의미/의도] 파트 크기를 2x2x1로 널찍하고 두껍게 설정 ➔ 무겁고 두꺼운 방패나 흉갑 같은 강인한 디자인을 연출하기 위함
partHandle.Material = Enum.Material.Metal              -- [의미/의도] 파트 재질을 금속(Metal)으로 설정 ➔ 철제 중갑옷의 튼튼하고 차가운 금속 질감을 묘사하기 위함
partHandle.BrickColor = BrickColor.new("Really black") -- [의미/의도] 파트 색을 완전 검은색(Really black)으로 설정 ➔ 묵직하고 강렬한 블랙 중갑옷 느낌을 시각화하기 위함
partHandle.Parent = toolHeavyArmor                     -- [의미/의도] 핸들 파트를 갑옷 도구의 자식으로 등록 ➔ 장착 시 캐릭터 손에 이 검은 금속 덩어리 외형이 부착되도록 하기 위함

print("7일차 준비 완료") -- [의미/의도] 출력창에 메시지 출력 ➔ 준비 작업이 무사히 끝났음을 확인하기 위함
