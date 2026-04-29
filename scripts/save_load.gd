extends Node
const save_location: String = "user://ORP_Save_File.tres"

var save_file_data: SaveDataResource = SaveDataResource.new()

func _save():
	save_file_data.high_score_num = Global.high_score
	save_file_data.best_slice = Global.best_slice_mult
	save_file_data.total_points_num = Global.total_points
	save_file_data.first_load = Global.load_game_1st_time
	save_file_data.first_completed_chall_view =  Global.seeing_completed_challenges_1st_time
	ResourceSaver.save(save_file_data,save_location)

func _load():
	if FileAccess.file_exists(save_location):
		save_file_data = ResourceLoader.load(save_location).duplicate(true)
		Global.high_score = save_file_data.high_score_num
		Global.best_slice_mult = save_file_data.best_slice
		Global.total_points = save_file_data.total_points_num
		Global.load_game_1st_time = save_file_data.first_load
		Global.seeing_completed_challenges_1st_time = save_file_data.first_completed_chall_view
	pass

func reset():
	if FileAccess.file_exists(save_location):
		save_file_data.high_score_num = 0
		save_file_data.best_slice = 0
		save_file_data.total_points_num = 0
		save_file_data.first_load = true
		save_file_data.first_completed_chall_view =  true
		ResourceSaver.save(save_file_data,save_location)
		_load()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
