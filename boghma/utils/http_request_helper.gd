class_name HTTPRequestHelper extends HTTPRequest

var result_helper:ResultHelper

func _ready():
	use_threads = true
	set_process(false)

func _process(delta):
	var db = get_downloaded_bytes()
	result_helper.update(db)

func get_request(url:String, method=HTTPClient.METHOD_GET) -> ResultHelper:
	var result_helper := ResultHelper.new()
	request_completed.connect(func(result, response_code, headers, body):
		queue_free()
		if response_code == 200:
			var data = {}
			if body:
				data = JSON.parse_string(body.get_string_from_utf8())
			result_helper.set_meta("data", data)
			result_helper.success()
		else:
			result_helper.set_meta("data", {"result":result,"response_code":response_code})
			result_helper.fail()
	)
	var error = request(url, [], method)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		result_helper.error()
		queue_free()
	return result_helper
		
func download(url:String, path:String) -> ResultHelper:
	result_helper = ResultHelper.new()
	request_completed.connect(func(result, response_code, headers, body):
		queue_free()
		set_process(false)
		if result == OK:
			result_helper.set_meta("data", {"path":path})
			result_helper.success()
		else:
			push_error("Download Failed")
			result_helper.set_meta("data", {"result":result,"response_code":response_code})
			result_helper.fail()
	)
	set_download_file(path)
	var request = request(url)
	if request != OK:
		push_error("Http request error")
		result_helper.error()
		queue_free()
	else:
		set_process(true)
	return result_helper


	
