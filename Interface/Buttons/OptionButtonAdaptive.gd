extends OptionButton

func _ready():
	add_color_override("font_color",Color(29.0/255,0,109.0/255))
	add_color_override("font_color_hover",Color(60.0/255,0,150.0/255))
	add_color_override("font_color_pressed",Color(60.0/255,0,150.0/255))
	margin_left = 10

func adapt(font_size = 'medium'):
	""" can also be 'small' or 'large' """
	var global = $"/root/GlobalVars"
	match font_size.to_upper():
		'SMALL':font_size = global.FONT_SIZE_SMALL
		'NORMAL':continue
		'MEDIUM':font_size = global.FONT_SIZE_MEDIUM
		'TITLE': font_size = global.FONT_SIZE_LARGE
		
	var option_text = ''
	for i in range(self.get_item_count()):
		option_text+=tr(self.get_item_text(i))
	
	global.adapt_font(self,font_size,option_text,preload("res://res/DefaultTheme.tres"))
	
	text = ' ' + text
	
	self.theme = self.theme.duplicate()
	var adjusted_style :StyleBoxTexture = self.theme.get("PopupMenu/styles/panel").duplicate()
	#var nr_tiles = 11
	var nr_options = self.get_item_count()
	var option_height = 112#Comes from the image
	adjusted_style.region_rect = Rect2(0,0,592,nr_options*option_height)
	
	self.theme.set_color("font_color", "PopupMenu", Color(29.0/255,0,109.0/255))
	self.theme.set_color("font_color_hover", "PopupMenu",Color(60.0/255,0,150.0/255))
	self.theme.set_color("font_color_pressed", "PopupMenu",Color(60.0/255,0,150.0/255))
	
	self.theme.set("PopupMenu/styles/panel",adjusted_style)
	
