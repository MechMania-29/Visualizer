extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$CanvasLayer/FileDialog.popup()
	pass # Replace with function body.

onready var dir = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	$Camera2D.move_local_x(dir.x)
#	$Camera2D.move_local_y(dir.y)


func _input(ev):
	return
	if Input.is_key_pressed(KEY_A):
		dir.x = -1
	elif Input.is_key_released(KEY_A):
		dir.x = 0
	
	if Input.is_key_pressed(KEY_D):
		dir.x = 1
	elif Input.is_key_released(KEY_D):
		dir.x = 0
	
	if Input.is_key_pressed(KEY_W):
		dir.y = -1
	elif Input.is_key_released(KEY_A):
		dir.y = 0
	
	if Input.is_key_pressed(KEY_S):
		dir.y = 1
	elif Input.is_key_released(KEY_A):
		dir.y = 0
		
	if Input.is_key_pressed(KEY_R) or ev.is_action("zoom_out"):
		$Camera2D.zoom = $Camera2D.zoom * 1.5
	
	if Input.is_key_pressed(KEY_F) or ev.is_action("zoom_in"):
		$Camera2D.zoom = $Camera2D.zoom /1.5
