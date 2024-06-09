class_name CustomConfirmationDialog extends ConfirmationDialog

enum ResultCode {
	None,
	OK,
	CANCEL,
	DISCARD,	
}
var result := ResultCode.None

func init_with(_title:String, _dialog_text:String) -> ResultHelper:
	var result_helper := ResultHelper.new()
	confirmed.connect(func():
		result = ResultCode.OK
		result_helper.success()
		queue_free()
	)
	canceled.connect(func():
		result = ResultCode.CANCEL
		result_helper.success()
		queue_free()
		
	)
	title = _title
	dialog_text = _dialog_text #
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	unresizable = true
	return result_helper
	
func init_with_discard(_title:String, _dialog_text:String) -> ResultHelper:
	var result_helper := init_with(_title, _dialog_text)
	add_button("Discard", true, "Discard")
	custom_action.connect(func(_acname:String):
		result = ResultCode.DISCARD
		hide()
		result_helper.success()
		queue_free()
	)
	return result_helper
