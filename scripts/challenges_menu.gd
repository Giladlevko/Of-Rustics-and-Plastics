extends UI
@export var return_to_main:Button
@export var chall_1:TextureButton
@export var chall_2:TextureButton
@export var chall_3:TextureButton
@export var chall_4:TextureButton
@export var plastic_bar:ProgressBar
@export var animal_rect:TextureRect
@export var animal_label:Label
@export var close_pics:Button
@export var photo_zoom_cont:MarginContainer
var racoon_tex = preload("res://assets/animals/racoon.jpg")
var cat_tex = preload("res://assets/animals/cat.jpg")
var goose_tex = preload("res://assets/animals/duck.jpg")
var elephant_tex = preload("res://assets/animals/elephant.jpg")

var chall_buttons:Array
var challenges:Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lighten_screen()
	plastic_bar.value = clampi(plastic_bar.max_value - Global.total_points,0,3000)
	buttons = [return_to_main,close_pics]
	chall_buttons = [chall_1,chall_2,chall_3,chall_4]
	music_track.volume_linear = db_to_linear(-100)
	tween_audio(db_to_linear(-15),2)
	
	challenges = {
	"chall_1": [Global.high_score >= 300],
	"chall_2":[Global.high_score>=500,Global.best_slice_mult >= 3],
	"chall_3":[Global.high_score >= 700,Global.best_slice_mult >= 4],
	"chall_4":[Global.high_score >= 1000,Global.best_slice_mult >=5 ,plastic_bar.value == 0],
	}
	
	for button in chall_buttons:
		button.animal_button_pressed.connect(load_animal_screen)
		for challenge in challenges[button.name].size():
			if challenges[button.name][challenge] == true:
				unlock_challenge(button,challenge)
				
		
		if Global.unlocked_pics.has(button.name):
			button.disabled = false


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

func unlock_challenge(button:TextureButton,c_i:int):
	button.unlock(c_i)
	pass

func get_animal_data(button_name:String) -> Array:
	var data:Dictionary
	data = {
	"chall_1":[racoon_tex,"I hope to never swallow a bottle cap again... Thank you"],#first texture then text
	"chall_2":[cat_tex,"Its nice for toys, but I hate when its in my food..."],
	"chall_3":[goose_tex,"Swimming in a lake without it? I wonder what that's like..."],
	"chall_4":[elephant_tex,"Sometimes I see it in a pond that is almost dried out. I try to avoid it, but I am so thirsty..."],
	}
	return data[button_name]

func load_animal_screen(button_name:String = ""):
	var a_value:int
	if photo_zoom_cont.visible:
		a_value = 0
	else:
		photo_zoom_cont.visible = true
		a_value = 1
	var animal_data:Array
	if button_name != "":
		animal_data = get_animal_data(button_name)
	if !animal_data.is_empty():
		animal_rect.texture = animal_data[0]
		animal_label.text = animal_data[1]
	tween_visiblity(photo_zoom_cont,a_value,0.8,self)
	pass
