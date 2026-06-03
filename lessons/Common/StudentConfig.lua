-- [Module] StudentConfig
local module = {}

local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))

-- --------------------------------------------------------------------------------
function module.readConfigNumber(tblConfig, strKey, numberDefault, numberMin, numberMax) -- [의미/의도] 학생 설정 숫자 읽기 함수 정의 ➔ 학생이 바꾼 수치를 서버 기준 범위 안으로 제한하기 위함
	local numberValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 값 조회 ➔ 없는 값은 기본값으로 처리하기 위함
	if type(numberValue) ~= "number" then -- [의미/의도] 숫자가 아니면 ➔ 잘못된 설정으로 서버 로직이 깨지지 않게 하기 위함
		return numberDefault
	end

	if numberMin and numberValue < numberMin then -- [의미/의도] 최솟값보다 작으면 ➔ 너무 약하거나 음수인 값으로 규칙이 망가지지 않게 하기 위함
		return numberMin
	end

	if numberMax and numberValue > numberMax then -- [의미/의도] 최댓값보다 크면 ➔ 학생 설정이 게임 밸런스를 벗어나지 않게 하기 위함
		return numberMax
	end

	return numberValue -- [의미/의도] 검증된 숫자 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigInteger(tblConfig, strKey, intDefault, intMin, intMax) -- [의미/의도] 학생 설정 정수 읽기 함수 정의 ➔ 반복 횟수와 개수 설정을 안전한 정수로 제한하기 위함
	return math.floor(module.readConfigNumber(tblConfig, strKey, intDefault, intMin, intMax)) -- [의미/의도] 숫자 설정을 정수로 보정 ➔ for 반복문에 안전하게 넣기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigString(tblConfig, strKey, strDefault) -- [의미/의도] 학생 설정 문자열 읽기 함수 정의 ➔ 이름/색상 같은 문자열 설정을 기본값과 함께 다루기 위함
	local strValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 문자열 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if type(strValue) ~= "string" or strValue == "" then -- [의미/의도] 문자열이 아니거나 비어 있다면 ➔ 잘못된 설정으로 이름이 깨지는 것을 막기 위함
		return strDefault
	end

	return strValue -- [의미/의도] 검증된 문자열 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigVector3(tblConfig, strKey, vectorDefault, vectorMin, vectorMax) -- [의미/의도] 학생 설정 Vector3 읽기 함수 정의 ➔ 위치와 크기 설정을 안전하게 받기 위함
	local vectorValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 Vector3 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if typeof(vectorValue) ~= "Vector3" then -- [의미/의도] Vector3가 아니라면 ➔ 잘못된 값으로 Part 위치/크기 설정이 실패하지 않게 하기 위함
		vectorValue = vectorDefault
	end

	if vectorMin then -- [의미/의도] 최솟값 제한이 있으면 ➔ 음수 크기나 과도하게 낮은 위치를 방지하기 위함
		vectorValue = Vector3.new(
			math.max(vectorValue.X, vectorMin.X),
			math.max(vectorValue.Y, vectorMin.Y),
			math.max(vectorValue.Z, vectorMin.Z)
		)
	end

	if vectorMax then -- [의미/의도] 최댓값 제한이 있으면 ➔ 너무 큰 파트나 맵 밖 배치로 수업장이 깨지는 것을 막기 위함
		vectorValue = Vector3.new(
			math.min(vectorValue.X, vectorMax.X),
			math.min(vectorValue.Y, vectorMax.Y),
			math.min(vectorValue.Z, vectorMax.Z)
		)
	end

	return vectorValue -- [의미/의도] 검증된 Vector3 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigEnumItem(tblConfig, strKey, enumDefault) -- [의미/의도] 학생 설정 EnumItem 읽기 함수 정의 ➔ Material/Shape 같은 엔진 enum 설정을 안전하게 받기 위함
	local enumValue = tblConfig and tblConfig[strKey] -- [의미/의도] 설정 테이블에서 EnumItem 조회 ➔ 없는 값은 기본값으로 대체하기 위함
	if typeof(enumValue) ~= "EnumItem" then -- [의미/의도] EnumItem이 아니라면 ➔ 잘못된 설정으로 속성 대입이 실패하지 않게 하기 위함
		return enumDefault
	end

	local boolValueEnumTypeOk, enumValueType = pcall(function()
		return enumValue.EnumType
	end)
	local boolDefaultEnumTypeOk, enumDefaultType = pcall(function()
		return enumDefault.EnumType
	end)
	if not boolValueEnumTypeOk or not boolDefaultEnumTypeOk or enumValueType ~= enumDefaultType then -- [의미/의도] 기본값과 다른 enum 종류라면 ➔ Material 자리에 PartType 같은 값이 들어가 오류 나는 것을 막기 위함
		return enumDefault
	end

	return enumValue -- [의미/의도] 검증된 EnumItem 반환 ➔ 서버 시스템에서 안전하게 사용하기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigBrickColor(tblConfig, strKey, strDefaultColor) -- [의미/의도] 학생 설정 BrickColor 읽기 함수 정의 ➔ BrickColor 값 또는 색상 이름을 안전하게 받기 위함
	local valueColor = tblConfig and tblConfig[strKey]
	if typeof(valueColor) == "BrickColor" then
		return valueColor
	end

	local strColorName = module.readConfigString(tblConfig, strKey, strDefaultColor) -- [의미/의도] 색상 이름 읽기 ➔ 비어 있거나 잘못된 문자열을 기본값으로 대체하기 위함
	local boolSuccess, brickColor = pcall(function()
		return BrickColor.new(strColorName)
	end)

	if not boolSuccess then -- [의미/의도] 색상 변환 실패 시 ➔ 색상 오타가 서버 스크립트 오류가 되지 않게 하기 위함
		return BrickColor.new(strDefaultColor)
	end

	return brickColor -- [의미/의도] 검증된 BrickColor 반환 ➔ Part 색상 설정에 사용하기 위함
