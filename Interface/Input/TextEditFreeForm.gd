extends TextEdit

var text_size

const BB_text = preload("res://res/chalkboard.jpg")	

signal long_press

func _ready():
	#Set random offset for the blackboard material
	set("custom_styles/normal",create_blackboard_style())
	
	text_size = $"/root/GlobalVars".FONT_SIZE_SMALL
	adapt()
	
	
func set_text_size(size):
	self.text_size = size
	
func _on_TextEditQuestion_text_changed():
	adapt()
	
func adapt():
	$"/root/GlobalVars".adapt_font(self,text_size)
	
	
func set_blackboard_style():
	#Couldn't get the scaling to work. Left it here for future reference
	var tex_subregion = AtlasTexture.new()
	tex_subregion.set_atlas(BB_text)
	tex_subregion.set_region(Rect2(Vector2(0,0),self.rect_size))
	tex_subregion.margin = Rect2(2000,2000,2000,1000)
	set("custom_styles/normal",tex_subregion)
	
func create_blackboard_style():
	var T = StyleBoxTexture.new()
	T.draw_center = true
	T.texture = preload("res://res/chalkboard.jpg")	
	var vrand = randi()%420 - 195
	var hrand = randi()%180 - 95
	T.expand_margin_left = 200 + vrand
	T.expand_margin_right = 275 - vrand
	T.expand_margin_top = 125 - hrand
	T.expand_margin_bottom = 100 + hrand

	#print(T.expand_margin_left,',',T.expand_margin_right,',',T.expand_margin_top,',',T.expand_margin_bottom)
	return T


var long_press_timer
func _on_TextEditFreeform_gui_input(event):
		if event is InputEventMouseButton:
			if event.pressed:
				long_press_timer = OS.get_ticks_msec()
			elif Rect2(Vector2(0,0),self.rect_size).has_point(event.position):
				if (OS.get_ticks_msec() - long_press_timer > 800):
					emit_signal('long_press')

