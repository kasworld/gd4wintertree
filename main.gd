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

	winter_tree = preload("res://winter_tree/winter_tree.tscn").instantiate(
		).init(WorldSize.y, WorldSize.z/2, WorldSize.y*2, PI, 1.0,
		).set_center_color(Color.GREEN)
	add_child(winter_tree)
	$"왼쪽패널/LabelTree".text = "branch count %d" % [ winter_tree.가지들얻기().multimesh.instance_count ]
	winter_tree.position.y = - WorldSize.y/2
	winter_tree_inst_index = winter_tree.make_index_array()

var winter_tree :WinterTree
enum AniDir { Up, Down, Left , Right }
var winter_tree_inst_index :Array
var color_fn_args := ShuffleIter.new( [[0],[1],[2],[0,1],[1,2],[2,0], [0,1,2]] )
var color_fn :Callable = RandomColor.pure_color
var ani_dir_data := ShuffleIter.new( [AniDir.Up, AniDir.Down, AniDir.Left , AniDir.Right] )
var change_count := 0
func linetree_animate(delta :float) -> void:
	winter_tree.rotate_y(delta)
	var lines :MultiMeshShape = winter_tree.가지들얻기()
	var co :Color = color_fn.call(color_fn_args.get_current())
	var ani_ended :bool = false
	match ani_dir_data.get_current():
		AniDir.Up:
			for i in winter_tree_inst_index[-change_count-1]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index.size()
		AniDir.Down:
			for i in winter_tree_inst_index[change_count]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index.size()
		AniDir.Left:
			for a :Array in winter_tree_inst_index:
				if change_count >= a.size():
					continue
				var i = a[change_count]
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index[-1].size()
		AniDir.Right:
			for a :Array in winter_tree_inst_index:
				if change_count >= a.size():
					continue
				var i = a[-change_count-1]
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index[-1].size()
	winter_tree.장식들얻기().set_inst_color( randi_range(0, winter_tree.장식들얻기().multimesh.instance_count-1),  random_color())

	if ani_ended:
		color_fn_args.get_next()
		ani_dir_data.get_next()
		change_count = 0
		color_fn = [RandomColor.pure_color, RandomColor.rate_color, random_color2].pick_random()
		winter_tree.장식들얻기().set_color_all( random_color())

var named_color_list := ShuffleIter.new(NamedColorList.color_list)
func random_color2(_arg ) -> Color:
	return named_color_list.get_next()[0]


func random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	label_demo()
	linetree_animate(delta)
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

func _on_button_esc_pressed() -> void:
	get_tree().quit()
func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()
func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_dec()
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
