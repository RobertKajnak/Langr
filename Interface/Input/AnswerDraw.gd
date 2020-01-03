extends Control

var color_default = Color(0,0.1,0.6,255) setget ,get_color_default
var width_default = 5 setget ,get_width_default
func get_color_default():
	return color_default
func get_width_default():
	return width_default

var lines = []
var current_line = []
var colors_and_widths = []

var texts = []

var cache = []
var currently_loaded = 0

var disable_mouse_interaction = false

func _ready():
	self.rect_size.x = 109*4
	self.rect_size.y = 109*4
	self.rect_min_size.x = 109*4
	self.rect_min_size.y = 109*4
	_init_colors_and_widths()

func change_size(new_size:Vector2):
	"""Changing size after lines are already added is not supported"""
	self.rect_min_size = new_size
	self.rect_size = new_size
	_init_colors_and_widths()

func _process(delta):
	var _delta = delta #silences the error
	update()

func _init_colors_and_widths():
	colors_and_widths = [[-1,[color_default,width_default]]]

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
	
func line_dist(v0,v1,vp):
	var divisor = (v1.x-v0.x) if v1.x!=v0.x else 0.01
	var a = (v0.y-v1.y)/divisor
	var c = -a*v1.x-v1.y
	var d = abs(a*vp.x+vp.y+c)/sqrt(a*a+1)
	return d

func simplify_line(line,tolerance=4):
	if line.size()>2:
		var new_line = [line[0],line[1]]
		var p1 = line[0]
		var p2 = line[1]
		var i = 2
		while i<line.size():
			while line_dist(p1,p2,line[i])<tolerance:
				i+=1
				if i==line.size():
					new_line.append(line[i-1])
					return new_line
			new_line.append(line[i])
			p1 = line[i-1]
			p2 = line[i]
			i+=1
			
		return new_line
	else:
		return line
	
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
	elif (dist(vec,current_line[-1])) > 4: #Ignore points that are too close together
		current_line.append(vec)
			
		#print('x = ' + str(X) + ';  y = ' + str(Y))

func include_line():
	current_line = simplify_line(current_line)
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
				'text':#text
					texts.append([element[1],element[2],element[3]])
					
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
	texts = []
	_init_colors_and_widths()
	 

func is_empty():
	var empty =  lines.empty()
	for l in cache:
		empty = empty and l[0].empty()
	return empty
	
#if somethign other then a string is provided, 
#it is assumed that it is an iterable and all its elements are filenames
func load_drawing(file_name_s):
	if file_name_s is String:
		var segments = $"/root/GlobalVars".read_svg(file_name_s)
		include_svg_path(segments)
	else:
		for file_name in file_name_s:
			var segments = $"/root/GlobalVars".read_svg(file_name)
			include_svg_path(segments)
			load_next_cached()
		load_prev_cached()
		cache.pop_back()

func save_dawing():
	if not is_empty():
		
		var supplement_directory = Directory.new()
		var lesson_dir_str = 'user://lessons/'+$"/root/GlobalVars".current_lesson
		if not supplement_directory.dir_exists(lesson_dir_str):
			supplement_directory.make_dir(lesson_dir_str)
		
		var filenames = []

		for lc in get_cache_and_lines():
			var drawing_file = File.new()
			var i =0;
			var dfn = lesson_dir_str + '/d'+ str(i) +'.svg'
			while drawing_file.file_exists(dfn):
				i += 1
				dfn = lesson_dir_str + '/d'+ str(i) +'.svg'
			
			
			$"/root/GlobalVars".save_svg_path(dfn,drawing_to_svg_path(lc[0]))
			filenames.append(dfn.substr(dfn.find_last('/')+1,dfn.length()))
		return filenames
	else:
		return null

func remove_last_line():
	current_line = []
	if lines.size()>0:
		lines.remove(lines.size()-1)
	
func load_prev_cached():
	return load_cached(currently_loaded-1)
	
func load_next_cached():
	return load_cached(currently_loaded+1)
	
#Return values: 
#  0 -- loaded successfully
#  -1 -- cannot load negative index or already loaded
#  1 -- added next index
func load_cached(index):
	if currently_loaded == index || index<0:
		return -1
	
	var retval = 0
	if currently_loaded >= cache.size():
		cache.append([lines,colors_and_widths])
		retval = 1
	else:
		cache[currently_loaded] = [lines,colors_and_widths]
		
	if index<cache.size():
		var cc = cache[index]
		lines = cc[0]
		colors_and_widths = cc[1]
	else:
		if index>cache.size():
			index = cache.size()
		lines = []
		_init_colors_and_widths()
	
	currently_loaded = index
	return retval
	
func remove_empty_cached_from_end():
	for _i in range(cache.size()):
		if cache[-1][0].empty():
			cache.remove(cache.size()-1)
		else:
			return

func get_cache_and_lines(remove_empty_from_end = true):
	if remove_empty_from_end:
		if lines.empty() or cache.size()!=currently_loaded:
			remove_empty_cached_from_end()
	load_cached(cache.size()+1)
	 
	return cache

func get_cache_status():
	return [currently_loaded+1,cache.size()+(1 if currently_loaded==cache.size() else 0)]
	
func cache_status_string():
	var cst = get_cache_status()
	return str(cst[0]) + '/' + str(cst[1])
	
#always runnign
func _draw():
	var color_index = 0;
	for line in lines + [current_line]:
		for i in range(1,line.size()):
			var caw = get_line_color_and_with(color_index)
			draw_line(line[i-1],line[i],caw[0],caw[1])
		color_index +=1 
	for s in texts:	
		draw_string(load('res://fonts/SubMenuFont.tres'),Vector2(s[0],s[1]),s[2],Color(0,0,0))
	
			
			
#Event handling
var button_down = false
func _on_AnswerDraw_gui_input(event):
	#print(event is InputEventMouseMotion)
	if disable_mouse_interaction:
		return
	if event is InputEventMouseButton:
		if button_down:
			include_line()
		button_down = !button_down
	if button_down and event is InputEventMouseMotion:
		update_mouse(event.position)
		
	#get_tree().set_input_as_handled()
