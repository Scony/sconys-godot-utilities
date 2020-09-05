extends CanvasLayer

var gosh_handler = self

var _command_handlers = []

onready var _panel = find_node('Panel')
onready var _text = find_node('RichTextLabel')
onready var _edit = find_node('LineEdit')


func _ready():
	_panel.hide()
	_text.clear()
	_text.add_text('Welcome to debug console')
	_edit.clear()


func _input(event):
	if event is InputEventKey and event.scancode == KEY_QUOTELEFT:
		if event.pressed:
			_toggle_visibility()
		get_tree().set_input_as_handled()


func execute_command(command, args):
	var root = get_node('/root')
	match command:
		'ping':
			return 'pong'
		'time_scale':
			Engine.time_scale = float(args[0])
			return
		'node_statistics':
			var depth = 2 if args.size() < 2 else int(args[1])
			var node_path = '/root' if args.size() < 1 else args[0]
			var node = get_node(node_path)
			if node != null:
				return _get_node_statistics_string(get_node(node_path), depth)
			return
		'commands':
			_refresh_handlers()
			var available_commands = []
			for command_handler in _command_handlers:
				available_commands += command_handler.provided_commands()
			return PoolStringArray(available_commands).join("\n")


func provided_commands():
	return [
		'ping',
		'time_scale',
		'node_statistics',
		'commands',
	]


func _toggle_visibility():
	_panel.visible = not _panel.visible
	if _panel.visible:
		_refresh_handlers()
		_edit.grab_focus()


func _refresh_handlers():
	_command_handlers = []
	Utils.NodTree.traverse(get_node('/root'), self, '_gather_handler_if_present')


func _gather_handler_if_present(node):
	var handler = node.get('gosh_handler')
	if handler != null:
		_command_handlers.append(handler)


func _on_edit_text_entered(command):
	_text.add_text('\n> ' + command)
	var command_chunks = command.split(' ')
	for command_handler in _command_handlers:
		var handler_commands = Utils.Set.from_array(command_handler.provided_commands())
		if handler_commands.has(command_chunks[0]):
			var output = command_handler.execute_command(
				command_chunks[0], Utils.Arr.slice(command_chunks, 1)
			)
			if output != null:
				_text.add_text('\n' + output)
	_edit.clear()


func _get_node_statistics_string(node, depth = 0):
	var ret = ''
	for tuple in _get_node_statistics(node, depth):
		ret += '\n%-10d %s' % [tuple[1], tuple[0]]
	return ret


func _get_node_statistics(node, depth):
	var node_statistics = [str(node.get_path()), 0]  # Tuple[str, int]
	var children_statistics = []  # List[Tuple[str, int]]
	if depth > 0:
		for child in node.get_children():
			var child_node_statistics = _get_node_statistics(child, depth - 1)
			node_statistics[1] += child_node_statistics[0][1] + 1
			children_statistics += child_node_statistics
	else:
		node_statistics[1] = _get_total_children_count(node)
	return [node_statistics] + children_statistics


func _get_total_children_count(node):
	var children_count = 0
	for child in node.get_children():
		children_count += _get_total_children_count(child) + 1
	return children_count
