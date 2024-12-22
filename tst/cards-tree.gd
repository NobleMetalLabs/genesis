extends Tree

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

var _object_to_treeitem : Dictionary = {} #[Object, TreeItem]

func display_cards(_cards : Array[ICardInstance]) -> void:
	if not self.visible: return
	self.clear()
	_object_to_treeitem.clear()
	var root : TreeItem = self.create_item(null)
		
	# tally cards
	var cards_parent : TreeItem = self.create_item(root)
	cards_parent.set_text(0, "Cards")
	for card : ICardInstance in _cards:
		var card_item : TreeItem = self.create_item(cards_parent)
		setup_card_row(card_item, card)
		_object_to_treeitem[card] = card_item

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
