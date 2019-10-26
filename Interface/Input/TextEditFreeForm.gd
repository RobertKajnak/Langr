extends TextEdit

func _ready():
	$"/root/GlobalVars".adapt_font(self,$"/root/GlobalVars".FONT_SIZE_SMALL)


func _on_TextEditQuestion_text_changed():
	$"/root/GlobalVars".adapt_font(self,$"/root/GlobalVars".FONT_SIZE_SMALL)
