extends Control

# Player stat label vars
@onready var attributeLabel = $AttributeLabel
@onready var cardsLabel = $CardLabel
@onready var encountersLabel = $EncounterLabel

# Score and grade labels
@onready var gradeLabel = $CenterContainer/GradeLabel
@onready var scoreLabel = $CenterContainer2/ScoreLabel

# Tables for grade, score and subscore ranges
# Format = { min, max, score }
const ENCOUNTER_TABLE = [
	{ "min": 10, "max": INF, "score": 1500 },
	{ "min": 7, "max": 9, "score": 1000 },
	{ "min": 6, "max": 6, "score": 800 },
	{ "min": 5, "max": 5, "score": 600 },
	{ "min": 2, "max": 4, "score": 400 },
	{ "min": 0, "max": 1, "score": 200 },
]

const ATTRIBUTE_TABLE = [
	{ "min": 600, "max": INF, "score": 1500 },
	{ "min": 500, "max": 599, "score": 1000 },
	{ "min": 400, "max": 499, "score": 800 },
	{ "min": 200, "max": 399, "score": 600 },
	{ "min": 100, "max": 199, "score": 400 },
	{ "min": 0, "max": 99, "score": 200 },
]

const AVG_CARDS_TABLE = [
	{ "min": 0.0, "max": 1.5, "score": 1500 },
	{ "min": 1.5, "max": 2.0, "score": 1000 },
	{ "min": 2.0, "max": 3.0, "score": 800 },
	{ "min": 3.0, "max": 4.0, "score": 600 },
	{ "min": 4.0, "max": 5.0, "score": 400 },
	{ "min": 5.0, "max": INF, "score": 200 },
]

const GRADE_TABLE = [
	{ "min": 4500, "grade": "P" },
	{ "min": 4000, "grade": "S" },
	{ "min": 2800, "grade": "A" },
	{ "min": 2200, "grade": "B" },
	{ "min": 1600, "grade": "C" },
	{ "min": 1000, "grade": "D" },
	{ "min": 0, "grade": "F" },
]

# Table for grade colors (psyche palette). Values chosen so text is at least 4.5:1 vs near-black UI.
const GRADE_COLORS = {
	"P": "#FFFFFF",
	"S": "#F9C84A",
	"A": "#FFB070",
	"B": "#FF8A9E",
	"C": "#E87090",
	"D": "#D0A8C8",
	"F": "#C8C0E0",
}

# Constant used to calculate attribute %
const MAXATTRIBUTE = 600


func _get_stats_model() -> StatsModel:
	if GameManager.stats == null or GameManager.stats.model == null:
		return null
	return GameManager.stats.model


func _set_placeholder_stats_view() -> void:
	cardsLabel.text = "0"
	encountersLabel.text = "0"
	attributeLabel.text = "0.00%"
	scoreLabel.text = "0"
	gradeLabel.text = "-"
	if gradeLabel.label_settings != null:
		gradeLabel.label_settings.font_color = Color.WHITE


func _ready():
	update_view()

# Retrieve and update stats, score and grade labels
func update_view():
	var sm := _get_stats_model()
	if sm == null:
		_set_placeholder_stats_view()
		return

	cardsLabel.text = str(sm.cards_used)
	encountersLabel.text = str(sm.total_encounters)
	attributeLabel.text = get_attrib_percent()

	# Score and grade
	var score := calc_score()
	scoreLabel.text = str(score)

	var grade := get_grade(score)
	gradeLabel.text = grade
	gradeLabel.label_settings.font_color = Color(GRADE_COLORS[grade])

# Helper to calculate score
func calc_score() -> int:
	var stats := _get_stats_model()
	if stats == null:
		return 0
	var encounters = stats.total_encounters
	var cards_used = stats.cards_used
	var attribute_sum = stats.hullIntegrity + stats.power + stats.velocity
	
	# Calculate average cards per scenario
	var avg_cards = 0.0
	if encounters > 0:
		avg_cards = float(cards_used) / encounters
	
	# Get individual subscores
	var encounter_score = get_score_from_table(encounters, ENCOUNTER_TABLE)
	var attribute_score = get_score_from_table(attribute_sum, ATTRIBUTE_TABLE)
	var avg_score = get_score_from_table(avg_cards, AVG_CARDS_TABLE)
	
	# Sum subscores for final score
	return encounter_score + attribute_score + avg_score

# Helper to convert score to grade
func get_grade(score: int) -> String:
	for entry in GRADE_TABLE:
		if score >= entry.min:
			return entry.grade
	return "F"

# Helper to get scores from table 
func get_score_from_table(value, table) -> int:
	for entry in table:
		if value >= entry.min and value <= entry.max:
			return entry.score
	return 0

# Helper to calculate and format attribute percentage
func get_attrib_percent() -> String:
	var stats := _get_stats_model()
	if stats == null:
		return "0.00%"
	var attribute_sum = stats.hullIntegrity + stats.power + stats.velocity
	var attribute_percent = float(attribute_sum) / MAXATTRIBUTE * 100.0
	return "%.2f%%" % attribute_percent

# Handles signal when play again button is pressed
func _on_play_again_button_pressed() -> void:
	GameManager.restartGame()
