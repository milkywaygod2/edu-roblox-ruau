-- [Module] EngineEnsure
local EngineEnsure = {}

local CoreEnums = require(script.Parent.CoreEnums)

-- --------------------------------------------------------------------------------
function EngineEnsure.applyInstanceProperties(instanceTarget, tblProperties) -- [의미/의도] 인스턴스 속성 묶음 적용 함수 정의 ➔ Size/Position/Material 같은 반복 속성 대입을 한곳에서 처리하기 위함
	if tblProperties then -- [의미/의도] 속성 테이블이 전달된 경우만 처리 ➔ 설정할 속성이 없는 호출도 안전하게 허용하기 위함
		for strPropertyName, valueProperty in pairs(tblProperties) do -- [의미/의도] 속성 이름과 값을 순회 ➔ 테이블에 담긴 설정을 인스턴스에 일괄 반영하기 위함
			instanceTarget[strPropertyName] = valueProperty -- [의미/의도] 대상 인스턴스 속성에 값을 대입 ➔ Roblox Properties 창에서 수동 설정하던 값을 코드로 적용하기 위함
		end
	end

	return instanceTarget -- [의미/의도] 설정된 인스턴스를 반환 ➔ 호출자가 이어서 추가 조작할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.resetNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 삭제 후 재생성 함수 정의 ➔ 수업장을 깨끗하게 초기화해야 하는 예외 상황에 사용하기 위함
	local instanceOld = instanceParent:FindFirstChild(strName) -- [의미/의도] 부모 아래에서 같은 이름의 기존 객체를 검색 ➔ 재생성 전에 이전 객체를 지우기 위함
	if instanceOld then -- [의미/의도] 기존 객체가 있다면 ➔ 이전 수업 실행 흔적을 제거하기 위함
		instanceOld:Destroy() -- [의미/의도] 기존 객체 삭제 ➔ 오래된 파트나 스크립트가 새 설정과 충돌하지 않게 하기 위함
	end

	local instanceNew = Instance.new(strClassName) -- [의미/의도] 요청한 클래스 타입의 새 인스턴스를 생성 ➔ 수업 오브젝트를 코드로 만들기 위함
	instanceNew.Name = strName -- [의미/의도] 인스턴스 이름을 지정 ➔ 학생 코드와 Explorer에서 같은 이름으로 찾을 수 있게 하기 위함
	EngineEnsure.applyInstanceProperties(instanceNew, tblProperties) -- [의미/의도] 전달된 속성 묶음을 적용 ➔ 생성 직후 필요한 설정을 한 번에 반영하기 위함
	instanceNew.Parent = instanceParent -- [의미/의도] 인스턴스 부모를 지정 ➔ 올바른 폴더/모델/서비스 아래에 배치하기 위함
	return instanceNew -- [의미/의도] 새 인스턴스 반환 ➔ 호출한 setup 코드에서 변수로 보관할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureNamedInstance(strClassName, strName, instanceParent, tblProperties) -- [의미/의도] 이름 있는 인스턴스 보장 함수 정의 ➔ 누적형 전초기지 월드에서 기존 오브젝트를 지우지 않고 재사용하기 위함
	local instanceTarget = instanceParent:FindFirstChild(strName) -- [의미/의도] 부모 아래에서 같은 이름의 객체 검색 ➔ 이미 만든 콘텐츠를 다음 회차에서도 유지하기 위함
	if instanceTarget and not instanceTarget:IsA(strClassName) then -- [의미/의도] 같은 이름이지만 타입이 다르다면 ➔ 잘못된 오브젝트가 학생 코드 참조를 막지 않게 하기 위함
		instanceTarget:Destroy() -- [의미/의도] 잘못된 타입 객체 삭제 ➔ 올바른 타입으로 다시 보장하기 위함
		instanceTarget = nil -- [의미/의도] 재생성 필요 상태로 초기화 ➔ 아래 생성 분기가 실행되게 하기 위함
	end

	if not instanceTarget then -- [의미/의도] 대상 객체가 없으면 ➔ 새로 필요한 수업 오브젝트를 만들기 위함
		instanceTarget = Instance.new(strClassName) -- [의미/의도] 요청한 타입의 인스턴스 생성 ➔ 누락된 오브젝트를 보강하기 위함
		instanceTarget.Name = strName          -- [의미/의도] 이름 지정 ➔ 학생/시스템 코드가 같은 이름으로 찾을 수 있게 하기 위함
		instanceTarget.Parent = instanceParent -- [의미/의도] 부모 지정 ➔ 누적 전초기지 월드의 올바른 계층에 배치하기 위함
	end

	EngineEnsure.applyInstanceProperties(instanceTarget, tblProperties) -- [의미/의도] 속성 보정 ➔ 기존 객체를 유지하되 크기/위치/재질 같은 기준값은 수업 표준으로 맞추기 위함
	return instanceTarget -- [의미/의도] 보장된 인스턴스 반환 ➔ 호출부에서 이어서 사용할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureStaticPart(strName, instanceParent, tblProperties) -- [의미/의도] 고정 Part 보장 함수 정의 ➔ 바닥/버튼/마커가 회차마다 삭제되지 않고 누적 유지되도록 하기 위함
	local tblPartProperties = tblProperties or {} -- [의미/의도] 속성 테이블 기본값 준비 ➔ 호출자가 속성을 생략해도 안전하게 처리하기 위함
	tblPartProperties.Anchored = tblPartProperties.Anchored ~= false -- [의미/의도] 기본 Anchored=true 설정 ➔ 명시적으로 false를 준 경우를 제외하고 setup 오브젝트를 고정하기 위함
	return EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.PART, strName, instanceParent, tblPartProperties) -- [의미/의도] Part 보장 실행 ➔ 기존 Part는 유지하고 필요한 속성만 보정하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureClickDetector(partParent, intMaxActivationDistance) -- [의미/의도] ClickDetector 보장 함수 정의 ➔ 버튼 setup 재실행 시 감지기가 중복 생성되지 않게 하기 위함
	local clickDetector = partParent:FindFirstChildOfClass(CoreEnums.eEnginePhysicalType.CLICK_DETECTOR) -- [의미/의도] 기존 ClickDetector 검색 ➔ 이미 연결된 클릭 컴포넌트를 재사용하기 위함
	if not clickDetector then -- [의미/의도] 클릭 감지기가 없다면 ➔ 버튼 기능을 새로 추가하기 위함
		clickDetector = Instance.new(CoreEnums.eEnginePhysicalType.CLICK_DETECTOR) -- [의미/의도] 새 ClickDetector 생성 ➔ Part를 마우스로 클릭 가능한 버튼으로 만들기 위함
		clickDetector.Parent = partParent -- [의미/의도] 클릭 감지기를 대상 Part 아래에 배치 ➔ 해당 Part 클릭 이벤트가 활성화되게 하기 위함
	end

	clickDetector.MaxActivationDistance = intMaxActivationDistance -- [의미/의도] 클릭 가능 거리 보정 ➔ 회차별 버튼 사용 거리 기준을 유지하기 위함
	return clickDetector -- [의미/의도] 보장된 ClickDetector 반환 ➔ 필요하면 호출부에서 추가 설정할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureToolWithHandle(strToolName, strToolTip, instanceParent, tblHandleProperties) -- [의미/의도] Tool과 Handle 보장 함수 정의 ➔ 학생 스크립트나 커스터마이즈가 붙은 Tool을 삭제하지 않고 규격만 보정하기 위함
	local toolTarget = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.TOOL, strToolName, instanceParent) -- [의미/의도] Tool 보장 ➔ 기존 장비와 내부 Script를 유지하면서 없으면 생성하기 위함
	toolTarget.RequiresHandle = true -- [의미/의도] Handle 필요 설정 ➔ Roblox 장착 규칙에 맞게 손잡이 파트를 사용하기 위함
	toolTarget.ToolTip = strToolTip  -- [의미/의도] Tool 설명 문구 보정 ➔ 플레이어가 장비 기능을 툴팁으로 확인할 수 있게 하기 위함

	local partHandle = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.PART, CoreEnums.eEngineLogicalType.RESERVED_HANDLE, toolTarget, tblHandleProperties) -- [의미/의도] Handle Part 보장 ➔ Tool이 캐릭터 손에 부착될 기준 파트를 유지 또는 생성하기 위함

	return toolTarget, partHandle -- [의미/의도] Tool과 Handle 반환 ➔ 호출부가 필요한 경우 두 객체를 추가 조작할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureHumanoidTarget(strName, instanceParent, tblRootPartProperties, tblHumanoidProperties) -- [의미/의도] Humanoid 목표물 보장 함수 정의 ➔ 전초기지 코어/가드가 회차 재실행 때 삭제되지 않고 기준만 보정되게 하기 위함
	local modelTarget = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.MODEL, strName, instanceParent) -- [의미/의도] 목표물 Model 보장 ➔ 몸통 파트와 Humanoid를 하나의 피해 가능 오브젝트로 묶기 위함
	local partHumanoidRoot = EngineEnsure.ensureStaticPart(CoreEnums.eEngineLogicalType.RESERVED_HUMANOID_ROOT_PART, modelTarget, tblRootPartProperties) -- [의미/의도] HumanoidRootPart 보장 ➔ 데미지 판정과 위치 기준이 되는 중심 파트를 유지 또는 생성하기 위함
	local humTarget = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.HUMANOID, CoreEnums.eEnginePhysicalType.HUMANOID, modelTarget, tblHumanoidProperties) -- [의미/의도] Humanoid 보장 ➔ 목표물이 체력과 피해 처리를 갖게 하기 위함

	return modelTarget, partHumanoidRoot, humTarget -- [의미/의도] 목표물 구성 객체 반환 ➔ 호출부에서 필요 시 세부 조작할 수 있게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.ensureOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 월드 보장 함수 정의 ➔ 어떤 회차부터 실행해도 같은 5v5 목표전 전장 구조가 유지되게 하기 위함
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType

	local fldOutpostBattleWorld = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.OUTPOST_BATTLE_WORLD, svcWorkspace) -- [의미/의도] 전초기지 공방전 루트 보장 ➔ 모든 회차 콘텐츠를 하나의 월드 아래에 누적하기 위함
	local fldBattlefield = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.BATTLEFIELD, fldOutpostBattleWorld) -- [의미/의도] 전투 공간 폴더 보장 ➔ 플레이 가능한 중심 전장을 유지하기 위함
	local fldBuildArea = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.BUILD_AREA, fldOutpostBattleWorld) -- [의미/의도] 건설 영역 폴더 보장 ➔ 방벽과 학생 건축물을 누적하기 위함
	local fldObjectiveArea = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.OBJECTIVE_AREA, fldOutpostBattleWorld) -- [의미/의도] 목표물 영역 폴더 보장 ➔ 코어/가드/표적을 누적하기 위함
	local fldItemSpawnArea = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.ITEM_SPAWN_AREA, fldOutpostBattleWorld) -- [의미/의도] 아이템 스폰 영역 보장 ➔ 파밍 장비를 전장 곳곳에 유지하기 위함
	local fldFortification = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.FORTIFICATION, fldOutpostBattleWorld) -- [의미/의도] 방어 구조물 영역 보장 ➔ 문과 벽을 기지 방어 구조로 관리하기 위함
	local fldSiegeEngine = EngineEnsure.ensureNamedInstance(ePhysical.FOLDER, eLogical.SIEGE_ENGINE, fldOutpostBattleWorld) -- [의미/의도] 중장비 폴더 보장 ➔ 발사 버튼과 기준점을 누적 관리하기 위함
	local partBattlefieldBase = EngineEnsure.ensureStaticPart(eLogical.BATTLEFIELD_BASE, fldBattlefield, { -- [의미/의도] 공통 전장 바닥 보장 ➔ 1회차부터 12회차까지 같은 플레이 공간을 유지하기 위함
		Size = Vector3.new(110, 1, 90),
		Position = Vector3.new(0, -0.5, 0),
		Material = Enum.Material.Grass,
	})

	return {
		fldOutpostBattleWorld = fldOutpostBattleWorld,
		fldBattlefield = fldBattlefield,
		fldBuildArea = fldBuildArea,
		fldObjectiveArea = fldObjectiveArea,
		fldItemSpawnArea = fldItemSpawnArea,
		fldFortification = fldFortification,
		fldSiegeEngine = fldSiegeEngine,
		partBattlefieldBase = partBattlefieldBase,
	}
