extends Control

@export var psycheMissionLink := "https://psyche.ssl.berkeley.edu/"
@export var cardGameLink := "https://psyche.ssl.berkeley.edu/gallery/psyche-against-the-universe/"
@export var capstoneLink := "https://psyche.ssl.berkeley.edu/get-involved/capstone-projects/"



func _on_nasa_psyche_mission_link_pressed() -> void:
	OS.shell_open(psycheMissionLink)


func _on_card_game_link_pressed() -> void:
	OS.shell_open(cardGameLink)


func _on_capstone_portal_link_pressed() -> void:
	OS.shell_open(capstoneLink)
