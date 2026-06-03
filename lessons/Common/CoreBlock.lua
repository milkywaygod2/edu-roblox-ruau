-- [Module] CoreBlock
local CoreBlock = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)
local Effect = require(script.Parent.Effect)
local CombatRules = require(script.Parent.CombatRules)

local MAX_STACK = 5 -- 등에 짊어질 수 있는 벽돌 최대 개수
local RESOURCE_PIECE_VALUE = 5 -- 자원 한 조각당 가치
local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds" -- 스파크 피드백 텍스처

-- Attribute는 function을 저장할 수 없으므로, 블록별 대미지 핸들러는 모듈 내 weak-key 테이블로 보관한다.
local mapBlockDamageHandlers = setmetatable({}, { __mode = "k" })

-- --------------------------------------------------------------------------------
-- [Helper] 파티클 스파크 피드백 이펙트
-- --------------------------------------------------------------------------------
local function playBlockEffect(partTarget, strColorName)
	local ePhysical = CoreEnums.eEnginePhysicalType

	local attachment = Instance.new(ePhysical.ATTACHMENT)
	attachment.Parent = partTarget

	local emitter = Instance.new(ePhysical.PARTICLE_EMITTER)
	emitter.Texture = SPARKLE_TEXTURE
	emitter.Color = ColorSequence.new(BrickColor.new(strColorName or "Light stone grey").Color)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Rate = 50
	emitter.Speed = NumberRange.new(5, 12)
	emitter.Lifetime = NumberRange.new(0.2, 0.4)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = attachment

	emitter:Emit(25)
	task.delay(0.5, function()
		attachment:Destroy()
	end)
end

-- --------------------------------------------------------------------------------
-- [Helper] 물리 자원 아이템 스폰 (채굴/파괴 시 획득 가능)
-- --------------------------------------------------------------------------------
local function spawnDropResources(vectorPosition, intYield, strResourceType)
	if not intYield or intYield <= 0 then return end

	local ePhysical = CoreEnums.eEnginePhysicalType
	local eService = CoreEnums.eEngineServiceSingleton
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey
	local numPieces = math.clamp(math.floor(intYield / RESOURCE_PIECE_VALUE), 1, 8)

	local colorMap = {
		Gold = BrickColor.new("Gold"),
		Wood = BrickColor.new("Red reddish brown"),
		Stone = BrickColor.new("Dark stone grey")
	}
	local brickColor = colorMap[strResourceType] or BrickColor.new("Mid gray")

	for i = 1, numPieces do
		local partDrop = Instance.new(ePhysical.PART)
		partDrop.Name = eLogical.RESOURCE_DROP_PREFIX .. strResourceType
		partDrop.Size = Vector3.new(0.8, 0.8, 0.8)
		partDrop.Material = Enum.Material.Neon
		partDrop.BrickColor = brickColor
		partDrop.CFrame = CFrame.new(vectorPosition + Vector3.new(0, 1, 0))
		partDrop.CanCollide = true
		partDrop.Anchored = false

		-- 사방으로 살짝 튀어나가는 물리 궤적 적용
		local angle = math.rad(math.random(0, 360))
		local force = math.random(6, 12)
		partDrop.AssemblyLinearVelocity = Vector3.new(
			math.cos(angle) * force,
			math.random(12, 18),
			math.sin(angle) * force
		)

		partDrop:SetAttribute(eAttr.RESOURCE_DROP_VALUE, RESOURCE_PIECE_VALUE)
		partDrop:SetAttribute(eAttr.BLOCK_RESOURCE_TYPE, strResourceType)
		partDrop.Parent = workspace

		game:GetService(eService.DEBRIS):AddItem(partDrop, 15) -- 15초 후 자동 소멸

		local touchedConnection
		touchedConnection = partDrop.Touched:Connect(function(partHit)
			local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
			local player = modelTarget and game:GetService(eService.PLAYERS):GetPlayerFromCharacter(modelTarget)
			if player then
				-- 물리 획득 시, 자원 종류(Gold, Wood, Stone) 상관없이 전부 등에 물리적으로 짊어짐
				local success = CoreBlock.carryBlock(player, partDrop)
				if success then
					touchedConnection:Disconnect()
				end
			end
		end)
	end
