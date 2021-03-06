extends TextureButton

const LEFT_CARET = preload('res://res/CaretLeft.png')
const LEFT_CARET_DISABLED = preload('res://res/CaretLeft_disabled.png')
const RIGHT_CARET = preload('res://res/CaretRight.png')
const RIGHT_CARET_DISABLED = preload('res://res/CaretRight_disabled_brush.png')
const MENU_ICON = preload('res://res/MenuNavigation.png')
const PLUS_SIGN = preload('res://res/Plus.png')
const UNDO_SIGN = preload('res://res/Undo_brush.png')
const X_SIGN = preload('res://res/X_brush.png')
const XX_SIGN = preload('res://res/XX_brush.png')

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
			'RIGHT': 
				ic = RIGHT_CARET
				icd = RIGHT_CARET_DISABLED
			'MENU': ic = MENU_ICON
			'PLUS': ic = PLUS_SIGN
			'FILE': ic = FILE
			'FOLDER': ic = FOLDER
			'UNDO': ic = UNDO_SIGN
			'X': ic = X_SIGN
			'XX': ic = XX_SIGN
			'EMPTY': ic = null
	else:
		ic = icon
		
	if self.texture_normal != ic:
		self.texture_normal = ic
	if self.texture_disabled != icd:
		self.texture_disabled = icd
