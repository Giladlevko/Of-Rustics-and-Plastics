extends Control
class_name UI
var buttons:Array = []
@export var start_button:Button
@export var rules_button:Button
@export var pic_button:Button
@export var credits_button:Button
@export var quit_button:Button
@export var rules_back:Button
@export var dark_screen:MarginContainer
@export var score_label:Label
@export var music_track:AudioStreamPlayer
@export var rules_cont:MarginContainer

signal visibility_tween_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lighten_screen()
	rules_cont.modulate.a = 0
	rules_cont.visible = false
	if Global.high_score > 0:
		score_label.text = "High Score: "+str(Global.high_score)
	else:score_label.visible = false
	buttons = [start_button,rules_button,pic_button,credits_button,quit_button,rules_back]
	for button in buttons:
		button.pivot_offset = button.size/2
	
	music_track.volume_linear = db_to_linear(-100)
	tween_audio(db_to_linear(-15),2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for button in buttons:
		if button.is_hovered():
			tween_scale(button,1.2,0.2,self)
		else:
			tween_scale(button,1,0.2,self)

func tween_scale(object,final,dur,bind_object:Node = self):
	object.pivot_offset = object.size / 2
	var tween = get_tree().create_tween().bind_node(bind_object)
	tween.tween_property(object,"scale",final * Vector2.ONE,dur)

func tween_visiblity(object,final,dur,bind_object:Node = self):
	var tween = get_tree().create_tween().bind_node(bind_object)
	tween.tween_property(object,"modulate",Color(1,1,1,final),dur)
	await tween.finished
	visibility_tween_finished.emit()
	object.visible = (object.modulate.a == 1)

func tween_audio(vol:float,dur:float = 5):
	var tween:Tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(music_track,"volume_linear",vol,dur)

func _on_start_game_button_pressed() -> void:
	tween_audio(db_to_linear(-100),0.8)
	await darken_screen()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/slicing_board.tscn")


func _on_pic_button_pressed() -> void:
	tween_audio(db_to_linear(-100),0.8)
	await darken_screen()
	get_tree().change_scene_to_file("res://scenes/challenges_menu.tscn")


func _on_credits_button_pressed() -> void:
	tween_audio(db_to_linear(-100),0.8)
	await darken_screen()
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_quit_button_pressed() -> void:
	tween_audio(db_to_linear(-100),0.8)
	await darken_screen()
	get_tree().quit()

func darken_screen():
	dark_screen.visible = true
	tween_visiblity(dark_screen,1,0.8,self)
	await visibility_tween_finished

func lighten_screen():
	dark_screen.visible = true
	dark_screen.modulate = Color(1,1,1,1)
	tween_visiblity(dark_screen,0,0.8,self)

func _on_rules_button_pressed() -> void:
	var a_value:int
	if rules_cont.visible:
		a_value = 0
	else: 
		rules_cont.visible = true
		a_value = 1
	tween_visiblity(rules_cont,a_value,0.4,self)
