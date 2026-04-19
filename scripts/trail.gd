extends Line2D
var point_pos:Vector2
var points_array:Array
const MAX_POINTS:int = 10
var tween:Tween
var mouse_speed:float
@onready var blade_area: Area2D = $Area2D
@onready var blade_colli: CollisionShape2D = $Area2D/CollisionShape2D
@onready var line_colli: CollisionShape2D = $Area2D/line_colli

var last_mouse_point:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO 
	#use these two points to get the movement angle
	#  to know how to cut the bottles
	var mouse_pos = get_global_mouse_position()
	var delta_x = (last_mouse_point.x - (blade_area.global_position.x-mouse_pos.x))
	var delta_y = (last_mouse_point.y - (blade_area.global_position.y-mouse_pos.y))
	var slash_slope:float
	if delta_x != 0:
		slash_slope = delta_y/delta_x
		Global.slash_angle = round(rad_to_deg(atan2(-delta_y,delta_x)))
	else:
		pass
		Global.slash_angle = 0
	if snapped(Global.slash_angle,45)%360 >0:
		$Label.text = str(snapped(Global.slash_angle,45)%360)
	
	
	line_colli.shape.b = last_mouse_point
	last_mouse_point = blade_area.global_position - mouse_pos
	
	if Input.is_action_pressed("LEFT_MOUSE") or Input.is_action_pressed("S"):
		#print(Global.slash_angle)
		if self_modulate.a < 1:
			self_modulate.a = 1
			tween.kill()
		
		handle_trail_collision()
		handle_trail()

	elif Input.is_action_just_released("LEFT_MOUSE") or Input.is_action_just_released("S"):
		Global.point_multiplier = 0
		tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(self,"self_modulate",Color(1,1,1,0),0.3)
		await tween.finished
		points_array.clear()
		clear_points()
		pass
	blade_area.position = get_global_mouse_position()
	if points_array.size()>0:
		var length:Vector2 = points_array[points_array.size()-1] - points_array[0]
		if length.length() >=30:
			blade_colli.set_deferred("disabled",false)
			line_colli.set_deferred("disabled",false)
		else:
			blade_colli.set_deferred("disabled",true)
			line_colli.set_deferred("disabled",true)
	else:
		blade_colli.set_deferred("disabled",true)
	
	
	handle_score()
	


func handle_score():
	if Input.is_action_pressed("LEFT_MOUSE"):
		pass
		

func handle_trail():
	point_pos = get_global_mouse_position()
	points_array.push_front(point_pos)
	if points_array.size() > MAX_POINTS:
		points_array.pop_back()
	clear_points()
	for p in points_array:
		add_point(p)
	pass

func handle_trail_collision():
	pass
		
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Input.is_action_pressed("LEFT_MOUSE"):
		print(body)
