extends VBoxContainer

var to_translate = {'ButtonClearDrawing':'drawClear',
					'ButtonUndoDrawing':'drawUndo',
					'LabelDraw':'drawLabel'}

func _ready():
	$"/root/GlobalVars".retranslate(get_node('/root'),to_translate)

	
func _on_ButtonClearDrawing_pressed():
	$AnswerDraw.clear_drawing()

func _on_ButtonUndoDrawing_pressed():
	$AnswerDraw.remove_last_line()

func clear_drawing():
	$AnswerDraw.clear_drawing()

func get_lines():
	return $AnswerDraw.lines
	
func add_lines(lines):
	$AnswerDraw.lines += lines