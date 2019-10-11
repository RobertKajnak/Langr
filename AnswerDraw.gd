extends Control



var lines = []
var current_line = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func clip(v):
	return Vector2(max(min(v.x,self.rect_size.x),0), max(min(v.y,self.rect_size.y),0))

func normalize(v):
	return Vector2(100 * v.x/self.rect_size.x, 100* v.y/self.rect_size.y)
	
func dist(v1,v2):
	return floor(sqrt(pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2)))
	

func update_mouse(vec):
	vec = clip(vec) #Make sure no points are outside bounds
	
	if len(current_line)==0:#If array empty, append it regarless
		current_line.append(vec)
	elif (dist(vec,current_line[-1])) > 2: #Ignore points that are too close together
		current_line.append(vec)
		#print('x = ' + str(X) + ';  y = ' + str(Y))

func save_line():
	if current_line.size()>0:
		lines.append(current_line)
		current_line = []

func clear_drawing():
	current_line = []
	lines = []
	var segments = $"/root/GlobalVars".read_svg('user://lessons/lesson0/06f5c.svg')
	print(segments)
	$"/root/GlobalVars".save_svg_path('user://lessons/lesson0/06f5c_re.svg',segments)

func _draw():
	for line in lines + [current_line]:
		for i in range(1,line.size()):
			draw_line(line[i-1],line[i],Color(0,255,0,255),5)
			
			