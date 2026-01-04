class_name ShuffleIter

var iter_data :Array
var curser :int

func _init(list :Array) -> void:
	iter_data = list.duplicate()
	shuffle()

func shuffle() -> ShuffleIter:
	iter_data.shuffle()
	curser = 0
	return self

func is_new_start() -> bool:
	return curser == 0

func get_current() -> Variant:
	return iter_data[curser]

func get_next() -> Variant:
	var rtn = iter_data[curser]
	curser += 1
	curser %= iter_data.size()
	if curser == 0:
		shuffle()
	return rtn