end

-- --------------------------------------------------------------------------------
-- [Helper] 플레이어 캐릭터 등 짊어지기 폴더 보장
-- --------------------------------------------------------------------------------
local function ensureCarryFolder(character)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eService = CoreEnums.eEngineServiceSingleton
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	local folder = character:FindFirstChild(eLogical.CARRIED_RESOURCES)
	if not folder then
		folder = Instance.new(ePhysical.FOLDER)
		folder.Name = eLogical.CARRIED_RESOURCES
		folder.Parent = character

		-- 캐릭터 사망 시 짊어지고 있던 현물 자원을 모두 바닥에 쏟아버림 (마인크래프트 효과)
		local humanoid = character:FindFirstChildOfClass(ePhysical.HUMANOID)
		if humanoid then
			humanoid.Died:Connect(function()
				for _, part in ipairs(folder:GetChildren()) do
					local weld = part:FindFirstChildOfClass(ePhysical.WELD_CONSTRAINT)
					if weld then weld:Destroy() end

					part.Parent = workspace
					part.Size = part:GetAttribute(eAttr.BLOCK_ORIGINAL_SIZE) or Vector3.new(3, 3, 3)
					part.CanCollide = true
					part.Anchored = false
					part:SetAttribute(eAttr.BLOCK_IS_CARRIED, false)

					-- 드롭 물리 탄도
					local angle = math.rad(math.random(0, 360))
					local force = math.random(6, 12)
					part.AssemblyLinearVelocity = Vector3.new(
						math.cos(angle) * force,
						math.random(10, 18),
						math.sin(angle) * force
					)

					-- 재생성 프롬프트 재연결
					local prompt = part:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
					if prompt then prompt.Enabled = true end

					game:GetService(eService.DEBRIS):AddItem(part, 20)
				end
				folder:Destroy()
			end)
		end
	end
	return folder
end

