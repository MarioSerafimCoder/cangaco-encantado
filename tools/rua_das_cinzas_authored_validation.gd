extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var street := _find_street_room()
	if street == null:
		failures.append("Rua das Cinzas não foi instanciada como RoomController.")
		_finish()
		return
	_validate_obstacles(street, world)
	_validate_npcs(street, world)
	_validate_existing_room_tree(street)
	_finish()


func _find_street_room() -> RoomController:
	for candidate in get_tree().get_nodes_in_group("production_rooms"):
		var room := candidate as RoomController
		if room.room_id == &"rua_cinzas":
			return room
	return null


func _validate_obstacles(street: RoomController, world: VilaGraybox) -> void:
	var expected := {
		"CarrocaOeste": [Vector2(300, 150), Vector2(0, -14.33898), Vector2(0.20338984, 0.20338984), Rect2(55, 145, 590, 265), Vector2(0, -31.79661), Vector2(102, 8)],
		"CaixaOeste": [Vector2(510, 150), Vector2(0, -16.97561), Vector2(0.23414634, 0.23414634), Rect2(830, 425, 205, 185), Vector2(0, -34.634148), Vector2(40, 8)],
		"ToldoCentral": [Vector2(690, 150), Vector2(0, -41.87097), Vector2(0.38064516, 0.38064516), Rect2(35, 665, 310, 300), Vector2(0, -94.96774), Vector2(100, 8)],
		"CarrocaRampa": [Vector2(900, 150), Vector2(-5, -17.000002), Vector2(0.19823009, 0.19823009), Rect2(695, 135, 565, 295), Vector2(-5, -36.8867), Vector2(94, 8)],
		"CaixaLeste": [Vector2(1090, 150), Vector2(0, -16.97561), Vector2(0.23414634, 0.23414634), Rect2(830, 425, 205, 185), Vector2(0, -34.634148), Vector2(40, 8)],
	}
	var obstacles := street.get_node_or_null("Geometry/EditableObstacles")
	if obstacles == null or obstacles.get_child_count() != expected.size():
		failures.append("Os cinco obstáculos da rua não estão organizados em Geometry/EditableObstacles.")
		return
	for obstacle_name in expected:
		var body := obstacles.get_node_or_null(obstacle_name) as StaticBody2D
		if body == null:
			failures.append("Obstáculo autoral ausente: %s." % obstacle_name)
			continue
		var values: Array = expected[obstacle_name]
		var sprite := body.get_node_or_null("ObstacleSprite") as Sprite2D
		var collision := body.get_node_or_null("WalkableSurface") as CollisionShape2D
		var shape := collision.shape as RectangleShape2D if collision != null else null
		if sprite == null or collision == null or shape == null:
			failures.append("Sprite ou colisão editável ausente em %s." % obstacle_name)
			continue
		if body.position.distance_to(values[0]) > 0.001 or sprite.position.distance_to(values[1]) > 0.001 or sprite.scale.distance_to(values[2]) > 0.00001 or sprite.region_rect != values[3]:
			failures.append("A composição runtime não foi preservada em %s." % obstacle_name)
		if collision.position.distance_to(values[4]) > 0.001 or shape.size != values[5] or body.collision_layer != 1:
			failures.append("A superfície física não foi preservada em %s." % obstacle_name)
		if sprite.texture == null or not sprite.region_enabled or sprite.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
			failures.append("Atlas pixel-perfect inválido em %s." % obstacle_name)
	for child in world.get_children():
		if child is AtlasWorldProp and child.position.x >= 640.0 and child.position.x < 1920.0:
			failures.append("Um obstáculo da Rua das Cinzas ainda é criado pelo compositor runtime.")


func _validate_npcs(street: RoomController, world: VilaGraybox) -> void:
	var expected := {
		"DonaTereza": [&"dona_tereza", &"dona_tereza", Vector2(120, 138), Rect2(0, 0, 328.25, 599)],
		"Raimundo": [&"raimundo", &"ferido", Vector2(185, 138), Rect2(328.25, 0, 328.25, 599)],
	}
	for actor_name in expected:
		var npc := street.get_node_or_null("Gameplay/Actors/%s" % actor_name) as NPCActor
		var values: Array = expected[actor_name]
		if npc == null:
			failures.append("NPC autoral ausente: %s." % actor_name)
			continue
		var sprite := npc.get_node_or_null("NPCSprite") as Sprite2D
		var collision := npc.get_node_or_null("InteractionCollision") as CollisionShape2D
		var prompt := npc.get_node_or_null("Prompt") as Label
		if npc.npc_id != values[0] or npc.dialogue_id != values[1] or npc.position != values[2]:
			failures.append("Identidade ou posição do NPC não foi preservada: %s." % actor_name)
		if sprite == null or collision == null or prompt == null or sprite.region_rect != values[3]:
			failures.append("Visual, colisão ou prompt do NPC não está editável: %s." % actor_name)
	for child in world.get_children():
		if child is NPCActor and (child as NPCActor).room_id == &"rua_cinzas":
			failures.append("Um NPC da Rua das Cinzas ainda é criado fora da cena autoral.")


func _validate_existing_room_tree(street: RoomController) -> void:
	if street.round_authored_sprite_positions:
		failures.append("A rua ainda altera em runtime os offsets fracionários materializados.")
	if get_tree().get_nodes_in_group("production_rooms").size() != 13:
		failures.append("A materialização da rua alterou a quantidade de salas de produção.")
	for path in [
		"Geometry/Ground/GroundCollision/CollisionShape2D",
		"Gameplay/Entrances/LEFT_ENTRANCE",
		"Gameplay/Entrances/RIGHT_ENTRANCE",
		"Gameplay/EnemySpawns/SaqueadorSpawn",
		"Gameplay/Triggers/RoomArea/CollisionShape2D",
	]:
		if street.get_node_or_null(path) == null:
			failures.append("Elemento anterior da sala foi perdido: %s." % path)
	var cactus := street.get_node_or_null("Environment/GameplayDecor/CactoExtremoLeste") as Sprite2D
	var cart := street.get_node_or_null("Environment/GameplayDecor/Carroca") as Sprite2D
	if cactus == null or cactus.scale.distance_to(Vector2(0.1156, 0.1156)) > 0.00001:
		failures.append("A escala runtime do cacto não foi materializada.")
	if cart == null or cart.position.distance_to(Vector2(480.0656, 132.4828)) > 0.001:
		failures.append("A carroça decorativa preexistente não preservou sua posição runtime.")


func _finish() -> void:
	if failures.is_empty():
		print("RUA_DAS_CINZAS_AUTHORED_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
