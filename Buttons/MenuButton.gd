extends Button

export(String) var scene_to_load
export(String) var text_loc

func _ready():
	$Label.text = tr(text_loc)