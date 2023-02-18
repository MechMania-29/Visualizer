extends Node

# Main containers
const GAMELOG_TURNNUM = "turn"
const GAMELOG_USE_ACTIONS = "use_actions"
const GAMELOG_MOVE_ACTIONS = "move_actions"
const GAMELOG_ATTACK_ACTIONS = "attack_actions"
const GAMELOG_BUY_ACTIONS = "buy_actions"
const GAMELOG_PLAYERS = "player_states"
const GAMELOG_ = "GameLog"
const GAMELOG_MAIN = "Main"
const GAMELOG_INFO = "Info"
const GAMELOG_TURNS = "Turns"

# Player state
const GAMELOG_PLAYER_CLASS = "class"
const GAMELOG_PLAYER_ITEM = "item"
const GAMELOG_PLAYER_POS = "position"
const GAMELOG_PLAYER_POS_X = "x"
const GAMELOG_PLAYER_POS_Y = "y"
const GAMELOG_PLAYER_HP = "health"
const GAMELOG_PLAYER_GOLD = "gold"
const GAMELOG_PLAYER_SCORE = "score"    
const GAMELOG_PLAYER_BUFFS = "StatBuffs" # not yet implemented
const GAMELOG_PLAYER_ID = "Player"

# Action state

const GAMELOG_ACTION_BUY_ITEM = "item"
const GAMELOG_ACTION_EXECUTOR = "executor"
const GAMELOG_ACTION_DESTINATION = "destination"
const GAMELOG_ACTION_DESTINATION_X = "x"
const GAMELOG_ACTION_DESTINATION_Y = "y"
const GAMELOG_ACTION_TARGET = "target"
const GAMELOG_ACTIONS = "Actions"
const GAMELOG_ACTION_ACTION = "Action"
const GAMELOG_ACTION_ID = "Player"

signal gamelog_verification_start
signal gamelog_verification_complete
signal gamelog_verification_failed
signal progress_text_changed
signal progress_changed

var GameLog : Array
var Names: Array
var gamelog_states : Array
var progress : float = 0 setget _set_progress
var max_progress : float
var progress_text : String = "" setget _set_progress_text

var current_turn : int # Current turn in play
var player_count : int # Number of players in game

# HTML5/JS detection
onready var use_js = OS.get_name() == "HTML5" and OS.has_feature('JavaScript')

enum Classes {
	KNIGHT, 
	ARCHER, 
	WIZARD,
}

enum Items {
	NONE = -1,
	SHIELD,
	PROCRUSTEAN_IRON,
	HEAVY_BROADSWORD,
	MAGIC_STAFF,
	STEEL_TIPPED_ARROWS,
	ANEMOI_WINGS,
	STRENGTH_POTION,
	SPEED_POTION,
	DEXTERITY_POTION,
}

func _ready():
	set_process(false)


# Starts gamelog verification process
func verify_GameLog(_gamelog):
	
	if !_valid_keys(_gamelog): 
		emit_signal("gamelog_verification_failed")
		return
	GameLog = _gamelog["turns"]
	Names = _gamelog["names"]
	gamelog_states = GameLog.duplicate(false)
	progress = 0
	true_turnNum = 0
	max_progress = gamelog_states.size() - 1
	set_process(true)
	emit_signal("gamelog_verification_start")


# Verification iteration
func _process(_delta):
	
	# Adjustable # of turns to verify per iteration
	for _i in range(1):
		
		if true_turnNum >= gamelog_states.size():
			_set_progress(max_progress)
			_set_progress_text("Verification complete!")
			emit_signal("gamelog_verification_complete")
			set_process(false)
			return
		
		var state = GameLog[true_turnNum]
		if !_valid_state(state):
			emit_signal("gamelog_verification_failed")
			set_process(false)
			return
		
		_set_progress(progress + 1)
		_set_progress_text("Verified %s/%s" % [progress, max_progress])
		#_set_progress_text(progress_text)
		
	

# Verifies that Main, Info, and Turns exist and are correct
func _valid_keys(gamelog) -> bool:
	gamelog = gamelog["turns"]
	if gamelog == null or !(gamelog is Array): 
		_set_progress_text("Invalid file")
		return false
	if gamelog.empty():
		_set_progress_text("Empty file")
		return false
	#if !gamelog.has(GAMELOG_): 
	#	_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_)
	#	return false
	#if !gamelog[GAMELOG_].has(GAMELOG_MAIN): 
	#	_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_MAIN)
	#	return false 
	#if !gamelog[GAMELOG_][GAMELOG_MAIN].has(GAMELOG_INFO):
	#	_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_INFO)
	#	return false
	#if !gamelog[GAMELOG_][GAMELOG_MAIN].has(GAMELOG_TURNS): 
	#	_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_TURNS)
	#	return false
	player_count = 4 #TODO: Get player count
	return true

# verifies each turn is correct
func _valid_state(state) -> bool:
	return _valid_TurnNum(state) and _valid_Players(state) and _valid_Actions(state)

