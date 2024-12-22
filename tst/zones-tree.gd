extends Tree

func _ready() -> void:
	self.columns = 1
	self.column_titles_visible = true
	self.set_column_title(0, "Name")
	self.set_column_expand(0, true)
	self.set_column_expand_ratio(0, 1)

var _treeitem_to_object : Dictionary = {} #[TreeItem, Object]

var game_access : GameAccess
func display_players(_game_access : GameAccess) -> void:
	game_access = _game_access
	var players : Array[Player] = game_access._players
	if not self.visible: return
	self.clear()
	_treeitem_to_object.clear()
	var root : TreeItem = self.create_item(null)
	for player : Player in players:
		var player_item : TreeItem = self.create_item(root)
		setup_player_row(player_item, player)
		_treeitem_to_object[player_item] = player

func setup_player_row(item : TreeItem, player : Player) -> void:
	item.set_text(0, str(player))

	for zone : StringName in ["deck", "field", "hand"]:
		var zone_item : TreeItem = self.create_item(item)
		setup_zone_row(zone_item, player, zone)

func setup_zone_row(item : TreeItem, player : Player, zone : StringName) -> void:
	item.set_text(0, str(zone).to_upper())
	var cards : Array[ICardInstance] = []

	match(zone):
		"deck":
			cards = game_access.get_players_deck(player)
		"field":
			cards = game_access.get_players_field(player)
		"hand":
			cards = game_access.get_players_hand(player)
		_:
			return
	
	for card : ICardInstance in cards:
		var card_item : TreeItem = self.create_item(item)
		setup_card_row(card_item, card)
		_treeitem_to_object[card_item] = card


func setup_card_row(item : TreeItem, card : ICardInstance) -> void:
	item.set_text(0, str(card))
	if card == null:
		push_warning("Card is null.")
		return

# https://forum.godotengine.org/t/dragging-treeitems-within-tree-control-node/42393
func _get_drag_data(_at_position: Vector2) -> Variant:
	var selected : TreeItem = get_next_selected(null)
	if selected == null: return null
	var selected_object : Variant = _treeitem_to_object.get(selected)
	if not selected_object is ICardInstance: return null

	# var v := VBoxContainer.new()
	# var l := Label.new()
	# l.text = "  %s" % selected.get_text(0)
	# v.add_child(l)
	# set_drag_preview(v)
	return selected

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var source_item : TreeItem = data
	if source_item.get_tree() != self: return false
	drop_mode_flags = Tree.DROP_MODE_ON_ITEM
	var target_section := get_drop_section_at_position(at_position)
	if target_section == -100:
		return false
	#var source_object : Variant = _treeitem_to_object.get(source_items[0])

	var target_item : TreeItem = get_item_at_position(at_position)
	var target_object : Variant = _treeitem_to_object.get(target_item)
	if target_object == null:
		var target_parent : TreeItem = target_item.get_parent()
		var target_parent_object : Variant = _treeitem_to_object.get(target_parent)
		if target_parent_object is Player:
			return true
		return false
	if target_item == source_item: return false
	if target_object is Player: return false
	if target_object is ICardInstance: return false
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_item : TreeItem = data
	var target_section := get_drop_section_at_position(at_position)
	if target_section == -100: return 
	var target_item : TreeItem = get_item_at_position(at_position)
	var source_object : Variant = _treeitem_to_object.get(source_item)
	if not source_object is ICardInstance: return
	var source_card : ICardInstance = source_object as ICardInstance
	var target_text : String = target_item.get_text(0)
	game_access.request_event(Event.new_from_type("ENTERED_%s" % target_text, [source_card]))