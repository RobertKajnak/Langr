extends Control

var valign setget set_valign,get_valign

const LABEL_MODE_SMALL = 0
const LABEL_MODE_NORMAL = 1
const LABEL_MODE_TITLE = 2

var _mode
export var mode = ''
export var text = '' setget set_text,get_text


func get_text():
	return $Label.text
func set_text(new_text):
	$Label.text = new_text
	adapt()

func get_valign():
	return $Label.valign
func set_valign(val):
	$Label.valign = val

func set_width(w):
	$Label.rect_size.x = w
	self.rect_size.x = w

func _ready():
	if mode == '':
		set_mode(LABEL_MODE_NORMAL)
	else:
		set_mode(mode)
	if text != '':
		self.set_text(text)
	
	
	var _valign = valign #The only purpose of this line is to silence the warning
	
func set_mode(new_mode=LABEL_MODE_NORMAL):
	if new_mode is String:
		new_mode = {'SMALL':LABEL_MODE_SMALL,
				'NORMAL':LABEL_MODE_NORMAL,
				'MEDIUM':LABEL_MODE_NORMAL,
				'TITLE':LABEL_MODE_TITLE
				}[new_mode.to_upper()]
	self._mode = new_mode
	adapt()

func adapt():
	if self.is_inside_tree():
		var global = $"/root/GlobalVars"
		match self._mode:
			LABEL_MODE_SMALL:
				global.adapt_font($Label,global.FONT_SIZE_SMALL)
				$Label.align = Label.ALIGN_LEFT
			LABEL_MODE_NORMAL:
				global.adapt_font($Label,global.FONT_SIZE_MEDIUM)
				$Label.align = Label.ALIGN_LEFT
			LABEL_MODE_TITLE:
				global.adapt_font($Label,global.FONT_SIZE_LARGE)
				$Label.align = Label.ALIGN_CENTER
	
func set_width_auto(extra_spacing=0):
	var auto_original = $Label.autowrap
	$Label.autowrap = false
	$Label.set_size(Vector2(8, 8))
	$Label.rect_size.x+=1+extra_spacing
	self.rect_size.x = $Label.rect_size.x
	$Label.autowrap = auto_original
	
	
func _process(_delta):
	self.rect_min_size = $Label.rect_size
	
	set_process(false)
