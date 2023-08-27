extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mouse_over_UI = false
var grabbed = false
var last_mouse_location = Vector2(0, 0)
# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/FileDialog.popup()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (grabbed):
		var curr_mouse_location = get_viewport().get_mouse_position()
		var diff = last_mouse_location - curr_mouse_location
		$Camera2D.move_local_x(diff.x * $Camera2D.zoom.x)
		$Camera2D.move_local_y(diff.y * $Camera2D.zoom.y)
		last_mouse_location = curr_mouse_location


func _input(ev):
	if not ($PlayerController.ready):
		return
	if ev.is_action_pressed("ui_reset"):
		$Camera2D.position = Vector2(0, 0)
		$Camera2D.zoom = Vector2(1, 1)
	if ev.is_action("ui_left"):
		$Camera2D.move_local_x(-100)
	if ev.is_action("ui_right"):
		$Camera2D.move_local_x(100)
	if ev.is_action("ui_up"):
		$Camera2D.move_local_y(-100)
	if ev.is_action("ui_down"):
		$Camera2D.move_local_y(100)
	
	if ev.is_action("ui_zoom_out") and $Camera2D.zoom.y < 18:
		$Camera2D.zoom = $Camera2D.zoom * 1.2
	
	if ev.is_action("ui_zoom_in") and $Camera2D.zoom.x > .5:
		$Camera2D.zoom = $Camera2D.zoom / 1.2

	if ev.is_action_pressed("main_click") and not mouse_over_UI:
		grabbed = true
		last_mouse_location = get_viewport().get_mouse_position()
	if ev.is_action_released("main_click"):
		grabbed = false
	
	


func _on_UI_mouse_entered_any():
	mouse_over_UI = true


func _on_UI_mouse_exited_any():
	mouse_over_UI = false
