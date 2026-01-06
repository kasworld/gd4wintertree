extends Node3D
class_name MeshTree

func init(mesh :Mesh, h :float, w :float, y_count :int, w_branch_density :float = PI, stage_count :int=5) -> MeshTree:
	var pos_list := []
	var y_step := h / y_count
	for yi in range(y_count-1,0,-1):
		var y := y_step * yi
		var rate := 1-float(yi) / float(y_count)
		var r :float= lerp(w/100, w/2, rate ) + fposmod(rate*h, h/stage_count)*rate
		pos_list.append_array(make_pos_list(y, w*w_branch_density*(rate+0.1), r))
	$MultiMeshShape.init_meshs_by_point_list(mesh, pos_list, Color.WHITE)
	return self

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

var instance_count_per_y :Array[int] = []
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
