extends OptionButton

func _ready():
	pass

func adapt():
	var global = $"/root/GlobalVars"
	var option_text = ''
	for i in self.get_child_count():
		option_text+=tr(self.get_item_text(i))
	
	global.adapt_font(self,global.FONT_SIZE_MEDIUM,option_text,true)