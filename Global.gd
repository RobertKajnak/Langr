extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var currentLang = 0;
var langs = ['en','hu']

var currentLesson = 'default'
var currentQuestion = '0'

var current_lesson
# Called when the node enters the scene tree for the first time.
func _ready():
	TranslationServer.set_locale(langs[currentLang])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
