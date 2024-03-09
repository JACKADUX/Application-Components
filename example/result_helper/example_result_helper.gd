extends Node

var http_requests := []

func _ready():
	var result_helper := download("user://test.zip", "https://xxxx.zip")

	result_helper.successed.connect(func():
		print(result_helper.get_meta("data"))
	)
	result_helper.failed.connect(func():
		print(result_helper.get_meta("data"))
	)
	result_helper.updated.connect(func(db):
		print(db)
	)
	if result_helper.is_error_occurred():
		print("download error")
		return 

func _process(delta):
	for http_request in http_requests:
		if not http_request.has_meta("result_helper"):
			continue
		var result_helper = http_request.get_meta("result_helper")
		var downloaded_bytes = http_request.get_downloaded_bytes()
		result_helper.update(downloaded_bytes)

func download(path, url_link) -> ResultHelper:
	var result_helper := ResultHelper.new()
	var http_request = HTTPRequest.new()
	http_requests.append(http_request)
	add_child(http_request)
	http_request.set_meta("result_helper", result_helper)
	http_request.request_completed.connect(func(result, response_code, headers, body):
		http_requests.erase(http_request)
		http_request.queue_free()
		if result == OK:
			result_helper.set_meta("data", {"path":path})
			result_helper.success()
		else:
			push_error("Download Failed")
			result_helper.set_meta("data", {"result":result,"response_code":response_code})
			result_helper.fail()
	)
	http_request.set_download_file(path)
	var request = http_request.request(url_link)
	if request != OK:
		push_error("Http request error")
		result_helper.error()
		http_requests.erase(http_request)
		http_request.queue_free()
	return result_helper
