-- [Module] Appearance
local Appearance = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)

local ROCK_LOOK_PRELOAD_WAIT_SECONDS = 8
local ROCK_LOOK_PRELOAD_WAIT_STEP_SECONDS = 0.1

local function get_rock_look_failed_assets()
	local tblFailedAssets = _G.RockLookFailedAssets or {}
	_G.RockLookFailedAssets = tblFailedAssets
	return tblFailedAssets
end


-- --------------------------------------------------------------------------------


local function mark_rock_look_asset_failed(strLook, strError)
	get_rock_look_failed_assets()[strLook] = strError or true
end


-- --------------------------------------------------------------------------------


local function clear_rock_look_asset_failure(strLook)
	get_rock_look_failed_assets()[strLook] = nil
end


-- --------------------------------------------------------------------------------


local function read_rock_look_asset_failure(strLook)
	return get_rock_look_failed_assets()[strLook]
end


-- --------------------------------------------------------------------------------


function Appearance.applyToolHandleStudentStyle(toolTarget, tblConfig) -- [의미/의도] Tool Handle 학생 스타일 적용 함수 정의 ➔ 학생이 외형만 바꿀 수 있게 크기/재질/색을 제한적으로 반영하기 위함
	local tblHandleConfig = tblConfig and tblConfig.Handle or {} -- [의미/의도] Handle 설정 테이블 준비 ➔ 학생이 생략한 값은 기존 기본값을 쓰기 위함
	local partHandle = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.PART, CoreEnums.eEngineLogicalType.RESERVED_HANDLE, toolTarget)
	partHandle.Size = StudentConfig.readConfigVector3(tblHandleConfig, "Size", partHandle.Size, Vector3.new(0.2, 0.2, 0.2), Vector3.new(20, 20, 20))
	partHandle.Material = StudentConfig.readConfigEnumItem(tblHandleConfig, "Material", partHandle.Material)
	local brickHandleColor = StudentConfig.readConfigBrickColor(tblHandleConfig, "BrickColor", partHandle.BrickColor.Name)
	local colorHandle = brickHandleColor.Color
	if tblHandleConfig.Color ~= nil then
		colorHandle = StudentConfig.readConfigColor3(tblHandleConfig, "Color", colorHandle)
		brickHandleColor = StudentConfig.createBrickColorFromColor3(colorHandle, partHandle.BrickColor.Name)
	end

	partHandle.BrickColor = brickHandleColor
	partHandle.Color = colorHandle
	partHandle.Shape = StudentConfig.readConfigEnumItem(tblHandleConfig, "Shape", partHandle.Shape)
	return partHandle
end


-- --------------------------------------------------------------------------------


local function normalize_rock_look_key(valueLook)
	if type(valueLook) == "number" then
		return tostring(valueLook)
	end

	if type(valueLook) == "string" and valueLook ~= "" then
		return valueLook
	end

	return nil
end


-- --------------------------------------------------------------------------------


local function find_rock_looks_folder()
	local eLogical = CoreEnums.eEngineLogicalType
	local svcReplicatedStorage = game:GetService(CoreEnums.eEngineServiceSingleton.REPLICATED_STORAGE)
	local fldOutpostAssets = svcReplicatedStorage:FindFirstChild(eLogical.OUTPOST_ASSETS)
	return fldOutpostAssets and fldOutpostAssets:FindFirstChild(eLogical.ROCK_LOOKS)
end


-- --------------------------------------------------------------------------------


local function store_loaded_rock_look_asset(fldRockLooks, strLook, loadedModel)
	local instanceExisting = fldRockLooks:FindFirstChild(strLook)
	if instanceExisting then
		loadedModel:Destroy()
		return instanceExisting
	end

	local instanceRealAsset = loadedModel:GetChildren()[1]
	if instanceRealAsset then
		instanceRealAsset.Name = strLook
		instanceRealAsset.Parent = fldRockLooks
		loadedModel:Destroy()
		return instanceRealAsset
	end

	loadedModel.Name = strLook
	loadedModel.Parent = fldRockLooks
	return loadedModel
end


-- --------------------------------------------------------------------------------


local function download_rock_look_template(fldRockLooks, strLook, assetId)
	local boolSuccess, loadedModel = pcall(function()
		return game:GetService("InsertService"):LoadAsset(assetId)
	end)

	if not boolSuccess or not loadedModel then
		return nil, tostring(loadedModel)
	end

	local instanceTemplate = store_loaded_rock_look_asset(fldRockLooks, strLook, loadedModel)
	clear_rock_look_asset_failure(strLook)
	return instanceTemplate, nil
end


-- --------------------------------------------------------------------------------


