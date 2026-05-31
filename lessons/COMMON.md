# Roblox Luau 수업 공통 참조 가이드 (COMMON)

이 문서는 교육용 Roblox Luau 프로젝트의 코딩 스타일 가이드, 네이밍 컨벤션, 공통 헬퍼 함수 및 공통 이넘(Enum) 상수를 정리한 마스터 참조 문서입니다.

---

## 1. 교육용 네이밍 컨벤션 (Naming Convention)

어린 학생들과 초보자들이 변수의 타입과 역할을 직관적으로 이해하고 오타를 최소화할 수 있도록 **타입 소문자 + 대문자 시작** 네이밍 컨벤션을 강제 적용합니다.

### 1) 기본 규칙
*   **게임 오브젝트(Instance)**: 로블록스의 클래스명 전체를 **약어와 언더바(_) 없이 100% 소문자**로 붙여 씁니다. (`localscript`, `remoteevent` 등 하나의 단어로 취급)
*   **로직 타입 (Luau 기본 데이터 타입)**: C++ 표준에 맞춘 약어형 소문자(`str`, `int`, `float`, `tbl`, `bool`)를 접두사로 사용합니다.
*   **고유이름**: 타입명 바로 뒤에 붙이며, **첫 글자를 대문자**로 시작하여 이어 씁니다.
*   **일차(Day) 표시**: 
    *   **폴더명(디렉토리)**: 정렬(Sorting) 편의를 위해 숫자를 **접두사**로 배치합니다. (예: `01_rock_tool`, `12_final_battle`)
    *   **변수명 / 로블록스 인스턴스명**: 코드 단순화를 위해 숫자를 **접미사**로 배치합니다. (예: `folderArena01`, `Arena01`)

### 2) 접두사 레퍼런스 표 (Prefix Reference Table)

| 접두사 (소문자 100%) | 대상 개념 (Roblox Class / Type) | 예시 변수명 | 설명 |
| :--- | :--- | :--- | :--- |
| **게임 오브젝트 타입 (Full Name)** | | | |
| `service` | game:GetService()로 가져오는 서비스들 | `serviceWorkspace`, `servicePlayers` | 로블록스 핵심 서비스 객체 |
| `folder` | Folder 인스턴스 | `folderArena01`, `folderDummies04` | 오브젝트를 그룹화하는 폴더 |
| `part` | Part (블록, 구체, 실린더 등 물리 파트) | `partPracticeBase`, `partWall03` | 게임 내 배치된 물리 단일 파트 |
| `model` | Model 인스턴스 | `modelPracticeDummy`, `modelSiege10` | 여러 파트가 조립된 모델(캐릭터 등) |
| `tool` | Tool 인스턴스 | `toolPracticeRock`, `toolSword04` | 플레이어가 장착할 수 있는 도구/무기 |
| `script` | Script (서버측 작동 코드) | `scriptStudentAnswer01` | 서버에서 돌아가는 일반 스크립트 |
| `localscript` | LocalScript (클라이언트측 코드) | `localscriptInput11` | 플레이어 기기에서 작동하는 로컬 스크립트 |
| `remoteevent` | RemoteEvent | `remoteeventCastMagic11` | 서버-클라이언트 간 통신 이벤트 |
| `clickdetector`| ClickDetector | `clickdetectorButton03` | 클릭 입력을 감지하는 객체 |
| `humanoid` | Humanoid | `humanoidPractice`, `humanoidBoss12` | 캐릭터의 생명력, 움직임을 관리하는 객체 |
| `intvalue` | IntegerValue | `intvalueWood03` | 정수형 데이터 보관 객체 |
| `stringvalue` | StringValue | `stringvalueRoundState12` | 문자열형 데이터 보관 객체 |
| `boolvalue` | BoolValue | `boolvalueReady12` | 참/거짓형 데이터 보관 객체 |
| **로직 기본 타입 (C++ 약어형)** | | | |
| `bool` | Boolean (참/거짓) | `boolIsTouched`, `boolIsCooldown` | 스크립트 내 참/거짓 논리 변수 |
| `tbl` | Table (배열/사전) | `tblDummies`, `tblSpawnPoints` | 여러 데이터를 담는 배열 또는 테이블 변수 |
| `int` | Integer (정수형) | `intDamage`, `intCount` | 소수점이 없는 정수형 일반 변수 |
| `float` | Float / Double (실수형) | `floatCooldown`, `floatSpeed` | 소수점을 포함하는 실수형 일반 변수 |
| `str` | String (문자열) | `strPlayerName`, `strErrorMessage` | 문자열형 일반 변수 |

