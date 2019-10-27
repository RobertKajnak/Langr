extends VBoxContainer

var to_translate = {'ButtonClearDrawing':'drawClear',
					'ButtonUndoDrawing':'drawUndo',
					'LabelDraw':'drawLabel'}

var can_add_drawing = true

func _ready():
	var global = $"/root/GlobalVars"
	global.retranslate(get_node('/root'),to_translate)
	global.adapt_font($HBoxContainer/ButtonClearDrawing,global.FONT_SIZE_SMALL)
	global.adapt_font($HBoxContainer/ButtonUndoDrawing,global.FONT_SIZE_SMALL)

	set_cache_status_label()
	$HBoxContainer/LabelProgress/Label.rect_size = Vector2(70,40)
	
	$LabelDraw.set_mode($LabelDraw.LABEL_MODE_SMALL)
	$LabelDraw/Label.rect_size = Vector2(450,0)
	#no effect...
	#$HBoxContainer/ButtonClearDrawing.rect_min_size = Vector2($HBoxContainer/ButtonClearDrawing.rect_size.x+5,
#															$HBoxContainer/ButtonClearDrawing.rect_size.y-20)
#	$HBoxContainer/ButtonClearDrawing.rect_size = Vector2($HBoxContainer/ButtonClearDrawing.rect_size.x+5,
#															$HBoxContainer/ButtonClearDrawing.rect_size.y-20)
	
func _on_ButtonClearDrawing_pressed():
	$AnswerDraw.clear_drawing()

func _on_ButtonUndoDrawing_pressed():
	$AnswerDraw.remove_last_line()

func clear_drawing():
	$AnswerDraw.clear_drawing()

func get_lines(include_cache=true):
	if include_cache:
		return $AnswerDraw.get_cache_and_lines()
	else:
		return $AnswerDraw.lines
	
func add_lines(lines):
	$AnswerDraw.lines += lines

func load_drawing(filename):
	$AnswerDraw.load_drawing(filename)
	set_cache_status_label()
	
func set_cache_status_label():
	$HBoxContainer/LabelProgress.text = $AnswerDraw.cache_status_string()
	$HBoxContainer/PreviousButton.set_icon("left")
	
	var cst = $AnswerDraw.get_cache_status()
	if cst[0] == cst[1] and can_add_drawing:
		if can_add_drawing:
			$HBoxContainer/NextButton.set_icon("plus")
		else:
			$HBoxContainer/NextButton.set_icon("empty")
	else:
		$HBoxContainer/NextButton.set_icon("right")
	if cst[0] == 1:
		$HBoxContainer/PreviousButton.disabled = true
	else:
		$HBoxContainer/PreviousButton.disabled = false
		
		
func create_empty_drawings(count,reset_position_to_0=true):
	for i in range(count):
		$AnswerDraw.load_next_cached()
	if reset_position_to_0:
		$AnswerDraw.load_chached(0)
	set_cache_status_label()

func disable_add_drawing():
	can_add_drawing = false
	set_cache_status_label()
	
func enable_add_drawing():
	can_add_drawing = true
	set_cache_status_label()

func _on_PreviousButton_pressed():
	var _cp = $AnswerDraw.load_prev_cached()
	set_cache_status_label()
	
func _on_NextButton_pressed():
	var cst = $AnswerDraw.get_cache_status()
	if can_add_drawing or cst[0]<cst[1]:
		var _cp = $AnswerDraw.load_next_cached()
		set_cache_status_label()
