extends Control

const MAP_ORIGIN := Vector2(24, 112)
const INK := Color("#f2f4ec")
const MUTED := Color("#aec2b9")
const GOLD := Color("#ffd488")
const ART := "res://art/"
const DATA := preload("res://world_map.json")

var map_data: Dictionary
var map_texture: Texture2D
var route_texture_cache: Dictionary = {}
var terrain_textures: Array[Texture2D] = []
var marker_buttons: Dictionary = {}
var selected := "town"
var status_label: Label
var name_label: Label
var detail_label: Label


func _ready() -> void:
	map_data = DATA.data
	map_texture = load(ART + map_data.background)
	for terrain: Dictionary in map_data.terrain:
		terrain_textures.append(load(ART + terrain.icon))
	for tiles: Array in map_data.routes.values():
		for tile: Dictionary in tiles:
			if not route_texture_cache.has(tile.tile):
				route_texture_cache[tile.tile] = load(
					ART + "sh_map_route_tiles_%s_planned_slate_64.png" % tile.tile
				)

	add_label("WORLD MAP  /  GODOT 4", Vector2(24, 22), 14, GOLD)
	add_label(map_data.name, Vector2(24, 44), 42, INK)
	add_label("Choose a location", Vector2(688, 114), 16, MUTED)
	status_label = add_label("", Vector2(688, 178), 16, GOLD)
	name_label = add_label("", Vector2(688, 210), 26, INK)
	detail_label = add_label("", Vector2(688, 253), 18, MUTED)
	detail_label.size.x = 230
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_label("Tab to a marker · Enter to select", Vector2(24, 504), 13, MUTED)
	add_label("Map markers · route tiles\nterrain symbols", Vector2(688, 390), 16, MUTED)

	var group := ButtonGroup.new()
	for place: Dictionary in map_data.places:
		var marker := Button.new()
		marker.name = place.id.capitalize() + "Marker"
		marker.icon = load(ART + place.icon)
		marker.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marker.expand_icon = true
		marker.add_theme_constant_override("icon_max_width", 30)
		marker.size = Vector2(46, 46)
		marker.position = MAP_ORIGIN + point(place.position) - marker.size / 2
		marker.tooltip_text = place.name + " · " + place.status
		marker.toggle_mode = true
		marker.button_group = group
		marker.add_theme_stylebox_override("normal", marker_style(Color("#12252a"), Color("#8cad9f")))
		marker.add_theme_stylebox_override("hover", marker_style(Color("#24483f"), INK))
		marker.add_theme_stylebox_override("pressed", marker_style(Color("#526148"), GOLD))
		marker.add_theme_stylebox_override("hover_pressed", marker_style(Color("#526148"), GOLD))
		marker.pressed.connect(select_place.bind(place))
		add_child(marker)
		marker_buttons[place.id] = marker
		var caption := add_label(
			place.name, MAP_ORIGIN + point(place.position) + Vector2(-83, 27), 15, INK
		)
		caption.size.x = 166
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_color_override("font_outline_color", Color("#12252a"))
		caption.add_theme_constant_override("outline_size", 5)

	select_place(map_data.places[0])


func select_place(place: Dictionary) -> void:
	selected = place.id
	marker_buttons[selected].set_pressed_no_signal(true)
	status_label.text = place.status
	name_label.text = place.name
	detail_label.text = place.detail
	queue_redraw()


func add_label(value: String, origin: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = origin
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


static func point(coordinates: Array) -> Vector2:
	return Vector2(coordinates[0], coordinates[1])


static func marker_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(23)
	return style


func _draw() -> void:
	if map_texture == null:
		return
	draw_rect(Rect2(676, 104, 260, 392), Color("#14262a"))
	draw_texture_rect(map_texture, Rect2(MAP_ORIGIN, Vector2(map_data.width, map_data.height)), false)
	for index in map_data.terrain.size():
		var terrain: Dictionary = map_data.terrain[index]
		var center := MAP_ORIGIN + point(terrain.position)
		draw_circle(center, 17, Color("#243d37"))
		draw_texture_rect(terrain_textures[index], Rect2(center - Vector2(16, 16), Vector2(32, 32)), false)
	for tile: Dictionary in map_data.routes.get(selected, []):
		var center := MAP_ORIGIN + point(tile.position)
		draw_set_transform(center, deg_to_rad(tile.get("rotation", 0.0)))
		draw_texture_rect(route_texture_cache[tile.tile], Rect2(-32, -32, 64, 64), false)
	draw_set_transform(Vector2.ZERO)
