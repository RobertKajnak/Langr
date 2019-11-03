extends LinkButton


func _ready():
	pass
	
func set_label(label):
	 self.text = label
	 $"/root/GlobalVars".adapt_font(self,$"/root/GlobalVars".FONT_SIZE_SMALL)


func auto_ellipse(max_width):
	$"/root/GlobalVars".auto_ellipse(max_width,self)

		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
