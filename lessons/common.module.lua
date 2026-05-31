--[[
	Roblox Studio 수업 공통 모듈 (ModuleScript)
	역할: 수업용 헬퍼 함수와 공통 이넘 상수를 제공하는 실제 참조용 공통 스크립트입니다.
	붙여넣기 위치: ReplicatedStorage > ModuleScript 이름 Common (또는 Rojo 동기화)
	사용 방법: local common = require(game:GetService("ReplicatedStorage"):WaitForChild("Common"))

	--------------------------------------------------------------------------------
	[1. 교육용 네이밍 컨벤션 (Naming Convention)]
	어린 학생들과 초보자들이 변수의 타입과 역할을 직관적으로 이해하고 오타를 최소화할 수 있도록
	"타입 소문자 + 대문자 시작" 네이밍 컨벤션을 강제 적용합니다.

	1) 기본 규칙
	* 게임 오브젝트(Instance): 클래스명 전체를 약어와 언더바(_) 없이 100% 소문자로 작성 (예: localscript, remoteevent)
	* 로직 타입 (Luau 기본 데이터 타입): C++ 표준 약어형 소문자(str, int, float, tbl, bool)를 접두사로 사용
	* 고유이름: 타입명 바로 뒤에 붙이며, 첫 글자를 대문자로 시작하여 이어 씀
	* 일차(Day) 표시:
		- 폴더명(디렉토리): 정렬 편의를 위해 숫자를 접두사로 배치 (예: 01_rock_tool)
		- 변수명 / 인스턴스명: 코드 단순화를 위해 숫자를 접미사로 배치 (예: folderArena01, Arena01)

	2) 접두사 레퍼런스 표 (Prefix Reference Table)
	* 게임 오브젝트 타입 (Full Name)
		- service       : game:GetService()로 가져오는 서비스들 (예: serviceWorkspace)
		- folder        : Folder 인스턴스 (예: folderArena01)
		- part          : Part 인스턴스 (예: partPracticeBase)
		- model         : Model 인스턴스 (예: modelPracticeDummy)
		- tool          : Tool 인스턴스 (예: toolPracticeRock)
		- script        : Script (서버측 작동 코드) (예: scriptStudentAnswer01)
		- localscript   : LocalScript (클라이언트측 코드) (예: localscriptInput11)
		- remoteevent   : RemoteEvent (예: remoteeventCastMagic11)
		- clickdetector : ClickDetector (예: clickdetectorButton03)
		- humanoid      : Humanoid (예: humanoidPractice)
		- intvalue      : IntegerValue (예: intvalueWood03)
		- stringvalue   : StringValue (예: stringvalueRoundState12)
		- boolvalue     : BoolValue (예: boolvalueReady12)
	* 로직 기본 타입 (C++ 약어형)
		- bool          : Boolean (참/거짓) (예: boolIsTouched)
		- tbl           : Table (배열/사전) (예: tblDummies)
		- int           : Integer (정수형) (예: intDamage)
		- float         : Float/Double (실수형) (예: floatCooldown)
		- str           : String (문자열) (예: strPlayerName)
	--------------------------------------------------------------------------------
]]

local common = {} -- [의미/의도] 공통 모듈 테이블 정의 ➔ 헬퍼 함수와 상수를 담아 반환하기 위함

-- --------------------------------------------------------------------------------

common.enumServiceName = { -- [의미/의도] 서비스 이름 이넘 정의 ➔ 오타 방지 및 로블록스 서비스 객체 접근 이름을 안전하게 통합 관리하기 위함
	WORKSPACE          = "Workspace",
	PLAYERS            = "Players",
	REPLICATED_STORAGE = "ReplicatedStorage",
	STARTER_PACK       = "StarterPack",
	DEBRIS             = "Debris",
	TEAMS              = "Teams",
}

-- --------------------------------------------------------------------------------

common.enumObjectType = { -- [의미/의도] 클래스 이름 이넘 정의 ➔ 오타 방지 및 생성할 인스턴스 종류를 한곳에서 안전하게 관리하기 위함
	FOLDER       = "Folder",
	TOOL         = "Tool",
	REMOTE_EVENT = "RemoteEvent",
}

-- --------------------------------------------------------------------------------

function common.createOrReplaceInstance(strClassName, strName, instanceParent) -- [의미/의도] 기존 인스턴스 대체 생성 함수 정의 ➔ 중복 오브젝트를 자동 정리하고 새 오브젝트를 만들기 위함
	local instanceOld = instanceParent:FindFirstChild(strName)                    -- [의미/의도] 부모 아래에서 동일한 이름의 기존 객체를 검색함 ➔ 중복 생성을 방지하기 위함
	if instanceOld then                                                           -- [의미/의도] 기존 객체가 존재한다면 ➔ 구버전 찌꺼기가 충돌하지 않도록 처리하기 위함
		instanceOld:Destroy()                                                        -- [의미/의도] 기존 객체를 삭제함 ➔ 맵이 꼬이거나 이전 데이터가 남는 것을 막기 위함
	end                                                                           -- [의미/의도] 기존 객체 정리 조건문 종료 ➔ 다음 생성 단계로 진행하기 위함

	local instanceNew = Instance.new(strClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성함 ➔ 새 구성 요소를 만들기 위함
	instanceNew.Name = strName                     -- [의미/의도] 인스턴스의 이름을 지정함 ➔ 탐색기에서 구분 가능하도록 이름을 설정하기 위함
	instanceNew.Parent = instanceParent            -- [의미/의도] 인스턴스의 부모를 지정함 ➔ 게임 세상의 올바른 위치에 배치하기 위함
	return instanceNew                             -- [의미/의도] 새로 만들어진 인스턴스를 반환함 ➔ 호출한 곳에서 이어서 속성을 조작할 수 있도록 하기 위함
end

-- --------------------------------------------------------------------------------

return common -- [의미/의도] 공통 모듈 반환 ➔ 외부 스크립트에서 require()로 이 모듈을 로드하여 사용하도록 하기 위함
