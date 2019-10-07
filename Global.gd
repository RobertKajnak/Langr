extends Node

var config;

var currentLang = 0;
var langs = ['en','hu']

var currentLesson = 'default'
var currentQuestion = '0'

var current_lesson
# Called when the node enters the scene tree for the first time.
func _ready():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # if not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		currentLang = config.get_value("general", "lang", 0)
		langs = config.get_value("general","allLangs",langs)#Allows external modification of available languages
	TranslationServer.set_locale(langs[currentLang])


func retranslate(node,to_translate_list):
	if node.name in to_translate_list:
		node.text = tr(to_translate_list[node.name])
	for child in node.get_children():
		retranslate(child,to_translate_list)
		
func save_settings():
	# Save the changes by overwriting the previous file
	config.set_value("general", "lang", currentLang)
	config.set_value("general","allLangs",langs)
	config.save("user://settings.cfg")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
