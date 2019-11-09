extends HBoxContainer

signal filter_changed(new_text)
signal order_changed(ID)

func _ready():
	$LabelSort.set_width_auto()

	var _err = $TextEditSearch.connect("focus_entered",self,"_tapped_to_edit")
	_err = $TextEditSearch.connect("focus_exited",self,"_tapped_away")

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

func select(idx:int):
	$OptionButtonSort.select(idx)

func _on_TextEditSearch_text_changed():
	emit_signal("filter_changed",$TextEditSearch.text)

func _on_OptionButtonSort_item_selected(ID):
	emit_signal("order_changed",ID)


func _tapped_to_edit():
	if $TextEditSearch.text == tr('search'):
		$TextEditSearch.text = ''
		
func _tapped_away(control):
	if $TextEditSearch.text == '':
		$TextEditSearch.text = tr('search')
