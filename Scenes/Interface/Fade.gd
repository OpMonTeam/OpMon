extends ColorRect

class_name Fade

var alpha: float = 0.0

var tween: Tween
var duration: int

func _ready():
	color = Color(0, 0, 0, alpha)
	tween = create_tween()
	tween.tween_property(self, "alpha", 1.0, duration)
	tween.play()

func unfade(duration_: int):
	tween.interpolate_property(self, "alpha", 0.0, duration_)
	tween.play()

func _process(_delta):
	color = Color(0, 0, 0, alpha)
