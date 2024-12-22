extends Tree

func _ready() -> void:
	self.columns = 1
	self.column_titles_visible = true
	self.set_column_title(0, "Name")
	self.set_column_expand(0, true)
	self.set_column_expand_ratio(0, 1)

var _object_to_treeitem : Dictionary = {} #[Object, TreeItem]

var game_access : GameAccess
func display_players(_game_access : GameAccess) -> void:
	game_access = _game_access
	var players : Array[Player] = game_access._players
	if not self.visible: return
	self.clear()
	_object_to_treeitem.clear()
	var root : TreeItem = self.create_item(null)
	for player : Player in players:
		var player_item : TreeItem = self.create_item(root)
		setup_player_row(player_item, player)
		_object_to_treeitem[player] = player_item

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

	if cards.size() == 0:
		item.visible = false
		return
	
	for card : ICardInstance in cards:
		var card_item : TreeItem = self.create_item(item)
		setup_card_row(card_item, card)
		_object_to_treeitem[card] = card_item


func setup_card_row(item : TreeItem, card : ICardInstance) -> void:
	item.set_text(0, str(card))
	if card == null:
		push_warning("Card is null.")
		return