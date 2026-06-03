-- [Module] Effect
local module = {}

local EngineEnsure = require(script.Parent:WaitForChild("EngineEnsure"))
local EngineNames = require(script.Parent:WaitForChild("EngineNames"))
local StudentConfig = require(script.Parent:WaitForChild("StudentConfig"))
local ThrowingStone = require(script.Parent:WaitForChild("ThrowingStone"))

-- --------------------------------------------------------------------------------
module.eParticleTexture = {
	EXPLOSION01_CORE_MAIN = "rbxasset://textures/particles/explosion01_core_main.dds",
	EXPLOSION01_IMPLOSION_MAIN = "rbxasset://textures/particles/explosion01_implosion_main.dds",
	EXPLOSION01_SHOCKWAVE_MAIN = "rbxasset://textures/particles/explosion01_shockwave_main.dds",
	EXPLOSION01_SMOKE_MAIN = "rbxasset://textures/particles/explosion01_smoke_main.dds",
	FIRE_MAIN = "rbxasset://textures/particles/fire_main.dds",
	FIRE_SPARKS_MAIN = "rbxasset://textures/particles/fire_sparks_main.dds",
	FORCEFIELD_GLOW_MAIN = "rbxasset://textures/particles/forcefield_glow_main.dds",
	FORCEFIELD_VORTEX_MAIN = "rbxasset://textures/particles/forcefield_vortex_main.dds",
	SMOKE_MAIN = "rbxasset://textures/particles/smoke_main.dds",
	SPARKLES_MAIN = "rbxasset://textures/particles/sparkles_main.dds",
	SQUARE_PARTICLE = "rbxasset://textures/particles/SquareParticle.png",

	SPARKLES = "rbxasset://textures/particles/sparkles_main.dds",
	FIRE = "rbxasset://textures/particles/fire_main.dds",
	SMOKE = "rbxasset://textures/particles/smoke_main.dds",
}


-- --------------------------------------------------------------------------------


function module.readEffectNumber(tblEffectConfig, strKey, numberDefault, numberMin, numberMax, tblValidationMessages, strSourceName)
	local numberRaw = tblEffectConfig and tblEffectConfig[strKey]
	if numberRaw ~= nil and type(numberRaw) ~= "number" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 숫자여야 해서 기본값으로 보정했습니다.")
		return numberDefault
	end

	if type(numberRaw) == "number" and (numberRaw < numberMin or numberRaw > numberMax) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
	end

	return StudentConfig.readConfigNumber(tblEffectConfig, strKey, numberDefault, numberMin, numberMax)
end


-- --------------------------------------------------------------------------------


function module.readEffectColor(tblEffectConfig, strKey, colorDefault, tblValidationMessages, strSourceName)
	local valueColor = tblEffectConfig and tblEffectConfig[strKey]
	if valueColor == nil then
		return colorDefault
	end

	if typeof(valueColor) == "ColorSequence" then
		return valueColor
	end

	if typeof(valueColor) == "Color3" then
		return ColorSequence.new(valueColor)
	end

	StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 ColorSequence.new(...) 또는 Color3.fromRGB(...) 값이어야 해서 기본색으로 보정했습니다.")
	return colorDefault
end


-- --------------------------------------------------------------------------------


function module.isAllowedParticleTexture(strTexture)
	for _, strAllowedTexture in pairs(module.eParticleTexture) do
		if strTexture == strAllowedTexture then
			return true
		end
	end

	return false
end


-- --------------------------------------------------------------------------------


function module.readEffectTexture(tblEffectConfig, strKey, strDefaultTexture, tblValidationMessages, strSourceName)
	local strTexture = StudentConfig.readConfigString(tblEffectConfig, strKey, strDefaultTexture)
	if module.isAllowedParticleTexture(strTexture) then
		return strTexture
	end

	StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 module.eParticleTexture 값만 사용할 수 있어 기본 Sparkles로 보정했습니다.")
	return strDefaultTexture
end


-- --------------------------------------------------------------------------------


function module.readEffectBoolean(tblEffectConfig, strKey, boolDefault, tblValidationMessages, strSourceName)
	local boolRaw = tblEffectConfig and tblEffectConfig[strKey]
	if boolRaw == nil then
		return boolDefault
	end

	if type(boolRaw) ~= "boolean" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 true/false 값이어야 해서 기본값으로 보정했습니다.")
		return boolDefault
	end

	return boolRaw
end


-- --------------------------------------------------------------------------------


