extends Node3D
class_name EnemyManager


@onready var enemies = $Enemies


var _player : Unit


func setup(player: Unit):
	_player = player


func switch_turn():
	for enemy : Unit in enemies.get_children():
		enemy.switch_turn()


func do_enemy_turn():
	for enemy : Unit in enemies.get_children():
		PathManager.set_target_for_pathfinding(enemy, _player.global_position, _player)
