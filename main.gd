extends Node2D

const outline = 1
var cube_size_percent = 50

var min_size = 0
var cube_size = 0
var cube_size_percent_velocity = 0

var vanishing_points = PoolVector2Array()
var vanishing_helper_points = PoolVector2Array()
var cube_points = PoolVector2Array()
var cube_intersection_points = PoolVector2Array()

var disposition = 0

var screen_index = 0

var cube_color

func _ready():
	for x in range(3):
		vanishing_points.append(Vector2(0, 0))
		vanishing_helper_points.append(Vector2(0, 0))
		cube_points.append(Vector2(0, 0))
		cube_intersection_points.append(Vector2(0, 0))
	
	cube_color = Color(0, 0, 0)
	set_process_input(true)
	
func _process(delta):
	disposition += delta / 4
	
	var window_size = get_viewport_rect().size
	
	update_min_size(window_size)
	update_cube_size()
	update_position(window_size)
	
	update_vanishing_points()
	update_cube_points()
	
	cube_size_percent_velocity = sin(disposition * 15) / 2
	
	cube_color.r = sin(disposition * 5)
	cube_color.g = sin(disposition * 7)
	cube_color.b = 1 - cos(disposition)
	
	update()
	
	#capture()

func capture():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var i = get_viewport().get_texture().get_data()
	i.save_png("user://cube2d-export/" + str(screen_index) + ".png")
	screen_index += 1

func _draw():
	draw_circle(Vector2(0, 0), min_size / 2, Color(1, 1, 1))
	draw_circle(Vector2(0, 0), min_size / 2 - outline, Color(0, 0, 0))
	
	for vp in vanishing_points:
		draw_line(Vector2(0, 0), vp, Color(0.5, 0.5, 0.5))
	for vp in vanishing_helper_points:
		draw_line(Vector2(0, 0), vp, Color(0.2, 0.2, 0.2))
	draw_cube()

func update_vanishing_points():
	var d1 = (PI * 2) / 3
	var d2 = d1 / 2.0
	for vp in len(vanishing_points):
		var x = sin(disposition + d1 * vp) * min_size / 2
		var y = cos(disposition + d1 * vp) * min_size / 2
		vanishing_points.set(vp, Vector2(x, y))
		
		# vanishing_helper_points rotated a bit, so they will show, where cube edges will be intercepted
		x = sin(disposition + d1 * vp + d2) * min_size / 2
		y = cos(disposition + d1 * vp + d2) * min_size / 2
		vanishing_helper_points.set(vp, Vector2(x, y))

func update_cube_points():
	var d1 = (PI * 2) / 3
	var d2 = d1 / 2.0
	
	for cp in len(cube_points):
		var x = sin(disposition + d1 * cp) * cube_size / 2
		var y = cos(disposition + d1 * cp) * cube_size / 2
		cube_points.set(cp, Vector2(x, y))
	
	# here we find interception between cube vertex and vanishing points
	for cp in len(cube_points):
		var i2 = cp + 1
		if i2 >= len(cube_points):
			i2 = 0
		
		var p1 = cube_points[cp]
		var p2 = vanishing_points[i2]
		var p3 = cube_points[i2]
		var p4 = vanishing_points[cp]
		
		var intersection = Geometry.segment_intersects_segment_2d(p1, p2, p3, p4)
		if intersection != null:
			cube_intersection_points.set(cp, intersection)

func draw_cube():
	for cp in len(cube_points):
		draw_line(Vector2(0, 0), cube_points[cp], cube_color)
		
		if cp < len(cube_points) - 1:
			draw_line(cube_points[cp], vanishing_points[cp + 1], Color(0.2, 0.2, 0.2))
		else:
			draw_line(cube_points[cp], vanishing_points[0], Color(0.2, 0.2, 0.2))
		if cp > 0:
			draw_line(cube_points[cp], vanishing_points[cp - 1], Color(0.2, 0.2, 0.2))
		else:
			draw_line(cube_points[cp], vanishing_points[len(cube_points) - 1], Color(0.2, 0.2, 0.2))
		
		draw_line(cube_points[cp], cube_intersection_points[cp], cube_color)
		if cp > 0:
			draw_line(cube_points[cp], cube_intersection_points[cp - 1], cube_color)
		else:
			draw_line(cube_points[cp], cube_intersection_points[len(cube_points) - 1], cube_color)
	

func update_min_size(window_size):
	min_size = min(window_size.x, window_size.y)

func update_cube_size():
	cube_size = min_size / 100.0 * cube_size_percent
	
	cube_size_percent += cube_size_percent_velocity
	if cube_size_percent > 100:
		cube_size_percent = 100
	elif cube_size_percent < 0:
		cube_size_percent = 0
	
	if cube_size_percent_velocity > 0.04:
		cube_size_percent_velocity -= 0.02
	elif cube_size_percent_velocity < -0.04:
		cube_size_percent_velocity += 0.02
	else:
		cube_size_percent_velocity = 0


func update_position(window_size):
	position.x = window_size.x / 2
	position.y = window_size.y / 2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			cube_size_percent_velocity = 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			cube_size_percent_velocity = -1