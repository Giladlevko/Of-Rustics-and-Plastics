extends UI
@export var return_to_main:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_track.volume_linear = db_to_linear(-100)
	tween_audio(db_to_linear(-15),2)
	lighten_screen()
	buttons = [return_to_main]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for button in buttons:
		if button.is_hovered():
			tween_scale(button,1.2,0.2,self)
		else:
			tween_scale(button,1,0.2,self)

func _on_return_button_pressed() -> void:
	tween_audio(db_to_linear(-100),0.8)
	await darken_screen()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
