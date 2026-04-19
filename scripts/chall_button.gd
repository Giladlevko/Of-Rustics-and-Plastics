extends TextureButton

@export var chall_amount:int = 1
var unlocked_chall_amount:int = 0
signal animal_button_pressed
@onready var check_mark_container: VBoxContainer = $"../../HBoxContainer/VBoxContainer/check_markContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tex:TextureRect in check_mark_container.get_children():
		tex.modulate = Color(1,1,1,0)
		
	pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func unlock(indx:int):
	unlocked_chall_amount += 1
	if chall_amount == unlocked_chall_amount:
		Global.unlocked_pics.append(name)
	var tex:TextureRect = check_mark_container.get_child(indx)
	tex.modulate = Color(1,1,1,1)
	tex.custom_minimum_size = Vector2(25,25)


func _on_button_pressed():
	animal_button_pressed.emit(name)
