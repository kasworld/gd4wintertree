extends Node3D

func _ready() -> void:
	var cone := make_cone(20,20)
	cone.position.y = 50
	cone = make_cone(30,30)
	cone.position.y = 35
	cone = make_cone(40,40)
	cone.position.y = 20
	cone = make_cone(50,50)
	cone.position.y = -10

func make_cone(r :float, h :float) -> MeshInstance3D:
	var cone := MeshInstance3D.new()
	cone.mesh = CylinderMesh.new()
	cone.mesh.top_radius = 0
	cone.mesh.bottom_radius = r
	cone.mesh.height = h
	cone.mesh.material = StandardMaterial3D.new()
	add_child(cone)
	return cone
