extends CharacterBody2D
var speed:Vector2
var gravity:int = 100
var type_of_slice:Dictionary = {}
var matching_sprites:Dictionary = {}
var is_sliced:bool
@onready var grape_full: Sprite2D = $sprites/grape_full
@onready var cherry_full: Sprite2D = $sprites/cherry_full
@onready var pear_full: Sprite2D = $sprites/pear_full
@onready var apple_full: Sprite2D = $sprites/apple_full
@onready var horizontal: Node2D = $sprites/half_sprites/horizontal
@onready var verticle: Node2D = $sprites/half_sprites/verticle
@onready var slant_right: Node2D = $sprites/half_sprites/slant_right
@onready var slant_left: Node2D = $sprites/half_sprites/slant_left
@onready var particles: CPUParticles2D = $particles
@onready var slash_sfx: AudioStreamPlayer = $sfx/slash

@onready var liqueur_full: Sprite2D = $sprites/liqueur_full

@export_enum("grape","cherry","pear","apple","liqueur") var ID: String = "cherry"
@onready var AREA: Area2D = $Area2D
signal start_timer_score_multi
var rotate_to : float
var tween:Tween
var crit:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var crit_chance = randi_range(1,100)
	if crit_chance >95:
		crit = true
	matching_sprites = {
		"grape" : [grape_full],
		"cherry" : [cherry_full],
		"pear" : [pear_full],
		"apple" : [apple_full],
		"liqueur": [liqueur_full],
	}
	type_of_slice ={
		"horizontal":horizontal,
		"verticle": verticle,
		"slant_left":slant_left,
		"slant_right":slant_right,
	} 
	if ID == "liqueur":
		AREA.remove_from_group("plastic")
	matching_sprites[ID][0].visible = true
	velocity.y += speed.y
	velocity.x += speed.x
	move_and_slide()
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self,"rotation",rotate_to,rotate_to/PI)
	handle_slice_tex()
	start_timer_score_multi.connect(on_start_timer_score_multi)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	velocity.y += gravity * delta
	move_and_slide()
	await tween.finished
	tween.kill()
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("blade"):
		if (Input.is_action_pressed("LEFT_MOUSE") or Input.is_action_pressed("S")) and !is_sliced:
			handle_slice()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("blade"):
		if (Input.is_action_pressed("LEFT_MOUSE") or Input.is_action_pressed("S")) and !is_sliced:
			handle_slice()

func handle_crit():
	if crit:
		SignalBus.hit_crit.emit()
		slash_sfx.volume_db = -20

func handle_slice():
	handle_crit()
	slash_sfx.play()
	velocity = Vector2.ZERO
	is_sliced = true
	tween.kill()
	if ID == "liqueur":
		print("No!!! Not my liqueur!!")
		SignalBus.on_liqueur_hit.emit()
	else:
		print("Bottle sliced!")
		Global.points_to_mult.append(self)
		if Global.point_multiplier == 0:
			start_timer_score_multi.emit()
		Global.point_multiplier +=1
		SignalBus.update_plus_label.emit()
		particles.emitting = true
		var slice_type = pick_slice_type()
		
		slice_type.visible = true
		matching_sprites[ID][0].visible = false
		var speed_sign:int = 1
		var slices:Array = slice_type.get_children()
		var speed_mult:int = 1
		if crit:
			speed_mult = 7
		slices[0].is_sliced = true
		slices[1].is_sliced = true
		slices[0].velocity = Vector2.LEFT.rotated(slices[0].global_rotation)*100 * speed_mult
		slices[1].velocity = Vector2.RIGHT.rotated(slices[0].global_rotation)*100 * speed_mult
		#call_deferred("queue_free")

func positive_mod(a:int,b:int) -> int:
	var result:int = ((a%b)+b)%b
	return result

func pick_slice_type() -> Node2D:
	$Label.rotation_degrees = -global_rotation_degrees
	$Label.text = str(snapped(positive_mod((round(Global.slash_angle) + round(global_rotation_degrees)),360),45))
	var relative_slash_angle:int = snapped(positive_mod((round(Global.slash_angle)+round(global_rotation_degrees)),360),45)
	print("relative_slash_angle:",relative_slash_angle,"slash_angle:",
	int(Global.slash_angle),"rotation:",int(global_rotation_degrees))
	match relative_slash_angle:
		0,180,360: return type_of_slice["horizontal"] 
		45,225: return type_of_slice["slant_right"]
		90,270:return type_of_slice["verticle"]
		135,315:return type_of_slice["slant_left"]
		_: return type_of_slice["horizontal"]

func handle_slice_tex():
	for slice_type in type_of_slice.values():
		for half in slice_type.get_children():
			for rect in half.get_children():
				for sprite_tex in rect.get_children():
					sprite_tex.region_rect = matching_sprites[ID][0].region_rect
	pass


func on_start_timer_score_multi():
	var port = get_viewport()
	var mouse_pos =get_global_mouse_position()
	var pos = (Vector2(mouse_pos.x + port.size.x/2,mouse_pos.y + port.size.y/2))
	
	await get_tree().create_timer(0.8).timeout
	if Global.point_multiplier >= 3:
		Global.current_score += Global.points_to_mult.size() * Global.point_multiplier
		print(Global.points_to_mult.size() , Global.point_multiplier)
		SignalBus.update_multiplier.emit()
	else:
		Global.current_score += Global.points_to_mult.size()
	Global.points_to_mult.clear()
	Global.point_multiplier = 0
