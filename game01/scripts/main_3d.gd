extends Node3D

# main_3d.gd - Master 3D Spatial Engine Controller for Study Cafe Tycoon

@onready var camera_3d: Camera3D = $Camera3D
@onready var env_3d: WorldEnvironment = $WorldEnvironment
@onready var sun_light: DirectionalLight3D = $DirectionalLight3D
@onready var floor_mesh: MeshInstance3D = $FloorMesh

var desk_nodes: Array = []
var customer_nodes: Dictionary = {}
var is_orbiting: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("🚀 Launching Full 3D Spatial Engine for Study Cafe Tycoon...")
	setup_3d_environment()
	build_3d_study_cafe_layout()
	
	GameState.customer_arrived.connect(_on_customer_arrived_3d)
	GameState.customer_left.connect(_on_customer_left_3d)
	GameState.time_of_day_changed.connect(_update_3d_lighting)

func setup_3d_environment() -> void:
	# Configure 3D Camera
	if camera_3d == null:
		camera_3d = Camera3D.new()
		camera_3d.name = "Camera3D"
		add_child(camera_3d)
		
	camera_3d.current = true
	camera_3d.position = Vector3(0, 8, 10)
	camera_3d.rotation_degrees = Vector3(-38, 0, 0)
	
	# Configure 3D Sky & Environment
	if env_3d == null:
		env_3d = WorldEnvironment.new()
		env_3d.name = "WorldEnvironment"
		add_child(env_3d)
		
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.12, 0.1, 0.09)
	env.ambient_light_color = Color(0.96, 0.7, 0.4)
	env.ambient_light_energy = 0.8
	env_3d.environment = env

	# Configure 3D Sun Light
	if sun_light == null:
		sun_light = DirectionalLight3D.new()
		sun_light.name = "DirectionalLight3D"
		add_child(sun_light)
		
	sun_light.rotation_degrees = Vector3(-45, 30, 0)
	sun_light.light_color = Color(1.0, 0.85, 0.6)
	sun_light.shadow_enabled = true

func build_3d_study_cafe_layout() -> void:
	# Create 3D Wood Tile Floor
	if floor_mesh == null:
		floor_mesh = MeshInstance3D.new()
		floor_mesh.name = "FloorMesh"
		add_child(floor_mesh)
		
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(20, 0.2, 14)
	floor_mesh.mesh = box_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.16, 0.12)
	mat.roughness = 0.4
	floor_mesh.material_override = mat
	floor_mesh.position = Vector3(0, -0.1, 0)
	
	# Build 3D Desks (8 Slots)
	for i in range(8):
		var col = i % 4
		var row = i / 4
		var pos_x = -6.0 + col * 4.0
		var pos_z = -3.0 + row * 4.5
		var is_booth = (i >= 6)
		
		create_3d_desk_unit(i, Vector3(pos_x, 0, pos_z), is_booth)

func create_3d_desk_unit(idx: int, pos: Vector3, is_booth: bool) -> void:
	var desk_group = Node3D.new()
	desk_group.name = "Desk3D_%d" % idx
	desk_group.position = pos
	add_child(desk_group)
	
	# 3D Desk Top Mesh
	var desk_top = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(2.4, 0.15, 1.6)
	desk_top.mesh = top_mesh
	
	var top_mat = StandardMaterial3D.new()
	top_mat.albedo_color = Color(0.35, 0.22, 0.14) if not is_booth else Color(0.18, 0.14, 0.25)
	top_mat.roughness = 0.3
	desk_top.material_override = top_mat
	desk_top.position = Vector3(0, 0.8, 0)
	desk_group.add_child(desk_top)
	
	# 3D Desk Legs (4 Legs)
	var leg_coords = [Vector3(-1.0, 0.4, -0.6), Vector3(1.0, 0.4, -0.6), Vector3(-1.0, 0.4, 0.6), Vector3(1.0, 0.4, 0.6)]
	for l_pos in leg_coords:
		var leg = MeshInstance3D.new()
		var leg_mesh = BoxMesh.new()
		leg_mesh.size = Vector3(0.1, 0.8, 0.1)
		leg.mesh = leg_mesh
		
		var leg_mat = StandardMaterial3D.new()
		leg_mat.albedo_color = Color(0.1, 0.1, 0.1)
		leg.material_override = leg_mat
		leg.position = l_pos
		desk_group.add_child(leg)
		
	# 3D Private Booth Partitions if Booth
	if is_booth:
		var wall_back = MeshInstance3D.new()
		var w_mesh = BoxMesh.new()
		w_mesh.size = Vector3(2.6, 1.4, 0.1)
		wall_back.mesh = w_mesh
		
		var w_mat = StandardMaterial3D.new()
		w_mat.albedo_color = Color(0.2, 0.15, 0.28)
		wall_back.material_override = w_mat
		wall_back.position = Vector3(0, 1.5, -0.8)
		desk_group.add_child(wall_back)
		
	# 3D OmniLight Lamp (Warm Amber Glow)
	var lamp_light = OmniLight3D.new()
	lamp_light.light_color = Color(1.0, 0.75, 0.3)
	lamp_light.light_energy = 2.5
	lamp_light.omni_range = 3.5
	lamp_light.shadow_enabled = true
	lamp_light.position = Vector3(0.8, 1.3, -0.5)
	desk_group.add_child(lamp_light)
	
	desk_nodes.append(desk_group)

func _on_customer_arrived_3d(c_info: Dictionary) -> void:
	var cid = c_info["id"]
	var customer_3d = MeshInstance3D.new()
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = 0.35
	cap_mesh.height = 1.4
	customer_3d.mesh = cap_mesh
	
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.2, 0.6, 1.0) if c_info["type"] == "student" else Color(0.2, 0.9, 0.4)
	customer_3d.material_override = c_mat
	
	var seat_idx = c_info.get("seat_index", 0)
	if seat_idx < desk_nodes.size():
		var d_pos = desk_nodes[seat_idx].position
		customer_3d.position = d_pos + Vector3(0, 0.7, 0.5)
		
	add_child(customer_3d)
	customer_nodes[cid] = customer_3d

func _on_customer_left_3d(c_info: Dictionary, _earnings: float) -> void:
	var cid = c_info["id"]
	if customer_nodes.has(cid):
		customer_nodes[cid].queue_free()
		customer_nodes.erase(cid)

func _update_3d_lighting(tod: String) -> void:
	if sun_light == null: return
	if tod == "DAY":
		sun_light.light_color = Color(1.0, 0.9, 0.7)
		sun_light.light_energy = 1.2
	elif tod == "DUSK":
		sun_light.light_color = Color(1.0, 0.5, 0.2)
		sun_light.light_energy = 0.7
	elif tod == "NIGHT":
		sun_light.light_color = Color(0.2, 0.3, 0.6)
		sun_light.light_energy = 0.25

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_orbiting = event.pressed
			last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if camera_3d: camera_3d.position.z = max(4.0, camera_3d.position.z - 0.8)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if camera_3d: camera_3d.position.z = min(18.0, camera_3d.position.z + 0.8)
	elif event is InputEventMouseMotion and is_orbiting:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		if camera_3d:
			camera_3d.rotation_degrees.y -= delta.x * 0.3
			camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x - delta.y * 0.3, -80.0, -10.0)
