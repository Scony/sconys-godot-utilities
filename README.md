# Scony' Godot Utilities

Bunch of useful Godot Nodes and Scripts - complementary to [Godot Next](https://github.com/willnationsdev/godot-next) and one of [TheDuriel's](https://github.com/TheDuriel/DurielsGodotUtilities).

## Installation

1. Clone or download this repository to your project's `res://addons/sconys-godot-utilities` directory.
2. Enable plugin in `Project Settings/Plugins`.

## Contents

#### Nodes

- `Circle2D` - texture-backed (hence ultra fast) Circle in 2D
- `ReducedTextureButton` - regular button with ability to scale texture it uses

#### Scripts

- `KVStore` - Redis-like key-value store (early prototype)
- `FSMLite` - Lightweight, convention-based finite state machine (FSM)

```
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
```
