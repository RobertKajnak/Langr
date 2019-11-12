extends OptionButton

func _ready():
	pass

func adapt(font_size = 'medium'):
	""" can also be 'small' or 'large' """
	var global = $"/root/GlobalVars"
	match font_size.to_upper():
		'SMALL':font_size = global.FONT_SIZE_SMALL
		'MEDIUM':font_size = global.FONT_SIZE_MEDIUM
		'TITLE': font_size = global.FONT_SIZE_LARGE
		
	var option_text = ''
	for i in range(self.get_child_count()):
		option_text+=tr(self.get_item_text(i))
	
	global.adapt_font(self,font_size,option_text,true)