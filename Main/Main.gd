extends Node3D

@onready var camera = $Camera3D
@onready var unit : Unit = null
@onready var grid = $TacticalGrid

func _unhandled_input(event):
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

func handle_selection(hit: Dictionary):
	var obj = hit.collider
	# default movement
	if !obj.has_method("is_selectable"):
		if unit != null:
			unit.move_to(hit.position, null)
		return

	# select unit
	if unit == null:
		unit = obj.select_unit()
		return

	# move a unit to target
	if obj.is_enemy():
		unit.move_to(obj.global_position, obj)
	else:
		unit.move_to(hit.position, null)
	return
	

func get_mouse_world_position() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	var from = origin
	var to = origin + dir * 200
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	

	return hit
