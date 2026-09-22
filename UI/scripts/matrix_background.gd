extends Control

@export_group("Number Rain")
@export var rain_enabled: bool = true
@export var rain_spacing: float = 18.0
@export var rain_font_size: int = 14
@export var rain_min_speed: float = 150.0
@export var rain_max_speed: float = 300.0
@export var rain_color: Color = Color(1.0, 0.0, 0.1)
@export var rain_brightness: float = 0.65

@export_group("Large Fading Numbers")
@export var large_numbers_enabled: bool = true
@export var large_font_size: int = 48
@export var large_color: Color = Color(1.0, 0.0, 0.1)
@export var large_opacity: float = 0.35
@export var large_fade_time: float = 1.5 # Fade duration
@export var large_min_duration: float = 4.0
@export var large_max_duration: float = 8.0

@export_group("Background Sparks")
@export var sparks_enabled: bool = true
@export var spark_count: int = 250
@export var spark_color: Color = Color(1.0, 0.05, 0.12)
@export var spark_brightness: float = 0.65
@export var spark_size: float = 1.5
@export var spark_speed: float = 2.0

var sparks: Array[Dictionary] = []
var spark_time: float = 0.0

var rain_streams: Array[Dictionary] = []
var large_numbers: Array[Dictionary] = []
var digit_timer: float = 0.0
var matrix_font: Font
var large_digit_timer: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	matrix_font = ThemeDB.fallback_font
	_create_rain()
	_create_large_numbers()
	_create_sparks()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_create_rain()
		_create_large_numbers()
		_create_sparks()

func _create_rain() -> void:
	rain_streams.clear()
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var columns: int = int(ceil(size.x / maxf(rain_spacing, 1.0)))
	for column in range(columns):
		var stream: Dictionary = {
			"x": float(column) * rain_spacing,
			"y": randf_range(-size.y, 0.0),
			"speed": randf_range(rain_min_speed, rain_max_speed),
			"length": randi_range(5, 15),
			"digits": _random_digits(15),
			"brightness": randf_range(0.35, 1.0)
		}
		rain_streams.append(stream)

func _random_digits(amount: int) -> String:
	var result: String = ""
	for i in range(amount):
		result += str(randi_range(0, 9))
	return result

func _create_sparks() -> void:
	sparks.clear()
	if size.x <= 0.0 or size.y <= 0.0:
		return
	for i in range(spark_count):
		var depth: float = sqrt(randf())
		sparks.append({
			"pos": Vector2(randf_range(0.0, size.x), lerpf(size.y * 0.5, size.y, depth)),
			"size": randf_range(0.5, spark_size),
			"phase": randf_range(0.0, TAU),
			"speed": randf_range(0.5, 2.0),
			"depth": depth
		})

func _create_large_numbers() -> void:
	large_numbers.clear()
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var columns: int = 4
	var rows: int = 2 # Screen sections
	var cell_width: float = size.x / float(columns)
	var cell_height: float = size.y / float(rows)
	for row in range(rows):
		for column in range(columns):
			var number: Dictionary = {
				"x": (column + randf_range(0.2, 0.7)) * cell_width,
				"y": (row + randf_range(0.3, 0.8)) * cell_height,
				"digit": str(randi_range(0, 9)),
				"age": randf_range(0.0, large_max_duration),
				"duration": randf_range(large_min_duration, large_max_duration),
				"scale": randf_range(0.8, 1.5)
			}
			large_numbers.append(number)

func _process(delta: float) -> void:
	_update_rain(delta)
	_update_large_numbers(delta)
	spark_time += delta * spark_speed
	queue_redraw()

func _update_rain(delta: float) -> void:
	if not rain_enabled:
		return
	digit_timer += delta
	for stream in rain_streams:
		stream["y"] += stream["speed"] * delta
		var trail_size: float = stream["length"] * float(rain_font_size)
		if stream["y"] - trail_size > size.y: # Reset offscreen streams
			stream["y"] = randf_range(-size.y * 0.5, 0.0)
			stream["speed"] = randf_range(rain_min_speed, rain_max_speed)
			stream["length"] = randi_range(5, 15)
	if digit_timer >= 0.12: # Refresh digits
		digit_timer = 0.0
		for stream in rain_streams:
			stream["digits"] = _random_digits(15)

func _update_large_numbers(delta: float) -> void:
	if not large_numbers_enabled:
		return
	large_digit_timer += delta
	for number in large_numbers:
		number["age"] += delta
		if number["age"] >= number["duration"]: # New number setup
			number["age"] = 0.0
			number["duration"] = randf_range(large_min_duration, large_max_duration)
			number["scale"] = randf_range(0.8, 1.5)
			number["x"] = randf_range(40.0, size.x - 40.0)
			number["y"] = randf_range(40.0, size.y - 40.0)
	if large_digit_timer >= 0.25: # Change digits
		large_digit_timer = 0.0
		for number in large_numbers:
			number["digit"] = str(randi_range(0, 9))

func _draw() -> void:
	if sparks_enabled:
		_draw_sparks()
	if matrix_font == null:
		return
	if rain_enabled:
		_draw_rain()
	if large_numbers_enabled:
		_draw_large_numbers()

func _draw_sparks() -> void:
	for spark in sparks:
		var glow: float = (sin(spark_time * spark["speed"] + spark["phase"]) + 1.0) * 0.5
		var alpha: float = (0.15 + glow * 0.85) * spark_brightness * spark["depth"]
		var color: Color = spark_color
		color.a = alpha
		draw_circle(spark["pos"], spark["size"], color)

func _draw_rain() -> void:
	for stream in rain_streams:
		var head_y: float = stream["y"]
		var stream_x: float = stream["x"]
		var stream_length: int = stream["length"]
		var digits: String = stream["digits"]
		for i in range(stream_length):
			var digit_y: float = head_y - i * rain_font_size
			if digit_y < -rain_font_size or digit_y > size.y:
				continue
			var fade: float = 1.0 - float(i) / float(stream_length)
			var alpha: float = fade * fade # Trail opacity
			alpha *= stream["brightness"]
			alpha *= rain_brightness
			var color: Color = rain_color
			color.a = alpha
			if i == 0:
				color = Color(1.0, 0.45, 0.45, alpha) # Bright leading digit rede
			var digit: String = digits.substr(i, 1)
			draw_string(matrix_font, Vector2(stream_x, digit_y), digit,
				HORIZONTAL_ALIGNMENT_LEFT, -1, rain_font_size, color)

func _draw_large_numbers() -> void:
	for number in large_numbers:
		var age: float = number["age"]
		var duration: float = number["duration"]
		var fade_in: float = clampf(age / maxf(large_fade_time, 0.01), 0.0, 1.0)
		var fade_out: float = clampf((duration - age) / maxf(large_fade_time, 0.01), 0.0, 1.0)
		var alpha: float = minf(fade_in, fade_out)
		alpha = alpha * alpha * (3.0 - 2.0 * alpha) # Smooth fade
		alpha *= large_opacity
		var color: Color = large_color
		color.a = alpha
		var font_size: int = int(large_font_size * number["scale"])
		draw_string(matrix_font, Vector2(number["x"], number["y"]), number["digit"],
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
