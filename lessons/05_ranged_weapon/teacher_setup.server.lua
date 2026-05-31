-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 05_ranged_weapon - 원거리 무기와 포물선
-- 문서 매핑: 커리큘럼 5회차와 강의가이드 "투사체와 포물선 공격"을 연결한 준비 코드입니다.
-- 강의가이드 연결: LookVector와 AssemblyLinearVelocity로 방향과 속도를 계산하는 원거리 무기 실습입니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 05_ranged_weapon_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: StarterPack/TrainingBow, Workspace/TargetRange05
-- 안전 운영: 기존 05 Tool과 사격장을 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: TrainingBow와 목표 사격장이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
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

local serviceStarterPack = game:GetService("StarterPack") -- [의미/의도] StarterPack 서비스를 가져옴 ➔ 게임 시작 시 플레이어 인벤토리에 자동으로 활(Tool)을 장착시켜주기 위함
local serviceWorkspace = game:GetService("Workspace")     -- [의미/의도] Workspace 서비스를 가져옴 ➔ 5일차 과녁 연습장 폴더와 파트를 맵에 추가하기 위함

local folderTargetRange05 = createOrReplaceInstance(enumClassName.Folder, "TargetRange05", serviceWorkspace) -- [의미/의도] TargetRange05 Folder 대체 생성 ➔ 기존 과녁판 폴더를 지우고 새로운 5일차 과녁판 경기장을 구성하기 위함

for index = 1, 6 do                                           -- [의미/의도] index 변수를 1부터 6까지 6번 반복 실행 ➔ 쏘아 맞힐 수 있는 6개의 과녁판(Target)을 만들기 위함
    local partTarget = Instance.new("Part")                   -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 투사체를 맞춰 쓰러뜨릴 과녁판 파트를 생성하기 위함
    partTarget.Name = "Target_" .. index                      -- [의미/의도] 과녁판 이름을 인덱스 번호를 붙여 "1_Target" 등으로 설정 ➔ 각 과녁을 개별 번호로 구분하기 위함
    partTarget.Size = Vector3.new(4, 6, 1)                    -- [의미/의도] 과녁판의 크기를 4x6x1의 넙데데한 크기로 설정 ➔ 플레이어가 활을 쏴서 충분히 맞힐 수 있는 적당한 과녁 너비로 만들기 위함
    partTarget.Position = Vector3.new(index * 8 - 28, 3, -40) -- [의미/의도] 과녁들을 X축 8칸 간격으로 정렬하고, 높이 3, 전방 Z축 -40에 배치 ➔ 플레이어의 정면에 거리를 두고 일정한 간격으로 나란히 서 있는 과녁 사격장을 연출하기 위함
    partTarget.Anchored = true                                -- [의미/의도] 과녁 파트를 고정시킴 ➔ 화살에 맞기 전까지 바람이나 중력에 의해 넘어지지 않고 꼿꼿이 서 있게 하기 위함
    partTarget.BrickColor = BrickColor.new("Bright red")      -- [의미/의도] 과녁 파트 색을 밝은 빨간색(Bright red)으로 지정 ➔ 멀리서도 뚜렷하게 표적으로 식별되도록 시각적으로 강조하기 위함
    partTarget.Parent = folderTargetRange05                   -- [의미/의도] 과녁 파트를 TargetRange05 폴더의 자식으로 등록 ➔ 과녁 연습장 폴더 내에 그룹화하여 관리하기 위함
end                                                           -- [의미/의도] 과녁 생성을 위한 반복문(for)의 종료 ➔ 6개의 과녁 생성을 완료함

local toolTrainingBow = createOrReplaceInstance(enumClassName.Tool, "TrainingBow", serviceStarterPack) -- [의미/의도] TrainingBow Tool 대체 생성 ➔ 기존 원거리 무기 활을 지우고 새로운 연습용 활을 초기화하기 위함
toolTrainingBow.ToolTip = "서버에서 투사체를 만드는 연습용 활"                                                        -- [의미/의도] 활 도구의 마우스 툴팁을 설정 ➔ 플레이어에게 서버 사이드에서 투사체를 생성함을 팁으로 설명하기 위함

local partHandle = Instance.new("Part")  -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 캐릭터가 손에 쥘 활의 중심 부위(Handle)를 만들기 위함
partHandle.Name = "Handle"               -- [의미/의도] 파트 이름을 반드시 "Handle"로 설정 ➔ 로블록스 도구 탑재 시스템이 캐릭터 손바닥에 부착할 파트로 인식하도록 하기 위함
partHandle.Size = Vector3.new(1, 4, 1)   -- [의미/의도] 핸들 파트 크기를 1x4x1로 얇고 길게 설정 ➔ 캐릭터가 쥘 수 있는 적당한 활대 크기를 구현하기 위함
partHandle.Material = Enum.Material.Wood -- [의미/의도] 재질을 나무(Wood)로 설정 ➔ 활의 자연 친화적인 나무 질감을 표현하기 위함
partHandle.Parent = toolTrainingBow      -- [의미/의도] 핸들 파트를 활 도구의 자식으로 등록 ➔ 도구 착용 시 외형으로 나타나게 하기 위함

print("5일차 준비 완료") -- [의미/의도] 출력창에 완료 메시지를 출력함 ➔ 5일차 사격장 및 활 생성 셋업이 완료되었음을 알려주기 위함
