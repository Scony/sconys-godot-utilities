extends "res://addons/gut/test.gd"

const FSMLite = preload('../scripts/FSMLite.gd')


class EmptyFSM:
	extends FSMLite


func test_empty_fsm():
	var sut = CustomFSM.new()
	sut.set_state('dummy')
	assert_ne(sut, null, "")


class GuardedFSM:
	extends FSMLite

	var guard_called = false

	func guard():
		guard_called = true


func test_guarded_fsm():
	var sut = GuardedFSM.new()
	sut.set_legal_states(['foo'])
	sut.set_state('bar')
	assert_eq(sut.guard_called, true, "guard should be called on illegal transition")


func test_unguarded_fsm():
	var sut = GuardedFSM.new()
	sut.set_state('bar')
	assert_eq(sut.guard_called, false, "guard should not be called given no legal states")


class CustomFSM:
	extends FSMLite

	var call_sequence = []

	func initial_enter():
		call_sequence.push_back(1)
		set_state('intermediate')

	func initial_exit():
		call_sequence.push_back(2)

	func intermediate_enter():
		call_sequence.push_back(3)
		set_state('final')

	func final_exit():
		call_sequence.push_back(4)


func test_custom_fsm():
	var sut = CustomFSM.new()
	sut.set_state('initial')  # initial -> intermediate -> final
	sut.set_state()
	assert_eq(sut.call_sequence, [1, 2, 3, 4], "call sequence should match")
