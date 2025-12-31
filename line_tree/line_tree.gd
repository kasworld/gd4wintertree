extends Node3D
class_name LineTree

func _ready() -> void:
	var lines := []
	for y in range(50,-50,-1):
		var rate := (50.0-y)/100.0
		var r :float= lerp(1.0,40.0, rate ) + fposmod(rate*100,20)*rate
		lines.append_array(make_lines(y,240*rate,10*rate,r))
	$Lines.multi_line_by_pos(lines, 0.5, Color.DARK_GREEN,1.0)
	$Lines.set_gradient_color_all(Color.RED, Color.GREEN)

func make_lines(start_y :float, count :int, h :float, r :float) -> Array:
	var rtn := []
	for i in count:
		var rad := 2*PI / count *i
		var to := Vector3(cos(rad)*r, start_y - h , sin(rad)*r)
		rtn.append([Vector3(0,start_y,0), to])
	return rtn
