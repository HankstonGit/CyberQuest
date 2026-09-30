extends Node

signal pause_requested(duration)

var pauses = []


func extract_pauses_from_string(source: String) -> String:
	pauses.clear()

	var clean_text = ""
	var visible_position = 0
	var i = 0

	while i < source.length():

		# Look for a pause command like {p=0.5}
		if source.substr(i, 3) == "{p=":
			var closing_brace = source.find("}", i)

			if closing_brace != -1:
				var number_text = source.substr(
					i + 3,
					closing_brace - (i + 3)
				)

				if number_text.is_valid_float():
					pauses.append({
						"position": visible_position,
						"duration": number_text.to_float()
					})

					i = closing_brace + 1
					continue

		# Keep BBCode tags, but don't count them as visible letters
		if source.substr(i, 1) == "[":
			var closing_bracket = source.find("]", i)

			if closing_bracket != -1:
				clean_text += source.substr(
					i,
					closing_bracket - i + 1
				)

				i = closing_bracket + 1
				continue

		clean_text += source.substr(i, 1)
		visible_position += 1
		i += 1

	return clean_text


func check_at_position(position: int) -> void:
	for pause in pauses:
		if pause["position"] == position:
			pause_requested.emit(pause["duration"])
