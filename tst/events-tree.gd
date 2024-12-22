extends Tree

func _ready() -> void:
	self.columns = 4
	self.column_titles_visible = true
	self.set_column_title(0, "Event / ProcessingStep")
	self.set_column_expand(0, true)
	self.set_column_expand_ratio(0, 8)
	self.set_column_title(1, "Card / Target")
	self.set_column_expand(1, true)
	self.set_column_expand_ratio(1, 6)
	self.set_column_title(2, "Other / Source")
	self.set_column_expand(2, true)
	self.set_column_expand_ratio(2, 3)
	self.set_column_title(3, "Hash / Priority")
	self.set_column_expand(3, true)
	self.set_column_expand_ratio(3, 1)

var history : EventHistory
var object_to_treeitem : Dictionary = {} #[Event, TreeItem]
var already_logged : Array[Event] = []

func display_event_history(_history : EventHistory) -> void:
	#print("Displaying history %s" % _history)
	
	history = _history
	if not self.visible: return
	self.clear()
	object_to_treeitem.clear()
	already_logged.clear()
	var root : TreeItem = self.create_item(null)
		
	var events_per_tick : Dictionary = history._events_by_gametick
	for tick : int in events_per_tick.keys():
		var events : Array[Event] = events_per_tick[tick]
		if events.is_empty(): continue
		
		var tick_parent : TreeItem = self.create_item(root)
		tick_parent.set_text(0, "Tick %s" % tick)
		for event : Event in events:
			if event in already_logged: continue
			setup_event_item(tick_parent, event)

	var last_item : TreeItem = self.get_root()
	var last_item_children : Array[TreeItem] = last_item.get_children()
	while last_item_children.size() > 0:
		last_item = last_item_children.back()
		last_item_children = last_item.get_children()
	self.scroll_to_item(last_item, true)

func setup_event_item(parent : TreeItem, event : Event) -> void:
	var item : TreeItem = self.create_item(parent)
	object_to_treeitem[event] = item
	item.set_text(0, str(event.event_type))
	item.set_tooltip_text(0, str(event))
	item.set_text(1, str(event.get_subject()))
	var other_card_prop : Variant = Event.get_event_property_names_of_cards(event).filter(
			func is_card(pname : StringName) -> bool: return pname != "card"
		).pop_front()
	
	var other_card : ICardInstance = null
	if other_card_prop != null:
		other_card = event.get(other_card_prop)
	
	item.set_text(2, str(other_card) if other_card != null else "")
	item.set_text(3, str(hash(event)))
	already_logged.append(event)

	for proc_step : EventProcessingStep in history.get_event_processing_record(event).processing_steps:
		setup_processing_step_item(item, event, proc_step)

func setup_processing_step_item(parent : TreeItem, event : Event, proc_step : EventProcessingStep) -> void:
	var item : TreeItem = self.create_item(parent)
	var proc_step_string : String = str(proc_step)
	item.set_text(0, proc_step_string.left(proc_step_string.rfind(",")).substr(proc_step_string.rfind(":") - 1))
	item.set_text(1, str(proc_step.target_group))
	item.set_text(2, str(proc_step.processing_source))
	item.set_text(3, str(proc_step.priority.to_int()))
	item.set_tooltip_text(3, str(proc_step.priority))

	var caused_events : Array[Event] = history.get_event_processing_record(event).caused_events_by_processing_step[proc_step]
	for caused_event : Event in caused_events:
		setup_event_item(item, caused_event)
	
	
