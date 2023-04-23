extends Camera2D

# Adapted from https://www.braindead.bzh/entry/godot-interactive-camera2d

export var MAX_ZOOM_LEVEL = 0.5
export var MIN_ZOOM_LEVEL = 12
export var ZOOM_INCREMENT = 0.5
export(NodePath) var map_path

signal moved
signal zoomed
#signal began_following(num)

var _current_zoom_level = 1
var _drag = false
var tilemap_bounds: Rect2
var initial_scale
var mvdir = Vector2.ZERO

onready var map = get_node(map_path)
onready var file_selected = false

func center():
	var tile_center = tilemap_bounds.position + tilemap_bounds.size / 2
	_center_on_position(Vector2(tile_center.x, 150))


func _center_on_position(pos: Vector2):
	set_offset(pos - get_viewport_rect().size / 2)


func refresh_bounds():
	tilemap_bounds = map.get_bounds()

func _process(_delta):
	set_offset(get_offset() - mvdir * -10 * zoom)

# Use _unhandled_input so that we don't move camera if mouse-down is on GUI
func _unhandled_input(event: InputEvent):
	if (!file_selected): return
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action_pressed("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action_pressed("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
		set_offset(get_offset() - event.relative * _current_zoom_level)
		#_constrain_view()
		emit_signal("moved")
	elif event.is_action_pressed("Down"):
		mvdir += Vector2.DOWN
	elif event.is_action_pressed("Left"):
		mvdir += Vector2.LEFT
	elif event.is_action_pressed("Right"):
		mvdir += Vector2.RIGHT
	elif event.is_action_pressed("Up"):
		mvdir += Vector2.UP
	elif event.is_action_released("Down"):
		mvdir -= Vector2.DOWN
	elif event.is_action_released("Left"):
		mvdir -= Vector2.LEFT
	elif event.is_action_released("Right"):
		mvdir -= Vector2.RIGHT
	elif event.is_action_released("Up"):
		mvdir -= Vector2.UP
	


func _update_zoom(incr: float, zoom_anchor: Vector2):
	var old_zoom = _current_zoom_level
	
	_current_zoom_level = clamp(_current_zoom_level + incr, MAX_ZOOM_LEVEL, MIN_ZOOM_LEVEL)

	if old_zoom == _current_zoom_level:
		return
	
	var zoom_center = zoom_anchor - get_offset()
	var ratio = 1-_current_zoom_level/old_zoom
	
	set_offset(get_offset() + zoom_center*ratio)
	set_zoom(Vector2(_current_zoom_level, _current_zoom_level))
	#_constrain_view()
	
	emit_signal("zoomed")


# Limits camera so that it is impossible to have just one of the two opposing
# edges of the tilemap off the screen. To be called after movement or zooming
func _constrain_view():
	var _map: Rect2 = Rect2( \
			tilemap_bounds.position - get_offset(), tilemap_bounds.size)
	var view: Rect2 = Rect2(get_viewport_rect().position, \
			get_viewport_rect().size * _current_zoom_level)
	
	# If just one of two opposite boundaries is out of view, 
	# move the camera the shortest distance so one boundary is on the edge
	if _map.end.x > view.end.x and _map.position.x >= view.position.x \
			or _map.position.x < view.position.x and _map.end.x <= view.end.x:
		if abs(_map.end.x - view.end.x) < abs(_map.position.x - view.position.x):
			self.offset.x +=  _map.end.x - view.end.x
		else:
			self.offset.x += _map.position.x - view.position.x
	
	if _map.end.y > view.end.y and _map.position.y >= view.position.y \
			or _map.position.y < view.position.y and _map.end.y <= view.end.y:
		if abs(_map.end.y - view.end.y) < abs(_map.position.y - view.position.y):
			self.offset.y +=  _map.end.y - view.end.y
		else:
			self.offset.y += _map.position.y - view.position.y


func _on_FileDialog_file_selected(_path):
	file_selected = true