-- --------------------------------------------------------------------------------
-- [Core 1] 만능 블록 생성자 (현물 자원 채굴/짊어지기 및 방벽 기능 통합)
-- --------------------------------------------------------------------------------
function CoreBlock.create(instanceParent, cframeOrPosition, tblConfig)
	local tblProps = tblConfig or {}
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	local partBlock = Instance.new(ePhysical.PART)
	partBlock.Name = eLogical.CORE_BLOCK

	local tblDefaultProps = {
		Size = tblProps.Size or Vector3.new(3, 3, 3),
		CFrame = (typeof(cframeOrPosition) == "Vector3" and CFrame.new(cframeOrPosition) or cframeOrPosition),
		Anchored = (tblProps.Anchored ~= nil and tblProps.Anchored or true),
		Material = tblProps.Material or Enum.Material.Rock,
		BrickColor = tblProps.BrickColor or BrickColor.new("Dark stone grey")
	}

	EngineEnsure.applyInstanceProperties(partBlock, tblDefaultProps)
	partBlock.Parent = instanceParent or workspace

	-- 속성 정의
	local maxHealth = tblProps.MaxHealth or 100
	partBlock:SetAttribute(eAttr.BLOCK_MAX_HEALTH, maxHealth)
	partBlock:SetAttribute(eAttr.BLOCK_HEALTH, maxHealth)
	partBlock:SetAttribute(eAttr.BLOCK_RESOURCE_YIELD, tblProps.ResourceYield or 10)
	partBlock:SetAttribute(eAttr.BLOCK_RESOURCE_TYPE, tblProps.ResourceType or "Gold")
	partBlock:SetAttribute(eAttr.BLOCK_DAMAGE, tblProps.Damage or 20)
	partBlock:SetAttribute(eAttr.BLOCK_IS_MINING, false)
	partBlock:SetAttribute(eAttr.BLOCK_IS_PROJECTILE, false)
	partBlock:SetAttribute(eAttr.BLOCK_IS_CARRIED, false)

	-- 플래그 설정
	local canMine = (tblProps.CanMine ~= nil and tblProps.CanMine or true)
	local canTakeDamage = (tblProps.CanTakeDamage ~= nil and tblProps.CanTakeDamage or true)
	partBlock:SetAttribute(eAttr.BLOCK_CAN_MINE, canMine)
	partBlock:SetAttribute(eAttr.BLOCK_CAN_TAKE_DAMAGE, canTakeDamage)

	-- 엄폐물 대미지 콜백 적용
	local function applyBlockDamage(numberDamage)
		if not partBlock:GetAttribute(eAttr.BLOCK_CAN_TAKE_DAMAGE) then return end
		if partBlock:GetAttribute(eAttr.BLOCK_HEALTH) <= 0 then return end
		if partBlock:GetAttribute(eAttr.BLOCK_IS_CARRIED) == true then return end

		local currentHealth = partBlock:GetAttribute(eAttr.BLOCK_HEALTH)
		local nextHealth = math.max(0, currentHealth - numberDamage)
		partBlock:SetAttribute(eAttr.BLOCK_HEALTH, nextHealth)

		playBlockEffect(partBlock, partBlock.BrickColor.Name)
		partBlock.Transparency = 0.8 * (1 - (nextHealth / partBlock:GetAttribute(eAttr.BLOCK_MAX_HEALTH)))

		if nextHealth <= 0 then
			playBlockEffect(partBlock, "Bright red")
			-- 파괴될 때 물리적으로 잔여 자원 파편 드랍
			spawnDropResources(partBlock.Position, partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_YIELD), partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_TYPE))
			partBlock:Destroy()
		end
	end

	-- Attribute에는 function을 담을 수 없으므로 weak-table에 핸들러를 등록한다.
	mapBlockDamageHandlers[partBlock] = applyBlockDamage

	partBlock:GetAttributeChangedSignal(eAttr.BLOCK_HEALTH):Connect(function()
		local hp = partBlock:GetAttribute(eAttr.BLOCK_HEALTH)
		if hp and hp <= 0 then
			playBlockEffect(partBlock, "Bright red")
			spawnDropResources(partBlock.Position, partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_YIELD), partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_TYPE))
			partBlock:Destroy()
		end
	end)

	-- 자원 상호작용 바인딩 (등에 짊어지기 수행 혹은 골드 즉시 채굴)
	-- 자원 상호작용 바인딩 (등에 짊어지기 수행)
	if canMine then
		local clickDetector = EngineEnsure.ensureClickDetector(partBlock, 15)

		local proximityPrompt = Instance.new(ePhysical.PROXIMITY_PROMPT)
		proximityPrompt.ObjectText = "CoreBlock" -- UI 표시 텍스트(.Name 계약이 아니므로 enum 미적용)
		proximityPrompt.ActionText = "등에 메기"
		proximityPrompt.HoldDuration = 0.5
		proximityPrompt.MaxActivationDistance = 12
		proximityPrompt.Parent = partBlock

		local function performCarry(player)
			if partBlock:GetAttribute(eAttr.BLOCK_IS_MINING) == true or
			   partBlock:GetAttribute(eAttr.BLOCK_IS_PROJECTILE) == true or
			   partBlock:GetAttribute(eAttr.BLOCK_IS_CARRIED) == true then
				return
			end

			local success = CoreBlock.carryBlock(player, partBlock)
			if not success then
				-- 소지 제한 피드백 (빨간 스파크)
				playBlockEffect(partBlock, "Bright red")
			end
		end

		clickDetector.MouseClick:Connect(performCarry)
		proximityPrompt.Triggered:Connect(performCarry)
	end

	return partBlock
