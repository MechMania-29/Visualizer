extends MarginContainer
signal timeline_changed(value)
signal pause_toggled(paused)
signal stepped_forward
signal stepped_backward
signal timeline_interaction(clicked)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timeline_value_changed(value):
	emit_signal("timeline_changed", value)


func _on_PlayButton_toggled(button_pressed):
	emit_signal("pause_toggled", button_pressed)


func _on_ForwardButton_pressed():
	emit_signal("stepped_forward")


func _on_BackButton_pressed():
	emit_signal("stepped_backward")

func force_pause(paused):
	$UI/HBoxContainer/TimeControls/PlayButton.pressed = not paused


func update_turn_num(turn):
	$UI/HBoxContainer/TimeControls/Panel/VBoxContainer/Label2.text = str(turn)
	$UI/HBoxContainer/TimeControls/Timeline.value = turn

func _on_Timeline_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("timeline_interaction", event.pressed)
func change_max_turns(turns):
	$UI/HBoxContainer/TimeControls/Timeline.max_value = turns - 1