end


-- --------------------------------------------------------------------------------


function module.readConfigColor3(tblConfig, strKey, colorDefault, tblValidationMessages, strSourceName)
	local valueColor = tblConfig and tblConfig[strKey]
	if valueColor == nil then
		return colorDefault
	end

	if typeof(valueColor) == "Color3" then
		return valueColor
	end

	if typeof(valueColor) == "BrickColor" then
		return valueColor.Color
	end

	if type(valueColor) == "string" then
		local boolSuccess, brickColor = pcall(function()
			return BrickColor.new(valueColor)
		end)
		if boolSuccess then
			return brickColor.Color
		end
	end

	module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Color3.fromRGB(...), BrickColor.new(...), 또는 색상 이름 문자열이어야 해서 기본색으로 보정했습니다.")
	return colorDefault
end


-- --------------------------------------------------------------------------------


function module.createBrickColorFromColor3(colorValue, strDefaultColor)
	local boolSuccess, brickColor = pcall(function()
		return BrickColor.new(colorValue)
	end)
	if boolSuccess then
		return brickColor
	end

	return BrickColor.new(strDefaultColor or "Dark stone grey")
end


-- --------------------------------------------------------------------------------


function module.clampNumber(numberValue, numberMin, numberMax)
	return math.min(math.max(numberValue, numberMin), numberMax)
end


-- --------------------------------------------------------------------------------


function module.addValidationMessage(tblValidationMessages, strSourceName, strMessage)
	if not tblValidationMessages then
		return
	end

	local strSafeSourceName = strSourceName or "Unknown"
	table.insert(tblValidationMessages, strSafeSourceName .. ": " .. strMessage)
end


-- --------------------------------------------------------------------------------


function module.readConfigTable(tblConfig, strKey, tblDefault, tblValidationMessages, strSourceName)
	local valueTable = tblConfig and tblConfig[strKey]
	if valueTable == nil then
		return tblDefault
	end

	if type(valueTable) ~= "table" then
		module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 table이어야 해서 기본 설정을 사용합니다.")
		return tblDefault
	end

	return valueTable
end


-- --------------------------------------------------------------------------------


function module.mergeConfigTables(tblBase, tblOverride)
	local tblMerged = {}
	if type(tblBase) == "table" then
		for keyConfig, valueConfig in pairs(tblBase) do
			tblMerged[keyConfig] = valueConfig
		end
	end

	if type(tblOverride) == "table" then
		for keyConfig, valueConfig in pairs(tblOverride) do
			tblMerged[keyConfig] = valueConfig
		end
	end

	return tblMerged
end


-- --------------------------------------------------------------------------------


function module.isVector3OutsideRange(vectorValue, vectorMin, vectorMax)
	return vectorValue.X < vectorMin.X or vectorValue.Y < vectorMin.Y or vectorValue.Z < vectorMin.Z
		or vectorValue.X > vectorMax.X or vectorValue.Y > vectorMax.Y or vectorValue.Z > vectorMax.Z
end


-- --------------------------------------------------------------------------------


