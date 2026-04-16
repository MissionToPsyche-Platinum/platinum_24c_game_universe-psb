extends GutTest

var stats_view

func before_each():
	var scene: PackedScene = load("res://Model/ScreenData/WinScreen.tscn")
	# Inject
	var stats = StatsController.new()
	stats.model = StatsModel.new()
	stats.model.cards_used = 10
	stats.model.total_encounters = 5
	stats.model.hullIntegrity = 200
	stats.model.power = 200
	stats.model.velocity = 200
	GameManager.stats = stats

	# instantiate
	stats_view = scene.instantiate()
	add_child(stats_view)

	await get_tree().process_frame


func after_each():
	stats_view.queue_free()

func test_calc_score_returns_expected_value():
	var score = stats_view.calc_score()

	assert_gt(score, 0, "Score should be greater than 0")

func test_get_grade_thresholds():
	assert_eq(stats_view.get_grade(5000), "P")
	assert_eq(stats_view.get_grade(4200), "S")
	assert_eq(stats_view.get_grade(3000), "A")
	assert_eq(stats_view.get_grade(2300), "B")
	assert_eq(stats_view.get_grade(1700), "C")
	assert_eq(stats_view.get_grade(1200), "D")
	assert_eq(stats_view.get_grade(100), "F")

func test_attribute_percent_format():
	var percent = stats_view.get_attrib_percent()

	assert_true(percent.ends_with("%"), "Should include percent sign")

func test_update_view_updates_labels():
	stats_view.update_view()
	await get_tree().process_frame

	assert_ne(stats_view.scoreLabel.text, "", "Score label should not be empty")
	assert_ne(stats_view.gradeLabel.text, "", "Grade label should not be empty")
	assert_ne(stats_view.attributeLabel.text, "", "Attribute label should not be empty")

func test_grade_color_applied():
	stats_view.update_view()
	await get_tree().process_frame

	var grade = stats_view.gradeLabel.text
	var expected_color = Color(stats_view.GRADE_COLORS[grade])
	var actual_color = stats_view.gradeLabel.label_settings.font_color

	assert_eq(actual_color, expected_color, "Grade color should match table")