# Verifies TurnNum
var true_turnNum : int = 0
func _valid_TurnNum(state) -> bool:
	if !state.has(GAMELOG_TURNNUM): 
		_set_progress_text("Invalid turn, missing key \"%s\" (%d)" % [GAMELOG_TURNNUM, true_turnNum])
		return false
	if !(state[GAMELOG_TURNNUM] is float) or !_is_integer(state[GAMELOG_TURNNUM]) or state[GAMELOG_TURNNUM] < 0:
		_set_progress_text("Invalid \"%s\", (%s) is !(a positive integer" % [GAMELOG_TURNNUM,state[GAMELOG_TURNNUM]])
		return false
	if int(state[GAMELOG_TURNNUM]) != true_turnNum:
		_set_progress_text("Out of order \"%s\", (%s) should be (%d)" % [GAMELOG_TURNNUM, state[GAMELOG_TURNNUM], true_turnNum])
		return false
	true_turnNum+=1
	return true

# Verifies Players info
func _valid_Players(state) -> bool:
	if !state.has(GAMELOG_PLAYERS):
		_set_progress_text("Invalid turn, missing key \"%s\"" % GAMELOG_PLAYERS)
		return false
	var players = state[GAMELOG_PLAYERS]
	if !players is Array:
		_set_progress_text("Invalid \"%s\" in turn %d, object is !(an array" % [GAMELOG_PLAYERS, true_turnNum])
		return false
	if players.size() != player_count:
		_set_progress_text("Invalid \"%s\" in turn %d, %d/%d players found" % [GAMELOG_PLAYERS, true_turnNum, players.size(), player_count])
		return false
	
	for i in range(players.size()):
		var player = players[i]
		if !(player is Dictionary):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is incorrect data format" % [GAMELOG_PLAYERS, true_turnNum, i])
			return false
		
#		if !player.has(GAMELOG_PLAYER_ID):
#			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_ID])
#			return false
#		var id = player[GAMELOG_PLAYER_ID]
#		if  !(id is float) or !_is_integer(id) or id < 0 or id > player_count:
#			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_ID])
#			return false
		
		if !player.has(GAMELOG_PLAYER_CLASS):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_CLASS])
			return false
		if !(player[GAMELOG_PLAYER_CLASS] is String):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_CLASS])
			return false
		
#		if !player.has(GAMELOG_PLAYER_BUFFS):
#			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_BUFFS])
#			return false
#		if !(player[GAMELOG_PLAYER_BUFFS] is Array):
#			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_BUFFS])
#			return false 
		#TODO: Missing buffs in gamelog, need to verify individual buffs
		
		if !player.has(GAMELOG_PLAYER_ITEM):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_ITEM])
			return false
		if !(player[GAMELOG_PLAYER_ITEM] is String):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_ITEM])
			return false
		
		if !player.has(GAMELOG_PLAYER_POS):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_POS])
			return false
		var pos = player[GAMELOG_PLAYER_POS]
		if !(pos is Dictionary) or pos.size() != 2:
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_POS])
			return false
		if (!pos.has(GAMELOG_PLAYER_POS_X) or !_is_integer(pos[GAMELOG_PLAYER_POS_X])) or \
		   (!pos.has(GAMELOG_PLAYER_POS_Y) or !_is_integer(pos[GAMELOG_PLAYER_POS_Y])) :
				_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, GAMELOG_PLAYER_POS])
				return false
		
		if !player.has(GAMELOG_PLAYER_HP):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_HP])
			return false
		var hp = player[GAMELOG_PLAYER_HP]
		if !(hp is float) or !_is_integer(hp):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_HP])
			return false
		
		if !player.has(GAMELOG_PLAYER_GOLD):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_GOLD])
			return false
		var gold = player[GAMELOG_PLAYER_GOLD]
		if !(gold is float) or !_is_integer(gold):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_HP])
			return false
		
		if !player.has(GAMELOG_PLAYER_SCORE):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d is missing key \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_GOLD])
			return false
		var score = player[GAMELOG_PLAYER_SCORE]
		if !(score is float) or !_is_integer(score):
			_set_progress_text("Invalid \"%s\" in turn %s, object %d contains invalid data for \"%s\"" % [GAMELOG_PLAYERS, true_turnNum, i, GAMELOG_PLAYER_HP])
			return false
	
	return true


