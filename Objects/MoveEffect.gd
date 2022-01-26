extends Resource

class_name MoveEffect

# To create a move effect, you have to create a script inheriting this class
# To assignate your move effect to a move, you have to create
# a resource object of your custom effect (even if it has parameters, put default ones)
# and then assign this object to a move and make the resource unique

signal dialog(content)
signal stat_changed(stat, change)

func apply(move: Move, user: OpMon, opponent: OpMon):
	pass
