-- [Module] FinalBattle
local FinalBattle = {}

local EngineEnsure = require(script.Parent.EngineEnsure)
local CoreEnums = require(script.Parent.CoreEnums)
local FieldItem = require(script.Parent.FieldItem)
local StudentConfig = require(script.Parent.StudentConfig)

-- --------------------------------------------------------------------------------
function FinalBattle.installFinalBattleSystem(svcWorkspace, svcPlayers, tblConfig) -- [의미/의도] 최종 라운드 서버 시스템 설치 함수 정의 ➔ 팀 스폰/라운드 타이머/상태 Attribute를 공통 서버 코드가 책임지게 하기 위함
	local eService = CoreEnums.eEngineServiceSingleton
	local ePhysical = CoreEnums.eEnginePhysicalType
	local eLogical = CoreEnums.eEngineLogicalType
	local eAttrKey = CoreEnums.eEngineAttributeKey
	local eRoundState = CoreEnums.eRoundStateValue
	local svcTeams = game:GetService(eService.TEAMS)
	local tblOutpostWorld = EngineEnsure.waitForOutpostBattleWorld(svcWorkspace)
	local fldBattlefield = tblOutpostWorld.fldBattlefield
	local fldObjectiveArea = tblOutpostWorld.fldObjectiveArea
	local fldItemSpawnArea = tblOutpostWorld.fldItemSpawnArea
	local partRoundStartButton = fldBattlefield:WaitForChild(eLogical.ROUND_START_BUTTON)
	if not EngineEnsure.markRuntimeInstalled(partRoundStartButton, "RuntimeInstalled_FinalBattle") then
		return
	end

	local intRoundTime = StudentConfig.readConfigInteger(tblConfig, "RoundTime", 180, 30, 600)
	local numberRespawnHeight = StudentConfig.readConfigNumber(tblConfig, "RespawnHeight", 4, 1, 12)
	local numberCoreHealth = StudentConfig.readConfigNumber(tblConfig, "CoreHealth", 160, 50, 500)
	local boolRoundRunning = false

	local function ensure_team(strTeamName, strColorName)
		local teamInstance = svcTeams:FindFirstChild(strTeamName) or Instance.new(ePhysical.TEAM)
		teamInstance.Name = strTeamName
		teamInstance.TeamColor = BrickColor.new(strColorName)
		teamInstance.AutoAssignable = false
		teamInstance.Parent = svcTeams
		return teamInstance
	end

	local function ensure_team_spawn(strTeamName, vectorPosition, strColorName)
		return EngineEnsure.ensureSpawnLocation(eLogical.SPAWN_POINT_PREFIX .. strTeamName, fldBattlefield, {
			Size = Vector3.new(8, 1, 8),
			Position = vectorPosition,
			BrickColor = BrickColor.new(strColorName),
			Material = Enum.Material.Neon,
			Neutral = false,
			TeamColor = BrickColor.new(strColorName),
		})
	end

	local function ensure_team_core(strTeamName, vectorPosition, strColorName)
		local modelCore, partCoreRoot, humCore = EngineEnsure.ensureHumanoidTarget(eLogical.OUTPOST_CORE_PREFIX .. strTeamName, fldObjectiveArea, {
			Size = Vector3.new(6, 6, 4),
			Position = vectorPosition,
			BrickColor = BrickColor.new(strColorName),
		}, {
			MaxHealth = numberCoreHealth,
			Health = numberCoreHealth,
		})

		if humCore.Health <= 0 then
			humCore:Destroy()
			humCore = EngineEnsure.ensureNamedInstance(ePhysical.HUMANOID, ePhysical.HUMANOID, modelCore, {
				MaxHealth = numberCoreHealth,
				Health = numberCoreHealth,
			})
		end

		partCoreRoot.BrickColor = BrickColor.new(strColorName)
		humCore.MaxHealth = numberCoreHealth
		humCore.Health = numberCoreHealth
		return humCore
	end

	local teamBlue = ensure_team(eLogical.TEAM_BLUE, "Bright blue")
	local teamRed = ensure_team(eLogical.TEAM_RED, "Bright red")
	local partSpawnBlue = ensure_team_spawn(eLogical.TEAM_BLUE, Vector3.new(0, 0.5, 38), "Bright blue")
	local partSpawnRed = ensure_team_spawn(eLogical.TEAM_RED, Vector3.new(0, 0.5, -38), "Bright red")
	local boolPreferBlueForOddRound = true

	local function count_team_players(teamTarget)
		local intCount = 0
		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			if playerPlayer.Team == teamTarget then
				intCount += 1
			end
		end
		return intCount
	end

	local function pick_open_team(intBlueCount, intRedCount, boolPreferBlue)
		if intBlueCount < intRedCount then return teamBlue end
		if intRedCount < intBlueCount then return teamRed end
		if boolPreferBlue then return teamBlue end
		return teamRed
	end

	local function apply_player_team(playerPlayer, teamTarget)
		playerPlayer.Neutral = false
		playerPlayer.Team = teamTarget
	end

	local function assign_player_to_open_team(playerPlayer)
		local teamTarget = pick_open_team(count_team_players(teamBlue), count_team_players(teamRed), boolPreferBlueForOddRound)
		apply_player_team(playerPlayer, teamTarget)
	end

	local function assign_round_teams()
		local intBlueCount = 0
		local intRedCount = 0

		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			local teamTarget = pick_open_team(intBlueCount, intRedCount, boolPreferBlueForOddRound)
			apply_player_team(playerPlayer, teamTarget)
			if teamTarget == teamBlue then
				intBlueCount += 1
			elseif teamTarget == teamRed then
				intRedCount += 1
			end
		end

		svcWorkspace:SetAttribute(eAttrKey.ROUND_BLUE_PLAYER_COUNT_RUNTIME, intBlueCount)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_RED_PLAYER_COUNT_RUNTIME, intRedCount)
		if (intBlueCount + intRedCount) % 2 == 1 then
			boolPreferBlueForOddRound = not boolPreferBlueForOddRound
		end
	end

	local function get_spawn_for_player(playerPlayer)
		if playerPlayer.Team == teamBlue then return partSpawnBlue end
		if playerPlayer.Team == teamRed then return partSpawnRed end
		return nil
	end

	local function move_player_to_team_spawn(playerPlayer)
		local partSpawn = get_spawn_for_player(playerPlayer)
		if not partSpawn then return end

		playerPlayer:LoadCharacter()
		local modelCharacter = playerPlayer.Character or playerPlayer.CharacterAdded:Wait()
		local partHumanoidRoot = modelCharacter:WaitForChild(eLogical.RESERVED_HUMANOID_ROOT_PART, 5)
		if partHumanoidRoot then
			partHumanoidRoot.CFrame = CFrame.new(partSpawn.Position + Vector3.new(0, numberRespawnHeight, 0))
		end
	end

	local function move_players_to_team_spawns()
		for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
			move_player_to_team_spawn(playerPlayer)
		end
	end

	local function get_core_health(strTeamName)
		local modelCore = fldObjectiveArea:FindFirstChild(eLogical.OUTPOST_CORE_PREFIX .. strTeamName)
		local humCore = modelCore and modelCore:FindFirstChildOfClass(ePhysical.HUMANOID)
		if not humCore then return 0 end
		return humCore.Health
	end

	local function get_destroyed_core_winner()
		local numberBlueHealth = get_core_health(eLogical.TEAM_BLUE)
		local numberRedHealth = get_core_health(eLogical.TEAM_RED)

		if numberBlueHealth <= 0 and numberRedHealth <= 0 then return "Draw", "BothCoresDestroyed" end
		if numberBlueHealth <= 0 then return eLogical.TEAM_RED, "BlueCoreDestroyed" end
		if numberRedHealth <= 0 then return eLogical.TEAM_BLUE, "RedCoreDestroyed" end
		return nil, nil
	end

	local function get_time_limit_winner()
		local numberBlueHealth = get_core_health(eLogical.TEAM_BLUE)
		local numberRedHealth = get_core_health(eLogical.TEAM_RED)

		if numberBlueHealth > numberRedHealth then return eLogical.TEAM_BLUE, "TimeLimitCoreHealth" end
		if numberRedHealth > numberBlueHealth then return eLogical.TEAM_RED, "TimeLimitCoreHealth" end
		return "Draw", "TimeLimitDraw"
	end

	local function finish_round(strWinner, strReason)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_WINNER_RUNTIME, strWinner)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_END_REASON_RUNTIME, strReason)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.FINISHED)
		boolRoundRunning = false
	end

	local function start_round(playerPlayer)
		if boolRoundRunning then return end

		boolRoundRunning = true
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STARTER_PLAYER_NAME_RUNTIME, playerPlayer.Name)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PREPARING)
		svcWorkspace:SetAttribute(eAttrKey.ROUND_WINNER_RUNTIME, "None")
		svcWorkspace:SetAttribute(eAttrKey.ROUND_END_REASON_RUNTIME, "None")
		ensure_team_core(eLogical.TEAM_BLUE, Vector3.new(0, 3, 32), "Bright blue")
		ensure_team_core(eLogical.TEAM_RED, Vector3.new(0, 3, -32), "Bright red")
		FieldItem.resetFieldToolPickupsToWorld(svcPlayers, fldItemSpawnArea)
		assign_round_teams()
		move_players_to_team_spawns()

		svcWorkspace:SetAttribute(eAttrKey.ROUND_STATE, eRoundState.PLAYING)
		for intTimeLeft = intRoundTime, 0, -1 do
			svcWorkspace:SetAttribute(eAttrKey.TIME_LEFT_RUNTIME, intTimeLeft)
			local strWinner, strReason = get_destroyed_core_winner()
			if strWinner then
				finish_round(strWinner, strReason)
				return
			end

			task.wait(1)
		end

		local strWinner, strReason = get_time_limit_winner()
		finish_round(strWinner, strReason)
	end

	for _, playerPlayer in ipairs(svcPlayers:GetPlayers()) do
		assign_player_to_open_team(playerPlayer)
	end

	svcPlayers.PlayerAdded:Connect(function(playerPlayer)
		assign_player_to_open_team(playerPlayer)
		if boolRoundRunning then
			task.defer(move_player_to_team_spawn, playerPlayer)
		end
	end)

	EngineEnsure.ensureClickDetector(partRoundStartButton, 30).MouseClick:Connect(start_round)
end


-- --------------------------------------------------------------------------------


return FinalBattle
