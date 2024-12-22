#class_name MultiplayerManager
extends Node

signal network_update()

var multiplayer_peer := ENetMultiplayerPeer.new()
var player_name : String = "P%s" % OS.get_process_id()

var network_player : NetworkPlayer
var peer_id_to_player : Dictionary = {} #[int, NetworkPlayer]

var ADDRESS : String
const PORT = 31570

var upnp : UPNP = UPNP.new()
func _ready() -> void:
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)

	var auto_connect : Callable = \
		func auto_connect() -> void:
			var args := Array(OS.get_cmdline_args())
			if args.has("-server"):
				host_lobby(true)
			elif args.has("-client"):
				join_lobby()
	
	auto_connect.call_deferred()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp.get_device_count() > 0:
			upnp.delete_port_mapping(PORT, "UDP")
			upnp.delete_port_mapping(PORT, "TCP")

func is_instance_server() -> bool:
	if multiplayer.multiplayer_peer == null: return false
	return multiplayer.get_unique_id() == 1

func get_peer_id() -> int:
	if network_player == null: return 0
	return network_player.peer_id

func get_num_players() -> int:
	return peer_id_to_player.size()

func host_lobby(over_lan : bool = false) -> void:
	if not over_lan:
		var discover_result := upnp.discover() as UPNP.UPNPResult
		if discover_result == UPNP.UPNP_RESULT_SUCCESS:
			if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
				var result_udp := upnp.add_port_mapping(PORT, PORT, "Genesis Gambit Multiplayer", "UDP")
				var result_tcp := upnp.add_port_mapping(PORT, PORT, "Genesis Gambit Multiplayer", "TCP")
				if not result_udp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(PORT, PORT, "", "UDP")
				if not result_tcp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(PORT, PORT, "", "TCP")
			ADDRESS = upnp.query_external_address()

	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Server started on port %s with clientid %s" % [PORT, multiplayer.get_unique_id()])
	network_player = NetworkPlayer.setup(multiplayer.get_unique_id(), player_name)
	assign_player_networkplayer(multiplayer.get_unique_id(), network_player)
	network_update.emit()

func join_lobby(address : String = "127.0.0.1") -> void:
	multiplayer_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joined server with clientid %s" % [multiplayer.get_unique_id()])
	network_player = NetworkPlayer.setup(multiplayer.get_unique_id(), player_name)
	assign_player_networkplayer(multiplayer.get_unique_id(), network_player)

func exit_lobby() -> void:
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.multiplayer_peer = null
	peer_id_to_player.clear()
	print("Left server")
	network_update.emit()

func on_player_connected(peer_id : int) -> void:
	var mid : int = multiplayer.get_unique_id()
	rpc_id(peer_id, "request_player_meta", mid)
	network_update.emit()

func on_player_disconnected(peer_id : int) -> void:
	if peer_id == 1:
		exit_lobby.call_deferred()
		print("Host disconnected.")
		return
	peer_id_to_player.erase(peer_id)
	network_update.emit()

@rpc("any_peer")
func request_player_meta(requester_id : int) -> void:
	var mid : int = multiplayer.get_unique_id()
	rpc_id(requester_id, "assign_player_networkplayer", mid, network_player.serialize())

@rpc("any_peer")
func assign_player_networkplayer(peer_id : int, _network_player : Variant) -> void:
	var player : NetworkPlayer
	if _network_player is Dictionary:
		player = Serializeable.deserialize(_network_player)
	else:
		player = _network_player
	peer_id_to_player[peer_id] = player
	#UIDDB.register_object(player)
	network_update.emit()

	await get_tree().create_timer(1).timeout

	var ps :  Array[NetworkPlayer] = []
	ps.assign(peer_id_to_player.values())
	var dr : Dictionary = {}
	for pid : int in peer_id_to_player.keys():
		dr[pid] = Deck.prebuilt_from_tribe(Genesis.CardTribe.BUGS)

func send_network_message(message : String, args : Array, recipient_id : int = -1, remote_only : bool = false) -> void:
	var msg_obj := NetworkMessage.setup(get_peer_id(), message, args)
	var msg_dict : Dictionary = msg_obj.serialize()
	# print("%s : Sending message %s" % [get_peer_id(), msg_obj])
	# print("%s : Sending message %s" % [get_peer_id(), msg_dict])
	if recipient_id == -1:
		rpc("receive_network_message", var_to_bytes(msg_dict))
	else:
		rpc_id(recipient_id, "receive_network_message", var_to_bytes(msg_dict))
	if remote_only: return
	received_network_message.emit(network_player, message, args)

@rpc("any_peer", "reliable") #some messages should be unreliable probably? idfk assuming bad perf has fd me so hard
func receive_network_message(bytes : PackedByteArray) -> void:
	var msg_dict : Dictionary = bytes_to_var(bytes)
	# print("\n%s : Handling message \n%s\n" % [get_peer_id(), JSON.stringify(msg_dict, "\t")])
	var message : NetworkMessage = Serializeable.deserialize(msg_dict)
	# print("%s : Handling message %s" % [get_peer_id(), message])
	received_network_message.emit(peer_id_to_player[message.sender_peer_id], message.message, message.args)

signal received_network_message(sender : NetworkPlayer, message : String, args : Array)
