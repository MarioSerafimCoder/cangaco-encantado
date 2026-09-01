extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var player := $Main/Nilo as NiloPlayer
	var home := _find_home_room()
	if home == null:
		failures.append("Casa de Nilo não foi instanciada como RoomController.")
		_finish()
		return
	_validate_authored_tree(home)
	_validate_visual_values(home)
	_validate_collisions(home)
	_validate_interactions(home, world)
	_validate_secret_and_checkpoint(home)
	_validate_player_and_rooms(home, player)
	_finish()


func _find_home_room() -> RoomController:
	for candidate in get_tree().get_nodes_in_group("production_rooms"):
		var room := candidate as RoomController
		if room.room_id == &"casa_nilo":
			return room
	return null


func _validate_authored_tree(home: RoomController) -> void:
	if home.suppress_authored_environment:
		failures.append("Casa de Nilo ainda suprime o ambiente autoral da cena.")
	for path in [
		"Environment/Architecture/Interior/BackWall",
		"Environment/Architecture/Interior/LeftWall",
		"Environment/Architecture/Interior/RightWall",
		"Environment/Architecture/Interior/Ceiling",
		"Environment/Architecture/Interior/Floor/FloorWest",
		"Environment/Architecture/Interior/Floor/FloorEast",
		"Environment/Architecture/Interior/Window",
		"Geometry/EditableFurniture/Bed/FurnitureSprite",
		"Geometry/EditableFurniture/Cabinet/FurnitureSprite",
		"Geometry/EditableFurniture/Workbench/FurnitureSprite",
		"Environment/Architecture/Interior/Furniture/WallShelf",
		"Environment/Architecture/Interior/Furniture/LongShelf",
		"Environment/Architecture/Interior/Furniture/Lamp",
	]:
		var sprite := home.get_node_or_null(path) as Sprite2D
		if sprite == null or sprite.texture == null or not sprite.region_enabled:
			failures.append("Sprite autoral ausente ou sem região editável: %s." % path)
		elif sprite.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
			failures.append("Sprite sem filtro nearest: %s." % path)


func _validate_visual_values(home: RoomController) -> void:
	var expected := {
		"Environment/Architecture/Interior/BackWall": [Vector2(305, 49), Rect2(302, 108, 910, 340), Vector2(0.681319, 0.681319), -9],
		"Environment/Architecture/Interior/Window": [Vector2(424, 77), Rect2(1294, 672, 216, 238), Vector2(0.351852, 0.351852), -4],
		"Geometry/EditableFurniture/Bed/FurnitureSprite": [Vector2(81.45503, 126), Rect2(28, 105, 455, 330), Vector2(0.20853055, 0.1818182), -3],
		"Geometry/EditableFurniture/Cabinet/FurnitureSprite": [Vector2(181.00002, 125), Rect2(500, 120, 240, 300), Vector2(0.17916685, 0.19555682), -3],
		"Geometry/EditableFurniture/Workbench/FurnitureSprite": [Vector2(337, 129), Rect2(805, 145, 395, 275), Vector2(0.20342602, 0.18419215), -3],
	}
	for path in expected:
		var sprite := home.get_node(path) as Sprite2D
		var values: Array = expected[path]
		if sprite.global_position.distance_to(values[0]) > 0.01 or sprite.region_rect != values[1] or sprite.scale.distance_to(values[2]) > 0.00001 or sprite.z_index != values[3]:
			failures.append("Valor visual runtime não foi preservado em %s." % path)


func _validate_collisions(home: RoomController) -> void:
	var ground := home.get_node_or_null("Geometry/Ground/GroundCollision/CollisionShape2D") as CollisionShape2D
	if ground == null or ground.shape is not RectangleShape2D:
		failures.append("Piso editável da casa está ausente.")
	else:
		var shape := ground.shape as RectangleShape2D
		var body := ground.get_parent() as StaticBody2D
		if shape.size != Vector2(640, 30) or not is_equal_approx(body.position.y - shape.size.y * 0.5, 150.0):
			failures.append("Piso editável não preservou a baseline y=150.")
	for path in [
		"Geometry/InteriorCollision/LeftBoundary/CollisionShape2D",
		"Geometry/EditableFurniture/Bed/CollisionShape2D",
		"Geometry/EditableFurniture/Cabinet/CollisionShape2D",
		"Geometry/EditableFurniture/Workbench/CollisionShape2D",
		"Geometry/DoorCollision/InteriorDoorWall/CollisionShape2D",
	]:
		var collision := home.get_node_or_null(path) as CollisionShape2D
		if collision == null or collision.shape == null:
			failures.append("Colisão autoral ausente: %s." % path)
		elif not bool(collision.get_meta("_edit_lock_", false)):
			failures.append("Colisão técnica desprotegida no editor: %s." % path)
	for furniture_name in ["Bed", "Cabinet", "Workbench"]:
		var furniture := home.get_node_or_null("Geometry/EditableFurniture/%s" % furniture_name) as StaticBody2D
		if furniture == null or not bool(furniture.get_meta("_edit_group_", false)):
			failures.append("Móvel sem agrupamento seguro no editor: %s." % furniture_name)
	if ground != null and ground.visible:
		failures.append("A grande forma azul do piso deve ficar oculta no editor.")


