extends GutTest

const AttackBehavior = preload("res://Model/CardData/CardBehaviorData/AttackBehavior.gd")
const AttributeBehavior = preload("res://Model/CardData/CardBehaviorData/AttributeBehavior.gd")
const AttributeEffect = preload("res://Model/CardData/CardBehaviorData/AttriubuteEffect.gd")
const ProtocolCard = preload("res://Model/CardData/BaseCardData/protocol_card_base.gd")
const BattleScenario = preload("res://Model/ScenarioData/ScenarioBases/BattleScenario.gd")
const Scenario = preload("res://Model/ScenarioData/ScenarioBases/Scenario.gd")

var _game_manager_player_backup: Player = null

# -------------------------
# Test doubles
# -------------------------

class TestEnemy:
	extends Enemy
	

	var hp := 10

	func isDefeated() -> bool:
		return hp <= 0

	func damageEnemy(dmg: int) -> void:
		hp = max(0, hp - dmg)

	func click() -> void:
		emit_signal("clicked", self)


class TestScenarioNonBattle:
	extends Scenario

	func _init():
		scenarioType = Scenario.ScenarioType.EVENT

	func performScenarioEffect() -> void:
		pass

	func getWinCondition() -> String:
		return ""


class TestBattleScenario:
	extends BattleScenario

	func _ready() -> void:
		# prevent real _ready from trying to spawn enemies / play animations
		pass

	func _init():
		scenarioType = Scenario.ScenarioType.BATTLE
		enemyList = []
		attributeWinConditions = []
		affectedAttributes = []


class TestPlayerStub:
	extends Player

	func setHullIntegrity(amount: float) -> void:
		hullIntegrity = clampf(hullIntegrity + amount, 0.0, float(HULL_INTEGRITY_MAX))

	func setPower(amount: float) -> void:
		power = clampf(power + amount, 0.0, float(POWER_MAX))

	func setVelocity(amount: float) -> void:
		velocity = clampf(velocity + amount, 0.0, float(VELOCITY_MAX))

# -------------------------
# Helpers
# -------------------------

func setup_targeting_state(battle: TestBattleScenario, targets: int, enemy: TestEnemy) -> void:
	# Make controller point at our scenario
	TargetController.targetingActive = true
	TargetController.currentScenario = battle
	TargetController.remainingTargets = targets

	# In the real flow beginTargeting connects enemy.clicked -> TargetController.onEnemyClicked
	# We do it manually to avoid beginTargeting's tween/await
	if not enemy.clicked.is_connected(Callable(TargetController, "onEnemyClicked")):
		enemy.clicked.connect(Callable(TargetController, "onEnemyClicked"))

	# Provide the enemy list so endTargeting/checkEarlyScenarioEnd work
	battle.enemyList = [enemy]


func before_each():
	TargetController.targetingActive = false
	TargetController.remainingTargets = 0
	TargetController.currentScenario = null

	# IMPORTANT: make sure getScenario never returns null unless a test wants it to
	GameManager.scenario = TestScenarioNonBattle.new()

	GameManager.scenarioHeader = Label.new()
	add_child_autofree(GameManager.scenarioHeader)

func after_each():
	TargetController.endTargeting()
	GameManager.scenarioHeader = null
	GameManager.scenario = null
	if _game_manager_player_backup != null:
		GameManager.player = _game_manager_player_backup
		_game_manager_player_backup = null

# =========================================================
# SF-C-12: Battle behaviors only usable in Battle scenarios
# =========================================================
func test_SF_C_12_attack_behavior_only_playable_in_battle_scenarios():
	var attack := AttackBehavior.new()
	attack.targets = 1
	attack.damage = 3

	# Non-battle scenario -> not playable
	var non_battle := TestScenarioNonBattle.new()
	GameManager.scenario = non_battle
	assert_false(attack.isCardPlayable())

	# Battle scenario with an alive enemy -> playable
	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 10
	battle.enemyList = [e]

	GameManager.scenario = battle
	assert_true(attack.isCardPlayable())


# =========================================================
# SF-C-16: Only battle (attack) behaviors affect enemy HP; attribute cards do not.
# Production code: damageEnemy is only invoked from AttackBehavior.onEnemyClicked.
# =========================================================
func test_SF_C_16_attribute_behavior_in_battle_does_not_affect_enemy_hp():
	_game_manager_player_backup = GameManager.player
	GameManager.player = TestPlayerStub.new()

	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 10
	battle.enemyList = [e]
	GameManager.scenario = battle

	var effect := AttributeEffect.new()
	effect.affectedAttribute = AttributeEffect.AttributeTypes.HULL_INTEGRITY
	effect.amount = 5.0

	var attr := AttributeBehavior.new()
	attr.affectedAttributes = [effect]

	assert_true(attr.isCardPlayable())
	assert_true(attr.use())
	assert_eq(e.hp, 10)
	assert_eq(GameManager.player.hullIntegrity, 105.0)


