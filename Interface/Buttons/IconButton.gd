extends TextureButton

const LEFT_CARET = preload('res://res/CaretLeft.png')
const LEFT_CARET_DISABLED = preload('res://res/CaretLeft_disabled.png')
const RIGHT_CARET = preload('res://res/CaretRight.png')
const MENU_ICON = preload('res://res/MenuNavigation.png')
const PLUS_SIGN = preload('res://res/Plus.png')

const FILE = preload("res://res/FileIcon.png")
const FOLDER = preload("res://res/FolderIcon.png")


func _ready():
	pass

#Can be plus, right, left, menu
func set_icon(icon='plus'):
	var ic 
	var icd = null
	if icon is String:
		match icon.to_upper():
			'LEFT': 
				ic = LEFT_CARET
				icd = LEFT_CARET_DISABLED
			'RIGHT': ic = RIGHT_CARET
			'MENU': ic = MENU_ICON
			'PLUS': ic = PLUS_SIGN
			'FILE': ic = FILE
			'FOLDER': ic = FOLDER
			'EMPTY': ic = null
	else:
		ic = icon
		
	if self.texture_normal != ic:
		self.texture_normal = ic
	if self.texture_disabled != icd:
		self.texture_disabled = icd