function common.readThrowingStoneMaterial(tblConfig, strKey, enumDefault, tblValidationMessages, strSourceName)
	local valueMaterial = tblConfig and tblConfig[strKey]
	if valueMaterial ~= nil and typeof(valueMaterial) ~= "EnumItem" then
		module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Enum.Material 값을 써야 해서 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	local enumMaterial = module.readConfigEnumItem(tblConfig, strKey, enumDefault)
	if valueMaterial ~= nil and enumMaterial == enumDefault and valueMaterial ~= enumDefault then
		module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Material 종류가 아니라 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	if ThrowingStone.isThrowingStoneMaterialBlocked(enumMaterial) then
		module.addValidationMessage(tblValidationMessages, strSourceName, tostring(enumMaterial) .. "는 돌 Part에 쓰지 않도록 막아서 기본 Slate로 보정했습니다.")
		return enumDefault
	end

	return enumMaterial
end


-- --------------------------------------------------------------------------------


function module.formatStudentRockValidationText(tblValidationMessages)
	if #tblValidationMessages == 0 then
		return "돌멩이 설정 검사 완료\n오류나 보정 항목이 없습니다."
	end

	local tblLines = {"돌멩이 설정 검사 결과"}
	for index, strMessage in ipairs(tblValidationMessages) do
		if index <= 10 then
			table.insert(tblLines, index .. ". " .. strMessage)
		end
	end
	if #tblValidationMessages > 10 then
		table.insert(tblLines, "...외 " .. (#tblValidationMessages - 10) .. "건은 Output 창을 확인하세요.")
	end

	return table.concat(tblLines, "\n")
end


-- --------------------------------------------------------------------------------


function module.showStudentRockValidationBoard(svcWorkspace, tblValidationMessages)
	local ePhysical = EngineNames.eEnginePhysicalType
	local eLogical = EngineNames.eEngineLogicalType
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local partBoard = EngineEnsure.ensureStaticPart(eLogical.STUDENT_ROCK_VALIDATION_BOARD, tblOutpostWorld.fldBattlefield, {
		Size = Vector3.new(36, 12, 1),
		Position = Vector3.new(0, 9, -46),
		CanCollide = false,
		Material = Enum.Material.SmoothPlastic,
		BrickColor = BrickColor.new(#tblValidationMessages == 0 and "Lime green" or "Bright yellow"),
	})

	local guiBoard = EngineEnsure.ensureNamedInstance(ePhysical.SURFACE_GUI, eLogical.STUDENT_ROCK_VALIDATION_GUI, partBoard, {
		Face = Enum.NormalId.Front,
		CanvasSize = Vector2.new(1200, 420),
	})
	local labelBoard = EngineEnsure.ensureNamedInstance(ePhysical.TEXT_LABEL, eLogical.STUDENT_ROCK_VALIDATION_TEXT, guiBoard, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.15,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 24,
		Font = Enum.Font.Gotham,
	})
	labelBoard.Text = module.formatStudentRockValidationText(tblValidationMessages)

	for _, strMessage in ipairs(tblValidationMessages) do
		warn("학생 돌멩이 설정 검사: " .. strMessage)
	end
end


-- --------------------------------------------------------------------------------



module.tblEquipmentSizeRule = {
	ThrowingStone = {
		Default = Vector3.new(1.2, 1.2, 1.2),
		Min = Vector3.new(0.5, 0.5, 0.5),
		Max = Vector3.new(2.6, 2.6, 2.6),
	},
	SiegeStone = {
		Default = Vector3.new(4, 4, 4),
		Min = Vector3.new(1.5, 1.5, 1.5),
		Max = Vector3.new(10, 10, 10),
	},
}

module.tblThrowingStoneMaterialBlockList = {
	Enum.Material.Air,
	Enum.Material.Water,
	Enum.Material.ForceField,
}

function module.readEquipmentSize(tblConfig, strKey, strEquipmentRuleName, tblValidationMessages, strSourceName)
	local tblSizeRule = module.tblEquipmentSizeRule[strEquipmentRuleName]
	local vectorDefault = tblSizeRule.Default
	local vectorMin = tblSizeRule.Min
	local vectorMax = tblSizeRule.Max
	local valueSize = tblConfig and tblConfig[strKey]

	if valueSize ~= nil and typeof(valueSize) ~= "Vector3" then
		module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Vector3.new(...) 값이어야 해서 기본 크기로 보정했습니다.")
		return vectorDefault
	end

	if typeof(valueSize) == "Vector3" and module.isVector3OutsideRange(valueSize, vectorMin, vectorMax) then
		module.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 장비 기준 범위를 벗어나 " .. tostring(vectorMin) .. " ~ " .. tostring(vectorMax) .. " 안으로 보정했습니다.")
	end

	return module.readConfigVector3(tblConfig, strKey, vectorDefault, vectorMin, vectorMax)
end

return module