extends Camera2D

func move(delta:Vector2):
	position += delta
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)
	
