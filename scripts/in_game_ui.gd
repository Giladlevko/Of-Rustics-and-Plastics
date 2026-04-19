extends UI
@export var current_score_label: Label
@export var multiplier_label:Label
@export var plus_point_label:Label
@export var miss_bottle_popup:Control
@export var miss_amount_label:Label
@export var fail_container:MarginContainer
@export var fail_label:Label
@export var critical_label:Label
@export var restart_button:Button
@export var back_to_main_button:Button
@export var pause_button:Button
@export var pause_to_main:Button
@export var resume_button:Button
@export var pause_menu:MarginContainer
@export var count_label:Label
signal countdown_finished
var point_pending:bool
var missed_tex_pending:bool
var missed_amount:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_current_score.connect(on_score_update)
	SignalBus.update_multiplier.connect(on_multiplier)
	SignalBus.update_plus_label.connect(on_point_pending)
	SignalBus.on_bottle_missed.connect(handle_missed_bottle)
	SignalBus.on_liqueur_hit.connect(handle_fail)
	SignalBus.hit_crit.connect(on_critical)
	Global.current_score = 0
	music_track.volume_linear = db_to_linear(-100)
	tween_audio(db_to_linear(-15))
	lighten_screen()
	fail_container.visible = false
	fail_container.modulate = Color(1,1,1,0)
	buttons = [back_to_main_button,restart_button,pause_to_main,resume_button]
	
	countdown()
	await countdown_finished
	SignalBus.fire_canons.emit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for button in buttons:
		if button.is_hovered():
			tween_scale(button,1.2,0.2,self)
		else:
			tween_scale(button,1,0.2,self)
	if pause_button.is_hovered():
		tween_scale(pause_button,1.1,0.2,self)
	else:
		tween_scale(pause_button,1.0,0.2,self)



func on_point_pending():
	
	plus_point_label.text += " +1"
	if point_pending:
		return
	await get_tree().create_timer(0.8).timeout
	point_pending = true
	var plus_points:Array =  plus_point_label.text.split(" ")
	var arr_size = plus_points.size()
	plus_points.remove_at(arr_size-1)
	#plus_points.remove_at(arr_size-2)
	plus_point_label.text = ""
	for plus_point in plus_points:
		plus_point_label.text += ""+plus_point
	point_pending = false
	
	
var i_100s:int = 1
func on_score_update(value):
	current_score_label.text = "Score: "+ str(value)
	print(Global.current_score)
	if i_100s * 100 <= value:
		i_100s+=1
		update_missed_label(-1)
		
	

func on_critical():
	critical_label.text = "Critical! + 10"
	await get_tree().create_timer(2).timeout
	critical_label.text = ""
	Global.current_score +=10

func on_multiplier():
	multiplier_label.text  = "x "+str(Global.point_multiplier)
	if Global.best_slice_mult < Global.point_multiplier:
		Global.best_slice_mult = Global.point_multiplier
	await get_tree().create_timer(1).timeout
	multiplier_label.text = ""

signal missed_bottle_finished
func handle_missed_bottle(x_pos):
	var offset:int = int(miss_bottle_popup.size.x/3)
	if missed_tex_pending:
		await missed_bottle_finished
	
	missed_tex_pending = true
	var screen_size = get_viewport_rect().size
	var miss_position_x: int = int(x_pos+screen_size.x/2)
	
	if miss_position_x > screen_size.x:
		miss_position_x = screen_size.x - offset
	elif miss_position_x < 0:
		miss_position_x = 0
	miss_bottle_popup.position.x = miss_position_x
	miss_bottle_popup.visible = true
	
	update_missed_label(1)
	if !get_tree():return
	await get_tree().create_timer(2).timeout
	miss_bottle_popup.visible = false
	missed_tex_pending = false
	missed_bottle_finished.emit()
	

func update_missed_label(value:int):
	missed_amount += value
	if missed_amount < 0: 
		missed_amount = 0
	miss_amount_label.text = ""
	#handle fail if amount > 3
	for amount in missed_amount:
		miss_amount_label.text += "x"
	if missed_amount >= 3:
		handle_fail("Looks like someone's Bottled up...")
		pass


func handle_fail(faill_message:String = ""):
	if faill_message != "":
		fail_label.text = faill_message
	get_tree().paused = true
	fail_container.visible = true
	tween_visiblity(fail_container,1,0.5,self)
	

func update_stats():
	if Global.high_score < Global.current_score:
		Global.high_score = Global.current_score
	Global.total_points += Global.current_score

func _on_restart_game_button_pressed() -> void:
	update_stats()
	tween_audio(db_to_linear(-100),0.8)
	darken_screen()
	await visibility_tween_finished
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_return_to_main_pressed() -> void:
	update_stats()
	tween_audio(db_to_linear(-100),0.8)
	darken_screen()
	await visibility_tween_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_pause_button_pressed() -> void:
	if pause_menu.visible:
		tween_visiblity(pause_menu,0,0.3,self)
		await visibility_tween_finished
		countdown()
		await countdown_finished
		get_tree().paused = false
	else:
		update_stats()
		pause_menu.visible = true
		tween_visiblity(pause_menu,1,0.3,self)
		get_tree().paused = true


func countdown(sec:int = 3):
	count_label.pivot_offset = count_label.size / 2
	for i in range(1,sec+1):
		var tween = get_tree().create_tween().bind_node(self)
		count_label.text = str(sec+1-i)
		tween.tween_property(count_label,"scale",1*Vector2(1,1),0.25)
		tween.tween_interval(0.5)
		tween.tween_property(count_label,"scale",0*Vector2(1,1),0.25)
		await tween.finished
		tween.kill()
	count_label.text = ""
	countdown_finished.emit()
