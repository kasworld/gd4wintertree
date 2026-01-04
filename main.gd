extends Node3D

const WorldSize := Vector3(160,90,80)

func on_viewport_size_changed() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var 짧은길이 :float = min(vp_size.x, vp_size.y)
	var panel_size := Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$"왼쪽패널".size = panel_size
	$"왼쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.size = panel_size
	$"오른쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	var msgrect := Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(vp_size.y*0.05 , msgrect, "%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version") ] )
func timed_message_hidden(_s :String) -> void:
	pass

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

func _ready() -> void:
	on_viewport_size_changed()
	get_viewport().size_changed.connect(on_viewport_size_changed)
	$TimedMessage.panel_hidden.connect(timed_message_hidden)
	$TimedMessage.show_message("",0)
	$OmniLight3D.position = Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightHober.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightAround.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/10)
	$FixedCameraLight.make_current()
	$GlassCabinet.init(WorldSize)
	$LineTree.init(WorldSize.y, WorldSize.z/2, 100,
		).set_center_color(Color.GREEN)
	$LineTree.position.y = - WorldSize.y/2
	line_tree_inst_index_ori = $LineTree.make_index_array()
	line_tree_inst_index = line_tree_inst_index_ori.duplicate()

enum AniDir { Up, Down, Left , Right }
var line_tree_inst_index_ori :Array
var line_tree_inst_index :Array
var rgb_index :int = 0
var rgb_data := [[0],[1],[2],[0,1],[1,2],[2,0], [0,1,2]]
var color_fn :Callable = RandomColor.pure_color
var change_count := 0
var ani_dir :AniDir
func linetree_color_animate() -> void:
	var lines :MultiMeshShape = $LineTree.get_lines()
	var co :Color = color_fn.call(rgb_data[rgb_index])

	var ani_ended :bool = false
	match ani_dir:
		AniDir.Up:
			for i in line_tree_inst_index[-change_count-1]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= line_tree_inst_index.size()
		AniDir.Down:
			for i in line_tree_inst_index[change_count]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= line_tree_inst_index.size()
		AniDir.Left:
			for a :Array in line_tree_inst_index:
				var i = a.pop_front()
				lines.set_inst_color(i, co)
				a.push_back(i)
			change_count +=1
			ani_ended = change_count >= line_tree_inst_index[-1].size()
		AniDir.Right:
			for a :Array in line_tree_inst_index:
				var i = a.pop_back()
				lines.set_inst_color(i, co)
				a.push_front(i)
			change_count +=1
			ani_ended = change_count >= line_tree_inst_index[-1].size()

	if ani_ended:
		change_count = 0
		rgb_index += 1
		rgb_index %= rgb_data.size()
		if rgb_index == 0:
			rgb_data.shuffle()
		line_tree_inst_index = line_tree_inst_index_ori.duplicate()
		ani_dir = randi_range(0,3)
		color_fn = [RandomColor.pure_color, RandomColor.rate_color].pick_random()

func random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

func _process(_delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	label_demo()
	linetree_color_animate()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

func _on_button_esc_pressed() -> void:
	get_tree().quit()
func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()
func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()
func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()
var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_PAGEUP:_on_button_fov_up_pressed,
	KEY_PAGEDOWN:_on_button_fov_down_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
	elif event is InputEventMouseButton and event.is_pressed():
		pass
