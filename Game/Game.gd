extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$FileDialog.popup()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(ev):
	if Input.is_key_pressed(KEY_A):
		$Camera2D.move_local_x(-100)
	if Input.is_key_pressed(KEY_D):
		$Camera2D.move_local_x(100)
	if Input.is_key_pressed(KEY_W):
		$Camera2D.move_local_y(-100)
	if Input.is_key_pressed(KEY_S):
		$Camera2D.move_local_y(100)
		
	if Input.is_key_pressed(KEY_R):
		$Camera2D.zoom = $Camera2D.zoom * 1.5
	
	if Input.is_key_pressed(KEY_F):
		$Camera2D.zoom = $Camera2D.zoom /1.5
