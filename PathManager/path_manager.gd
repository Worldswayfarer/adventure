extends Node3D
class_name PathManager


class CalculatedMovement:
	var target_position : Vector3
	var distance : float

	func _init(pos, dist) -> void:
		target_position = pos
		distance = dist

static func set_target_for_pathfinding(mover: Unit, target_pos: Vector3, target_unit: Object):
	var agent:= mover.agent
	agent.target_position = target_pos
	
	await agent.path_changed
	var path := agent.get_current_navigation_path()
	var stop_point := compute_stop_point(mover, path, target_unit)
	agent.target_position = stop_point.target_position
	mover.target = target_unit
	mover.calculated_target_pos = stop_point.target_position
	mover.distance_traveling = stop_point.distance
	if mover.is_enemy():
		mover.move_to_target()


static func compute_stop_point(mover: Unit, path: PackedVector3Array, target: Object) -> CalculatedMovement:
	var total_distance = 0.0

	var target_position : Vector3 = path[path.size()-1]
	var is_attacking = target != null

	for i in range(path.size()-1):
		var current_point : Vector3 = path[i]
		var next_point : Vector3 = path[i+1]
		var segment_distance = current_point.distance_to(next_point)

		var movement_range_reached = total_distance + segment_distance > mover.movement_points
		var is_in_attack_range = next_point.distance_to(target_position) < mover.attack_range

		var point_in_attack_range = Vector3.ZERO
		var maximum_movement_point = Vector3.ZERO

		if is_attacking and is_in_attack_range:
			point_in_attack_range = segment_sphere_intersection(
					current_point, next_point, target_position, mover.attack_range)

		if movement_range_reached:
			var remaining_movement = mover.movement_points - total_distance
			var direction : Vector3 = next_point - current_point
			var modified_direction : Vector3 = direction * (remaining_movement/segment_distance)
			maximum_movement_point = current_point + modified_direction
		
		var result := Vector3.ZERO

		# max movement is reached and segment is in attack range
		if point_in_attack_range != Vector3.ZERO and maximum_movement_point != Vector3.ZERO:
			var distance_a = current_point.distance_to(point_in_attack_range)
			var distance_b = current_point.distance_to(maximum_movement_point)
			if distance_a < distance_b:
				result = point_in_attack_range
			result = maximum_movement_point

		if point_in_attack_range != Vector3.ZERO:
			result = point_in_attack_range
		if maximum_movement_point != Vector3.ZERO:
			result = maximum_movement_point

		if result != Vector3.ZERO:
			total_distance += current_point.distance_to(result)
			return CalculatedMovement.new(result, total_distance)
		total_distance += segment_distance

	return CalculatedMovement.new(target_position, total_distance)

static func segment_sphere_intersection(
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