function Appearance.loadRockLookTemplateNow(valueLook)
	local strLook = normalize_rock_look_key(valueLook)
	if not strLook then return nil, "empty" end

	local fldRockLooks = find_rock_looks_folder()
	if not fldRockLooks then
		return nil, "missing RockLooks folder"
	end

	local instanceExisting = fldRockLooks:FindFirstChild(strLook)
	if instanceExisting then
		return instanceExisting, nil
	end

	local assetId = tonumber(strLook)
	local svcRunService = game:GetService(CoreEnums.eEngineServiceSingleton.RUN_SERVICE)
	if not assetId or not svcRunService:IsServer() then
		return nil, "not a server-loadable asset id"
	end

	local tblDownloadingAssets = _G.DownloadingAssets or {}
	_G.DownloadingAssets = tblDownloadingAssets
	if tblDownloadingAssets[strLook] then
		local numberStartTime = os.clock()
		while os.clock() - numberStartTime < ROCK_LOOK_PRELOAD_WAIT_SECONDS do
			task.wait(ROCK_LOOK_PRELOAD_WAIT_STEP_SECONDS)
			instanceExisting = fldRockLooks:FindFirstChild(strLook)
			if instanceExisting then
				return instanceExisting, nil
			end
		end

		return nil, "asset download already in progress"
	end

	tblDownloadingAssets[strLook] = true
	local boolDownloadSuccess, instanceTemplate, strError = pcall(download_rock_look_template, fldRockLooks, strLook, assetId)
	tblDownloadingAssets[strLook] = nil
	if not boolDownloadSuccess then
		mark_rock_look_asset_failed(strLook, instanceTemplate)
		return nil, tostring(instanceTemplate)
	end

	if not instanceTemplate then
		mark_rock_look_asset_failed(strLook, strError)
	end
	return instanceTemplate, strError
end


-- --------------------------------------------------------------------------------


function Appearance.preloadRockLookTemplates(tblLookShapes, tblValidationMessages, strSourceName)
	if type(tblLookShapes) ~= "table" then return 0 end

	local intLoadedCount = 0
	for _, valueLook in ipairs(tblLookShapes) do
		local strLook = normalize_rock_look_key(valueLook)
		if strLook then
			local instanceTemplate, strError = Appearance.loadRockLookTemplateNow(strLook)
			if instanceTemplate then
				intLoadedCount += 1
			elseif strError ~= "empty" and strError ~= "not a server-loadable asset id" then
				StudentConfig.addValidationMessage(
					tblValidationMessages,
					strSourceName or "RockLooks",
					"LookShape '" .. strLook .. "' 선다운로드에 실패해 기본 모양으로 시작할 수 있습니다. " .. tostring(strError)
				)
			end
		end
	end

	return intLoadedCount
end


-- --------------------------------------------------------------------------------


function Appearance.findRockLookTemplate(strLook)
	strLook = normalize_rock_look_key(strLook)
	if not strLook then
		return nil
	end

	local fldRockLooks = find_rock_looks_folder()
	if not fldRockLooks then
		return nil
	end

	-- 1. 캐시된 기존 템플릿 검색 (이름 기반 또는 이미 로드된 에셋 ID 기반)
	local instanceExisting = fldRockLooks:FindFirstChild(strLook)
	if instanceExisting then
		return instanceExisting
	end

	-- 2. 서버 환경일 경우, 입력값이 숫자 ID라면 InsertService로 비동기 다운로드 시도
	local assetId = tonumber(strLook)
	local RunService = game:GetService("RunService")
	if assetId and RunService:IsServer() then
		local tblDownloadingAssets = _G.DownloadingAssets or {}
		_G.DownloadingAssets = tblDownloadingAssets

		-- 이미 다운로드 진행 중인 에셋이라면 중복 요청 방지
		if tblDownloadingAssets[strLook] then
			return nil
		end

		tblDownloadingAssets[strLook] = true

		task.spawn(function()
			local success, instanceTemplate, strError = pcall(function()
				local template, errorMessage = download_rock_look_template(fldRockLooks, strLook, assetId)
				return template, errorMessage
			end)
			tblDownloadingAssets[strLook] = nil

			if not success or not instanceTemplate then
				local strFailure = success and strError or instanceTemplate
				local boolAlreadyWarned = read_rock_look_asset_failure(strLook) ~= nil
				mark_rock_look_asset_failed(strLook, strFailure)
				if not boolAlreadyWarned then
					warn("[Appearance] 에셋 ID '" .. strLook .. "' 동적 다운로드 실패: " .. tostring(strFailure))
				end
			end
		end)
	end

	return nil
end


-- --------------------------------------------------------------------------------


function Appearance.calculateFitScaleWithinBounds(vectorSourceSize, vectorTargetSize)
	if vectorSourceSize.X <= 0 or vectorSourceSize.Y <= 0 or vectorSourceSize.Z <= 0 then
		return 1
	end

	return math.min(
		vectorTargetSize.X / vectorSourceSize.X,
		vectorTargetSize.Y / vectorSourceSize.Y,
		vectorTargetSize.Z / vectorSourceSize.Z
	)
