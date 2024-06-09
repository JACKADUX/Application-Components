class_name Contoller

signal message_sended(msg:BaseMessage)

var undoredo:=UndoRedo.new()

#---------------------------------------------------------------------------------------------------
func _init():
	undoredo.max_steps = 50
	
#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ActionMessage.BundleAction:
		undoredo.create_action(msg.action_name)
		for _msg in msg.messages:
			handle_message(_msg)
		undoredo.commit_action()
			
#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)

##==================================================================================================
func initialize():
	send_message(Update.Initialize.new([]))