# Verifies Actions
func _valid_Actions(state: Dictionary) -> bool:
	if !state.has(GAMELOG_USE_ACTIONS): 
		_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_USE_ACTIONS)
		return false
	if !state.has(GAMELOG_MOVE_ACTIONS): 
		_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_MOVE_ACTIONS)
		return false
	if !state.has(GAMELOG_ATTACK_ACTIONS): 
		_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_ATTACK_ACTIONS)
		return false
	if !state.has(GAMELOG_BUY_ACTIONS): 
		_set_progress_text("Invalid file, missing \"%s\"" % GAMELOG_BUY_ACTIONS)
		return false
	
	
	var use_actions = state[GAMELOG_USE_ACTIONS]
	if !(use_actions is Array):
		_set_progress_text("Invalid file, \"%s\" is not an array" % GAMELOG_USE_ACTIONS)
		return false
	for i in range(use_actions.size()):
		var a = use_actions[i]
		if a == null: continue # Quick fix for current test json
		if !(a is Dictionary):
			_set_progress_text("Invalid %s in turn %s, object %d is invalid data" % [GAMELOG_USE_ACTIONS, true_turnNum, i])
			return false
		if (!a.has(GAMELOG_ACTION_EXECUTOR)):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_USE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_EXECUTOR])
		if !(a[GAMELOG_ACTION_EXECUTOR] is float) or !_is_integer(a[GAMELOG_ACTION_EXECUTOR]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data" % [GAMELOG_USE_ACTIONS, true_turnNum, i])
			return false
		#TODO: Verify item used
		
	
	var move_actions = state[GAMELOG_MOVE_ACTIONS]
	if !(move_actions is Array):
		_set_progress_text("Invalid file, \"%s\" is not an array" % GAMELOG_MOVE_ACTIONS)
		return false
	for i in range(move_actions.size()):
		var a = move_actions[i]
		if a == null: continue # Quick fix for current test json
		if !(a is Dictionary):
			_set_progress_text("Invalid %s in turn %s, object %d is invalid data" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i])
			return false
		if !a.has(GAMELOG_ACTION_EXECUTOR):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_EXECUTOR])
		if !(a[GAMELOG_ACTION_EXECUTOR] is float) or !_is_integer(a[GAMELOG_ACTION_EXECUTOR]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i])
			return false
		
		if !a.has(GAMELOG_ACTION_DESTINATION):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_DESTINATION])
			return false
		
		var d = a[GAMELOG_ACTION_DESTINATION]
		if !d.has(GAMELOG_ACTION_DESTINATION_X):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_DESTINATION_X])
			return false
		if !_is_integer(d[GAMELOG_ACTION_DESTINATION_X]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data in \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_DESTINATION_X])
			return false
		if !d.has(GAMELOG_ACTION_DESTINATION_Y):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_DESTINATION_Y])
			return false
		if !_is_integer(d[GAMELOG_ACTION_DESTINATION_Y]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data in \"%s\"" % [GAMELOG_MOVE_ACTIONS, true_turnNum, i, GAMELOG_ACTION_DESTINATION_X])
			return false
		
	
	var attack_actions = state[GAMELOG_ATTACK_ACTIONS]
	if !(attack_actions is Array):
		_set_progress_text("Invalid file, \"%s\" is not an array" % GAMELOG_ATTACK_ACTIONS)
		return false
	for i in range(attack_actions.size()):
		var a = attack_actions[i]
		if a == null: continue # Quick fix for current test json
		if !(a is Dictionary):
			_set_progress_text("Invalid %s in turn %s, object %d is invalid data" % [GAMELOG_ATTACK_ACTIONS, true_turnNum, i])
			return false
		if (!a.has(GAMELOG_ACTION_EXECUTOR)):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_ATTACK_ACTIONS, true_turnNum, i, GAMELOG_ACTION_EXECUTOR])
			
		if !(a[GAMELOG_ACTION_EXECUTOR] is float) or !_is_integer(a[GAMELOG_ACTION_EXECUTOR]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data" % [GAMELOG_ATTACK_ACTIONS, true_turnNum, i])
			return false
		
		if !a.has(GAMELOG_ACTION_TARGET):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_ATTACK_ACTIONS, true_turnNum, i, GAMELOG_ACTION_TARGET])
			return false
		if !(a[GAMELOG_ACTION_TARGET] is float) or !_is_integer(a[GAMELOG_ACTION_TARGET]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data in \"%S\"" % [GAMELOG_ATTACK_ACTIONS, true_turnNum, i, GAMELOG_ACTION_TARGET])
			return false
		
	
	var buy_actions = state[GAMELOG_BUY_ACTIONS]
	if !(buy_actions is Array):
		_set_progress_text("Invalid file, \"%s\" is not an array" % GAMELOG_BUY_ACTIONS)
		return false
	for i in range(buy_actions.size()):
		var a = buy_actions[i]
		if a == null: continue # Quick fix for current test json
		if !(a is Dictionary):
			_set_progress_text("Invalid %s in turn %s, object %d is invalid data" % [GAMELOG_BUY_ACTIONS, true_turnNum, i])
			return false
		if (!a.has(GAMELOG_ACTION_EXECUTOR)):
			_set_progress_text("Invalid %s in turn %s, object %d is missing key \"%s\"" % [GAMELOG_BUY_ACTIONS, true_turnNum, i, GAMELOG_ACTION_EXECUTOR])
		if !(a[GAMELOG_ACTION_EXECUTOR] is float) or !_is_integer(a[GAMELOG_ACTION_EXECUTOR]):
			_set_progress_text("Invalid %s in turn %s, object %d contains invalid data" % [GAMELOG_BUY_ACTIONS, true_turnNum, i])
			return false
		# TODO: verify item bought
	
	return true


func _set_progress_text(new : String):
	progress_text = new
	print(progress_text)
	emit_signal("progress_text_changed", new)

func _set_progress(new: float):
	progress = new
	emit_signal("progress_changed", (new / max_progress) * 100)

func _is_integer(x : float):
	return fmod(x, 1.0) == 0
