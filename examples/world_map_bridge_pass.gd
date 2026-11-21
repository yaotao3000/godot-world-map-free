extends "res://world_map.gd"

const CAMP := "camp"
const GATE := "gate"
const EAST_GATE_ROUTE := [
	{"tile": "end_e", "position": [288, 160]},
	{"tile": "straight_ew", "position": [352, 160]},
	{"tile": "straight_ew", "position": [416, 160]},
	{"tile": "straight_ew", "position": [480, 160]},
	{"tile": "end_e", "position": [544, 160], "rotation": 180},
]

var has_bridge_pass := false
var gate_place: Dictionary
var pass_button: Button


func _ready() -> void:
	super._ready()
	# Keep runtime routes separate from the loaded JSON resource.
	map_data = map_data.duplicate(true)
	for place: Dictionary in map_data.places:
		if place.id == GATE:
			gate_place = place
			break

	pass_button = Button.new()
	pass_button.name = "BridgePassButton"
	pass_button.position = Vector2(688, 445)
	pass_button.size = Vector2(232, 38)
	pass_button.text = "Take bridge pass"
	pass_button.hide()
	pass_button.pressed.connect(_take_bridge_pass)
	add_child(pass_button)


func select_place(place: Dictionary) -> void:
	var display_place := place
	if place.id == GATE and has_bridge_pass:
		display_place = place.duplicate()
		display_place.status = "Route available"
		display_place.detail = "You have the bridge pass. Follow the dashed trail from Pine Camp."
	super.select_place(display_place)
	if is_instance_valid(pass_button):
		pass_button.visible = place.id == CAMP


func set_bridge_pass(owned: bool) -> void:
	has_bridge_pass = owned
	if owned:
		map_data.routes[GATE] = EAST_GATE_ROUTE
	else:
		map_data.routes.erase(GATE)

	marker_buttons[GATE].tooltip_text = "East Gate · Route available" if owned else "East Gate · Locked"
	pass_button.disabled = owned
	pass_button.text = "Bridge pass obtained" if owned else "Take bridge pass"
	if selected == GATE:
		select_place(gate_place)


func _take_bridge_pass() -> void:
	set_bridge_pass(true)
	marker_buttons[CAMP].grab_focus()
