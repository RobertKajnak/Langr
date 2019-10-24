extends Button

export(String) var scene_to_load
export(String) var text_loc

func _ready():
	if (TranslationServer.get_locale()=='jp'):
		set('custom_fonts/font',load('res://fonts/jp2.tres'))
	$Label.text = tr(text_loc)