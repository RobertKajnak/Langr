extends Node

#Constants
const MAX_SKILL_LEVEL = 6
const random_key_length = 8 # 7e14 possibilities

#Not constants
var global
var lesson_path
var _all_questions = []

var temp_answer = {}
var _quiz_map = {} #maps question to a lesson

var quiz_rotation = []
var rotation_size = 7
var skill_value_map = {0:20,1:15,2:12,3:10,4:7,5:5,6:1}

const SORT_MODES = ['dateAdded','alphabetical','skill']

func _ready():
	randomize()
	global = $"/root/GlobalVars"
	pass

static func sort_alphabetical(q1, q2):
	if q1['question'] < q2['question']:
		return true
	return false

static func sort_skill(q1, q2):
	if q1['skill'] < q2['skill']:
		return true
	return false

static func fitler_quesiton_list(question_list,regex):
	"""Returns a new array containing the elements that match the regex"""
	var rc = RegEx.new()
	rc.compile(regex)
	var good = []
	for q in question_list:
		if rc.search(q['question']) or ('answer_free' in q and rc.search(q['answer_free'])):
			good.append(q)
	return good

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
func add_question(question,lesson_path=null):
	var err = _check_question(question,true)
	if err:
		return err
	if not 'id' in question:
		question['id'] = global.random_string(random_key_length)
	self._all_questions.append(question)
	var lesson_file = File.new()
	if lesson_path == null:
		lesson_path = self.lesson_path
	lesson_file.open(lesson_path, File.READ_WRITE)
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


func update_question_skill(question,delta, force_update_skill=false):
	"""Updates the skill associated with a question. Date can aslo be set.
		params: 
			question: Can be either a question or a question title. Question has faster lookup
			delta: The difference to be added to the skill. Plus increases the skill. Capped between set limits
			date: the date to be added with the delta. Positive adds 'good_answer_date'. Negative adds 'bad_answer_date'.
			force_update_skill: Updates the field even if it has already been modified 'today'
		
	"""
	if not question:
		push_warning('Question not specified')
		return -1
		
	var today = global.get_date_compact()
		
	var cc
	if question is String:
		cc = get_question(question)
	else:
		cc = question
	
	#This helsp with the skip day. the inverse of the cc modification could also be used, but this is more robust
	var skill_original = cc['skill'] if 'skill' in cc else -1
	
	#The basic idea is that either it is forced, or neither the good nor the bad dates are 'today'
	if force_update_skill \
		or (((not 'bad_answer_date' in cc) \
				or ('bad_answer_date' in cc and cc['bad_answer_date']!=today)) \
			and ((not 'good_answer_date' in cc) \
				or ('good_answer_date' in cc and cc['good_answer_date']!=today))):
		cc['skill'] = max(1,min(MAX_SKILL_LEVEL,cc['skill']+delta))
		
	if delta>0:
		cc['good_answer_date'] = today
		#Check for first try success and update it
		#If you are seeing it for the first time, you might remember it from adding it, or 
		#if you made enough mistakes to bring it down to 1 point, it would be counter-productive to let 
		#you off for a day
		if (not 'bad_answer_date' in cc) or ('bad_answer_date' in cc and cc['bad_answer_date']!=today)\
				and (skill_original>=2):
			if not 'skip_days' in cc:
				cc['skip_days'] = 1
			else:
				cc['skip_days'] = min(14,cc['skip_days']+2)
	elif delta<0:
		cc['bad_answer_date'] = today
		if 'skip_days' in cc:
			cc.erase('skip_days')
	
	
	var lesson = null
	if _quiz_map and 'id' in cc:
		lesson = _quiz_map[cc['id']]
	_save_current_questions(lesson)


func remove_question(question_title):
	"""removes a single question from the lsit with the specified question name"""
	
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
				push_warning('Question was not in quiz map!')
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
	var cskill = MAX_SKILL_LEVEL
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

func compare_questions(q1,q2):
	if not 'id' in q1 or not 'id' in q2:
		return false
	return q1['id']==q2['id']

func question_in_list(question,list_of_questions, return_question=false):
	for q in list_of_questions:
		if compare_questions(q,question):
			if return_question:
				return q
			else:
				return true
	return false