---

## 2. 공통 클래스 이넘 (enumClassName)

클래스 이름을 직접 하드코딩된 문자열 리터럴로 사용할 시 생길 수 있는 오타 방지 및 중앙 통제를 위해 공통 이넘 상수를 정의합니다.
C++ 표준 및 설계 원칙에 따라 **이넘의 원자(Key)는 모두 대문자(스네이크케이스)**로 작성합니다.

```lua
local enumClassName = { -- [의미/의도] 클래스 이름 이넘 정의 ➔ 오타 방지 및 생성할 인스턴스 종류를 한곳에서 안전하게 관리하기 위함
	FOLDER       = "Folder",
	TOOL         = "Tool",
	REMOTE_EVENT = "RemoteEvent",
}
```

* **호출 예시**: `enumClassName.FOLDER`, `enumClassName.TOOL`, `enumClassName.REMOTE_EVENT`

---

## 3. 공통 셋업 헬퍼 함수 (createOrReplaceInstance)

선생님 준비 코드(`teacher_setup.server.lua`)에서 빈번히 사용되는 **"기존 자식 오브젝트가 있으면 파괴(Destroy)하고, 새 인스턴스를 지정된 이름과 부모로 안전하게 덮어쓰기 생성"**하는 공통 로직을 함수화하여 사용합니다.

```lua
local function createOrReplaceInstance(strClassName, strName, instanceParent) -- [의미/의도] 기존 인스턴스 대체 생성 함수 정의 ➔ 중복 오브젝트를 자동 정리하고 새 오브젝트를 만들기 위함
	local instanceOld = instanceParent:FindFirstChild(strName)                     -- [의미/의도] 부모 아래에서 동일한 이름의 기존 객체를 검색함 ➔ 중복 생성을 방지하기 위함
	if instanceOld then                                                            -- [의미/의도] 기존 객체가 존재한다면 ➔ 구버전 찌꺼기가 충돌하지 않도록 처리하기 위함
		instanceOld:Destroy()                                                         -- [의미/의도] 기존 객체를 삭제함 ➔ 맵이 꼬이거나 이전 데이터가 남는 것을 막기 위함
	end                                                                            -- [의미/의도] 기존 객체 정리 조건문 종료 ➔ 다음 생성 단계로 진행하기 위함

	local instanceNew = Instance.new(strClassName)                                 -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성함 ➔ 새 구성 요소를 만들기 위함
	instanceNew.Name = strName                                                     -- [의미/의도] 인스턴스의 이름을 지정함 ➔ 탐색기에서 구분 가능하도록 이름을 설정하기 위함
	instanceNew.Parent = instanceParent                                            -- [의미/의도] 인스턴스의 부모를 지정함 ➔ 게임 세상의 올바른 위치에 배치하기 위함
	return instanceNew                                                             -- [의미/의도] 새로 만들어진 인스턴스를 반환함 ➔ 호출한 곳에서 이어서 속성을 조작할 수 있도록 하기 위함
end
```

### 💡 활용 예시
```lua
-- 1일차 Arena 폴더 생성 시
local folderArena01 = createOrReplaceInstance(enumClassName.FOLDER, "Arena01", serviceWorkspace)
```
