#warning-ignore-all:unused_variable
extends Node

var config;

#CONSTANTS
var currentLang = 0; #currently used languge index from langs
var langs = ['en','hu']

#Render Constants
var POSSIBLE_SCALES = [8,12,14,16,24,32,48,56,64,72] setget ,get_possible_scales
func get_possible_scales():
	return POSSIBLE_SCALES
var UI_SCALE = 32 setget set_ui_scale
const LARGE_FACTOR = 1.5
const MEDIUM_FACTOR = 1.15
const FONT_SIZE_SMALL = 'SMALL'
const FONT_SIZE_MEDIUM = 'MEDIUM'
const FONT_SIZE_LARGE = 'LARGE'
var FONTS = {}
var DEBUG = false

var skill_color_dict = {0:Color(1,0,0),
						1:Color(1,0.3,0.35),
						2:Color(1,0.3,0.35),
						3:Color(0.8,0.5,0.5),
						4:Color(0.6,0.8,0.6),
						5:Color(0.35,0.8,0.35),
						6:Color(0,1,0),
						null:Color(0.7,0.7,0.7)} setget ,get_skill_color_dict
func get_skill_color_dict():
	return skill_color_dict

func set_ui_scale(val):
	UI_SCALE = val
	
	for font in ['FONT_SMALL_JP', 'FONT_SMALL_LAT', 
				'FONT_MEDIUM_JP', 'FONT_MEDIUM_LAT',
				'FONT_LARGE_JP', 'FONT_LARGE_LAT']:
		FONTS[font] = DynamicFont.new()
		var font_data = DynamicFontData.new()
		if 'JP' in font:
			font_data.font_path = 'res://fonts/851H-kktt.ttf'
		else:
			if 'SMALL' in font:
				font_data.font_path = 'res://fonts/AA_Brush Stroke_Hun.ttf'
			elif 'LARGE' in font:
				font_data.font_path = 'res://fonts/AA_Antique Type_Hun.ttf'
			else: #elif 'MEDIUM' in font
				font_data.font_path = 'res://fonts/AA_Antique Type_Hun.ttf'
		
		if 'SMALL' in font:
			FONTS[font] .size = UI_SCALE
		elif 'LARGE' in font:
			FONTS[font] .size = UI_SCALE*LARGE_FACTOR
		else: #elif 'MEDIUM' in font
			FONTS[font] .size = UI_SCALE*MEDIUM_FACTOR

		FONTS[font].font_data = font_data


#Question list editing
var current_lesson = ''
var current_question = '' setget set_current_question,get_current_question
func set_current_question(val):
	current_question = val
func get_current_question():
	return current_question

#Transition scenes. E.g. when not enough words are present and the user is redirected
var _transition_title = ''
var _transition_message = ''
var _transition_goal = ''

#Quiz
var rotation_size = 9

#Answer dictionary -- continuing the LSD joke from ?2nd? year
var adict = {'TextEditQuestion':'question',
			'AnswerTextEdit':'answer_free',
			'VBoxContainerDraw':'answer_draw',
			'TextEditCheckBoxMulti0':'answer_multi',
			'OptionButtonSkill':'skill',
			'LabelID':'id',
			'LabelGoodDate':'good_answer_date',
			'LabelBadDate':'bad_answer_date',
			'LabelSkipDays':'skip_days'} setget ,get_adict#TODO: Ez még mindig elég hándi
func get_adict():
	return adict
func adict_inv():
	return reverse_dict(adict)
var active_lessons = []

func _ready():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		currentLang = config.get_value("general", "lang", 0)
		langs = config.get_value("general","allLangs",langs)#Allows external modification of available languages
		
		#Render options, such as font size
		var ui_scale_default = 32 if OS.get_name() in ["iOS", "HTML5", "Server", "Windows","UWP", "X11"] else 48
		var ui_scale_temp = config.get_value("render", "ui_scale", ui_scale_default)
		set_ui_scale(ui_scale_temp)
		
		active_lessons = config.get_value("quiz", "active_lessons", [''])
		rotation_size = config.get_value("quiz","rotation_size",7)
		
		DEBUG = config.get_value("debug","debug_enabled",false)
	TranslationServer.set_locale(langs[currentLang])

