extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("blade"):
		var parent = area.get_parent()
		if area.is_in_group("plastic") and !parent.is_sliced:
			SignalBus.on_bottle_missed.emit(parent.global_position.x)
			
		parent.queue_free()
