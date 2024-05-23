extends Object

class_name MyTimer

var is_running = false;
var timeout_time_in_unix;
var counted_time;
var callback: Callable;

func start(_timeout_time_in_unix, _callback: Callable):
	is_running = true;
	counted_time = 0;
	timeout_time_in_unix = _timeout_time_in_unix
	callback = _callback;
	
func progress(delta: float):
	if is_running:
		counted_time += delta * 1000;
		if(counted_time >= timeout_time_in_unix):
			callback.call();
