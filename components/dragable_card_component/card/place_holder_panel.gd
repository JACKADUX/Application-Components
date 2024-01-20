class_name PlaceHolderPanel extends Panel

var active := false

var tween:Tween
func change_size(value:Vector2, duration:float):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "custom_minimum_size", value, duration)
	
