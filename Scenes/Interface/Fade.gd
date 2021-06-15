extends ColorRect

var alpha: float = 0.0

func _ready():
	color = Color(0, 0, 0, alpha)
	
func _process(_delta):
	print(alpha)
	color = Color(0, 0, 0, alpha)
