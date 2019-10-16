extends Node

var global
var lesson_path
var _all_questions = []


func _ready():
	global = $"/root/GlobalVars"
	pass

#Loads the questions associated to the currently open lesson. Can be overriden by specifiying the parameter
func load_questions(lesson_path=null, replace_current_questions = true):
	if replace_current_questions:
		_all_questions = []
		
	if lesson_path == null:
		self.lesson_path = 'user://lessons/' + global.current_lesson +'.les'
	
	var lesson_file = File.new()
	lesson_file.open(self.lesson_path, File.READ)
	while not lesson_file.eof_reached():
		var question = parse_json(lesson_file.get_line())
		if question == null:
			break
		_all_questions.append(question)
	lesson_file.close()
	
func get_questions():
	return _all_questions
	
func get_question_titles():
	var titles = []
	for question in _all_questions:
		titles.append(question['question'])
	return titles
	
func get_question(question_title):
	for question in _all_questions:
		if question['question'] == question_title:
			return question
	return null

func question_from_fields(question_title,score=0,answer_free='',answer_multi=[],drawing_node = null):
	var new_dict = {}
	if question_title:
		new_dict['question'] = question_title
	if answer_free!='':
		new_dict['answer_free'] = answer_free
	if answer_multi != []:
		new_dict['answer_multi'] = answer_multi
	if drawing_node != null:
		 new_dict['drawing_node'] = drawing_node
	new_dict['score'] = score

#Adds a question based on the parameters. Returns an untranslated error string if the question could not be added
#Otherwise returns null

func _check_question(question, check_duplicate=true):
	if not 'question' in question:
		return 'questionNotSet'
	elif check_duplicate and (question['question'] in self.get_question_titles()):
		return 'questionAlreadyExists'
	elif not ('answer_free' in question or 'answer_multi' in question or 'answer_draw' in question):
		return 'answerNotSet'
	return null
		
func add_question(question):
	var err = _check_question(question,true)
	if err:
		return err
	
	self._all_questions.append(question)
	var lesson_file = File.new()
	lesson_file.open(self.lesson_path, File.READ_WRITE)
	lesson_file.seek_end()
	lesson_file.store_line(to_json(question))
	lesson_file.close()

func replace_question(to_replace_title,new_question):
	var err = _check_question(new_question,false)
	if err:
		return err
		
	var lesson_file = File.new()
	if not to_replace_title in get_question_titles():
		add_question(new_question)
	else:
		lesson_file.open(self.lesson_path, File.WRITE)
		var index = 0
		var increment = 1
		for question in _all_questions:
			if question['question'] == to_replace_title:
				lesson_file.store_line(to_json(new_question))
				increment = 0
			else:
				lesson_file.store_line(to_json(question))
			index+=increment
		lesson_file.close()
		_all_questions.remove(index)
		_all_questions.insert(index,new_question)

#removes a single question from the lsit with the specified question name
func remove_question(question_title):
	var index = self.get_question_titles().find(question_title)
	if index == -1:
		return
	else:
		_all_questions.remove(index)
		
	var lesson_file = File.new()
	lesson_file.open(self.lesson_path, File.WRITE)
	for question in _all_questions:
		lesson_file.store_line(to_json(question))
	lesson_file.close()

#--- Asking---
func get_next_question_to_ask():
	return _all_questions[0]