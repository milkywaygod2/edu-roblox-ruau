-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- Roblox Studio 수업 스크립트 안내
-- 수업: 12_final_battle - 최종 공성 대대전
-- 문서 매핑: 커리큘럼 12회차와 강의가이드 "최종 대전 운영과 실시간 핫픽스"를 연결한 준비 코드입니다.
-- 강의가이드 연결: 팀 스폰, 라운드 운영, 전투 테스트, 밸런스 핫픽스를 하나의 최종 플레이테스트로 묶습니다.
-- 역할: teacher_setup.server.lua, 선생님 전용 수업 준비 코드입니다.
-- 편집 위치: Roblox Studio에서 Explorer, Properties, Output 창을 켜고 작업합니다.
-- 붙여넣기 위치: ServerScriptService > Script 이름 12_final_battle_TeacherSetup
-- 실행 순서: 붙여넣기 > Play 실행 > 생성물 확인 > Stop > 수업 플레이테스트 전 setup Script 비활성화 또는 삭제
-- 생성/초기화 대상: Workspace/FinalBattle12, Teams/Blue, Teams/Red
-- 안전 운영: 기존 12 전장과 Teams를 다시 만들 수 있으므로 저장된 수업 복사본에서만 실행합니다.
-- 검증 기준: 최종 전장과 Blue/Red 팀이 생성되고, Output에 준비 완료 메시지가 빨간 오류 없이 출력됩니다.
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

local serviceTeams = game:GetService("Teams")         -- [의미/의도] Teams 서비스를 가져옴 ➔ 공성전 전투를 치를 Blue/Red 두 진영(팀)을 등록하고 관리하기 위함
local serviceWorkspace = game:GetService("Workspace") -- [의미/의도] Workspace 서비스를 가져옴 ➔ 게임 세상(Workspace)에 12일차 라운드 버튼과 스폰지점 폴더를 생성하기 위함

for _, teamName in ipairs({"Blue", "Red"}) do                                                     -- [의미/의도] "Blue", "Red" 두 문자열을 가지고 2번 반복을 실행 ➔ 청팀과 홍팀 두 개의 진영 오브젝트를 생성하기 위함
    local teamInstance = serviceTeams:FindFirstChild(teamName) or Instance.new("Team")            -- [의미/의도] Teams 서비스 내에서 해당 이름의 팀을 찾거나, 없으면 새로운 팀(Team) 객체를 생성 ➔ 기존 팀이 있다면 중복 생성을 막고 재사용하며, 없으면 새로 만들기 위함
    teamInstance.Name = teamName                                                                  -- [의미/의도] 팀의 이름을 teamName("Blue" 혹은 "Red")으로 설정 ➔ 게임 내에서 청팀/홍팀을 텍스트로 쉽게 구분하기 위함
    teamInstance.TeamColor = BrickColor.new(teamName == "Blue" and "Bright blue" or "Bright red") -- [의미/의도] Blue 팀이면 파란색(Bright blue), Red 팀이면 빨간색(Bright red)을 팀 색상(TeamColor)으로 지정 ➔ 팀 간의 구분을 시각적으로 뚜렷하게 지원하기 위함
    teamInstance.AutoAssignable = true                                                            -- [의미/의도] 새로 들어오는 플레이어를 무작위로 팀에 균등 자동 배정(AutoAssignable)되도록 설정 ➔ 플레이어들이 공성전에 들어올 때 팀 밸런스에 맞춰 자동으로 반반씩 나눠 들어가게 하기 위함
    teamInstance.Parent = serviceTeams                                                            -- [의미/의도] 팀 객체를 Teams 서비스의 자식으로 등록 ➔ 로블록스 팀 시스템에 정식 팀으로 작동하도록 활성화하기 위함
end                                                                                               -- [의미/의도] 팀 생성 반복문(for)의 종료 ➔ Blue, Red 팀 등록 완료

local folderFinalBattle12 = createOrReplaceInstance(enumClassName.Folder, "FinalBattle12", serviceWorkspace) -- [의미/의도] FinalBattle12 Folder 대체 생성 ➔ 기존 최종 대전 폴더를 지우고 12일차 맵을 초기화하기 위함

