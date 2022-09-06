# Note: model class
# Can’t be use as actual resource class since Godot’s interface can’t create new resources
# with types inheriting types inheriting from Resource
# Hope this will be possible in 4.0
# Meanwhile, just copy-paste these methods into each class and make it directly inherit Resource
extends Resource

class_name MoveEffect

func apply(battle_scene, _move, user: OpMon, opponent: OpMon) -> bool:
	return true