func get_date_compact():
	var dd = OS.get_date()
	return dd['year']*10000+dd['month']*100+dd['day']
	
func get_date_from_date_compact(date_compact):
	var date := int(date_compact)
	return {'year':date/10000,
			'month':date/100%100,
			'day':date%100,
			'hour':0,
			'minute':0,
			'second':0}
	
func get_date_difference(date_later,date_earlier):
	var date1 = date_earlier
	var date2 = date_later
	if not date1 is Dictionary:
		date1 = get_date_from_date_compact(date1)
	if not date2 is Dictionary:
		date2 = get_date_from_date_compact(date2)
	date1 = OS.get_unix_time_from_datetime(date1)
	date2 = OS.get_unix_time_from_datetime(date2)
	return int((date2-date1)/86400)
	
func retranslate(node,to_translate_list):
	if node.name in to_translate_list:
		node.text = tr(to_translate_list[node.name])
		if TranslationServer.get_locale() == 'jp':
			node.set('custom_fonts/font',load('res://fonts/jp2.tres'))
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
	for _i in range(size):
		a.append(value)
	return a

func random_string(length):
	var a = ''
	var v
	for _i in range(length):
		v = randi()%(122-48) + 48
		if v ==92 or v == 96:
			v+=1
		a += char(v)
	return a
	
func set_active_lessons(active_lessons):
	self.active_lessons = active_lessons
	save_settings()

#Auto_ellipse<=0 =>no ellipse
func get_active_lessons_string(auto_ellipse=-1):
	var s = ''
	for lesson in active_lessons:
		s += lesson.substr(0,lesson.find('.les')) + ', '
	s = s.substr(0,s.length()-2)
	if auto_ellipse>0 and s.length()>auto_ellipse:
		s = s.substr(0,auto_ellipse-3) + '...'
	return s

func save_settings():
	# Save the changes by overwriting the previous file
	config.set_value("general", "lang", currentLang)
	config.set_value("general","allLangs",langs)
	config.set_value("render","ui_scale",UI_SCALE)
	config.set_value("quiz","active_lessons",active_lessons)
	config.set_value("quiz","rotation_size",rotation_size)
	config.set_value("debug","debug_enabled",DEBUG)
	config.save("user://settings.cfg")
	
#If text is left as null, node.text is used.
#Size should be one of the FONT_SIZE constants
func adapt_font(node,size=FONT_SIZE_SMALL,text = null):
	var latin_only = true
	if not text:
		text = node.text
	for i in text.length():
		if text.ord_at(i)>500:
			latin_only = false
	var font 
	if latin_only:
		if size==FONT_SIZE_LARGE:
			font = FONTS['FONT_LARGE_LAT']
		elif size==FONT_SIZE_MEDIUM:
			font = FONTS['FONT_MEDIUM_LAT']
		else:
			font = FONTS['FONT_SMALL_LAT']
	else:
		if size==FONT_SIZE_SMALL:
			font = FONTS['FONT_SMALL_JP']
		elif size==FONT_SIZE_MEDIUM:
			font = FONTS['FONT_MEDIUM_JP']
		else:
			font = FONTS['FONT_LARGE_JP']
		
	node.set('custom_fonts/font',font)

func get_actual_width(text_node):
	text_node.set_size(Vector2(8, 8))
	return text_node.rect_size.x

func auto_ellipse(max_width:int,node:Node,ellipse_replacement : String = '[...]'):
	""" The node should contain both the .text and .rect_size elements.
	based on these the node is automatically resized to the requested size
	"""
	
	var gen_w = get_actual_width(node)
	if max_width<gen_w:
		node.text = node.text.substr(0,int(node.text.length()*(max_width*1.3/gen_w))) #not all characters are equally large
		while get_actual_width(node)>max_width:
			node.text = node.text.substr(0,node.text.length()-ellipse_replacement.length()-1) + ellipse_replacement

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

