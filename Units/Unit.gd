extends CharacterBody3D
class_name Unit

@onready var agent = $NavigationAgent3D
@onready var mesh = $MeshInstance3D

var speed = 10.0
var is_selected = false
var original_color : Color

@export var is_enemy = true

var self_mesh : Mesh 
var material : Material

func is_selectable() -> bool:
	return true 

func select_unit() -> Object:
	if is_enemy:
		return
	is_selected = true
	original_color = material.albedo_color
	material.albedo_color = Color.CYAN
	return self

func deselect_unit():
	material.albedo_color = original_color
	is_selected = false

func _ready():
	var new_mesh = mesh.mesh.duplicate()
	mesh.mesh = new_mesh
	var new_mat = mesh.mesh.surface_get_material(0).duplicate(true)
	mesh.mesh.surface_set_material(0, new_mat)

	material = new_mesh.material

func _physics_process(_delta):
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var next = agent.get_next_path_position()
	var next_vector : Vector3 = next - global_position
	var new_velocity = next_vector.normalized() * speed
	
	agent.set_velocity(new_velocity)
	
	move_and_slide()



func move_to(target_pos: Vector3):
	agent.target_position = target_pos


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