function module.readEffectEnumItem(tblEffectConfig, strKey, enumDefault, tblValidationMessages, strSourceName)
	local enumRaw = tblEffectConfig and tblEffectConfig[strKey]
	if enumRaw == nil then
		return enumDefault
	end

	local enumValue = StudentConfig.readConfigEnumItem(tblEffectConfig, strKey, enumDefault)
	if enumValue == enumDefault and enumRaw ~= enumDefault then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 올바른 Roblox Enum 값이어야 해서 기본값으로 보정했습니다.")
	end

	return enumValue
end


-- --------------------------------------------------------------------------------


function module.readEffectVector2(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax, tblValidationMessages, strSourceName)
	local vectorRaw = tblEffectConfig and tblEffectConfig[strKey]
	if vectorRaw == nil then
		return vectorDefault
	end

	if typeof(vectorRaw) ~= "Vector2" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 Vector2.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return vectorDefault
	end

	if vectorMin and (vectorRaw.X < vectorMin.X or vectorRaw.Y < vectorMin.Y) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 허용 범위 안으로 보정했습니다.")
	end
	if vectorMax and (vectorRaw.X > vectorMax.X or vectorRaw.Y > vectorMax.Y) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 허용 범위 안으로 보정했습니다.")
	end

	return Vector2.new(
		StudentConfig.clampNumber(vectorRaw.X, vectorMin and vectorMin.X, vectorMax and vectorMax.X),
		StudentConfig.clampNumber(vectorRaw.Y, vectorMin and vectorMin.Y, vectorMax and vectorMax.Y)
	)
end


-- --------------------------------------------------------------------------------


function module.readEffectVector3(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax, tblValidationMessages, strSourceName)
	local vectorRaw = tblEffectConfig and tblEffectConfig[strKey]
	if vectorRaw ~= nil and typeof(vectorRaw) ~= "Vector3" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 Vector3.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return vectorDefault
	end

	return StudentConfig.readConfigVector3(tblEffectConfig, strKey, vectorDefault, vectorMin, vectorMax)
end


-- --------------------------------------------------------------------------------


function module.createOrderedNumberRange(numberMin, numberMax, strLabel, tblValidationMessages, strSourceName)
	if numberMin <= numberMax then
		return NumberRange.new(numberMin, numberMax)
	end

	StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strLabel .. "Min이 Max보다 커서 두 값을 서로 바꿨습니다.")
	return NumberRange.new(numberMax, numberMin)
end


-- --------------------------------------------------------------------------------


function module.readEffectNumberRange(tblEffectConfig, strKey, strMinKey, strMaxKey, numberDefaultMin, numberDefaultMax, numberMin, numberMax, tblValidationMessages, strSourceName)
	local rangeRaw = tblEffectConfig and tblEffectConfig[strKey]
	if rangeRaw ~= nil then
		if typeof(rangeRaw) ~= "NumberRange" then
			StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 NumberRange.new(...) 값이어야 해서 기본값으로 보정했습니다.")
			return NumberRange.new(numberDefaultMin, numberDefaultMax)
		end

		if rangeRaw.Min < numberMin or rangeRaw.Max > numberMax then
			StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
		end

		return module.createOrderedNumberRange(
			StudentConfig.clampNumber(rangeRaw.Min, numberMin, numberMax),
			StudentConfig.clampNumber(rangeRaw.Max, numberMin, numberMax),
			strKey,
			tblValidationMessages,
			strSourceName
		)
	end

	local numberRangeMin = module.readEffectNumber(tblEffectConfig, strMinKey, numberDefaultMin, numberMin, numberMax, tblValidationMessages, strSourceName)
	local numberRangeMax = module.readEffectNumber(tblEffectConfig, strMaxKey, numberDefaultMax, numberMin, numberMax, tblValidationMessages, strSourceName)
	return module.createOrderedNumberRange(numberRangeMin, numberRangeMax, strKey, tblValidationMessages, strSourceName)
end


-- --------------------------------------------------------------------------------