end


-- --------------------------------------------------------------------------------


function EngineEnsure.waitForOutpostBattleWorld(svcWorkspace) -- [의미/의도] 누적 전초기지 공방전 월드 대기 함수 정의 ➔ 학생/시스템 스크립트가 선생님 setup이 만든 공통 구조를 안전하게 참조하기 위함
	local eLogical = CoreEnums.eEngineLogicalType
	local fldOutpostBattleWorld = svcWorkspace:WaitForChild(eLogical.OUTPOST_BATTLE_WORLD) -- [의미/의도] 전초기지 공방전 루트 대기 ➔ 누적 전장 구조가 준비된 뒤 진행하기 위함
	local fldBattlefield = fldOutpostBattleWorld:WaitForChild(eLogical.BATTLEFIELD) -- [의미/의도] 전투 공간 폴더 대기 ➔ 바닥/엄폐/스폰/라운드 버튼 참조를 안전하게 하기 위함
	local partBattlefieldBase = fldBattlefield:WaitForChild(eLogical.BATTLEFIELD_BASE) -- [의미/의도] 공통 바닥 Part 대기 ➔ 어떤 회차에서도 같은 플레이 바닥이 준비된 뒤 진행하기 위함
	local fldBuildArea = fldOutpostBattleWorld:WaitForChild(eLogical.BUILD_AREA) -- [의미/의도] 건설 영역 폴더 대기 ➔ 방벽 버튼과 생성 위치를 안전하게 찾기 위함
	local fldObjectiveArea = fldOutpostBattleWorld:WaitForChild(eLogical.OBJECTIVE_AREA) -- [의미/의도] 목표물 영역 폴더 대기 ➔ 코어/가드/표적 참조를 안전하게 하기 위함
	local fldItemSpawnArea = fldOutpostBattleWorld:WaitForChild(eLogical.ITEM_SPAWN_AREA) -- [의미/의도] 아이템 스폰 영역 대기 ➔ 파밍 장비 배치를 안전하게 하기 위함
	local fldFortification = fldOutpostBattleWorld:WaitForChild(eLogical.FORTIFICATION) -- [의미/의도] 방어 구조물 영역 대기 ➔ 문/벽 참조를 안전하게 하기 위함
	local fldSiegeEngine = fldOutpostBattleWorld:WaitForChild(eLogical.SIEGE_ENGINE) -- [의미/의도] 중장비 폴더 대기 ➔ 발사 버튼과 기준점 참조를 안전하게 하기 위함

	return {
		fldOutpostBattleWorld = fldOutpostBattleWorld,
		fldBattlefield = fldBattlefield,
		partBattlefieldBase = partBattlefieldBase,
		fldBuildArea = fldBuildArea,
		fldObjectiveArea = fldObjectiveArea,
		fldItemSpawnArea = fldItemSpawnArea,
		fldFortification = fldFortification,
		fldSiegeEngine = fldSiegeEngine,
	}
end


-- --------------------------------------------------------------------------------


function EngineEnsure.markRuntimeInstalled(instanceTarget, strAttributeKey) -- [의미/의도] 런타임 시스템 중복 설치 방지 함수 정의 ➔ 같은 버튼/Tool에 이벤트가 여러 번 연결되는 것을 막기 위함
	if instanceTarget:GetAttribute(strAttributeKey) then -- [의미/의도] 이미 설치 표시가 있으면 ➔ 중복 이벤트 연결을 차단하기 위함
		return false
	end

	instanceTarget:SetAttribute(strAttributeKey, true) -- [의미/의도] 설치 완료 표시 저장 ➔ 이후 같은 시스템이 다시 연결되지 않게 하기 위함
	return true -- [의미/의도] 이번 호출에서 설치 가능함을 반환 ➔ 호출부가 이벤트를 연결하게 하기 위함
end


-- --------------------------------------------------------------------------------


function EngineEnsure.removeLuaSourceDescendants(instanceTarget)
	for _, instanceDescendant in ipairs(instanceTarget:GetDescendants()) do
		if instanceDescendant:IsA("LuaSourceContainer") then
			instanceDescendant:Destroy()
		end
	end
end

-- --------------------------------------------------------------------------------

return EngineEnsure