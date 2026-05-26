extends Node3D

class_name TacticalGrid

@export var cell_size := 1.0
@export var grid_width := 50
@export var grid_height := 50

var cells = []

func _ready():
	generate_grid()

func generate_grid():
	var space = get_world_3d().direct_space_state
	cells.resize(grid_width)
	for x in range(grid_width):
		cells[x] = []
		for z in range(grid_height):
			var from = Vector3(x * cell_size, 50, z * cell_size)
			var to = from - Vector3.UP * 200

			var query = PhysicsRayQueryParameters3D.create(from, to)
			var hit = space.intersect_ray(query)

			if hit:
				var pos = hit.position
				cells[x].append({
					"walkable": true,
					"world_pos": pos,
					"height": pos.y
				})
			else:
				cells[x].append({
					"walkable": false
				})

func world_to_cell(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		int(world_pos.x / cell_size),
		int(world_pos.z / cell_size)
	)

func cell_to_world(cell: Vector2i) -> Vector3:
	return cells[cell.x][cell.y]["world_pos"]
