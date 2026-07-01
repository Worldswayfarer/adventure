extends Node3D
class_name TurnManager

var _is_player_turn = true
func is_player_turn():
	return _is_player_turn

var _player : Unit
var _enemy_manager : EnemyManager
var game_running = true

func setup(player : Unit, enemy_manager : EnemyManager):
	_player = player
	_enemy_manager = enemy_manager


func switch_turn():
	_is_player_turn = !_is_player_turn
	_player.switch_turn()
	_enemy_manager.switch_turn()


func _process(_delta: float) -> void:
	if !game_running:
		return
	if _player == null:
		game_running = false
		print("Lose")
		Signals.lose.emit()
		return
	if _enemy_manager.number_of_enemies() == 0:
		game_running = false
		print("Win")
		Signals.win.emit()
		return