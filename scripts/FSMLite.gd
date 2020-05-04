class_name FSMLite
extends Node

var _legal_states = []
var _current_state = null
var _managed_object = self


func set_managed_object(managed_object):
	_managed_object = managed_object


func set_legal_states(states):
	_legal_states = states


func set_state(state = null):
	if _current_state != null and _managed_object.has_method('%s_exit' % _current_state):
		_managed_object.call('%s_exit' % _current_state)
	if state == null:
		return
	if _legal_states == [] or state in _legal_states:
		_current_state = state
		if _managed_object.has_method('%s_enter' % state):
			_managed_object.call('%s_enter' % state)
	else:
		guard()


func enable_signal_dispatching(prefix, object, signal_name, signal_args_num):
	object.connect(
		signal_name, self, '_on_signal_{0}'.format([signal_args_num]), [prefix, signal_name]
	)


func guard():
	assert(false)


func _on_signal_0(prefix, signal_name):
	# TODO: bounds checking
	_managed_object.call('%s_%s_%s' % [_current_state, prefix, signal_name])


func _on_signal_1(arg0, prefix, signal_name):
	# TODO: bounds checking
	_managed_object.call('%s_%s_%s' % [_current_state, prefix, signal_name], arg0)
