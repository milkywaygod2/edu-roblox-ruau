-- [Module] CoreBlock
local CoreBlock = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local StudentConfig = require(script.Parent.StudentConfig)
local Effect = require(script.Parent.Effect)
local CombatRules = require(script.Parent.CombatRules)

local MAX_STACK = 5 -- 등에 짊어질 수 있는 벽돌 최대 개수

-- --------------------------------------------------------------------------------
-- [Helper] 파티클 스파크 피드백 이펙트
-- --------------------------------------------------------------------------------
local function play_block_effect(partTarget, strColorName)
	local attachment = Instance.new("Attachment")
	attachment.Parent = partTarget

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
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
local function spawn_drop_resources(vectorPosition, intYield, strResourceType)
	if not intYield or intYield <= 0 then return end
	
	local valPerPiece = 5 -- 한 조각당 자원 가치
	local numPieces = math.clamp(math.floor(intYield / valPerPiece), 1, 8)
	
	local colorMap = {
		Gold = BrickColor.new("Gold"),
		Wood = BrickColor.new("Red reddish brown"),
		Stone = BrickColor.new("Dark stone grey")
	}
	local brickColor = colorMap[strResourceType] or BrickColor.new("Mid gray")
	
	for i = 1, numPieces do
		local partDrop = Instance.new("Part")
		partDrop.Name = "ResourceDrop_" .. strResourceType
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
		
		partDrop:SetAttribute("Value", valPerPiece)
		partDrop:SetAttribute("ResourceType", strResourceType)
		partDrop.Parent = workspace
		
		game:GetService("Debris"):AddItem(partDrop, 15) -- 15초 후 자동 소멸
		
		local touchedConnection
		touchedConnection = partDrop.Touched:Connect(function(partHit)
			local modelTarget = partHit:FindFirstAncestorOfClass("Model")
			local player = modelTarget and game:GetService("Players"):GetPlayerFromCharacter(modelTarget)
			if player then
				-- 물리 획득 시, 즉시 등에 짊어지는(Carry) 모드로 연동
				local success = CoreBlock.carryBlock(player, partDrop)
				if success then
					touchedConnection:Disconnect()
				else
					-- 짊어지기 실패(스택 꽉 참 등) 시 일반 리더스탯으로 환원 지급 백업
					local leaderstats = player:FindFirstChild("leaderstats")
					local resource = leaderstats and (
						leaderstats:FindFirstChild(strResourceType) or 
						leaderstats:FindFirstChild("Wood") or 
						leaderstats:FindFirstChild("Gold")
					)
					if resource then
						resource.Value = resource.Value + partDrop:GetAttribute("Value")
						play_block_effect(partDrop, brickColor.Name)
						touchedConnection:Disconnect()
						partDrop:Destroy()
					end
				end
			end
		end)
	end
end

