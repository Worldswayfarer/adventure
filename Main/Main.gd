extends Node3D

@onready var camera = $Camera3D
@onready var unit : Unit = null
@onready var grid = $TacticalGrid
@onready var turn_manager = $TurnManager

func _unhandled_input(event):
	if event.is_action_pressed("switch_turn"):
		turn_manager.switch_turn()
	
	
	# player controls
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if unit == null:
			return
		unit.deselect_unit()
		unit = null
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit := get_mouse_world_position()
		if hit == {}:
			return
		handle_selection(hit)
		
	if !turn_manager.is_player_turn():
		return
		
	if event is InputEventMouseMotion and unit != null:
		if unit.is_moving():
			return
		var hit := get_mouse_world_position()
		if hit == {}:
			return
		handle_mouse_movement(hit)


var last_mouse_position : Vector3 = Vector3.INF
var last_target = null
const MIN_DISTANCE : float = 0.2

func handle_mouse_movement(hit: Dictionary):
	var obj = hit.collider
	if last_mouse_position.distance_to(hit.position) < MIN_DISTANCE:
		return

	last_mouse_position = hit.position
	# move a unit to target
	if obj.has_method("is_enemy") and obj.is_enemy():
		unit.set_target(obj.global_position, obj)
	else:
		unit.set_target(hit.position, null)
	return


func handle_selection(hit: Dictionary):
	var target = hit.collider
	if unit == null and target.has_method("is_selectable"):
		unit = target.select_unit()
		return
	if turn_manager.is_player_turn():
		handle_movement(target)


func handle_movement(target):
	if unit == null:
		return
	if target.has_method("is_selectable"):
		unit.move_to_target()
		return
	unit.move_to_target()
	

func get_mouse_world_position() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	var from = origin
	var to = origin + dir * 200
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	

	return hit
