extends Control

var color_default = Color(0,0.1,0.6,255)
var width_default = 5

var lines = []
var current_line = []
var colors_and_widths = []

func _ready():
	self.rect_size.x = 109*4
	self.rect_size.y = 109*4
	colors_and_widths.append([-1,[color_default,width_default]])

func _process(delta):
	var _delta = delta #silences the error
	update()

func clip(v):
	return Vector2(max(min(v.x,self.rect_size.x),0), max(min(v.y,self.rect_size.y),0))

func normalize(v,w=-1,h=-1):
	if w<0:
		w = self.rect_size.x
	if h<0:
		h = self.rect_size.y
	if v is Array or v is PoolVector2Array:
		var norm_arr = PoolVector2Array()
		for elem in v:
			norm_arr.append(normalize(elem))
		return norm_arr
	else:
		return Vector2(109.0 * v.x/w, 109.0* v.y/h)
	
func denormalize(v,w=-1,h=-1):
	if w<0:
		w = self.rect_size.x
	if h<0:
		h = self.rect_size.y
	if v is Array or v is PoolVector2Array:
		var denorm_arr = PoolVector2Array()
		for elem in v:
			denorm_arr.append(denormalize(elem))
		return denorm_arr
	else:
		return Vector2(w * v.x/109.0, h* v.y/109.0)

func dist(v1,v2):
	return floor(sqrt(pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2)))
	
func get_line_color_and_with(index):
	for ca in colors_and_widths:
		if index<ca[0]:
			return ca[1]
	return colors_and_widths[colors_and_widths.size()-1][1]
	
func change_line_color_to(color=Color(0,0.1,0.6,255),width=5):
	colors_and_widths[colors_and_widths.size()-1][0]=lines.size()
	colors_and_widths.append([-1,[color,width]])

func update_mouse(vec):
	vec = clip(vec) #Make sure no points are outside bounds
	
	if len(current_line)==0:#If array empty, append it regarless
		current_line.append(vec)
	elif (dist(vec,current_line[-1])) > 2: #Ignore points that are too close together
		current_line.append(vec)
		#print('x = ' + str(X) + ';  y = ' + str(Y))

func include_line():
	if current_line.size()>0:
		lines.append(current_line)
		current_line = []

func include_svg_path(svg_path):
	for segment in svg_path:
		var pen = Vector2(0,0)
		for element in segment:
			match element[0]:
				'M':#TOOD implicit lineto not implemented
					pen = Vector2(element[1],element[2])
				'm':#move
					pen.x += element[1]
					pen.y += element[2]
				'l':#line
					var pen_new = Vector2(element[1]+pen.x,element[2]+pen.y)
					lines.append(denormalize([pen,pen_new]))
					pen = pen_new
				'L':#line absolute
					var pen_new = Vector2(element[1],element[2])
					lines.append(denormalize([pen,pen_new]))
					pen = pen_new
				'c':#quadratic bezier
					var curve = Curve2D.new()#c 7.7 -0.57, 22.91 -1.86, 32.51 -2.35
					curve.add_point(pen,Vector2(0,0),Vector2(element[1],element[2]))
					curve.add_point(Vector2(pen.x+element[5],pen.y+element[6]),Vector2(0,0),Vector2(element[3],element[4]))
					pen = Vector2(pen.x+element[5],pen.y+element[6])
					#print(curve.tessellate())
					lines.append(denormalize(curve.tessellate(3)))
				'C':#quadratic bezier absolute
					var curve = Curve2D.new()#c 7.7 -0.57, 22.91 -1.86, 32.51 -2.35
					curve.add_point(pen,Vector2(0,0),Vector2(element[1]-pen.x,element[2]-pen.y))
					curve.add_point(Vector2(element[5],element[6]),Vector2(0,0),Vector2(element[3]-pen.x,element[4]-pen.y))
					pen = Vector2(element[5],element[6])
					#print(curve.tessellate())
					lines.append(denormalize(curve.tessellate(3)))
					
#Does not try to approximate drawing with bezier
#TODO compress image
func drawing_to_svg_path(lines):
	var segments = []
	for line in lines:
		var segment = []
		var point = normalize(line[0])
		segment.append(['M',point.x,point.y])
		for i in range(1,line.size()):
			point = normalize(line[i])
			segment.append(['L',point.x,point.y])
		segments.append(segment)
	return segments

					
func clear_drawing():
	current_line = []
	lines = []
	#$"/root/GlobalVars".save_svg_path('user://lessons/lesson0/06f5c_re.svg',segments)

func is_empty():
	return lines.empty()
	
func load_drawing(file_name):
	var segments = $"/root/GlobalVars".read_svg(file_name)
	include_svg_path(segments)

func save_dawing():
	if not lines.empty():
		
		var supplement_directory = Directory.new()
		var lesson_dir_str = 'user://lessons/'+$"/root/GlobalVars".current_lesson
		if not supplement_directory.dir_exists(lesson_dir_str):
			supplement_directory.make_dir(lesson_dir_str)
		
		var drawing_file = File.new()
		var i =0;
		var dfn = lesson_dir_str + '/d'+ str(i) +'.svg'
		while drawing_file.file_exists(dfn):
			i += 1
			dfn = lesson_dir_str + '/d'+ str(i) +'.svg'
		
		
		$"/root/GlobalVars".save_svg_path(dfn,drawing_to_svg_path(lines))
		return dfn.substr(dfn.find_last('/')+1,dfn.length())
	else:
		return null

func remove_last_line():
	current_line = []
	lines.remove(lines.size()-1)

func _draw():
	var color_index = 0;
	for line in lines + [current_line]:
		for i in range(1,line.size()):
			var caw = get_line_color_and_with(color_index)
			draw_line(line[i-1],line[i],caw[0],caw[1])
		color_index +=1 
	#for path in svg_paths:
	#	draw_svg_path(path)
			
			
#Event handling
var button_down = false
func _on_AnswerDraw_gui_input(event):
	#print(event is InputEventMouseMotion)
	if event is InputEventMouseButton:
		if button_down:
			include_line()
		button_down = !button_down
	if button_down and event is InputEventMouseMotion:
		update_mouse(event.position)