function module.readEffectNumberSequence(tblEffectConfig, strKey, numberDefault, numberMin, numberMax, tblValidationMessages, strSourceName)
	local sequenceRaw = tblEffectConfig and tblEffectConfig[strKey]
	if sequenceRaw == nil then
		return NumberSequence.new(numberDefault)
	end

	if typeof(sequenceRaw) == "NumberSequence" then
		local tblKeypoints = {}
		local boolWasClamped = false
		for _, keypoint in ipairs(sequenceRaw.Keypoints) do
			local numberValue = StudentConfig.clampNumber(keypoint.Value, numberMin, numberMax)
			local numberMaxEnvelope = math.max(0, math.min(numberValue - numberMin, numberMax - numberValue))
			local numberEnvelope = StudentConfig.clampNumber(keypoint.Envelope, 0, numberMaxEnvelope)
			if numberValue ~= keypoint.Value or numberEnvelope ~= keypoint.Envelope then
				boolWasClamped = true
			end
			table.insert(tblKeypoints, NumberSequenceKeypoint.new(keypoint.Time, numberValue, numberEnvelope))
		end
		if boolWasClamped then
			StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. " 내부 숫자는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
		end
		return NumberSequence.new(tblKeypoints)
	end

	if type(sequenceRaw) ~= "number" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 숫자 또는 NumberSequence.new(...) 값이어야 해서 기본값으로 보정했습니다.")
		return NumberSequence.new(numberDefault)
	end

	if sequenceRaw < numberMin or sequenceRaw > numberMax then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect." .. strKey .. "는 " .. numberMin .. "~" .. numberMax .. " 범위로 보정했습니다.")
	end

	return NumberSequence.new(StudentConfig.clampNumber(sequenceRaw, numberMin, numberMax))
end


-- --------------------------------------------------------------------------------


function module.readParticleEffectConfig(tblConfig, strKey, tblValidationMessages, strSourceName)
	local valueEffect = tblConfig and tblConfig[strKey]
	if valueEffect == nil or valueEffect == false then
		return nil
	end

	if type(valueEffect) ~= "table" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, "Effect는 table이어야 해서 효과를 끕니다.")
		return nil
	end

	return {
		Texture = module.readEffectTexture(valueEffect, "Texture", module.eParticleTexture.SPARKLES, tblValidationMessages, strSourceName),
		Rate = module.readEffectNumber(valueEffect, "Rate", 24, 0, 60, tblValidationMessages, strSourceName),
		LightEmission = module.readEffectNumber(valueEffect, "LightEmission", 0.4, 0, 1, tblValidationMessages, strSourceName),
		LightInfluence = module.readEffectNumber(valueEffect, "LightInfluence", 0, 0, 1, tblValidationMessages, strSourceName),
		Brightness = module.readEffectNumber(valueEffect, "Brightness", 1, 0, 10, tblValidationMessages, strSourceName),
		Color = module.readEffectColor(valueEffect, "Color", ColorSequence.new(Color3.fromRGB(255, 112, 36)), tblValidationMessages, strSourceName),
		Transparency = module.readEffectNumberSequence(valueEffect, "Transparency", 0, 0, 1, tblValidationMessages, strSourceName),
		Lifetime = module.readEffectNumberRange(valueEffect, "Lifetime", "LifetimeMin", "LifetimeMax", 0.25, 0.7, 0.05, 3, tblValidationMessages, strSourceName),
		Speed = module.readEffectNumberRange(valueEffect, "Speed", "SpeedMin", "SpeedMax", 0.5, 2, 0, 20, tblValidationMessages, strSourceName),
		Size = module.readEffectNumberSequence(valueEffect, "Size", 0.35, 0.05, 3, tblValidationMessages, strSourceName),
		SpreadAngle = module.readEffectVector2(valueEffect, "SpreadAngle", Vector2.new(
			module.readEffectNumber(valueEffect, "SpreadX", 20, 0, 180, tblValidationMessages, strSourceName),
			module.readEffectNumber(valueEffect, "SpreadY", 20, 0, 180, tblValidationMessages, strSourceName)
		), Vector2.new(0, 0), Vector2.new(180, 180), tblValidationMessages, strSourceName),
		Acceleration = module.readEffectVector3(valueEffect, "Acceleration", Vector3.new(0, 0, 0), Vector3.new(-50, -50, -50), Vector3.new(50, 50, 50), tblValidationMessages, strSourceName),
		Drag = module.readEffectNumber(valueEffect, "Drag", 0, 0, 20, tblValidationMessages, strSourceName),
		Rotation = module.readEffectNumberRange(valueEffect, "Rotation", "RotationMin", "RotationMax", 0, 0, -360, 360, tblValidationMessages, strSourceName),
		RotSpeed = module.readEffectNumberRange(valueEffect, "RotSpeed", "RotSpeedMin", "RotSpeedMax", 0, 0, -360, 360, tblValidationMessages, strSourceName),
		VelocityInheritance = module.readEffectNumber(valueEffect, "VelocityInheritance", 0, 0, 1, tblValidationMessages, strSourceName),
		ZOffset = module.readEffectNumber(valueEffect, "ZOffset", 0, -5, 5, tblValidationMessages, strSourceName),
		TimeScale = module.readEffectNumber(valueEffect, "TimeScale", 1, 0, 2, tblValidationMessages, strSourceName),
		Shape = module.readEffectEnumItem(valueEffect, "Shape", Enum.ParticleEmitterShape.Sphere, tblValidationMessages, strSourceName),
		ShapeStyle = module.readEffectEnumItem(valueEffect, "ShapeStyle", Enum.ParticleEmitterShapeStyle.Surface, tblValidationMessages, strSourceName),
		ShapeInOut = module.readEffectEnumItem(valueEffect, "ShapeInOut", Enum.ParticleEmitterShapeInOut.Outward, tblValidationMessages, strSourceName),
		ShapePartial = module.readEffectNumber(valueEffect, "ShapePartial", 1, 0, 1, tblValidationMessages, strSourceName),
		EmissionDirection = module.readEffectEnumItem(valueEffect, "EmissionDirection", Enum.NormalId.Top, tblValidationMessages, strSourceName),
		Orientation = module.readEffectEnumItem(valueEffect, "Orientation", Enum.ParticleOrientation.FacingCamera, tblValidationMessages, strSourceName),
		LockedToPart = module.readEffectBoolean(valueEffect, "LockedToPart", false, tblValidationMessages, strSourceName),
	}
