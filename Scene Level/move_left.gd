extends TouchScreenButton

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		var local_pos = to_local(event.position)

		if texture_normal:
			var size = texture_normal.get_size()
			var rect = Rect2(Vector2.ZERO, size)

			if rect.has_point(local_pos):
				# Defer the block so the built-in button action still fires
				call_deferred("_block_input")

func _block_input():
	get_viewport().set_input_as_handled()
