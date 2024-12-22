extends Tree

@onready var drag_event_option_button : OptionButton = get_parent().get_node("%DragEventOptionButton")

func _ready() -> void:
	self.columns = 4
	self.column_titles_visible = true
	self.set_column_title(0, "UID")
	self.set_column_expand(0, true)
	self.set_column_expand_ratio(0, 1)
	self.set_column_title(1, "Name")
	self.set_column_expand(1, true)
	self.set_column_expand_ratio(1, 3)
	self.set_column_title(2, "Location")
	self.set_column_expand(2, true)
	self.set_column_expand_ratio(2, 1)
	self.set_column_title(3, "Meta")
	self.set_column_expand(3, true)
	self.set_column_expand_ratio(3, 1)

var _treeitem_to_object : Dictionary = {} #[TreeItem, Object]

var game_access : GameAccess
func display_cards(_game_access : GameAccess) -> void:
	game_access = _game_access
	if not self.visible: return
	self.clear()
	_treeitem_to_object.clear()
		
	var root : TreeItem = self.create_item(null)
	for card : ICardInstance in game_access._cards:
		var card_item : TreeItem = self.create_item(root)
		setup_card_row(card_item, card)
		_treeitem_to_object[card_item] = card

func setup_card_row(item : TreeItem, card : ICardInstance) -> void:
	item.set_text(0, str(UIDDB.uid(card.get_object())))
	item.set_text(1, str(card))
	if card == null:
		push_warning("Card is null.")
		return
	var card_stats := IStatisticPossessor.id(card)
	var in_deck : bool = card_stats.get_statistic(Genesis.Statistic.IS_IN_DECK)
	var in_hand : bool = card_stats.get_statistic(Genesis.Statistic.IS_IN_HAND)
	var on_field : bool = card_stats.get_statistic(Genesis.Statistic.IS_ON_FIELD)
	var state_sum : int = (in_deck as int) + (in_hand as int) + (on_field as int)
	if state_sum == 0:
		item.set_text(2, "!!!NONE")
	elif state_sum == 1:
		if in_deck:
			item.set_text(2, "DECK")
		elif in_hand:
			item.set_text(2, "HAND")
		else:
			item.set_text(2, "FIELD")
	else:
		item.set_text(2, "!!!MULTIPLE")

	for stat : Genesis.Statistic in card_stats._statistic_db.keys():
		var stat_item : TreeItem = self.create_item(item)
		setup_statistic_row(stat_item, stat, card_stats.get_statistic(stat))

	item.collapsed = true

func setup_statistic_row(item : TreeItem, stat : Genesis.Statistic, value : Variant) -> void:
	item.set_text(1, Genesis.Statistic.keys()[stat])
	item.set_text(3, str(value))

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

func _can_drop_data(at_position: Vector2, _data: Variant) -> bool:
	drop_mode_flags = Tree.DROP_MODE_ON_ITEM
	var target_section := get_drop_section_at_position(at_position)
	if target_section == -100: return false

	var target_item : TreeItem = get_item_at_position(at_position)
	var target_object : Variant = _treeitem_to_object.get(target_item)
	if target_object == null: return false
	if not target_object is ICardInstance: return false
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_item : TreeItem = data
	var source_card : ICardInstance = _treeitem_to_object.get(source_item)
	var target_section := get_drop_section_at_position(at_position)
	if target_section == -100: return 
	var target_item : TreeItem = get_item_at_position(at_position)
	var target_card : ICardInstance = _treeitem_to_object.get(target_item)
	var event_type : StringName = drag_event_option_button.get_item_text(drag_event_option_button.selected).to_upper()
	game_access.request_event(Event.new_from_type(event_type, [source_card, target_card]))