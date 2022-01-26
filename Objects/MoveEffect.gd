extends Resource

class_name MoveEffect

# To create a move effect, you have to create a script inheriting this class
# To assignate your move effect to a move, you have to create
# a resource object of your custom effect (even if it has parameters, put default ones)
# and then assign this object to a move and make the resource unique

signal play_dialog(content)
signal stat_changed(stat, change)

const signals = ["play_dialog", "stat_changed"]

# Must return a boolean indicating if the move can continue or not (true if continue, false if not)
# Mostly used for pre-move effects
func apply(move: Move, user: OpMon, opponent: OpMon) -> bool:
	return true
