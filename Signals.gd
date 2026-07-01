extends Node


signal player_path(current_health : float, max_health : float)
signal win()
signal lose()


var signals = [
	player_path,
	win,
	lose
	]