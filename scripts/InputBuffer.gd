extends Node
# Keeps track of recent inputs in order to make timing windows more flexible.
# Intended use: Add this file to your project as an Autoload script and have other objects call the class' methods.
# (more on AutoLoad: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

const BUFFER_WINDOW: int = 350
const JOY_DEADZONE: float = 0.2

var keyboard_timestamps: Dictionary
var mouse_buttons_timestamps: Dictionary
var joypad_timestamps: Dictionary
var joymotion_timestamps: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize all dictionary entris.
	keyboard_timestamps = {}
	mouse_buttons_timestamps = {}
	joypad_timestamps = {}
	joymotion_timestamps = {}
	

# Called whenever the player makes an input.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed or event.is_echo():
			return
		
		var keycode: int = event.physical_keycode
		keyboard_timestamps[keycode] = Time.get_ticks_msec()
	elif event is InputEventMouseButton:
		if !event.pressed or event.is_echo():
			return
		
		var keycode: int = event.button_index
		mouse_buttons_timestamps[keycode] = Time.get_ticks_msec()
	elif event is InputEventJoypadButton:
		if !event.pressed or event.is_echo():
			return
			
		var button_index: int = event.button_index
		joypad_timestamps[button_index] = Time.get_ticks_msec()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < JOY_DEADZONE:
			return
			
		var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
		joymotion_timestamps[axis_code] = Time.get_ticks_msec()
	
# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
func is_action_press_buffered(action: String) -> bool:
	# Get the inputs associated with the action. If any one of them was pressed in the last BUFFER_WINDOW milliseconds,
	# the action is buffered.
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton:
			var keycode: int = event.button_index
			if mouse_buttons_timestamps.has(keycode):
				if Time.get_ticks_msec() - mouse_buttons_timestamps[keycode] <= BUFFER_WINDOW:
					# Prevent this method from returning true repeatedly and registering duplicate actions.
					_invalidate_action(action)
					
					return true;
		elif event is InputEventKey:
			var keycode: int = event.physical_keycode
			if keyboard_timestamps.has(keycode):
				if Time.get_ticks_msec() - keyboard_timestamps[keycode] <= BUFFER_WINDOW:
					# Prevent this method from returning true repeatedly and registering duplicate actions.
					_invalidate_action(action)
					
					return true;
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				if Time.get_ticks_msec() - joypad_timestamps[button_index] <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) < JOY_DEADZONE:
				return false
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joymotion_timestamps.has(axis_code):
				var delta = Time.get_ticks_msec() - joymotion_timestamps[axis_code]
				if delta <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
	
	return false


# Records unreasonable timestamps for all the inputs in an action. Called when IsActionPressBuffered returns true, as
# otherwise it would continue returning true every frame for the rest of the buffer window.
func _invalidate_action(action: String) -> void:
	return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			print(event.keycode)
			var keycode: int = event.keycode
			if keyboard_timestamps.has(keycode):
				keyboard_timestamps[keycode] = 0
		elif event is InputEventMouseButton:
			var keycode: int = event.button_index
			if mouse_buttons_timestamps.has(keycode):
				mouse_buttons_timestamps[keycode] = 0
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				joypad_timestamps[button_index] = 0
		elif event is InputEventJoypadMotion:
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joymotion_timestamps.has(axis_code):
				joymotion_timestamps[axis_code] = 0
