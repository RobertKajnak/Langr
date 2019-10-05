extends LinkButton

export(String) var label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_label():
	$Label.text = label

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
