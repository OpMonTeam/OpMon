extends Object

# OpTeam: Class storing a team of maximum 6 OpMon and having different methods
# to manage it.

class_name OpTeam

var _team = [null, null, null, null, null, null]
# The number of non-null objects in the _team
var _size = 0

# The "team" parameter must be an array of 6 OpMon, with "null" if a square is empty
func _init(team: Array):
	for o in team:
		add_opmon(o)

# Adds an OpMon to the team, if there is still room.
# Returns true if the OpMon has been added, false otherwise.
func add_opmon(to_add: OpMon) -> bool:
	if _size < 6 and to_add != null:
		_team[_size] = to_add
		_size += 1
		return true
	else:
		return false

# Removes an OpMon from the team and returns it
# Returns null if there was no OpMon at the given place
# Note: the "number" argument is used as an array index so it starts at 0
func remove_opmon(number: int) -> OpMon:
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

func size() -> int:
	return _size
	
# Returns the OpMon at the given position
func get_opmon(number: int) -> OpMon:
	return _team[number]

# Completely heals the team 
func heal():
	for opmon in _team:
		opmon.heal()

# Checks if the entire team is ko
func is_ko() -> bool:
	var total = true
	for opmon in _team:
		if(opmon != null):
			total = total and opmon.is_ko()
	return total

# Returns the next non-ko OpMon available, null if the team is KO
func next_available() -> OpMon:
	for opmon in _team:
		if opmon != null:
			if not opmon.is_ko():
				return opmon
	return null

# Switches two OpMons
func switch(index1: int, index2: int):
	var op1 = _team[index1]
	_team[index1] = _team[index2]
	_team[index2] = op1
	
func save() -> Array:
	var ret := []
	for opmon in _team:
		if opmon == null:
			ret.append(null)
		else:
			ret.append(opmon.save())
	return ret
