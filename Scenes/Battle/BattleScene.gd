extends Interface

func opmon_selected():
	pass
	
func item_selected():
	pass
	
func move_selected():
	pass
	
func run_selected():
	emit_signal("closed")