func _get_question_for_rotation(questions_to_ignore):
	var roulette = []
	var S = 0
	var roulette_candidates_without_new = []
	var roulette_candidates_with_new = []
	var today = global.get_date_compact()
	for q in _all_questions:
		#Basically, the skip conditions are:
		#1: it is in the ignore list (e.g. the current rotation, so no duplicates)
		#2: already answered correctly today
		#3: It was answered correctly on first try and earned skip-days which have not yet expired
		if question_in_list(q, questions_to_ignore) \
				or ('good_answer_date' in q and q['good_answer_date']==today) \
				or ('skip_days' in q and 'good_answer_date' in q \
					and global.get_date_difference(today,global.get_date_from_date_compact(q['good_answer_date']))<=q['skip_days']):
			continue
			
		roulette_candidates_with_new.append(q)
		if 'bad_answer_date' in q or 'good_answer_date' in q:
			roulette_candidates_without_new.append(q)
	
	var roulette_candidates = roulette_candidates_without_new if roulette_candidates_without_new.size()>0 else roulette_candidates_with_new
	if roulette_candidates.size()<1:
		return null
	
	for q in roulette_candidates:
		var sk = skill_value_map[int(q['skill'])] if 'skill' in q else skill_value_map[0]
		S += sk
		roulette.append([q,sk])
		
	var slot = randi()%S
	var cp = 0
	for sc in roulette:
		cp += sc[1]
		if cp>=slot:
			return sc[0]
	return roulette[-1][0] # just in case
#if questions is set to null, currently loaded questions are used (_all_questions)	

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
			
			while q['id'] in _quiz_map:
				push_warning('Quesiton ID Already Exists for quesiton '+q['question']+'. Assigning new temp id')
				q['id'] = global.random_string(random_key_length)
			_quiz_map[q['id']] = str(lesson)
	self.lesson_path = ''
	
func exit_quiz():
	_quiz_map = {}
	_all_questions = []
	global.current_lesson = ''
	lesson_path = ''

func _print_question_list(question_list):
	var s := '['
	for i in question_list:
		s+=i['question']
		s+=', '
	if s.length()>1:
		s = s.substr(0,s.length()-2)
	print(s+']')

#Also sets the current_question in global
func get_next_question_to_ask():
	rotation_size = global.rotation_size
	
	#If the lessons have been changed meanwhile, the questions from those lessons are removed
	var to_remove = []
	for q in quiz_rotation:
		if not q['id'] in _quiz_map:
			to_remove.append(q)
	for q in to_remove:
		quiz_rotation.erase(q)
	
	#If the settings have been changed, the surplus is removed
	while quiz_rotation.size()>rotation_size:
		quiz_rotation.pop_back()
		
	#Fill up with roulette-based selection of questions that are not already inside
	while quiz_rotation.size()<rotation_size:
		var qcand = _get_question_for_rotation(quiz_rotation)
		if qcand == null:
			break
		quiz_rotation.append(qcand)
	
	if quiz_rotation.empty():
		return null
		
	return quiz_rotation[0]
	
func move_question_to_rotation_end(question):
	question = question_in_list(question,quiz_rotation,true)
	if question:
		quiz_rotation.erase(question)
	quiz_rotation.push_back(question)
	
func remove_from_rotation(question):
	question = question_in_list(question,quiz_rotation,true)
	if question:
		quiz_rotation.erase(question)
	
func get_recap_question_count():
	var rqcr = 0
	for q in _all_questions:
		var today = global.get_date_compact()
		if ('good_answer_date' in q and q['good_answer_date']==today) \
			or ('skip_days' in q and 'good_answer_date' in q \
				and global.get_date_difference(today,global.get_date_from_date_compact(q['good_answer_date']))<=q['skip_days']):
			continue
			
		if 'bad_answer_date' in q or 'good_answer_date' in q:
			rqcr +=1
	return rqcr
	
func get_lesson_for_question(question, cut_extension=false):
	var ln = _quiz_map[question['id']]
	if cut_extension:
		ln = ln.substr(0,ln.find_last('.'))
	return ln
	
	
