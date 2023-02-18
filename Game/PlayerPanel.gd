extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_health(new_health):
	for i in $MarginContainer/PlayerContainer/Health/HeartContainer.get_child_count():
		$MarginContainer/PlayerContainer/Health/HeartContainer.get_child(i).visible = new_health > i

func subtract_health(health_diff):
	for i in range($MarginContainer/PlayerContainer/Health/HeartContainer.get_child_count()-1, -1, -1):
		if health_diff > 0 and $MarginContainer/PlayerContainer/Health/HeartContainer.get_child(i).visible:
			$MarginContainer/PlayerContainer/Health/HeartContainer.get_child(i).visible = 0
			health_diff -= 1

func update_gold(value):
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/IconStats/Coins/Coins.text = str(value)

func update_attack(value):
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/IconStats/Attack/Attack.text = str(value)
	
func update_range(value):
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/IconStats/Range/Range.text = str(value)
	
func update_speed(value):
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/IconStats/Speed/Speed.text = str(value)

func update_score(value):
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/Score.text = "Score: " + str(value)

func update_item(value):
	if (value == "None"):
		value = ""
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/Item.text = "Item: " + str(value)

func update_shielded(value):
	$MarginContainer/PlayerContainer/Health/Shield.visible = value
func update_active_item(item):
	if (item == "None"):
		item = ""
	$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/ActiveItem.text = "Active Item: " + str(item)
func update_turns_left(value):
	if (value < 0):
		$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/TurnsLeft.text = ""
	else:
		$MarginContainer/PlayerContainer/HBoxContainer/PlayerInfo/TurnsLeft.text = "Turns Left: " + str(value)
func set_name(value):
	$MarginContainer/PlayerContainer/NameLabel.text = "Name: " + str(value)

func update_class(new_class):
	#$MarginContainer/PlayerContainer/HBoxContainer/P1ClassSprite.texture = class_texture
	pass
