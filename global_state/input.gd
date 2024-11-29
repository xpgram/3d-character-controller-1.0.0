extends Node
## Manages global application input state.

func _input(event: InputEvent) -> void:
   # Capture the mouse when the game is focused.
   if event.is_action_pressed("left_click"):
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
   # Release the mouse when the game is unfocused.
   if event.is_action_pressed("ui_cancel"):
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

   # TODO Is it better that this is managed by a camera object and not the application?