func _validate_interactions(home: RoomController, world: VilaGraybox) -> void:
	var doors := world.find_children("*", "TransitionDoor", true, false)
	if doors.size() != 2:
		failures.append("Casa de Nilo deve possuir exatamente duas portas.")
	for candidate in doors:
		var door := candidate as TransitionDoor
		if not home.is_ancestor_of(door):
			failures.append("Uma porta da casa ainda foi gerada fora da cena autoral.")
		if door.get_node_or_null("DoorSprite") == null or door.get_node_or_null("InteractionCollision") == null or door.get_node_or_null("Prompt") == null:
			failures.append("Porta não expõe visual, colisão e prompt na árvore.")
	var keepsake := home.get_node_or_null("Gameplay/Interactables/FamilyKeepsake") as NarrativeInteractable
	if keepsake == null or keepsake.dialogue_id != &"lembranca_nilo":
		failures.append("Lembrança narrativa não foi materializada com o ID original.")
	elif keepsake.get_node_or_null("KeepsakeSprite") == null or keepsake.get_node_or_null("InteractionCollision") == null:
		failures.append("Lembrança narrativa não expõe sprite e colisão editáveis.")
	for child in world.get_children():
		if child is AtlasWorldProp and child.position.x < 640.0:
			failures.append("Prop da Casa de Nilo ainda é gerado no compositor runtime.")
		if child is NarrativeInteractable and (child as NarrativeInteractable).dialogue_id == &"lembranca_nilo":
			failures.append("Lembrança da casa ainda é duplicada no compositor runtime.")


func _validate_secret_and_checkpoint(home: RoomController) -> void:
	var checkpoint := home.get_node_or_null("Gameplay/Interactables/HomeCheckpoint") as Checkpoint
	if checkpoint == null or checkpoint.checkpoint_id != &"vila_casa" or checkpoint.get_node_or_null("InteractionCollision") == null:
		failures.append("Checkpoint da casa não está materializado e editável.")
	for path in ["Gameplay/Secret/SecretStep01", "Gameplay/Secret/SecretStep02", "Gameplay/Secret/SecretStep03"]:
		var platform := home.get_node_or_null(path) as TraversalPlatform
		if platform == null or platform.reveal_ability != &"dash" or platform.get_node_or_null("CollisionShape2D") == null or platform.get_node_or_null("PlatformSprite") == null:
			failures.append("Rota secreta não está totalmente materializada: %s." % path)
	var gate := home.get_node_or_null("Gameplay/Secret/DustSeal") as AbilityGate
	var upgrade := home.get_node_or_null("Gameplay/Secret/HeartUpgrade") as PermanentUpgradePickup
	if gate == null or gate.get_node_or_null("GateSprite") == null or gate.get_node_or_null("CollisionShape2D") == null:
		failures.append("Selo do segredo não está materializado.")
	if upgrade == null or upgrade.upgrade_id != &"coracao_casa_nilo" or upgrade.get_node_or_null("UpgradeSprite") == null:
		failures.append("Melhoria permanente da casa não está materializada.")


func _validate_player_and_rooms(home: RoomController, _player: NiloPlayer) -> void:
	if get_tree().get_nodes_in_group("production_rooms").size() != 13:
		failures.append("A refatoração alterou a quantidade das salas de produção.")
	if not home.get_global_bounds().has_point(GameState.DEFAULT_SPAWN):
		failures.append("O ponto de nascimento padrão de Nilo não fica dentro da Casa de Nilo.")
	var room_area := home.get_node_or_null("Gameplay/Triggers/RoomArea/CollisionShape2D") as CollisionShape2D
	if room_area == null or room_area.shape == null:
		failures.append("Trigger da sala não está materializado.")
	elif room_area.visible or not bool(room_area.get_meta("_edit_lock_", false)):
		failures.append("A grande forma azul do RoomArea deve ficar oculta e bloqueada no editor.")


func _finish() -> void:
	if failures.is_empty():
		print("CASA_DE_NILO_AUTHORED_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
