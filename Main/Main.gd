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
	if event is InputEventMouseMotion and unit != null:
		if unit.is_moving():
			return
		var hit := get_mouse_world_position()
		if hit == {}:
			return
		handle_mouse_movement(hit)



func handle_mouse_movement(hit: Dictionary):
	var obj = hit.collider

	# move a unit to target
	if obj.has_method("is_enemy") and obj.is_enemy():
		unit.set_target(obj.global_position, obj)
	else:
		unit.set_target(hit.position, null)
	return


func handle_selection(hit: Dictionary):
	var obj = hit.collider
	# default movement
	if !obj.has_method("is_selectable"):
		if unit != null:
			unit.move_to_target()
		return

	# select unit
	if unit == null:
		unit = obj.select_unit()
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
