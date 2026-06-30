extends CharacterBody3D
class_name Unit

@onready var agent : NavigationAgent3D = $NavigationAgent3D
@onready var mesh : MeshInstance3D  = $Unit2/metarig/Skeleton3D/Unit
@onready var animation_player : AnimationPlayer = $Unit2/AnimationPlayer


var is_selected = false
var original_color : Color

@export var enemy = true


var self_mesh : Mesh 
var material : Material

var _is_moving : bool = false

####### stats

# Movement
var speed = 10.0
@export var attack_range = 2.0
@export var movement_range = 20.0
@export var movement_points = movement_range
@export var distance_traveling = 0.0

# Combat
@export var max_health : int = 10
@export var current_health : int = max_health
@export var damage : int = 5

#######

# Currently needs to be public

var target : Unit = null:
	set(value): target = value

var calculated_target_pos = Vector3.ZERO:
	set(value): calculated_target_pos = value

#


func take_damage(dmg : int):
	current_health -= dmg
	if current_health < 1 :
		queue_free()


func switch_turn():
	movement_points = movement_range

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
	_is_moving = false
	var new_mesh = mesh.mesh.duplicate()
	mesh.mesh = new_mesh
	var new_mat = mesh.mesh.surface_get_material(0).duplicate(true)
	new_mesh.surface_set_material(0, new_mat)
	material = new_mat

	if enemy:
		material.albedo_color = Color.RED
	

func _physics_process(delta):
	
	if agent.is_navigation_finished() and _is_moving:
		finish_movement()
		return
	if !_is_moving:
		return
	var next = agent.get_next_path_position()
	var next_vector : Vector3 = next - global_position
	var new_velocity = next_vector.normalized() * speed
	var target_yaw = atan2(new_velocity.x, velocity.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, delta * 10.0)
	agent.set_velocity(new_velocity)


func is_moving():
	return _is_moving


func finish_movement():
	velocity = Vector3.ZERO
	_is_moving = false
	move_and_slide()
	attack_target()

func attack_target():
	if target == null:
		print("attacking no target, this shouldnt happen")
		return
	if global_position.distance_to(target.global_position) > (attack_range + 0.1):
		print("out_of_range")
		return 
	print("attacking_target")
	animation_player.play("Attack")
	target.take_damage(damage)
	target = null

func move_to_target():
	if calculated_target_pos == Vector3.ZERO:
		return
	_is_moving = true
	movement_points -= distance_traveling


func start_movement(target_pos: Vector3, target_unit: Object):
	PathManager.set_target_for_pathfinding(self, target_pos, target_unit)



func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !_is_moving:
		return
	velocity = safe_velocity
	move_and_slide()
