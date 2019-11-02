extends Button

export(String) var scene_to_load
export(String) var text_loc

func _ready():
	$Label.text = tr(text_loc)
	$"/root/GlobalVars".adapt_font($Label,$"/root/GlobalVars".FONT_SIZE_LARGE)
	
	
func _process(delta):
	rect_min_size = Vector2($Label.rect_size.x*1.1,$Label.rect_size.y)
	rect_size = Vector2($Label.rect_size.x*1.1,$Label.rect_size.y)
	set_process(false)
