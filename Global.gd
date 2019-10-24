extends Node

var config;

#CONSTANTS
var currentLang = 0; #currently used languge index from langs
var langs = ['en','hu']

#Question list editing
var current_lesson = ''
var current_question = ''

#Transition scenes. E.g. when not enough words are present and the user is redirected
var _transition_title = ''
var _transition_message = ''
var _transition_goal = ''

#Quiz
#Answer dictionary -- continuing the LSD joke from ?2nd? year
var adict = {'TextEditQuestion':'question',
			'AnswerTextEdit':'answer_free',
			'AnswerDraw':'answer_draw',
			'TextEditCheckBoxMulti0':'answer_multi',
			'OptionButtonSkill':'skill',
			'LabelID':'id',
			'LabelGoodDate':'good_answer_date',
			'LabelBadDate':'bad_answer_date'} #TODO: Ez még mindig elég hándi
var adict_inv = reverse_dict(adict)
var active_lessons = []

func _ready():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		currentLang = config.get_value("general", "lang", 0)
		langs = config.get_value("general","allLangs",langs)#Allows external modification of available languages
		
		active_lessons = config.get_value("quiz", "active_lessons", [''])
	TranslationServer.set_locale(langs[currentLang])

func get_date_compact():
	var dd = OS.get_date()
	return dd['year']*10000+dd['month']*100+dd['day']
	
func retranslate(node,to_translate_list):
	if node.name in to_translate_list:
		node.text = tr(to_translate_list[node.name])
	for child in node.get_children():
		retranslate(child,to_translate_list)

#WARNIGN: only works if the values are unique as well
func reverse_dict(dict):
	var dict_inv = {}
	for key in dict.keys():
		dict_inv[dict[key]] = key
	return dict_inv

func list_files_in_directory(path):
	var file_list = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if not dir.current_is_dir():
				file_list.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return file_list

func fill_array(size,value):
	var a = []
	for i in range(size):
		a.append(value)
	return a

func random_string(length):
	var a = ''
	var v
	for i in range(length):
		v = randi()%(122-48) + 48
		if v ==92 or v == 96:
			v+=1
		a += char(v)
	return a
	
func set_active_lessons(active_lessons):
	self.active_lessons = active_lessons
	save_settings()

func save_settings():
	# Save the changes by overwriting the previous file
	config.set_value("general", "lang", currentLang)
	config.set_value("general","allLangs",langs)
	config.set_value("quiz","active_lessons",active_lessons)
	config.save("user://settings.cfg")
	
	
func read_svg(file_name):
	var components = []
	
	var xml = XMLParser.new()
	xml.open(file_name)
	while xml.read() == OK:
		if xml.get_node_name() == 'path':
			var path = xml.get_named_attribute_value('d')
			var conv = _path_string_to_path(path)
			components.append(conv)
		elif false:#xml.get_node_name() == 'text':
			var coords = xml.get_named_attribute_value('transform')
			if coords == '':
				continue
			coords = coords.split(',')
			print('coords = ',coords[coords.size()-1])
			var textval = xml.get_node_data()
			print('textval = ',textval)
			components.append(['text',coords[coords.size()-2],coords[coords.size()-1],textval])
	return components
	
func _path_string_to_path(string):
	var all_segments = []
	var buff = []
	var val = null
	var coeff = 1
	var sgn = 1;
	for c in string:
		if c in ['M', 'm', # Move to
					'L', 'l', 'H', 'h', 'V', 'v', #straight line segment
					'Z', 'z', #closed path command
					'C', 'c', 'S', 's', # cubic Bézier 
					'Q', 'q', 'T', 't',#quadratic Bézier
					'A', 'a']: #elliptical arc
			if buff != []:
				buff.append(val*sgn) 
				val = null
				coeff = 1
				sgn = 1
				all_segments.append(buff)
				buff = []
			buff.append(c)
		elif c in ['0','1','2','3','4','5','6','7','8','9']:
			if val == null:
				val = 0
			val = val*(10 if coeff==1 else 1) + int(c)*coeff
			if coeff != 1:
				coeff /= 10
		elif c == '-' or c==',':
			if val != null:
				buff.append(val*sgn) 
			val = null
			coeff = 1
			sgn = 1
			if c== '-':
				sgn = -1
		elif c == '.':
			coeff = 0.1
		else:
			print('Unidentified character detected: ' + c)
	if val!=null:
		buff.append(val*sgn) 
	all_segments.append(buff)
	return all_segments
	
func save_svg_path(file_name,svg_path_array):
	var f = File.new()
	f.open(file_name,File.WRITE)
	f.store_line('<svg xmlns="http://www.w3.org/2000/svg" width="109" height="109" viewBox="0 0 109 109">')
	f.store_line('<g id="kvg:StrokePaths_06f5c" style="fill:none;stroke:#000000;stroke-width:3;stroke-linecap:round;stroke-linejoin:round;">')
	for segment in svg_path_array:
		var segment_string = '<path d="'
		var prev_val = ''
		for element in segment:
			for val in element:
				segment_string += str(prev_val)
				if (val is float or val is int) and (prev_val is float or prev_val is int) and (val>=0):
					segment_string += ','
				prev_val = val
		segment_string += str(prev_val)
		f.store_line(segment_string + '"/>')
	f.store_line('</g>')
	f.store_line('</svg>')
	f.close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func to_transition_scene(current_tree,next_scene_name,title,message):
	_transition_goal = next_scene_name
	_transition_title = title
	_transition_message = message
	var _err = current_tree.change_scene("res://TransitionScene.tscn")
	