local partRoundStartButton = Instance.new("Part")              -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 최종 매치 라운드를 시작할 수 있는 물리적인 스위치 버튼(RoundStartButton)을 만들기 위함
partRoundStartButton.Name = "RoundStartButton"                 -- [의미/의도] 파트 이름을 "RoundStartButton"으로 설정 ➔ 라운드 개시 버튼임을 명확하게 식별하기 위함
partRoundStartButton.Size = Vector3.new(8, 1, 8)               -- [의미/의도] 버튼 크기를 8x1x8로 매우 널찍하게 설정 ➔ 플레이어들이 올라가서 누르기 쉽고 멀리서도 돋보이는 시작 버튼을 묘사하기 위함
partRoundStartButton.Position = Vector3.new(0, 0.5, 0)         -- [의미/의도] 버튼 위치를 맵 중앙 원점(0, 0.5, 0) 바닥으로 설정 ➔ 맵 중심부의 통제 타워나 제어 스위치 위치에 맞추기 위함
partRoundStartButton.Anchored = true                           -- [의미/의도] 버튼 파트를 고정시킴 ➔ 버튼 장치가 튕겨 날아가지 않고 단단히 고정되도록 하기 위함
partRoundStartButton.BrickColor = BrickColor.new("Lime green") -- [의미/의도] 파트 색을 라임색(Lime green)으로 설정 ➔ 대결 매치를 안전하게 활성화하여 시작하라는 신호의 녹색을 띠게 하기 위함
partRoundStartButton.Parent = folderFinalBattle12              -- [의미/의도] 버튼 파트를 FinalBattle12 폴더의 자식으로 등록 ➔ 12일차 폴더 내부에서 버튼을 관리하기 위함

local clickdetectorButton = Instance.new("ClickDetector") -- [의미/의도] 새로운 클릭 감지기(ClickDetector) 컴포넌트를 생성함 ➔ 플레이어들이 이 스위치를 클릭해 매치를 원격 제어할 수 있게 연결하기 위함
clickdetectorButton.MaxActivationDistance = 30            -- [의미/의도] 클릭 작동 반경을 30칸으로 설정 ➔ 어느 정도 가까이 다가온 사람만 라운드를 시작할 수 있도록 제약하기 위함
clickdetectorButton.Parent = partRoundStartButton         -- [의미/의도] 클릭 감지기 부모를 RoundStartButton 파트로 설정 ➔ 해당 버튼에 마우스 클릭 리스너 역할을 활성화하기 위함

for index, x in ipairs({-28, 28}) do                                                         -- [의미/의도] -28과 28 두 X좌표 값을 가지고 index 1, 2로 나누어 2번 반복 실행 ➔ 성의 양 측면에 각각 청팀과 홍팀이 부활할 스폰 거점 위치를 다르게 계산하여 소환하기 위함
    local partSpawnPoint = Instance.new("Part")                                              -- [의미/의도] 새로운 파트(Part) 객체를 생성함 ➔ 플레이어 캐릭터들이 매치 시작과 동시에 텔레포트해 배치될 스폰 지점(SpawnPoint)을 만들기 위함
    partSpawnPoint.Name = "SpawnPoint_" .. index                                             -- [의미/의도] 파트 이름을 고유 번호를 붙여 "1_SpawnPoint" 등으로 설정 ➔ 각각의 팀 스폰 패드를 구분하기 위함
    partSpawnPoint.Size = Vector3.new(6, 1, 6)                                               -- [의미/의도] 스폰 패드 크기를 6x1x6으로 널찍하게 설정 ➔ 플레이어가 스폰 시 맵에서 떨어지지 않고 안전하게 올라설 발판 크기로 지정함
    partSpawnPoint.Position = Vector3.new(x, 0.5, -20)                                       -- [의미/의도] X축은 -28(청팀)과 28(홍팀)로 벌리고, 높이 0.5, Z축 -20 전방에 각각 배치 ➔ 청팀과 홍팀이 성문을 사이에 두고 공평하게 대칭 구조의 거리에 서서 대결하도록 배치 좌표식을 구성함
    partSpawnPoint.Anchored = true                                                           -- [의미/의도] 스폰 패드를 고정시킴 ➔ 스폰 타일이 굴러다니거나 밀려나지 않고 고정되어 있게 하기 위함
    partSpawnPoint.BrickColor = BrickColor.new(index == 1 and "Bright blue" or "Bright red") -- [의미/의도] 첫 번째 스폰 패드(청팀)는 파란색(Bright blue), 두 번째(홍팀)는 빨간색(Bright red)으로 설정 ➔ 시각적으로 해당 위치가 누구 팀의 본진 스폰 영역인지 한눈에 알게 하기 위함
    partSpawnPoint.Parent = folderFinalBattle12                                              -- [의미/의도] 스폰 패드 파트를 FinalBattle12 폴더의 자식으로 등록 ➔ 12일차 폴더 내에 함께 묶어 보관하기 위함
end                                                                                          -- [의미/의도] 스폰 패드 생성 반복문(for)의 종료 ➔ 양 팀의 스폰 거점 생성을 마침

print("12일차 준비 완료") -- [의미/의도] 출력창에 완료 메시지를 출력 ➔ 최종 대대전 아레나 셋업이 오류 없이 정상 완료되었음을 알리기 위함
