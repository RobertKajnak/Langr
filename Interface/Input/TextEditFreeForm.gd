extends TextEdit

var text_size

func _ready():
	text_size = $"/root/GlobalVars".FONT_SIZE_SMALL
	adapt()

func set_text_size(size):
	self.text_size = size
	
func _on_TextEditQuestion_text_changed():
	adapt()
	
func adapt():
	$"/root/GlobalVars".adapt_font(self,text_size)
	