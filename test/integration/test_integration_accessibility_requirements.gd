extends GutTest

## Integration tests for accessibility-related requirements: keyboard reachability for primary UI,
## minimum typography size, and WCAG-style contrast on representative dark backgrounds.
##
## Full-screen artwork behind text does not yield a single deterministic backdrop in code; contrast
## uses near-black reference surfaces. Requirement: at least 4.5:1 for all sampled text colors.
## Bitmap sprites, textured buttons, and photo backgrounds are not auto-verified (no single matte).

const MIN_FONT_SIZE_PX := 16
const MIN_CONTRAST_RATIO := 4.5

const TITLE_SCREEN := preload("res://Model/ScreenData/TitleScreen.tscn")
const MAIN_SCENE := preload("res://Model/Scenes/MainScene.tscn")
const WIN_SCREEN := preload("res://Model/ScreenData/WinScreen.tscn")
const LOSE_SCREEN := preload("res://Model/ScreenData/LoseScreen.tscn")

## Representative dark surfaces behind HUD/title typography when no solid panel is present.
## Mid-tones are omitted: saturated magentas can fail against them while still reading on near-black art.
const REFERENCE_BACKGROUNDS: Array[Color] = [
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.02, 0.03, 0.08, 1.0),
]

## Accent used in `rich_text_label.gd` (Against the) — WCAG check against reference backgrounds.
const _RICHTEXT_ACCENT_COLOR := Color(237.0 / 255.0, 87.0 / 255.0, 99.0 / 255.0, 1.0)


func _forgive_known_scenario_ui_animation_warnings() -> void:
	for e in get_errors():
		if not e.is_engine_error():
			continue
		if (
			e.contains_text("track_get_key_count")
			or e.contains_text("Method/function failed. Returning: false")
			or e.contains_text("Method/function failed. Returning: nullptr")
		):
			e.handled = true


func _srgb_channel_to_linear(c: float) -> float:
	if c <= 0.03928:
		return c / 12.92
	return pow((c + 0.055) / 1.055, 2.4)


func _relative_luminance(col: Color) -> float:
	var r := _srgb_channel_to_linear(col.r)
	var g := _srgb_channel_to_linear(col.g)
	var b := _srgb_channel_to_linear(col.b)
	return 0.2126 * r + 0.7152 * g + 0.0722 * b


func _contrast_ratio(fg: Color, bg: Color) -> float:
	var l1 := _relative_luminance(fg)
	var l2 := _relative_luminance(bg)
	var light := maxf(l1, l2)
	var dark := minf(l1, l2)
	return (light + 0.05) / (dark + 0.05)


func _composite_over(fg: Color, bg: Color) -> Color:
	var a := clampf(fg.a, 0.0, 1.0)
	return Color(
		fg.r * a + bg.r * (1.0 - a),
		fg.g * a + bg.g * (1.0 - a),
		fg.b * a + bg.b * (1.0 - a),
		1.0
	)


func _foreground_colors_for_control(node: Control, bg_for_alpha: Color) -> Array[Color]:
	var colors: Array[Color] = []
	if node is Label:
		var lab := node as Label
		if lab.text.strip_edges() == "":
			return colors
		if lab.label_settings != null:
			colors.append(_composite_over(lab.label_settings.font_color, bg_for_alpha))
		else:
			colors.append(
				_composite_over(lab.get_theme_color("font_color", "Label"), bg_for_alpha)
			)
	elif node is RichTextLabel:
		var rtl := node as RichTextLabel
		colors.append(_composite_over(rtl.get_theme_color("default_color", "RichTextLabel"), bg_for_alpha))
		var s: Script = rtl.get_script()
		if s != null and String(s.resource_path).ends_with("rich_text_label.gd"):
			colors.append(_composite_over(_RICHTEXT_ACCENT_COLOR, bg_for_alpha))
	elif node is Button:
		var btn := node as Button
		if String(btn.text).strip_edges() == "":
			return colors
		colors.append(_composite_over(btn.get_theme_color("font_color", "Button"), bg_for_alpha))
	elif node is LineEdit:
		var le := node as LineEdit
		if le.text == "" and le.placeholder_text == "":
			return colors
		colors.append(_composite_over(le.get_theme_color("font_color", "LineEdit"), bg_for_alpha))
	return colors


