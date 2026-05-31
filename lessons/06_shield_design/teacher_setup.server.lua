-- Roblox Studio 수업 스크립트 안내
-- 수업: 06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가, 투사체 방어벽, 데미지 반사 규칙을 준비합니다.
-- 강의가이드 연결: 전투 수업 통제 원칙을 적용해 공격뿐 아니라 방어와 밸런스도 게임 규칙으로 다룹니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 06_shield_design - 방패와 방어 규칙
-- 문서 매핑: 커리큘럼 6회차의 체력 증가, 투사체 방어벽, 데미지 반사 규칙을 준비합니다.
-- 강의가이드 연결: 전투 수업 통제 원칙을 적용해 공격뿐 아니라 방어와 밸런스도 게임 규칙으로 다룹니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 06_shield_design_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/PracticeShield
-- 안전 운영: 기존 06 Tool을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: PracticeShield Tool이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
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

local serviceStarterPack = game:GetService("StarterPack")                                        -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 플레이어가 게임에 접속할 때 자동으로 방패(Tool)를 인벤토리에 넣어주기 위함
local toolPracticeShield = createOrReplaceInstance("Tool", "PracticeShield", serviceStarterPack) -- [의미/의도] PracticeShield Tool 대체 생성 ➔ 기존 방패 무기를 지우고 새로운 방패 도구를 생성하기 위함
toolPracticeShield.ToolTip = "장착하면 방어하고 체력이 늘어납니다"                                               -- [의미/의도] 장비 툴팁 설명을 작성 ➔ 방패의 기능적 효과를 플레이어에게 툴팁 팝업으로 안내하기 위함

local partHandle = Instance.new("Part")                   -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터가 손에 쥘 방패의 손잡이이자 외형 본체(Handle)를 만들기 위함
partHandle.Name = "Handle"                                -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 장착 규격에 맞게 캐릭터 손 위치에 방패가 부착되도록 하기 위함
partHandle.Size = Vector3.new(4, 5, 0.6)                  -- [의미/의도] 파트 크기를 4x5x0.6으로 납작하고 넓게 설정 ➔ 캐릭터 앞을 가릴 수 있는 방패 판 모양을 묘사하기 위함
partHandle.Material = Enum.Material.Metal                 -- [의미/의도] 파트 재질을 금속(Metal)으로 설정 ➔ 튼튼하고 단단한 철제 방패 질감을 표현하기 위함
partHandle.BrickColor = BrickColor.new("Dark stone grey") -- [의미/의도] 파트 색을 어두운 돌 회색(Dark stone grey)으로 설정 ➔ 중후한 철광석 방패 느낌을 강조하기 위함
partHandle.Parent = toolPracticeShield                    -- [의미/의도] 핸들 파트를 방패 도구의 자식으로 등록 ➔ 도구를 들었을 때 이 방패 판 외형이 캐릭터 손에 부착되도록 하기 위함

print("6일차 준비 완료") -- [의미/의도] 출력창에 메시지를 출력 ➔ 준비 작업이 성공적으로 끝났음을 확인하기 위함
