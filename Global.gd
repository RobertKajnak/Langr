extends Node

var config;

var currentLang = 0; #currently used languge index from langs
var langs = ['en','hu']

#Question list editing
var current_lesson = ''
var current_question = ''
var all_questions = []

#Quiz
#Answer dictionary -- continuing the LSD joke from ?2nd? year
var adict = {'TextEditQuestion':'question',
			'AnswerTextEdit':'answer_free',
			'AnswerDraw':'answer_draw',
			'TextEditCheckBoxMulti0':'answer_multi'} #TODO: Ez még mindig elég hándi
var active_lessons = []
var active_quesiton = ''

func _ready():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		currentLang = config.get_value("general", "lang", 0)
		langs = config.get_value("general","allLangs",langs)#Allows external modification of available languages
		
		active_lessons = config.get_value("quiz", "active_lessons", [''])
	TranslationServer.set_locale(langs[currentLang])


func retranslate(node,to_translate_list):
	if node.name in to_translate_list:
		node.text = tr(to_translate_list[node.name])
	for child in node.get_children():
		retranslate(child,to_translate_list)


func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files

func save_settings():
	# Save the changes by overwriting the previous file
	config.set_value("general", "lang", currentLang)
	config.set_value("general","allLangs",langs)
	config.set_value("quiz","active_lessons",active_lessons)
	config.save("user://settings.cfg")
	
	
func read_svg(file_name):
	var xml = XMLParser.new()
	xml.open(file_name)
	while xml.read() == OK:
		if xml.get_node_name() == 'path':
			var path = xml.get_named_attribute_value('d')
			var conv = _path_string_to_path(path)
			print(conv)
		
	var components = []
	return components
	
func _path_string_to_path(string):
	var all_segments = []
	var buff = []
	var val = 0
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
				val = 0
				coeff = 1
				sgn = 1
				all_segments.append(buff)
				buff = []
			buff.append(c)
		elif c in ['0','1','2','3','4','5','6','7','8','9']:
			val = val*(10 if coeff==1 else 1) + int(c)*coeff
			if coeff != 1:
				coeff /= 10
		elif c == '-' or c==',':
			buff.append(val*sgn) 
			val = 0
			coeff = 1
			sgn = 1
			if c== '-':
				sgn = -1
		elif c == '.':
			coeff = 0.1
		else:
			print('Unidentified character detected: ' + c)
	buff.append(val*sgn) 
	all_segments.append(buff)
	return all_segments
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
