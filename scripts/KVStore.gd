# TODO: MTs, refa, extend, lazy write (signal)

var _data = {}
var _json_file_path


func _init(json_file_path):
	_json_file_path = json_file_path
	var file = File.new()
	if not file.file_exists(json_file_path):
		file.open(json_file_path, File.WRITE)
		file.store_string(JSON.print(_data))
		file.close()
	file.open(json_file_path, File.READ)
	var data = JSON.parse(file.get_as_text()).result
	assert(data is Dictionary)
	_data = data
	file.close()


func set(key, value, set_only_if_not_exists = false):
	if set_only_if_not_exists and not key in _data:
		_data[key] = value
		var file = File.new()
		file.open(_json_file_path, File.WRITE)
		file.store_string(JSON.print(_data))
		file.close()
	if not set_only_if_not_exists:
		_data[key] = value
		var file = File.new()
		file.open(_json_file_path, File.WRITE)
		file.store_string(JSON.print(_data))
		file.close()


func get(key):
	return _data.get(key)
