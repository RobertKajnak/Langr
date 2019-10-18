extends Node

#Constants
var max_skill_level = 7
var random_key_length = 8 # 7e14 possibilities

#Not constants
var global
var lesson_path
var _all_questions = []

var temp_answer = {}
var _quiz_map = {} #maps question to a lesson

func _ready():
	randomize()
	global = $"/root/GlobalVars"
	pass

#Loads the questions associated to the currently open lesson. Can be overriden by specifiying the parameter
func load_questions(lesson_path=null, replace_current_questions = true):
	if replace_current_questions:
		_all_questions = []
		
	if lesson_path == null:
		self.lesson_path = 'user://lessons/' + global.current_lesson +'.les'
	else:
		self.lesson_path = lesson_path
		
	var lesson_file = File.new()
	if lesson_file.file_exists(self.lesson_path):
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
	new_dict['id'] = global.random_string(random_key_length)
	return new_dict

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
		
#if null is specified, the current lesson is used
func add_question(question,lesson=null):
	var err = _check_question(question,true)
	if err:
		return err
	if not 'id' in question:
		question['id'] = global.random_string(random_key_length)
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
	if not 'id' in new_question:
		new_question['id'] = global.random_string(random_key_length)
		
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

#Can be either a question or a question title. Question has faster lookup
func update_question_skill(question,delta,date = null, force_reduction=false):
	if not question:
		print('Question not specified')
		return -1
		
	if not date:
		date = global.get_date_compact()
		
	var cc
	if question is String:
		cc = get_question(question)
	else:
		cc = question
		
	if delta>0 or force_reduction or not 'bad_answer_date' in cc \
		or ('bad_answer_date' in cc and cc['bad_answer_date']!=global.get_date_compact()):
		cc['skill'] = max(1,min(max_skill_level,cc['skill']+delta))
	if delta>0:
		cc['good_answer_date'] = date
	elif delta<0:
		cc['bad_answer_date'] = date
	
	var lesson = null
	if _quiz_map and 'id' in cc:
		lesson = _quiz_map[cc['id']]
	_save_current_questions(lesson)

#removes a single question from the lsit with the specified question name
func remove_question(question_title):
	var index = self.get_question_titles().find(question_title)
	
	if index == -1:
		return
	else:
		_all_questions.remove(index)
	_save_current_questions()

func _save_current_questions(lesson=null):
	var lesson_file = File.new()
	if _quiz_map:
		lesson_path = ''
		for question in _all_questions:
			if lesson != _quiz_map[question['id']]:
				continue
			var les_path = 'user://lessons/' + _quiz_map[question['id']]
			if les_path != lesson_path:
				if lesson_path != '':
					lesson_file.close()
				lesson_path = les_path
				lesson_file.open(lesson_path, File.WRITE)
			lesson_file.store_line(to_json(question))
		lesson_file.close()
	else:
		lesson_file.open(lesson_path, File.WRITE)
		for question in _all_questions:
			lesson_file.store_line(to_json(question))
		lesson_file.close()

#---Transition---
func set_temp_answer(answer):
	temp_answer = answer
	
func get_temp_answer():
	return temp_answer


	
	
#--- Asking---
#if questions is set to null, currently loaded questions are used (_all_questions)
func _get_lowest_scored_questions(questions = null):
	if questions == null:
		questions = _all_questions
	var cskill = max_skill_level
	var candidates = []
	for q in questions:
		if 'good_answer_date' in q and q['good_answer_date']==global.get_date_compact():
			continue
		if q['skill'] == cskill:
			candidates.append(q)
		elif q['skill'] < cskill:
			candidates = [q]
			cskill = q['skill']
	return candidates

#if questions is set to null, currently loaded questions are used (_all_questions)	
func _get_earliest_dated(questions = null):
	if questions == null:
		questions = _all_questions
	var cdate = global.get_date_compact()
	var candidates = []
	for q in questions:
		pass
	return candidates

func load_lessons_for_quiz():
	_all_questions = [] #Empty current list, then replace
	_quiz_map = {}
	global.current_lesson = ''
	for lesson in global.active_lessons:
		var last_end = _all_questions.size()
		load_questions('user://lessons/' + lesson,false)
		for i in range(last_end,_all_questions.size()):
			var q = _all_questions[i]
			if not 'id' in q:
				q['id'] = global.random_string(random_key_length)
			_quiz_map[q['id']] = str(lesson)
	self.lesson_path = ''
	
func exit_quiz():
	_quiz_map = {}
	_all_questions = []
	global.current_lesson = ''
	lesson_path = ''

#Also sets the current_question in global
func get_next_question_to_ask():
	if not _all_questions:
		return null
	var questions = _get_lowest_scored_questions()
	if not questions: #No valid questions found
		return null
		
	var next_question = questions[randi()%questions.size()]
	global.current_question = next_question
	
	return next_question
	
func get_lesson_for_question(question, cut_extension=false):
	var ln = _quiz_map[question['id']]
	if cut_extension:
		ln = ln.substr(0,ln.find_last('.'))
	return ln