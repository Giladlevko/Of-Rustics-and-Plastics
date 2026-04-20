extends UI
var intro:String = "of_rustics_and_plastics_intro"
var end:String = "of_rustics_and_plastics_end"
@export var skip_button:Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().paused:
		get_tree().paused = false
	Dialogic.timeline_ended.connect(on_time_line_end)
	if Global.load_game_1st_time:
		Dialogic.start(intro)
		SignalBus.fire_canons.emit()
	else: 
		print("not 1st")
		Dialogic.start(end)
		
	lighten_screen()
	

	

func on_time_line_end():
	darken_screen()
	await visibility_tween_finished
	if Global.load_game_1st_time:
		Global.load_game_1st_time = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif Global.seeing_completed_challenges_1st_time:
		get_tree().change_scene_to_file("res://scenes/challenges_menu.tscn")
		Global.seeing_completed_challenges_1st_time = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skip_button.is_hovered():
		tween_scale(skip_button,1.2,0.2,self)
	else:
		tween_scale(skip_button,1.0,0.2,self)


func _on_return_button_pressed() -> void:
	pressed_sfx.play()
	if Dialogic.current_timeline:
		Dialogic.end_timeline()
	
