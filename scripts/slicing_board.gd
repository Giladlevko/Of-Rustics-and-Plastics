extends Node2D
@onready var cannons: Node2D = $cannons
var PLASTIC:PackedScene = preload("res://scenes/plastic.tscn")
var can_spawn:bool = false
var plastic_id:Array = ["grape","cherry","pear","apple","grape","cherry","pear","apple","liqueur"]
var cannon_array:Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cannon_array = cannons.get_children()
	SignalBus.fire_canons.connect(on_fire_canons)
	pass # Replace with function body.

func on_fire_canons():
	can_spawn = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_spawn:
		handle_cannons()



func handle_cannons():
	if can_spawn:
		for amount in randi_range(1,4):
			var cannon = cannon_array.pick_random()
			cannon_array.erase(cannon)
			var plastic = PLASTIC.instantiate()
			plastic.rotate_to = randf_range(PI,8*PI)
			plastic.speed = Vector2(sin(cannon.rotation)*randf_range(200,400),cos(cannon.rotation)*randf_range(-300,-400))
			plastic.ID = plastic_id.pick_random()
			cannon.add_child(plastic)
	cannon_array.clear()
	cannon_array = cannons.get_children()
	can_spawn = false
	await get_tree().create_timer(2).timeout
	can_spawn = true
