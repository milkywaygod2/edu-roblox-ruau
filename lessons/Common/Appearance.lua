-- [Module] Appearance
local Appearance = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function Appearance.applyToolHandleStudentStyle(toolTarget, tblConfig) -- [의미/의도] Tool Handle 학생 스타일 적용 함수 정의 ➔ 학생이 외형만 바꿀 수 있게 크기/재질/색을 제한적으로 반영하기 위함
	local tblHandleConfig = tblConfig and tblConfig.Handle or {} -- [의미/의도] Handle 설정 테이블 준비 ➔ 학생이 생략한 값은 기존 기본값을 쓰기 위함
	local partHandle = EngineEnsure.ensureNamedInstance(CoreEnums.eEnginePhysicalType.PART, CoreEnums.eEngineLogicalType.RESERVED_HANDLE, toolTarget)
	partHandle.Size = StudentConfig.readConfigVector3(tblHandleConfig, "Size", partHandle.Size, Vector3.new(0.2, 0.2, 0.2), Vector3.new(8, 8, 8))
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


function Appearance.findRockLookTemplate(strLook)
	if type(strLook) ~= "string" or strLook == "" then
		return nil
	end

	local eLogical = CoreEnums.eEngineLogicalType
	local svcReplicatedStorage = game:GetService(CoreEnums.eEngineServiceSingleton.REPLICATED_STORAGE)
	local fldOutpostAssets = svcReplicatedStorage:FindFirstChild(eLogical.OUTPOST_ASSETS)
	local fldRockLooks = fldOutpostAssets and fldOutpostAssets:FindFirstChild(eLogical.ROCK_LOOKS)
	if not fldRockLooks then
		return nil
	end

	return fldRockLooks:FindFirstChild(strLook)
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

	local instanceTemplate = Appearance.findRockLookTemplate(strLookShape)
	if not instanceTemplate then
		partTarget.Transparency = 0
		return
	end

	local instanceLook = instanceTemplate:Clone()
	instanceLook.Name = CoreEnums.eEngineLogicalType.THROWING_STONE_LOOK
	EngineEnsure.removeLuaSourceDescendants(instanceLook)
	instanceLook.Parent = partTarget
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