extends MultiMeshShape
class_name MeshTree

func init(mesh :Mesh, h :float, w :float, y_count :int, w_branch_density :float = PI, stage_count :int=5) -> MeshTree:
	pos_list = []
	instance_count_per_y = []
	var y_step := h / y_count
	for yi in range(y_count-1,0,-1):
		var y := y_step * yi
		var r :float= calc_radius_by_y(y, h, w, stage_count)
		pos_list.append_array(make_pos_list(y, r*w_branch_density, r))
	init_meshs_by_point_list(mesh, pos_list, Color.WHITE)
	return self

func calc_radius_by_y(y :float, h :float, w :float, stage_count :int) -> float:
	var rate := 1.0 - y/h
	return lerp(w/100, w/2, rate ) + fposmod(rate*h, h/stage_count)*rate

func make_pos_list(start_y :float, count :int, r :float) -> Array:
	instance_count_per_y.append(count)
	var rtn := []
	var rad_step := 2*PI / count
	var rad_shift :float = randf_range(0,rad_step)
	for i in count:
		var rad := rad_step*i + rad_shift
		var to := Vector3(cos(rad)*r, start_y , sin(rad)*r)
		rtn.append(to)
	return rtn

var pos_list :Array
var instance_count_per_y :Array[int]
func make_index_array() -> Array:
	var rtn := []
	var i := 0
	for count in instance_count_per_y:
		var index_array := []
		for j in count:
			index_array.append(i)
			i += 1
		rtn.append(index_array)
	return rtn