end

-- --------------------------------------------------------------------------------
-- [Core 2] 자원 벽돌을 플레이어 등에 WeldConstraint로 부착 및 스태킹
-- --------------------------------------------------------------------------------
function CoreBlock.carryBlock(player, partBlock)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	local character = player.Character
	if not character then return false end

	local torso = character:FindFirstChild(eLogical.RESERVED_UPPER_TORSO) or character:FindFirstChild(eLogical.RESERVED_TORSO)
	if not torso then return false end

	local folder = ensureCarryFolder(character)
	local currentCount = #folder:GetChildren()
	if currentCount >= MAX_STACK then
		return false
	end

	-- 상호작용 프롬프트 일시 정지
	local prompt = partBlock:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if prompt then prompt.Enabled = false end
	local click = partBlock:FindFirstChildOfClass(ePhysical.CLICK_DETECTOR)
	if click then click.Enabled = false end

	-- 원형 크기 기록 및 짊어지기용 축소
	local originalSize = partBlock:GetAttribute(eAttr.BLOCK_ORIGINAL_SIZE) or partBlock.Size
	partBlock:SetAttribute(eAttr.BLOCK_ORIGINAL_SIZE, originalSize)
	partBlock.Size = Vector3.new(1.8, 0.8, 1.2) -- 등에 붙는 아담한 큐브 형태
	partBlock.CanCollide = false
	partBlock.Anchored = false
	partBlock.Massless = true
	partBlock:SetAttribute(eAttr.BLOCK_IS_CARRIED, true)
	partBlock.Parent = folder

	-- Weld 연결
	local weld = Instance.new(ePhysical.WELD_CONSTRAINT)
	weld.Part0 = torso
	weld.Part1 = partBlock
	weld.Parent = partBlock

	-- 가로 적재(Stacking) 좌표 연출
	local blockHeight = partBlock.Size.Y + 0.1
	local offsetZ = 0.9 -- 등 바로 뒤
	local offsetY = (currentCount * blockHeight) - (torso.Size.Y / 2) + 0.4

	partBlock.CFrame = torso.CFrame * CFrame.new(0, offsetY, offsetZ) * CFrame.Angles(0, math.rad(90), 0)

	playBlockEffect(torso, partBlock.BrickColor.Name)
	return true
end