func strip_les_ending(string):
	if string.substr(string.length()-4,string.length()) == '.les':
		string = string.substr(0,string.length()-4)
	return string

func to_transition_scene(current_tree,next_scene_name,title,message):
	_transition_goal = next_scene_name
	_transition_title = title
	_transition_message = message
	var _err = current_tree.change_scene("res://Screens/TransitionScene.tscn")
	
func create_file_dialog(viewport_rect : Rect2, parent: Node, access_mode):
	var fd = FileDialog.new()
	fd.set_theme( preload('res://res/DefaultJPTheme.tres'))
	var vps = viewport_rect.size 
	fd.rect_size = vps * 0.8
	fd.rect_position = vps *0.1
	fd.set_mode_overrides_title(true)
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.mode = access_mode
	fd.set_filters(PoolStringArray(["*.les ; Lesson File"]))
	var _err = fd.set_current_dir(OS.get_system_dir(2))
	parent.add_child(fd)
	fd.show()
	fd.invalidate()#AKA Refresh
	return fd
	
#Returns -1 if the lesson could not be changed. If there is no '.les' ending, it will be implied
func change_lesson_name(old_name,new_name):
	old_name = strip_les_ending(old_name)
	new_name = strip_les_ending(new_name)
		
	var dir = Directory.new()
	var dir_name_old = 'user://lessons/' + old_name
	var dir_name_new = 'user://lessons/' + new_name

	#While the two individual rename functions do return errors themselves, 
	#it would be bad if only one was renamed, while the other failed
	if dir.file_exists(dir_name_new+'.les') or dir.dir_exists(dir_name_new):
		return -1
	else:
		dir.rename(dir_name_old,dir_name_new)
		dir.rename(dir_name_old+'.les',dir_name_new+'.les')
		return 0

func import_lesson(file_name:String):
	file_name = strip_les_ending(file_name)
		
	var dir = Directory.new()
	var dest_dir = 'user://lessons/' + file_name.substr(file_name.rfind("/")+1,file_name.length()-1)

	if dir.file_exists(dest_dir+'.les') or dir.dir_exists(dest_dir):
		return false
	else:
		var success = true
		if dir.file_exists(file_name+'.les'):
			var err = dir.copy(file_name+'.les',dest_dir+'.les')
			success = success and (err == OK)
		if dir.dir_exists(file_name):
			var err = dir.make_dir(dest_dir)
			for f in list_files_in_directory(file_name):
				print(file_name+'/'+f)
				print(dest_dir +'/' + f)
				var err2 = dir.copy(file_name+'/'+f,dest_dir +'/' + f)
				err = err and err2
				print('File copy Error: ',err2)
		return success

func export_lesson(file_name, lesson=null):
	if lesson == null:
		lesson = current_lesson
	
	lesson = strip_les_ending(lesson)
	file_name = strip_les_ending(file_name)
	var dir = Directory.new()
	var dir_name = 'user://lessons/' + lesson
	
	var success = true
	if dir.file_exists(dir_name+'.les'):
		var err = dir.copy(dir_name+'.les',file_name+'.les')
		success = success and (err == OK)
	if dir.dir_exists(dir_name):
		var err = dir.make_dir(file_name)
		for f in list_files_in_directory(dir_name):
			var err2 = dir.copy(dir_name+'/'+f,file_name +'/' + f)
			err = err and err2
			print('File copy Error: ',err2)
		#success = success and (err == OK if err is bool else false)
	return success

func delete_lesson(lesson):
	var dir = Directory.new()
	var dir_name = 'user://lessons/' + lesson
	dir_name = strip_les_ending(dir_name)
	#remove all files from the directory first, otherwise the request will fail
	for f in self.list_files_in_directory(dir_name):
		dir.remove(dir_name + '/' + f)
	dir.remove(dir_name + '.les')
	dir.remove(dir_name)
	
	if lesson == current_lesson:
		current_lesson = ''