-- --------------------------------------------------------------------------------
-- [Helper] 플레이어 캐릭터 등 짊어지기 폴더 보장
-- --------------------------------------------------------------------------------
local function get_or_create_carry_folder(character)
	local folder = character:FindFirstChild("CarriedResources")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "CarriedResources"
		folder.Parent = character
		
		-- 캐릭터 사망 시 짊어지고 있던 현물 자원을 모두 바닥에 쏟아버림 (마인크래프트 효과)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				for _, part in ipairs(folder:GetChildren()) do
					local weld = part:FindFirstChildOfClass("WeldConstraint")
					if weld then weld:Destroy() end
					
					part.Parent = workspace
					part.Size = part:GetAttribute("OriginalSize") or Vector3.new(3, 3, 3)
					part.CanCollide = true
					part.Anchored = false
					part:SetAttribute("IsCarried", false)
					
					-- 드롭 물리 탄도
					local angle = math.rad(math.random(0, 360))
					local force = math.random(6, 12)
					part.AssemblyLinearVelocity = Vector3.new(
						math.cos(angle) * force,
						math.random(10, 18),
						math.sin(angle) * force
					)
					
					-- 재생성 프롬프트 재연결
					local prompt = part:FindFirstChildOfClass("ProximityPrompt")
					if prompt then prompt.Enabled = true end
					
					game:GetService("Debris"):AddItem(part, 20)
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
	
	local partBlock = Instance.new(ePhysical.PART)
	partBlock.Name = "CoreBlock"
	
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
	partBlock:SetAttribute("MaxHealth", maxHealth)
	partBlock:SetAttribute("Health", maxHealth)
	partBlock:SetAttribute("ResourceYield", tblProps.ResourceYield or 10)
	partBlock:SetAttribute("ResourceType", tblProps.ResourceType or "Gold")
	partBlock:SetAttribute("Damage", tblProps.Damage or 20)
	partBlock:SetAttribute("IsMining", false)
	partBlock:SetAttribute("IsProjectile", false)
	partBlock:SetAttribute("IsCarried", false)
	
	-- 플래그 설정
	local canMine = (tblProps.CanMine ~= nil and tblProps.CanMine or true)
	local canTakeDamage = (tblProps.CanTakeDamage ~= nil and tblProps.CanTakeDamage or true)
	partBlock:SetAttribute("CanMine", canMine)
	partBlock:SetAttribute("CanTakeDamage", canTakeDamage)

	-- 엄폐물 대미지 콜백 적용
	local function take_damage(numberDamage)
		if not partBlock:GetAttribute("CanTakeDamage") then return end
		if partBlock:GetAttribute("Health") <= 0 then return end
		if partBlock:GetAttribute("IsCarried") == true then return end
		
		local currentHealth = partBlock:GetAttribute("Health")
		local nextHealth = math.max(0, currentHealth - numberDamage)
		partBlock:SetAttribute("Health", nextHealth)
		
		play_block_effect(partBlock, partBlock.BrickColor.Name)
		partBlock.Transparency = 0.8 * (1 - (nextHealth / partBlock:GetAttribute("MaxHealth")))
		
		if nextHealth <= 0 then
			play_block_effect(partBlock, "Bright red")
			-- 파괴될 때 물리적으로 잔여 자원 파편 드랍
			spawn_drop_resources(partBlock.Position, partBlock:GetAttribute("ResourceYield"), partBlock:GetAttribute("ResourceType"))
			partBlock:Destroy()
		end
	end
	
	partBlock:SetAttribute("DamageCallback", function(amount)
		take_damage(amount)
	end)
	
	partBlock:GetAttributeChangedSignal("Health"):Connect(function()
		local hp = partBlock:GetAttribute("Health")
		if hp and hp <= 0 then
			play_block_effect(partBlock, "Bright red")
			spawn_drop_resources(partBlock.Position, partBlock:GetAttribute("ResourceYield"), partBlock:GetAttribute("ResourceType"))
			partBlock:Destroy()
		end
	end)

	-- 자원 상호작용 바인딩 (등에 짊어지기 수행)
	if canMine then
		local clickDetector = EngineEnsure.ensureClickDetector(partBlock, 15)
		
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = "CoreBlock"
		proximityPrompt.ActionText = "등에 메기"
		proximityPrompt.HoldDuration = 0.5
		proximityPrompt.MaxActivationDistance = 12
		proximityPrompt.Parent = partBlock
		
		local function perform_carry(player)
			if partBlock:GetAttribute("IsMining") == true or 
			   partBlock:GetAttribute("IsProjectile") == true or 
			   partBlock:GetAttribute("IsCarried") == true then 
				return 
			end
			
			local success = CoreBlock.carryBlock(player, partBlock)
			if not success then
				-- 소지 제한 피드백 (빨간 스파크)
				play_block_effect(partBlock, "Bright red")
			end
		end
		
		clickDetector.MouseClick:Connect(perform_carry)
		proximityPrompt.Triggered:Connect(perform_carry)
	end
	
	return partBlock
end

-- --------------------------------------------------------------------------------
-- [Core 2] 자원 벽돌을 플레이어 등에 WeldConstraint로 부착 및 스태킹
-- --------------------------------------------------------------------------------
function CoreBlock.carryBlock(player, partBlock)
	local character = player.Character
	if not character then return false end
	
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then return false end
	
	local folder = get_or_create_carry_folder(character)
	local currentCount = #folder:GetChildren()
	if currentCount >= MAX_STACK then
		return false
	end
	
	-- 상호작용 프롬프트 일시 정지
	local prompt = partBlock:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt.Enabled = false end
	local click = partBlock:FindFirstChildOfClass("ClickDetector")
	if click then click.Enabled = false end
	
	-- 원형 크기 기록 및 짊어지기용 축소
	local originalSize = partBlock:GetAttribute("OriginalSize") or partBlock.Size
	partBlock:SetAttribute("OriginalSize", originalSize)
	partBlock.Size = Vector3.new(1.8, 0.8, 1.2) -- 등에 붙는 아담한 큐브 형태
	partBlock.CanCollide = false
	partBlock.Anchored = false
	partBlock.Massless = true
	partBlock:SetAttribute("IsCarried", true)
	partBlock.Parent = folder
	
	-- Weld 연결
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = partBlock
	weld.Parent = partBlock
	
	-- 가로 적재(Stacking) 좌표 연출
	local blockHeight = partBlock.Size.Y + 0.1
	local offsetZ = 0.9 -- 등 바로 뒤
	local offsetY = (currentCount * blockHeight) - (torso.Size.Y / 2) + 0.4
	
	partBlock.CFrame = torso.CFrame * CFrame.new(0, offsetY, offsetZ) * CFrame.Angles(0, math.rad(90), 0)
	
	play_block_effect(torso, partBlock.BrickColor.Name)
	return true
