extends ItemEffect

class_name GenericEffect

@export var dialog_key: String

func _init(p_dialog_key := ""):
	dialog_key = p_dialog_key
	
func apply_overworld(map_manager: MapManager) -> bool:
	emit_signal("close_bag")
	var dialog := map_manager.load_dialog(dialog_key)
	dialog.go()
	return true
