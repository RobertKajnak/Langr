extends TextEdit

var text_size

func _ready():
	text_size = $"/root/GlobalVars".FONT_SIZE_SMALL
	$"/root/GlobalVars".adapt_font(self,text_size)

func set_text_size(size):
	self.text_size = size
	
func _on_TextEditQuestion_text_changed():
	$"/root/GlobalVars".adapt_font(self,text_size)
