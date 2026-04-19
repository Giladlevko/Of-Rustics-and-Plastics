extends CharacterBody2D
var is_sliced:bool
var speed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_sliced:
		#global_rotation = 0
		velocity.y +=(20 - delta)
		move_and_slide()
