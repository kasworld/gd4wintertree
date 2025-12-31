extends Node3D
class_name LineTree


func init(h :float, w :float, co1 :Color, co2 :Color) -> LineTree:
	$"중심기둥".mesh.top_radius = w/1000
	$"중심기둥".mesh.bottom_radius = w/100
	$"중심기둥".mesh.height = h
	$"중심기둥".mesh.material.albedo_color = co2
	$"중심기둥".position.y = h /2
	var lines := []
	for y in range(h,0,-1):
		var rate := (h-y)/h
		var r :float= lerp(1.0, w/2, rate ) + fposmod(rate*h, h/5)*rate
		lines.append_array(make_lines(y,w*2*rate,10*rate,r))
	$Lines.multi_line_by_pos(lines, 0.5, Color.WHITE)
	$Lines.set_gradient_color_all(co1,co2)
	return self

func make_lines(start_y :float, count :int, h :float, r :float) -> Array:
	var rtn := []
	for i in count:
		var rad := 2*PI / count *i
		var to := Vector3(cos(rad)*r, start_y  , sin(rad)*r)
		rtn.append([Vector3(0,start_y+h,0), to])
	return rtn