func test_SF_C_16_protocol_card_with_only_attribute_behaviors_does_not_affect_enemy_hp():
	_game_manager_player_backup = GameManager.player
	GameManager.player = TestPlayerStub.new()

	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 10
	battle.enemyList = [e]
	GameManager.scenario = battle

	var effect := AttributeEffect.new()
	effect.affectedAttribute = AttributeEffect.AttributeTypes.POWER
	effect.amount = 3.0

	var attr := AttributeBehavior.new()
	attr.affectedAttributes = [effect]

	var card := ProtocolCard.new()
	card.cardBehavior = [attr]

	assert_true(card.isCardPlayable())
	await card.use()
	assert_eq(e.hp, 10)
	assert_eq(GameManager.player.power, 103.0)


# =========================================================
# SF-C-13: Using battle card enters targeting; clicking consumes target + damages
# =========================================================
func test_SF_C_13_click_enemy_consumes_target_and_damages():
	var attack := AttackBehavior.new()
	attack.targets = 2
	attack.damage = 4

	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 10

	# Simulate AttackBehavior's connection: TargetController.enemyClicked -> attack.onEnemyClicked
	if not TargetController.enemyClicked.is_connected(Callable(attack, "onEnemyClicked")):
		TargetController.enemyClicked.connect(Callable(attack, "onEnemyClicked"))

	setup_targeting_state(battle, 2, e)

	# Click once
	e.click()
	await get_tree().process_frame
	assert_eq(e.hp, 6)
	assert_eq(TargetController.remainingTargets, 1)
	assert_true(TargetController.targetingActive)

	# Click twice
	e.click()
	await get_tree().process_frame
	assert_eq(e.hp, 2)
	assert_eq(TargetController.remainingTargets, 0)


# =========================================================
# SF-C-14: When targets are used up, exit targeting state
# AND (in your architecture) player-turn can proceed via Continue control.
# Unit-level: verify targetingCompleted emitted + targetingActive false.
# =========================================================
func test_SF_C_14_after_last_target_targeting_completes_and_exits():
	var attack := AttackBehavior.new()
	attack.targets = 1
	attack.damage = 1

	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 10

	if not TargetController.enemyClicked.is_connected(Callable(attack, "onEnemyClicked")):
		TargetController.enemyClicked.connect(Callable(attack, "onEnemyClicked"))

	var completed := {"v": false}
	TargetController.targetingCompleted.connect(func(): completed["v"] = true, CONNECT_ONE_SHOT)

	setup_targeting_state(battle, 1, e)

	TargetController.onEnemyClicked(e)
	await get_tree().process_frame

	assert_true(completed["v"])
	assert_false(TargetController.targetingActive)
	assert_eq(e.mouse_filter, Control.MOUSE_FILTER_IGNORE)



# =========================================================
# SF-C-15: If targeting has remaining targets but no enemies left,
# exit targeting and end scenario.
#
# Your controller already exits targeting early.
# Your scenario ends when performScenarioEffect() runs and checkWinCondition() is true.
# So we assert BOTH:
#  - targeting ends early
#  - performScenarioEffect emits scenarioWon after enemies are dead
# =========================================================
func test_SF_C_15_no_enemies_left_exits_targeting_early_and_scenario_wins_on_next_effect():
	var attack := AttackBehavior.new()
	attack.targets = 3
	attack.damage = 999

	var battle := TestBattleScenario.new()
	var e := TestEnemy.new()
	e.hp = 5

	if not TargetController.enemyClicked.is_connected(Callable(attack, "onEnemyClicked")):
		TargetController.enemyClicked.connect(Callable(attack, "onEnemyClicked"))

	var completed := {"v": false}
	TargetController.targetingCompleted.connect(func(): completed["v"] = true, CONNECT_ONE_SHOT)

	setup_targeting_state(battle, 3, e)

	TargetController.onEnemyClicked(e)
	await get_tree().process_frame

	assert_true(e.isDefeated())
	assert_true(completed["v"])
	assert_false(TargetController.targetingActive)
	assert_eq(TargetController.remainingTargets, 2)

	var won := {"v": false}
	battle.scenarioWon.connect(func(): won["v"] = true, CONNECT_ONE_SHOT)

	battle.performScenarioEffect()
	assert_true(won["v"])


# Bailout card must get real DefaultBehavior at runtime (same as Player.drawCard for defaultCard).
func test_quantum_default_card_scene_is_playable_with_hint():
	var scene := preload("res://Model/CardData/Cards/QuantumCoinFliptscn.tscn")
	var card := scene.instantiate() as ProtocolCard
	assert_not_null(card)
	card.apply_default_bailout_behavior()
	assert_false(card.cardBehavior.is_empty())
	assert_true(card.isCardPlayable())
	var hint := card.getCardHint()
	assert_true("beat" in hint.to_lower() or "/" in hint)
	card.queue_free()
