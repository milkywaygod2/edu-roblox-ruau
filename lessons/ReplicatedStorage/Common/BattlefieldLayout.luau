-- [Module] BattlefieldLayout
local BattlefieldLayout = {}

BattlefieldLayout.VECTOR_BATTLEFIELD_BASE_SIZE = Vector3.new(330, 1, 270)

BattlefieldLayout.tblOutpostBattleWorldLayout = {
	NEUTRAL_RESPAWN_HEIGHT = 4,
	ROUND_START_BUTTON = Vector3.new(-132, 0.5, 0),
	BUILD_BUTTON = Vector3.new(0, 0.5, 54),
	WALL_SPAWN = Vector3.new(0, 0.1, 72),
	BLUE_SPAWN = Vector3.new(0, 0.5, 114),
	RED_SPAWN = Vector3.new(0, 0.5, -114),
	BLUE_CORE = Vector3.new(0, 3, 96),
	RED_CORE = Vector3.new(0, 3, -96),
}

BattlefieldLayout.tblThrowingStoneSpawnPositions = {
	Vector3.new(-108, 0.1, 78),
	Vector3.new(-72, 0.1, 84),
	Vector3.new(-36, 0.1, 78),
	Vector3.new(0, 0.1, 78),
	Vector3.new(36, 0.1, 78),
	Vector3.new(72, 0.1, 84),
	Vector3.new(108, 0.1, 78),
	Vector3.new(-126, 0.1, 42),
	Vector3.new(-84, 0.1, 45),
	Vector3.new(-42, 0.1, 42),
	Vector3.new(42, 0.1, 42),
	Vector3.new(84, 0.1, 45),
	Vector3.new(126, 0.1, 42),
	Vector3.new(-108, 0.1, 6),
	Vector3.new(-54, 0.1, 9),
	Vector3.new(0, 0.1, 12),
	Vector3.new(54, 0.1, 9),
	Vector3.new(108, 0.1, 6),
	Vector3.new(-126, 0.1, -42),
	Vector3.new(-84, 0.1, -45),
	Vector3.new(-42, 0.1, -42),
	Vector3.new(42, 0.1, -42),
	Vector3.new(84, 0.1, -45),
	Vector3.new(126, 0.1, -42),
	Vector3.new(-108, 0.1, -78),
	Vector3.new(-72, 0.1, -84),
	Vector3.new(-36, 0.1, -78),
	Vector3.new(36, 0.1, -78),
	Vector3.new(72, 0.1, -84),
	Vector3.new(108, 0.1, -78),
}

return BattlefieldLayout
