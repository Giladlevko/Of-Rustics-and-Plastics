extends Node

var current_score:int:
	set(value):
		current_score = value
		SignalBus.update_current_score.emit(value)

var point_multiplier:int
var slash_angle:float
var points_to_mult:Array
var high_score:int
var unlocked_pics:Array
var best_slice_mult:int
var total_points:int
var load_game_1st_time:bool = true
var seeing_completed_challenges_1st_time = true
