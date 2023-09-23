extends MarginContainer
signal timeline_changed(value)
signal pause_toggled(paused)
signal stepped_forward
signal stepped_backward
signal timeline_interaction(clicked)

signal mouse_entered_any
signal mouse_exited_any


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

func _input(event):
	if event.is_action_pressed("ui_pause"):
		$UI/HBoxContainer/TimeControls/PlayButton.pressed = !$UI/HBoxContainer/TimeControls/PlayButton.pressed

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


func _on_Timeline_mouse_entered():
	emit_signal("mouse_entered_any")

func _on_PlayButton_mouse_entered():
	emit_signal("mouse_entered_any")

func _on_Panel_mouse_entered():
	emit_signal("mouse_entered_any")


func _on_Panel_mouse_exited():
	emit_signal("mouse_exited_any")

func _on_PlayButton_mouse_exited():
	emit_signal("mouse_exited_any")

func _on_Timeline_mouse_exited():
	emit_signal("mouse_exited_any")

func update_minimap(new_map):
	$UI/HBoxContainer/RightSideInfo/HBoxContainer/Minimap.board = new_map
	$UI/HBoxContainer/RightSideInfo/HBoxContainer/Minimap.update()

func update_score(zombie_score, human_score):
	$UI/HBoxContainer/RightSideInfo/Panel/MarginContainer/ScoreLeftBox/TBox/LBox/ZScore.text = str(zombie_score)
	$UI/HBoxContainer/RightSideInfo/Panel/MarginContainer/ScoreLeftBox/TBox/RBox/HScore.text = str(human_score)
func update_num_left(zombies, humans):
	$UI/HBoxContainer/RightSideInfo/Panel/MarginContainer/ScoreLeftBox/BBox/LBox/ZLeft.text = str(zombies)
	$UI/HBoxContainer/RightSideInfo/Panel/MarginContainer/ScoreLeftBox/BBox/RBox/HLeft.text = str(humans)
	
func update_info_box(new_string, coord):
	$UI/HBoxContainer/RightSideInfo/InfoPanel/IBox/Contains.text = new_string
	$UI/HBoxContainer/RightSideInfo/InfoPanel/IBox/Coord.text = str(coord)

func log_error(err):
	$UI/HBoxContainer/LeftSideInfo/Errors.text = err
