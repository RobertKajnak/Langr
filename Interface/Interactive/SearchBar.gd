extends HBoxContainer

const LABEL_MODE_SMALL = 0
const LABEL_MODE_NORMAL = 1
const LABEL_MODE_TITLE = 2

signal filter_changed(new_text)
signal order_changed(ID)

var global 

func _ready():
	global = $"/root/GlobalVars"
	$LabelSort.set_width_auto()

	var _err = $TextEditSearch.connect("focus_entered",self,"_tapped_to_edit")
	_err = $TextEditSearch.connect("focus_exited",self,"_tapped_away")
	
	$OptionButtonSort.grab_focus()

func add_options(options,auto_translate=true,directional_arrows=['↓','↑']):
	""" Specify null or empty list to skip arrows. They will be appended in front of the options list's elements
	If auto_translate is specified, the translation funcion is applied to the options list provided
	"""
	for crit in options:
		if directional_arrows:
			for dir in directional_arrows:
				$OptionButtonSort.add_item(dir+tr(crit) if auto_translate else crit)
		else:
			$OptionButtonSort.add_item(tr(crit) if auto_translate else crit)
	
	$OptionButtonSort.adapt()
	
	$OptionButtonSort.grab_focus()
func select(idx:int):
	$OptionButtonSort.select(idx)


func set_mode(mode=LABEL_MODE_NORMAL):
	if mode is String:
		mode = {'SMALL':LABEL_MODE_SMALL,
				'NORMAL':LABEL_MODE_NORMAL,
				'MEDIUM':LABEL_MODE_NORMAL,
				'TITLE':LABEL_MODE_TITLE
				}[mode.to_upper()]
	$LabelSort.set_mode(mode)
	
	match mode:
		LABEL_MODE_SMALL:mode= global.FONT_SIZE_SMALL
		LABEL_MODE_NORMAL:mode=global.FONT_SIZE_MEDIUM
		LABEL_MODE_TITLE:mode=global.FONT_SIZE_LARGE
	$OptionButtonSort.adapt(mode)
	if mode ==global.FONT_SIZE_MEDIUM:
		mode = global.FONT_SIZE_SMALL
	elif mode==global.FONT_SIZE_LARGE:
		mode = global.FONT_SIZE_MEDIUM
	$TextEditSearch.set_text_size(mode)

	$OptionButtonSort.grab_focus()
	
	$LabelSort.set_width_auto()

func disable_label():
	$LabelSort.visible = false
	
#EVENTS
func _on_TextEditSearch_text_changed():
	emit_signal("filter_changed",$TextEditSearch.text)

func _on_OptionButtonSort_item_selected(ID):
	emit_signal("order_changed",ID)


func _tapped_to_edit():
	if $TextEditSearch.text == tr('search'):
		$TextEditSearch.text = ''
		
func _tapped_away():
	if $TextEditSearch.text == '':
		$TextEditSearch.text = tr('search')
