extends Control

func _ready():
	adapt()

var text setget set_text,get_text
var align setget set_align,get_align

func get_text():
	return $LabelTitle.text
func set_text(text):
	$LabelTitle.text = text
	adapt()

func get_align():
	return $LabelTitle.valign
func set_align(val):
	$LabelTitle.valign = val

func adapt():
	var global = $"/root/GlobalVars"
	global.adapt_font($LabelTitle,global.FONT_SIZE_LARGE)
	self.rect_size = $LabelTitle.rect_size

func _process(delta):
	self.rect_min_size = $LabelTitle.rect_size
	
	set_process(false)