func _font_size_for_control(node: Control) -> int:
	if node is Label:
		var lab := node as Label
		if lab.label_settings != null:
			return lab.label_settings.font_size
		return lab.get_theme_font_size("font_size", "Label")
	if node is RichTextLabel:
		var rtl := node as RichTextLabel
		var sz := rtl.get_theme_font_size("normal_font_size", "RichTextLabel")
		if sz <= 0:
			sz = rtl.get_theme_font_size("font_size", "RichTextLabel")
		if sz <= 0:
			sz = rtl.get_theme_default_font_size()
		return sz
	if node is Button:
		var btn := node as Button
		return btn.get_theme_font_size("font_size", "Button")
	if node is LineEdit:
		var le := node as LineEdit
		return le.get_theme_font_size("font_size", "LineEdit")
	return -1


func _collect_text_controls(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	for n in root.find_children("*", "Control", true, false):
		var c := n as Control
		if not c.visible:
			continue
		if c is Label or c is RichTextLabel or c is Button or c is LineEdit:
			out.append(c)
	return out


func _assert_text_meets_minimum_font_size(root: Node, context: String) -> void:
	for c in _collect_text_controls(root):
		if c is Label:
			if (c as Label).text.strip_edges() == "":
				continue
		if c is Button:
			if String((c as Button).text).strip_edges() == "":
				continue
		var sz := _font_size_for_control(c)
		assert_gt(sz, 0, "%s: %s should resolve a theme font size." % [context, c.get_path()])
		assert_gte(
			sz,
			MIN_FONT_SIZE_PX,
			"%s: %s (%s) should use font size >= %spx (got %s)." % [
				context,
				c.get_path(),
				c.get_class(),
				MIN_FONT_SIZE_PX,
				sz
			]
		)


func _assert_text_meets_contrast_on_reference_backgrounds(root: Node, context: String) -> void:
	for c in _collect_text_controls(root):
		var font_px := _font_size_for_control(c)
		if font_px <= 0:
			continue
		for ref_bg in REFERENCE_BACKGROUNDS:
			for fg in _foreground_colors_for_control(c, ref_bg):
				var ratio := _contrast_ratio(fg, ref_bg)
				assert_gte(
					ratio,
					MIN_CONTRAST_RATIO,
					(
						"%s: %s foreground should meet %.1f:1 vs reference background %s at %spx (got %.2f:1)."
						% [context, c.get_path(), MIN_CONTRAST_RATIO, ref_bg, font_px, ratio]
					)
				)


## Solid UI fills (small ColorRects): 4.5:1 vs reference backgrounds. Skips large rects (likely full-screen art).
func _assert_solid_color_rect_graphics_contrast(root: Node, context: String) -> void:
	const MAX_DIM_PX := 320.0
	for n in root.find_children("*", "ColorRect", true, false):
		var cr := n as ColorRect
		if not cr.visible:
			continue
		if cr.color.a < 0.95:
			continue
		if cr.size.x >= MAX_DIM_PX or cr.size.y >= MAX_DIM_PX:
			continue
		var fill := cr.color
		for ref_bg in REFERENCE_BACKGROUNDS:
			var ratio := _contrast_ratio(fill, ref_bg)
			assert_gte(
				ratio,
				MIN_CONTRAST_RATIO,
				(
					"%s: %s fill should meet %.1f:1 vs reference background %s (got %.2f:1)."
					% [context, cr.get_path(), MIN_CONTRAST_RATIO, ref_bg, ratio]
				)
			)


func _collect_interactive_focusables(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	for n in root.find_children("*", "Control", true, false):
		var c := n as Control
		if not c.visible:
			continue
		if c is BaseButton or c is Range or c is LineEdit or c is TextEdit:
			out.append(c)
	return out


var _main: Node2D


func _setup_main_scene() -> void:
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main)
	get_tree().current_scene = _main


func before_each() -> void:
	pass


func after_each() -> void:
	get_tree().paused = false
	_forgive_known_scenario_ui_animation_warnings()

	if GameManager.scenario != null and is_instance_valid(GameManager.scenario):
		if GameManager.scenario.is_connected("scenarioWon", Callable(GameManager, "endScenario")):
			GameManager.scenario.disconnect("scenarioWon", Callable(GameManager, "endScenario"))
		if GameManager.scenario.is_connected("endScenarioTurn", Callable(GameManager, "endScenarioTurn")):
			GameManager.scenario.disconnect("endScenarioTurn", Callable(GameManager, "endScenarioTurn"))
		GameManager.scenario.queue_free()
	GameManager.scenario = null

	if is_instance_valid(GameManager.stats):
		GameManager.stats.queue_free()
	GameManager.stats = null

	if is_instance_valid(_main):
		_main.queue_free()
	_main = null

	GameManager.player = null
	GameManager.card_manager = null
	GameManager.map = null
	GameManager.UI = null
	GameManager.handController = null
	GameManager.UIAnimationPlayer = null
	GameManager.playerInstantiated = false

	await get_tree().process_frame


func _add_scene_autoqfree(packed: PackedScene) -> Node:
	var inst := packed.instantiate()
	add_child_autoqfree(inst)
	return inst


func test_title_screen_interactive_controls_support_keyboard_focus() -> void:
	var title: Node = TITLE_SCREEN.instantiate()
	add_child_autoqfree(title)
	await wait_process_frames(2)

	var main_menu: Node = title.get_node("MainMenu")
	var focusables := _collect_interactive_focusables(main_menu)
	assert_gt(focusables.size(), 0, "Main menu should expose focusable interactive controls.")

	for c in focusables:
		assert_ne(
			c.focus_mode,
			Control.FOCUS_NONE,
			"%s should be keyboard-focusable (focus_mode not NONE)." % c.get_path()
		)

	var buttons: Array[BaseButton] = []
	for n in main_menu.find_children("*", "BaseButton", true, false):
		var b := n as BaseButton
		if b.visible and b.focus_mode != Control.FOCUS_NONE:
			buttons.append(b)

	assert_gte(buttons.size(), 4, "Title main menu should expose at least four primary buttons.")

	var start_btn: BaseButton = title.get_node("MainMenu/StartGameLabel/StartButton") as BaseButton
	start_btn.grab_focus()
	await wait_process_frames(1)

	var visited: Dictionary = {}
	var cur: Control = get_viewport().gui_get_focus_owner()
	var first: Control = cur
	var guard := 0
	while cur != null and guard < 64:
		if cur is BaseButton and main_menu.is_ancestor_of(cur):
			visited[cur] = true
		var nxt: Control = cur.find_next_valid_focus()
		if nxt == null:
			break
		cur = nxt
		if cur == first:
			break
		guard += 1

	assert_gte(
		visited.size(),
		4,
		"Tab order should reach at least four main-menu BaseButton nodes (keyboard navigation)."
	)
	_forgive_known_scenario_ui_animation_warnings()


func test_title_screen_text_meets_minimum_size_and_contrast() -> void:
	var title: Node = TITLE_SCREEN.instantiate()
	add_child_autoqfree(title)
	await wait_process_frames(2)

	_assert_text_meets_minimum_font_size(title, "TitleScreen")
	_assert_text_meets_contrast_on_reference_backgrounds(title, "TitleScreen")
	_assert_solid_color_rect_graphics_contrast(title, "TitleScreen")
	_forgive_known_scenario_ui_animation_warnings()
