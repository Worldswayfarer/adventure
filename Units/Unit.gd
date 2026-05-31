extends CharacterBody3D
class_name Unit

@onready var agent : NavigationAgent3D = $NavigationAgent3D
@onready var mesh : MeshInstance3D  = $MeshInstance3D

var speed = 10.0
var is_selected = false
var original_color : Color

@export var enemy = true
@export var attack_range = 2
@export var movement_range = 10

var self_mesh : Mesh 
var material : Material

var is_moving : bool = false

var target = null

func is_selectable() -> bool:
	return true 

func is_enemy() -> bool:
	return enemy

func select_unit() -> Object:
	if enemy:
		return
	is_selected = true
	original_color = material.albedo_color
	material.albedo_color = Color.CYAN
	return self

func deselect_unit():
	material.albedo_color = original_color
	is_selected = false

func _ready():
	is_moving = false
	var new_mesh = mesh.mesh.duplicate()
	mesh.mesh = new_mesh
	var new_mat = mesh.mesh.surface_get_material(0).duplicate(true)
	mesh.mesh.surface_set_material(0, new_mat)

	material = new_mesh.material

func _physics_process(_delta):
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
		is_moving = false
		target = null
		move_and_slide()
		return
	if !is_moving:
		return
	var next = agent.get_next_path_position()
	var next_vector : Vector3 = next - global_position
	var new_velocity = next_vector.normalized() * speed
	
	agent.set_velocity(new_velocity)
	

func set_target(target_pos: Vector3, target_unit: Object):
	agent.target_position = target_pos
	
	if target_unit == null:
		is_moving = true
		target = target_unit
		return
	
	await agent.path_changed
	var path := agent.get_current_navigation_path()
	var stop_point := compute_stop_point(path)
	agent.target_position = stop_point
	is_moving = true
	target = stop_point


func compute_stop_point(path: PackedVector3Array) -> Vector3:
	var total_distance = 0.0

	var target_position : Vector3 = path[path.size()-1]

	for i in range(path.size()-2):
		var current_point : Vector3 = path[i]
		var next_point : Vector3 = path[i+1]
		var segment_distance = current_point.distance_to(next_point)

		var movement_range_reached = total_distance + segment_distance > movement_range
		var is_in_attack_range = next_point.distance_to(target_position)

		var point_in_attack_range = Vector3.ZERO
		var maximum_movement_point = Vector3.ZERO

		if is_in_attack_range:
			point_in_attack_range = segment_sphere_intersection(
					current_point, next_point, target_position, attack_range)

		if movement_range_reached:
			var remaining_movement = movement_range - total_distance
			var direction : Vector3 = next_point - current_point
			var modified_direction : Vector3 = direction * (remaining_movement/segment_distance)
			maximum_movement_point = current_point + modified_direction
		
		# max movement is reached and segment is in attack range
		if point_in_attack_range != Vector3.ZERO and maximum_movement_point != Vector3.ZERO:
			var distance_a = current_point.distance_to(point_in_attack_range)
			var distance_b = current_point.distance_to(maximum_movement_point)
			if distance_a < distance_b:
				return point_in_attack_range
			return maximum_movement_point

		if point_in_attack_range != Vector3.ZERO:
			return point_in_attack_range
		if maximum_movement_point != Vector3.ZERO:
			return maximum_movement_point


	return target_position

func segment_sphere_intersection(
		segment_start: Vector3,
		segment_end: Vector3,
		sphere_center: Vector3,
		sphere_radius: float
	) -> Vector3:

	var segment_dir: Vector3 = segment_end - segment_start
	var start_to_center: Vector3 = segment_start - sphere_center

	var point_a: float = segment_dir.dot(segment_dir)
	var point_b: float = 2.0 * start_to_center.dot(segment_dir)
	var point_c: float = start_to_center.dot(start_to_center) - sphere_radius * sphere_radius

	var discriminant: float = point_b * point_b - 4.0 * point_a * point_c
	if discriminant < 0.0:
		return Vector3.ZERO

	var sqrt_disc: float = sqrt(discriminant)

	var t1: float = (-point_b - sqrt_disc) / (2.0 * point_a)
	var t2: float = (-point_b + sqrt_disc) / (2.0 * point_a)

	# We want the earliest intersection ON the segment (t in [0,1])
	if t1 >= 0.0 and t1 <= 1.0:
		return segment_start.lerp(segment_end, t1)

	if t2 >= 0.0 and t2 <= 1.0:
		return segment_start.lerp(segment_end, t2)

	return Vector3.ZERO



func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !is_moving:
		return
	velocity = safe_velocity
	move_and_slide()