-- --------------------------------------------------------------------------------
-- [Core 3] 등에 메고 있는 벽돌 하나를 플레이어 앞쪽에 드롭 (창고 적재용)
-- --------------------------------------------------------------------------------
function CoreBlock.dropCarriedBlock(player)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	local character = player.Character
	if not character then return nil end
	local root = character:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
	if not root then return nil end

	local folder = character:FindFirstChild(eLogical.CARRIED_RESOURCES)
	if not folder then return nil end

	local carried = folder:GetChildren()
	if #carried <= 0 then return nil end

	-- 맨 위에 스택된 블록 선택
	local partBlock = carried[#carried]

	local weld = partBlock:FindFirstChildOfClass(ePhysical.WELD_CONSTRAINT)
	if weld then weld:Destroy() end

	-- 원래 크기 및 충돌 복구
	local originalSize = partBlock:GetAttribute(eAttr.BLOCK_ORIGINAL_SIZE) or Vector3.new(3, 3, 3)
	partBlock.Size = originalSize
	partBlock.CanCollide = true
	partBlock.Anchored = false
	partBlock.Massless = false
	partBlock:SetAttribute(eAttr.BLOCK_IS_CARRIED, false)
	partBlock.Parent = workspace

	-- 플레이어 전방 3.5스터드 앞에 물리 드랍
	partBlock.CFrame = root.CFrame * CFrame.new(0, 0.5, -3.5)
	partBlock.AssemblyLinearVelocity = root.CFrame.LookVector * 10 + Vector3.new(0, 8, 0)

	-- 프롬프트 활성화
	local prompt = partBlock:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if prompt then
		prompt.Enabled = true
	else
		prompt = Instance.new(ePhysical.PROXIMITY_PROMPT)
		prompt.ObjectText = "CoreBlock" -- UI 표시 텍스트(.Name 계약이 아니므로 enum 미적용)
		prompt.ActionText = "등에 메기"
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = 12
		prompt.Parent = partBlock
		prompt.Triggered:Connect(function(interactor)
			CoreBlock.carryBlock(interactor, partBlock)
		end)
	end

	local click = partBlock:FindFirstChildOfClass(ePhysical.CLICK_DETECTOR)
	if click then
		click.Enabled = true
	end

	playBlockEffect(partBlock, partBlock.BrickColor.Name)
	return partBlock
end

-- --------------------------------------------------------------------------------
-- [Core 4] 등에 메고 있는 벽돌 하나를 소모하여 지정 위치에 벽(Cover) 조립/신축
-- --------------------------------------------------------------------------------
function CoreBlock.buildBlockFromCarried(player, cframeTarget, tblAppearance)
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	local character = player.Character
	if not character then return nil end

	local folder = character:FindFirstChild(eLogical.CARRIED_RESOURCES)
	if not folder then return nil end

	local carried = folder:GetChildren()
	if #carried <= 0 then return nil end

	-- 탑 스택 자원 소모
	local partCarried = carried[#carried]
	local resourceType = partCarried:GetAttribute(eAttr.BLOCK_RESOURCE_TYPE) or "Gold"
	local resourceYield = partCarried:GetAttribute(eAttr.BLOCK_RESOURCE_YIELD) or 10
	local brickColor = partCarried.BrickColor
	local material = partCarried.Material

	partCarried:Destroy()

	-- 지정 좌표에 엄폐용 Anchored 벽 건축
	local tblProps = tblAppearance or {}
	tblProps.Size = tblProps.Size or Vector3.new(4, 3, 2)
	tblProps.Material = tblProps.Material or material or Enum.Material.WoodPlanks
	tblProps.BrickColor = tblProps.BrickColor or brickColor or BrickColor.new("Red reddish brown")
	tblProps.Anchored = true
	tblProps.CanMine = false -- 설치 완료된 방벽은 즉시 채굴 불가
	tblProps.CanTakeDamage = true
	tblProps.MaxHealth = tblProps.MaxHealth or 120
	tblProps.ResourceType = resourceType
	tblProps.ResourceYield = math.floor(resourceYield * 0.5) -- 회수량 보장

	local partWall = CoreBlock.create(workspace, cframeTarget, tblProps)
	playBlockEffect(partWall, tblProps.BrickColor.Name)

	return partWall
end

-- --------------------------------------------------------------------------------
-- [Core 5] 블록 발사 기능 (투사체 역할 가동 및 넉백 지원)
-- --------------------------------------------------------------------------------
function CoreBlock.launch(partBlock, vectorVelocity, playerAttacker, numberDamage, tblKnockback)
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eService = CoreEnums.eEngineServiceSingleton
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttr = CoreEnums.eEngineAttributeKey

	if not partBlock or not partBlock:IsA(ePhysical.BASE_PART) then return end

	partBlock:SetAttribute(eAttr.BLOCK_IS_PROJECTILE, true)
	partBlock:SetAttribute(eAttr.BLOCK_CAN_MINE, false)
	partBlock.Anchored = false
	partBlock.CanCollide = true

	local prompt = partBlock:FindFirstChildOfClass(ePhysical.PROXIMITY_PROMPT)
	if prompt then prompt:Destroy() end
	local click = partBlock:FindFirstChildOfClass(ePhysical.CLICK_DETECTOR)
	if click then click:Destroy() end

	partBlock.AssemblyLinearVelocity = vectorVelocity

	local boolHit = false
	local touchedConnection
	touchedConnection = partBlock.Touched:Connect(function(partHit)
		if boolHit then return end
		if partHit == partBlock or partHit:IsDescendantOf(partBlock) then return end

		if playerAttacker and playerAttacker.Character and partHit:IsDescendantOf(playerAttacker.Character) then
			return
		end

		boolHit = true
		touchedConnection:Disconnect()

		local damage = numberDamage or partBlock:GetAttribute(eAttr.BLOCK_DAMAGE) or 20
		local resourceYield = partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_YIELD) or 10
		local resourceType = partBlock:GetAttribute(eAttr.BLOCK_RESOURCE_TYPE) or "Gold"
		local pos = partBlock.Position

		playBlockEffect(partBlock, partBlock.BrickColor.Name)

		-- 캐릭터 피격 및 넉백
		local modelTarget = partHit:FindFirstAncestorOfClass(ePhysical.MODEL)
		local humanoidTarget = modelTarget and modelTarget:FindFirstChildOfClass(ePhysical.HUMANOID)
		local partTargetRoot = modelTarget and modelTarget:FindFirstChild(eLogical.RESERVED_HUMANOID_ROOT_PART)
		if humanoidTarget then
			if CombatRules.canPlayerDamageModel(playerAttacker, modelTarget) then
				humanoidTarget:TakeDamage(damage)

				-- 물리 넉백 처리
				if partTargetRoot and tblKnockback then
					local forwardForce = tblKnockback.Forward or tblKnockback.KnockbackForward or 0
					local upForce = tblKnockback.Up or tblKnockback.KnockbackUp or 0
					local launchDir = vectorVelocity.Magnitude > 0 and vectorVelocity.Unit or Vector3.new(0, 0, -1)
					local knockbackDir = Vector3.new(launchDir.X, 0, launchDir.Z).Unit
					partTargetRoot.AssemblyLinearVelocity = knockbackDir * forwardForce + Vector3.new(0, upForce, 0)
				end
			end
		end

		-- 타 방벽 엄폐물 피격 (weak-table에 등록된 블록 대미지 핸들러 호출)
		local damageHandler = mapBlockDamageHandlers[partHit]
		if damageHandler then
			damageHandler(damage * 1.5)
		end

		-- 투사체 부서지며 물리 자원 조각 스폰
		spawnDropResources(pos, math.floor(resourceYield * 0.5), resourceType)
		partBlock:Destroy()
	end)

	game:GetService(eService.DEBRIS):AddItem(partBlock, 10)
end

-- --------------------------------------------------------------------------------
-- [Legacy Interfaces] 하위 호환용 팩토리 래핑
-- --------------------------------------------------------------------------------
function CoreBlock.createResourceBlock(instanceParent, vectorPosition, intResourceYield, tblAppearance)
	local tblProps = tblAppearance or {}
	tblProps.ResourceYield = intResourceYield or 10
	tblProps.CanMine = true
	tblProps.CanTakeDamage = false
	tblProps.Anchored = true

	return CoreBlock.create(instanceParent, vectorPosition, tblProps)
end

function CoreBlock.spawnCoverBlock(instanceParent, cframePosition, numberMaxHealth, tblAppearance)
	local tblProps = tblAppearance or {}
	tblProps.MaxHealth = numberMaxHealth or 100
	tblProps.CanMine = false
	tblProps.CanTakeDamage = true
	tblProps.Anchored = true

	return CoreBlock.create(instanceParent, cframePosition, tblProps)
end

function CoreBlock.launchProjectileBlock(instanceParent, cframeStart, vectorVelocity, numberDamage, playerAttacker, tblAppearance)
	local tblProps = tblAppearance or {}
	tblProps.Damage = numberDamage or 20
	tblProps.CanMine = false
	tblProps.CanTakeDamage = true
	tblProps.Anchored = false

	local partBlock = CoreBlock.create(instanceParent, cframeStart, tblProps)
	CoreBlock.launch(partBlock, vectorVelocity, playerAttacker, numberDamage)

	return partBlock
end

return CoreBlock
