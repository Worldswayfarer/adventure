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
		if unit != null:
			unit.move_to(hit.position)
			return
		var obj = hit.collider
		if obj.has_method("is_selectable"):
			unit = obj.select_unit()
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
