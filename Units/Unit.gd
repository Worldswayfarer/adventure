extends CharacterBody3D
class_name Unit

@onready var agent : NavigationAgent3D = $NavigationAgent3D
@onready var mesh : MeshInstance3D  = $MeshInstance3D

var speed = 10.0
var is_selected = false
var original_color : Color

@export var enemy = true
@export var attack_range = 2

var self_mesh : Mesh 
var material : Material

var is_moving : bool

var target

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
	var current_position = global_position
	if target != null:
		var distance_to_target = current_position.distance_to(target.global_position)
		if distance_to_target <= attack_range:
			agent.set_velocity(Vector3.ZERO)
			velocity = Vector3.ZERO
			return
	var next = agent.get_next_path_position()
	var next_vector : Vector3 = next - global_position
	var new_velocity = next_vector.normalized() * speed
	
	agent.set_velocity(new_velocity)
	

func move_to(target_pos: Vector3, target_unit: Object):
	agent.target_position = target_pos
	is_moving = true
	target = target_unit


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !is_moving:
		return
	velocity = safe_velocity
	move_and_slide()
