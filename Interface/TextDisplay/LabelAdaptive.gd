extends Control

var text setget set_text,get_text
var valign setget set_valign,get_valign

const LABEL_MODE_SMALL = 0
const LABEL_MODE_NORMAL = 1
const LABEL_MODE_TITLE = 2

var mode

func get_text():
	return $Label.text
func set_text(text):
	$Label.text = text
	adapt()

func get_valign():
	return $Label.valign
func set_valign(val):
	$label.valign = val

func set_width(w):
	$Label.rect_size = Vector2(w,$Label.rect_size.y)
	self.rect_size = Vector2(w,self.rect_size.y)

func _ready():
	set_mode(LABEL_MODE_NORMAL)
	
func set_mode(mode=LABEL_MODE_NORMAL):
	if mode is String:
		mode = {'SMALL':LABEL_MODE_SMALL,
				'NORMAL':LABEL_MODE_NORMAL,
				'MEDIUM':LABEL_MODE_NORMAL,
				'TITLE':LABEL_MODE_TITLE
				}[mode.to_upper()]
	self.mode = mode
	adapt()

func adapt():
	var global = $"/root/GlobalVars"
	match self.mode:
		LABEL_MODE_SMALL:
			global.adapt_font($Label,global.FONT_SIZE_SMALL)
			$Label.align = Label.ALIGN_LEFT
		LABEL_MODE_NORMAL:
			global.adapt_font($Label,global.FONT_SIZE_MEDIUM)
			$Label.align = Label.ALIGN_LEFT
		LABEL_MODE_TITLE:
			global.adapt_font($Label,global.FONT_SIZE_LARGE)
			$Label.align = Label.ALIGN_CENTER
	
func _process(delta):
	self.rect_min_size = $Label.rect_size
	
	set_process(false)