end

-- --------------------------------------------------------------------------------
-- [Core 3] 등에 메고 있는 벽돌 하나를 플레이어 앞쪽에 드롭 (창고 적재용)
-- --------------------------------------------------------------------------------
function CoreBlock.dropCarriedBlock(player)
	local character = player.Character
	if not character then return nil end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	
	local folder = character:FindFirstChild("CarriedResources")
	if not folder then return nil end
	
	local carried = folder:GetChildren()
	if #carried <= 0 then return nil end
	
	-- 맨 위에 스택된 블록 선택
	local partBlock = carried[#carried]
	
	local weld = partBlock:FindFirstChildOfClass("WeldConstraint")
	if weld then weld:Destroy() end
	
	-- 원래 크기 및 충돌 복구
	local originalSize = partBlock:GetAttribute("OriginalSize") or Vector3.new(3, 3, 3)
	partBlock.Size = originalSize
	partBlock.CanCollide = true
	partBlock.Anchored = false
	partBlock.Massless = false
	partBlock:SetAttribute("IsCarried", false)
	partBlock.Parent = workspace
	
	-- 플레이어 전방 3.5스터드 앞에 물리 드랍
	partBlock.CFrame = root.CFrame * CFrame.new(0, 0.5, -3.5)
	partBlock.AssemblyLinearVelocity = root.CFrame.LookVector * 10 + Vector3.new(0, 8, 0)
	
	-- 프롬프트 활성화
	local prompt = partBlock:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Enabled = true
	else
		prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = "CoreBlock"
		prompt.ActionText = "등에 메기"
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = 12
		prompt.Parent = partBlock
		prompt.Triggered:Connect(function(interactor)
			CoreBlock.carryBlock(interactor, partBlock)
		end)
	end
	
	local click = partBlock:FindFirstChildOfClass("ClickDetector")
	if click then
		click.Enabled = true
	end
	
	play_block_effect(partBlock, partBlock.BrickColor.Name)
	return partBlock
end

-- --------------------------------------------------------------------------------
-- [Core 4] 등에 메고 있는 벽돌 하나를 소모하여 지정 위치에 벽(Cover) 조립/신축
-- --------------------------------------------------------------------------------
function CoreBlock.buildBlockFromCarried(player, cframeTarget, tblAppearance)
	local character = player.Character
	if not character then return nil end
	
	local folder = character:FindFirstChild("CarriedResources")
	if not folder then return nil end
	
	local carried = folder:GetChildren()
	if #carried <= 0 then return nil end
	
	-- 탑 스택 자원 소모
	local partCarried = carried[#carried]
	local resourceType = partCarried:GetAttribute("ResourceType") or "Gold"
	local resourceYield = partCarried:GetAttribute("ResourceYield") or 10
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
	play_block_effect(partWall, tblProps.BrickColor.Name)
	
	return partWall
end

-- --------------------------------------------------------------------------------
-- [Core 5] 블록 발사 기능 (투사체 역할 가동 및 넉백 지원)
-- --------------------------------------------------------------------------------
function CoreBlock.launch(partBlock, vectorVelocity, playerAttacker, numberDamage, tblKnockback)
	if not partBlock or not partBlock:IsA("BasePart") then return end
	
	partBlock:SetAttribute("IsProjectile", true)
	partBlock:SetAttribute("CanMine", false)
	partBlock.Anchored = false
	partBlock.CanCollide = true
	
	local prompt = partBlock:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt:Destroy() end
	local click = partBlock:FindFirstChildOfClass("ClickDetector")
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
		
		local damage = numberDamage or partBlock:GetAttribute("Damage") or 20
		local resourceYield = partBlock:GetAttribute("ResourceYield") or 10
		local resourceType = partBlock:GetAttribute("ResourceType") or "Gold"
		local pos = partBlock.Position
		
		play_block_effect(partBlock, partBlock.BrickColor.Name)
		
		-- 캐릭터 피격 및 넉백
		local modelTarget = partHit:FindFirstAncestorOfClass("Model")
		local humanoidTarget = modelTarget and modelTarget:FindFirstChildOfClass("Humanoid")
		local partTargetRoot = modelTarget and modelTarget:FindFirstChild("HumanoidRootPart")
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
		
		-- 타 방벽 엄폐물 피격
		local damageCallback = partHit:GetAttribute("DamageCallback")
		if damageCallback and type(damageCallback) == "function" then
			damageCallback(damage * 1.5)
		end
		
		-- 투사체 부서지며 물리 자원 조각 스폰
		spawn_drop_resources(pos, math.floor(resourceYield * 0.5), resourceType)
		partBlock:Destroy()
	end)
	
	game:GetService("Debris"):AddItem(partBlock, 10)
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


