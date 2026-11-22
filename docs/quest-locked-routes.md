# Unlock a Godot 4 world map route with a quest flag

In this Godot 4.6 example, a player gets a bridge pass at Pine Camp and can then see the route to East Gate. The map listens for changes to the flag so the same scene can show the route as locked again when the player loses the pass.

[Download the editable Godot project](https://github.com/yaotao3000/godot-world-map-free/releases/download/v1.0.0/small-hours-godot-bridge-pass-free-project.zip) · [Watch the 36-second demo and try it in your browser](https://small-hours-assets.vercel.app/guides/godot-world-map-bridge-pass?utm_source=github_bridge_pass_readme)

## Run the bridge-pass scene

1. Extract the ZIP, import `project.godot` in Godot 4.6 and press F5.
2. Select **East Gate**, then **Pine Camp**. Take the bridge pass.
3. Select **East Gate** again. Five dashed route tiles appear.

## Connect your quest state to the map

Make a parent scene with two children. Add a Node named `QuestState` and instance [`bridge_pass_map.tscn`](../examples/bridge_pass_map.tscn) as a child named `BridgePassMap`.

Save this script as `quest_state.gd` and attach it to `QuestState`. Replace it with your own inventory or quest manager when ready.

```gdscript
extends Node

signal bridge_pass_changed(owned: bool)

@export var owns_bridge_pass := false


func set_bridge_pass_owned(owned: bool) -> void:
	if owns_bridge_pass == owned:
		return
	owns_bridge_pass = owned
	bridge_pass_changed.emit(owned)
```

Attach this script to the parent. It applies the initial flag after the map is ready, then connects future changes. Set the flag on `QuestState` before the scene initializes if you already loaded it from a save.

```gdscript
extends Node

@onready var quest_state = $QuestState
@onready var world_map = $BridgePassMap


func _ready() -> void:
	quest_state.bridge_pass_changed.connect(world_map.set_bridge_pass)
	world_map.set_bridge_pass(quest_state.owns_bridge_pass)
```

When the player gains or loses the pass, call `quest_state.set_bridge_pass_owned(true)` or `quest_state.set_bridge_pass_owned(false)` from your game logic. While adapting the sample, have your own reward handler grant the pass so the quest flag stays authoritative. Store that flag in your save data to restore the route after quitting.

The existing [map script](../examples/world_map_bridge_pass.gd) adds the five-tile `gate` route when the flag is true and removes the route when it is false. Each map instance owns its runtime route data, so toggling one map leaves the other untouched.

[Godot 4.6 signals](https://docs.godotengine.org/en/4.6/getting_started/step_by_step/signals.html) · [Godot 4.6 scene instances and initialization](https://docs.godotengine.org/en/4.6/tutorials/scripting/nodes_and_scene_instances.html)

## Use the route tiles in your game

The ZIP includes 11 example PNGs across the map, markers and route layers. [Map Route Tiles](https://yaotao3000.itch.io/map-route-tiles) adds 15 connector layouts in open and planned states, with transparent PNGs, SVG source files and atlas JSON.

See [the license](../LICENSE.txt) for the included files. Small Hours used AI assistance for vector art, code and documentation.
