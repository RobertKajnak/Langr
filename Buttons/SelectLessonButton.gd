extends LinkButton


func _ready():
	pass
	
func set_label(label):
	 self.text = label
	 $"/root/GlobalVars".adapt_font(self,$"/root/GlobalVars".FONT_SIZE_SMALL)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
