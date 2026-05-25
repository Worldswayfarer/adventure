extends CharacterBody3D

@onready var agent = $NavigationAgent3D

var speed = 10.0

func _ready():
	agent.target_desired_distance = 0.1
	agent.path_desired_distance = 0.1

func _physics_process(_delta):
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
	
	var next = agent.get_next_path_position()
	var next_vector : Vector3 = next - global_position
	velocity = next_vector.normalized() * speed
	move_and_slide()


func move_to(target_pos: Vector3):
	agent.target_position = target_pos
