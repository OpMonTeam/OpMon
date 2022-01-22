extends Object

# OpTeam: Class storing a team of maximum 6 OpMon and having different methods
# to manage it.

const OpMon = preload("res://Objects/OpMon.gd")

var _team = [null, null, null, null, null, null]
# The number of non-null objects in the _team
var _size = 0

# The "team" parameter must be an array of 6 OpMon, with "null" if a square is empty
func _init(team: Array):
	pass

# Adds an OpMon to the team, if there is still room.
# Returns true if the OpMon has been added, false otherwise.
func add_opmon(to_add: OpMon):
	if(_size < 6):
		_team[_size] = to_add
		_size += 1
		return true
	else:
		return false

# Removes an OpMon from the team and returns it
# Returns null if there was no OpMon at the given place
# Note: the "number" argument is used as an array index so it starts at 0
func remove_opmon(number: int):
	if(_size == 1):
		return null
	var to_ret = _team[number]
	_team[number] = null
	_purge_empty_spaces()
	return to_ret

# Removes empty spaces from theteam
func _purge_empty_spaces():
	var old_team = _team
	_team = [null, null, null, null, null, null]
	for opmon in old_team:
		if(opmon != null):
			add_opmon(opmon)

func size():
	return _size
	
# Returns the OpMon at the given position
func get_opmon(number: int):
	return _team[number]

# Completely heals the team 
func heal():
	for opmon in _team:
		opmon.heal()

# Checks if the entire team is ko
func is_ko():
	var total = true
	for opmon in _team:
		if(opmon != null):
			total = total and opmon.is_ko()
	return total