end


-- --------------------------------------------------------------------------------


function Appearance.fitBasePartWithinBounds(partVisual, vectorTargetSize)
	local numberScale = Appearance.calculateFitScaleWithinBounds(partVisual.Size, vectorTargetSize)
	if numberScale <= 0 then
		return false
	end

	partVisual.Size = partVisual.Size * numberScale
	return true
end


-- --------------------------------------------------------------------------------


function Appearance.fitModelWithinBounds(modelVisual, vectorTargetSize)
	local _, vectorBoundsSize = modelVisual:GetBoundingBox()
	local numberScale = Appearance.calculateFitScaleWithinBounds(vectorBoundsSize, vectorTargetSize)
	if numberScale <= 0 then
		return false
	end

	local boolSuccess = pcall(function()
		modelVisual:ScaleTo(modelVisual:GetScale() * numberScale)
	end)
	if not boolSuccess then
		return false
	end

	return true
end


-- --------------------------------------------------------------------------------


function Appearance.findSingleMeshPart(instanceTemplate)
	if not instanceTemplate then
		return nil
	end

	if instanceTemplate:IsA(CoreEnums.eEnginePhysicalType.MESH_PART) then
		return instanceTemplate
	end

	if not instanceTemplate:IsA(CoreEnums.eEnginePhysicalType.MODEL) then
		return nil
	end

	local meshPartResult = nil
	local intBasePartCount = 0
	for _, instanceDescendant in ipairs(instanceTemplate:GetDescendants()) do
		if instanceDescendant:IsA(CoreEnums.eEnginePhysicalType.BASE_PART) then
			intBasePartCount += 1
			if not instanceDescendant:IsA(CoreEnums.eEnginePhysicalType.MESH_PART) then
				return nil
			end
			meshPartResult = instanceDescendant
		end
	end

	if intBasePartCount == 1 then
		return meshPartResult
	end

	return nil
end


-- --------------------------------------------------------------------------------


function Appearance.inspectRockLookTemplate(strLookShape, vectorTargetSize)
	local instanceTemplate = Appearance.findRockLookTemplate(strLookShape)
	if not instanceTemplate then
		return nil
	end

	local instanceLook = instanceTemplate:Clone()
	EngineEnsure.removeLuaSourceDescendants(instanceLook)

	local tblLookInfo = {
		IsSingleMeshPart = Appearance.findSingleMeshPart(instanceLook) ~= nil,
		BoundsSize = nil,
	}

	if typeof(vectorTargetSize) ~= "Vector3" then
		instanceLook:Destroy()
		return tblLookInfo
	end

	if instanceLook:IsA("SpecialMesh") then
		instanceLook:Destroy()
		return tblLookInfo
	end

	if instanceLook:IsA(CoreEnums.eEnginePhysicalType.BASE_PART) then
		if Appearance.fitBasePartWithinBounds(instanceLook, vectorTargetSize) then
			tblLookInfo.BoundsSize = instanceLook.Size
		end
	elseif instanceLook:IsA(CoreEnums.eEnginePhysicalType.MODEL) then
		if Appearance.fitModelWithinBounds(instanceLook, vectorTargetSize) then
			local _, vectorBoundsSize = instanceLook:GetBoundingBox()
			tblLookInfo.BoundsSize = vectorBoundsSize
		end
	end

	instanceLook:Destroy()
	return tblLookInfo
end


-- --------------------------------------------------------------------------------


function Appearance.pivotModelBoundsToTarget(modelVisual, cframeTarget)
	local cframePivot = modelVisual:GetPivot()
	local cframeBounds = modelVisual:GetBoundingBox()
	local cframeBoundsFromPivot = cframePivot:ToObjectSpace(cframeBounds)
	modelVisual:PivotTo(cframeTarget * cframeBoundsFromPivot:Inverse())
end


-- --------------------------------------------------------------------------------


function Appearance.prepareRockLookPart(partVisual, partTarget, boolKeepCurrentCFrame)
	partVisual.Anchored = false
	partVisual.CanCollide = false
	partVisual.CanTouch = false
	partVisual.CanQuery = false
	partVisual.Massless = true
	if not boolKeepCurrentCFrame then
		partVisual.CFrame = partTarget.CFrame
	end

	local weldVisual = Instance.new(CoreEnums.eEnginePhysicalType.WELD_CONSTRAINT)
	weldVisual.Part0 = partTarget
	weldVisual.Part1 = partVisual
	weldVisual.Parent = partVisual
end


-- --------------------------------------------------------------------------------


function Appearance.clearRockLook(partTarget)
	local instanceOldLook = partTarget:FindFirstChild(CoreEnums.eEngineLogicalType.THROWING_STONE_LOOK)
	if instanceOldLook then
		instanceOldLook:Destroy()
	end