end


-- --------------------------------------------------------------------------------


function common.readEquipmentSize(tblConfig, strKey, strEquipmentRuleName, tblValidationMessages, strSourceName)
	local tblSizeRule = ThrowingStone.tblEquipmentSizeRule[strEquipmentRuleName]
	local vectorDefault = tblSizeRule.Default
	local vectorMin = tblSizeRule.Min
	local vectorMax = tblSizeRule.Max
	local valueSize = tblConfig and tblConfig[strKey]

	if valueSize ~= nil and typeof(valueSize) ~= "Vector3" then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 Vector3.new(...) 값이어야 해서 기본 크기로 보정했습니다.")
		return vectorDefault
	end

	if typeof(valueSize) == "Vector3" and StudentConfig.isVector3OutsideRange(valueSize, vectorMin, vectorMax) then
		StudentConfig.addValidationMessage(tblValidationMessages, strSourceName, strKey .. "는 장비 기준 범위를 벗어나 " .. tostring(vectorMin) .. " ~ " .. tostring(vectorMax) .. " 안으로 보정했습니다.")
	end

	return StudentConfig.readConfigVector3(tblConfig, strKey, vectorDefault, vectorMin, vectorMax)
end


-- --------------------------------------------------------------------------------


function module.applyParticleEffect(partTarget, tblEffectConfig)
	local emitEffect = partTarget:FindFirstChild(EngineNames.eEngineLogicalType.PARTICLE_EFFECT)
	if not tblEffectConfig then
		if emitEffect then
			emitEffect:Destroy()
		end
		return
	end

	emitEffect = EngineEnsure.ensureNamedInstance(EngineNames.eEnginePhysicalType.PARTICLE_EMITTER, EngineNames.eEngineLogicalType.PARTICLE_EFFECT, partTarget)
	emitEffect.Enabled = true
	emitEffect.Texture = tblEffectConfig.Texture
	emitEffect.LockedToPart = tblEffectConfig.LockedToPart
	emitEffect.SpreadAngle = tblEffectConfig.SpreadAngle
	emitEffect.Lifetime = tblEffectConfig.Lifetime
	emitEffect.Speed = tblEffectConfig.Speed
	emitEffect.Size = tblEffectConfig.Size
	emitEffect.Transparency = tblEffectConfig.Transparency
	emitEffect.Rate = tblEffectConfig.Rate
	emitEffect.LightEmission = tblEffectConfig.LightEmission
	emitEffect.LightInfluence = tblEffectConfig.LightInfluence
	emitEffect.Brightness = tblEffectConfig.Brightness
	emitEffect.Color = tblEffectConfig.Color
	emitEffect.Acceleration = tblEffectConfig.Acceleration
	emitEffect.Drag = tblEffectConfig.Drag
	emitEffect.Rotation = tblEffectConfig.Rotation
	emitEffect.RotSpeed = tblEffectConfig.RotSpeed
	emitEffect.VelocityInheritance = tblEffectConfig.VelocityInheritance
	emitEffect.ZOffset = tblEffectConfig.ZOffset
	emitEffect.TimeScale = tblEffectConfig.TimeScale
	emitEffect.Shape = tblEffectConfig.Shape
	emitEffect.ShapeStyle = tblEffectConfig.ShapeStyle
	emitEffect.ShapeInOut = tblEffectConfig.ShapeInOut
	emitEffect.ShapePartial = tblEffectConfig.ShapePartial
	emitEffect.EmissionDirection = tblEffectConfig.EmissionDirection
	emitEffect.Orientation = tblEffectConfig.Orientation
end

-- --------------------------------------------------------------------------------

return module