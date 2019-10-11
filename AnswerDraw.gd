extends Control

var color_default = Color(0,0.1,0.6,255)
var width_default = 5

var lines = []
var current_line = []
var svg_paths = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
		return Vector2(100 * v.x/w, 100* v.y/h)
	
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
		return Vector2(w * v.x/100, h* v.y/100)

func dist(v1,v2):
	return floor(sqrt(pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2)))
	

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
				'm':
					pen.x += element[1]
					pen.y += element[2]
				'l':
					var pen_new = Vector2(element[1],element[2])
					lines.append([pen,pen_new])
					pen = pen_new
				'L':
					var pen_new = Vector2(element[1]+pen.x,element[2]+pen.y)
					lines.append([pen,pen_new])
					pen = pen_new
				'c':
					var curve = Curve2D.new()#c 7.7 -0.57, 22.91 -1.86, 32.51 -2.35
					curve.add_point(pen,Vector2(0,0),Vector2(element[1],element[2]))
					curve.add_point(Vector2(pen.x+element[5],pen.y+element[6]),Vector2(0,0),Vector2(element[3],element[4]))
					pen = Vector2(pen.x+element[5],pen.y+element[6])
					#print(curve.tessellate())
					lines.append(denormalize(curve.tessellate(3)))
				'C':
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
		var point = denormalize(normalize(line[0]),109,109)
		segment.append(['M',point.x,point.y])
		for i in range(1,line.size()):
			point = denormalize(normalize(line[i]),109,109)
			segment.append(['L',point.x,point.y])
		segments.append(segment)
	return segments

					
func clear_drawing():
	$"/root/GlobalVars".save_svg_path('user://lessons/lesson0/temp_drawing.svg',drawing_to_svg_path(lines))
	current_line = []
	lines = []
	var segments = $"/root/GlobalVars".read_svg('user://lessons/lesson0/06f5c.svg')
	include_svg_path(segments)
	$"/root/GlobalVars".save_svg_path('user://lessons/lesson0/06f5c_re.svg',segments)


func _draw():
	for line in lines + [current_line]:
		for i in range(1,line.size()):
			draw_line(line[i-1],line[i],color_default,width_default)
	#for path in svg_paths:
	#	draw_svg_path(path)
			