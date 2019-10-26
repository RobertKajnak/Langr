extends TextureButton

const LEFT_CARET = preload('res://res/CaretLeft.png')
const RIGHT_CARET = preload('res://res/CaretRight.png')
const MENU_ICON = preload('res://res/MenuNavigation.png')
const PLUS_SIGN = preload('res://res/Plus.png')

func _ready():
	pass

#Can be plus, right, left, menu
func set_icon(icon='plus'):
	var ic 
	if icon is String:
		match icon.to_upper():
			'LEFT': ic = LEFT_CARET
			'RIGHT': ic = RIGHT_CARET
			'MENU': ic = MENU_ICON
			'PLUS': ic = PLUS_SIGN
			'EMPTY': ic = null
	else:
		ic = icon
		
	if self.texture_normal != ic:
		self.texture_normal = ic