end


-- --------------------------------------------------------------------------------


function Appearance.applyRockLook(partTarget, strLookShape)
	Appearance.clearRockLook(partTarget)

	-- partTarget 자체의 표면을 Smooth로 강제하여 자동 웰딩 현상을 원천 방어합니다.
	partTarget.TopSurface = Enum.SurfaceType.Smooth
	partTarget.BottomSurface = Enum.SurfaceType.Smooth
	partTarget.LeftSurface = Enum.SurfaceType.Smooth
	partTarget.RightSurface = Enum.SurfaceType.Smooth
	partTarget.FrontSurface = Enum.SurfaceType.Smooth
	partTarget.BackSurface = Enum.SurfaceType.Smooth

	local instanceTemplate = Appearance.findRockLookTemplate(strLookShape)
	if not instanceTemplate then
		partTarget.Transparency = 0
		
		-- [비동기 다운로드 완료 후 실시간 겉모습 변환 처리]
		-- 처음 스폰 및 집었을 때 구체로 머물러있다가 다운로드가 완료되는 순간 즉시 상자(에셋) 모양으로 자동 갱신합니다.
		if type(strLookShape) == "number" then
			strLookShape = tostring(strLookShape)
		end
		if type(strLookShape) == "string" and strLookShape ~= "" then
			task.spawn(function()
				local svcReplicatedStorage = game:GetService(CoreEnums.eEngineServiceSingleton.REPLICATED_STORAGE)
				local eLogical = CoreEnums.eEngineLogicalType
				local fldOutpostAssets = svcReplicatedStorage:WaitForChild(eLogical.OUTPOST_ASSETS, 5)
				local fldRockLooks = fldOutpostAssets and fldOutpostAssets:WaitForChild(eLogical.ROCK_LOOKS, 5)
				if fldRockLooks then
					local template = fldRockLooks:WaitForChild(strLookShape, 8) -- 최대 8초 대기
					-- partTarget이 유효하고 아직 월드 상에 살아있는 경우에만 외형을 실시간으로 갱신
					if template and partTarget and partTarget.Parent then
						Appearance.applyRockLook(partTarget, strLookShape)
					end
				end
			end)
		end
		return
	end

	local instanceLook = instanceTemplate:Clone()
	instanceLook.Name = CoreEnums.eEngineLogicalType.THROWING_STONE_LOOK
	EngineEnsure.removeLuaSourceDescendants(instanceLook)

	-- 에셋 팩 모델 내에 묻어있던 구식 물리 조인트(Weld, Snap 등)로 인해 벽/지형에 충돌 시 엉뚱하게 달라붙어 멈춰 서는 버그를 완전히 차단합니다.
	-- 또한 모든 파트의 표면을 Smooth로 변경하여 Roblox 물리 엔진이 닿았을 때 자동으로 조인트를 맺는 현상을 막아줍니다.
	for _, descendant in ipairs(instanceLook:GetDescendants()) do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		end
		if descendant:IsA("BasePart") then
			descendant.TopSurface = Enum.SurfaceType.Smooth
			descendant.BottomSurface = Enum.SurfaceType.Smooth
			descendant.LeftSurface = Enum.SurfaceType.Smooth
			descendant.RightSurface = Enum.SurfaceType.Smooth
			descendant.FrontSurface = Enum.SurfaceType.Smooth
			descendant.BackSurface = Enum.SurfaceType.Smooth
		end
	end

	instanceLook.Parent = partTarget

	if instanceLook:IsA("SpecialMesh") then
		partTarget.Transparency = 0
		return
	end

	partTarget.Transparency = 1

	if instanceLook:IsA(CoreEnums.eEnginePhysicalType.BASE_PART) then
		if not Appearance.fitBasePartWithinBounds(instanceLook, partTarget.Size) then
			instanceLook:Destroy()
			partTarget.Transparency = 0
			return
		end
		Appearance.prepareRockLookPart(instanceLook, partTarget)
		return
	end

	if instanceLook:IsA(CoreEnums.eEnginePhysicalType.MODEL) then
		if not Appearance.fitModelWithinBounds(instanceLook, partTarget.Size) then
			instanceLook:Destroy()
			partTarget.Transparency = 0
			return
		end
		Appearance.pivotModelBoundsToTarget(instanceLook, partTarget.CFrame)
		for _, instanceDescendant in ipairs(instanceLook:GetDescendants()) do
			if instanceDescendant:IsA(CoreEnums.eEnginePhysicalType.BASE_PART) then
				Appearance.prepareRockLookPart(instanceDescendant, partTarget, true)
			end
		end
		return
	end

	instanceLook:Destroy()
	partTarget.Transparency = 0
end

-- --------------------------------------------------------------------------------

return Appearance
