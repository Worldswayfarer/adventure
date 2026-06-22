extends Node3D
class_name TurnManager

var _is_player_turn = true
func is_player_turn():
	return _is_player_turn

var _player : CharacterBody3D

func setup(player):
	_player = player


func switch_turn():
	_is_player_turn = !_is_player_turn
