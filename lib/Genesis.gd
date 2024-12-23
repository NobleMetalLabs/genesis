class_name Genesis
extends Object

## Genesis is a class that provides objects needed in a global scope for the game. This is mostly data-related enums and constants.

# Cards

enum CardType {
	ATTACKER,
	SUPPORT,
	INSTANT,
	PASSIVE,
	LEADER,
}

const COLOR_BY_CARDTYPE : Dictionary = {
	Genesis.CardType.ATTACKER: Color.CRIMSON,
	Genesis.CardType.INSTANT: Color.CORNFLOWER_BLUE,
	Genesis.CardType.SUPPORT: Color.LIME_GREEN,
	Genesis.CardType.PASSIVE: Color.DARK_ORCHID,
	Genesis.CardType.LEADER: Color.GHOST_WHITE
}

enum CardRarity {
	COMMON,
	RARE,
	MYTHIC,
	EPIC,
	LEADER,
}

enum PackRarity {
	COMMON,
	RARE,
	MYTHIC,
	EPIC,
}

enum CardTribe {
	NONE,
	ARCHITECTURE,
	BEASTS,
	BIRDS,
	BUGS,
	ELECTRONICS,
	ENTERTAINMENT,
	EVIL,
	FISH,
	FOLKLORE,
	FOOD,
	GAMBLING,
	GOOD,
	MEDICINE,
	MONKEY,
	NERDS_GEEKS,
	THE_FUEL,
	VAMPIRE,
	WEATHER,
}

# Actions and Events

# Cooldown*
enum CooldownType {
	DRAW,
	BURN,
	FREEZE,
	SHUFFLE,
	DECK_MAINTENANCE,
	SSICKNESS,
	ATTACK,
	ACTIVATE,
	CUSTOM,
	CUSTOM2,
	CUSTOM3
}

# NOTE: merge all of these?
# CreatureLeavePlay*
enum LeavePlayReason {
	DIED,
	BANISHED,
	SACRIFICED,
	SPENT
}

# HandRemoveCard*
enum LeaveHandReason {
	PLAYED,
	DISCARDED,
	BURNED,
	BANISHED,
}

# DeckRemoveCard*
enum LeaveDeckReason {
	DRAWN,
	PLAYED,
	BANISHED,
}

# *RemoveCard*
enum CardRemoveAnimation {
	INHERIT,
	PLAY,
	DISCARD,
	BURN,
	BANISH,
}

const DRAW_TIMER_PERIOD : float = 5

const NETWORK_FRAME_PERIOD : float = 0.1#99999999999# 0.1

const MAX_SPEED_VALUE : int = 10 # This probably should not change i think.
const SPEED_FLOOR : float = 1.5
const SPEED_SPREAD : float = 1.75

static func speed_value_to_cooldown_frame_count(speed : int) -> int:
	return (((MAX_SPEED_VALUE - max(1, speed)) / SPEED_SPREAD) + SPEED_FLOOR) / NETWORK_FRAME_PERIOD


# Statistics

enum Statistic {
	# Basic
	HEALTH,
	STRENGTH,
	SPEED,
	ENERGY,
	CHARGES,
	POSITION,
	# State
	IS_IN_HAND,
	IS_ON_FIELD,
	IS_IN_DECK,
	IS_MARKED,
	WAS_JUST_MARKED,
	WAS_JUST_UNMARKED,
	IS_FROZEN,
	WAS_JUST_FROZEN,
	WAS_JUST_UNFROZEN,
	WAS_JUST_PLAYED,
	WAS_JUST_BURNED,
	WAS_JUST_DISCARDED,
	JUST_ATTACKED,
	WAS_JUST_ATTACKED,
	WAS_JUST_ACTIVATED,
	JUST_TARGETED,
	WAS_JUST_TARGETED,
	JUST_KILLED,
	WAS_JUST_KILLED,
	WAS_JUST_SACRIFICED,
	HAS_TARGET,
	# References
	TARGET,
	MOST_RECENT_ATTACKED,
	MOST_RECENT_ATTACKED_BY,
	HAND_VISIBLE_PLAYERS,
	DECK_TOPCARD_VISIBLE_PLAYERS,
	CURRENT_COOLDOWNS,
	# Ability
	CAN_ATTACK,
	CAN_BE_ATTACKED,
	CAN_BE_ACTIVATED,
	CAN_TARGET,
	CAN_TARGET_ATTACKERS,
	CAN_TARGET_INSTANTS,
	CAN_TARGET_SUPPORTS,
	CAN_TARGET_SELF,
	CAN_BE_TARGETED,
	CAN_BE_TARGETED_OPPONENTS_ONLY,
	CAN_BE_TARGETED_FRIENDLIES_ONLY,
	CAN_BE_SACRIFICED,
	CAN_BE_KILLED,
	CAN_HAVE_MOODS,
	ACTS_AS_BLOCKER,
	ACTS_AS_UNMARKED,
	IS_TRANSIENT,
	# Counts
	NUM_ATTACKS_MADE,
	NUM_ATTACKS_RECIEVED,
	NUM_ACTIVATIONS,
	NUM_MOODS,
	NUM_MOOD_CHANGES,
	# Player
	MAX_HAND_SIZE,
	MAX_ENERGY,
	NUM_INSTANTS_PLAYED,
	NUM_CREATURES_PLAYED,
	NUM_SUPPORTS_PLAYED,
	NUM_CARDS_PLAYED,
	NUM_CARDS_DRAWN,
	NUM_CARDS_BURNED,
	NUM_CARDS,
	NUM_CARDS_MARKED_IN_DECK,
	NUM_CARDS_LEFT_IN_DECK,
	HAND_VISIBLE,
	HAND_VISIBLE_TO_OPPONENTS,
	HAND_VISIBLE_RARITY_ONLY,
	HAND_VISIBLE_TYPE_ONLY,
	HAND_VISIBLE_TO_OPPONENTS_RARITY_ONLY,
	HAND_VISIBLE_TO_OPPONENTS_TYPE_ONLY,
	DECK_TOPCARD_VISIBLE,
	DECK_TOPCARD_VISIBLE_TO_OPPONENTS,
	DECK_TOPCARD_VISIBLE_RARITY_ONLY,
	DECK_TOPCARD_VISIBLE_TYPE_ONLY,
	DECK_TOPCARD_VISIBLE_TO_OPPONENTS_RARITY_ONLY,
	DECK_TOPCARD_VISIBLE_TO_OPPONENTS_TYPE_ONLY,
}

const STATISTIC_DEFAULTS : Dictionary = { #[Statistic, Variant]
	# Basic
	Statistic.HEALTH : -1,
	Statistic.STRENGTH : -1,
	Statistic.SPEED : -1,
	Statistic.ENERGY : -1,
	Statistic.CHARGES : 0,
	Statistic.POSITION : Vector2.ZERO, # Vector type friendly version of null
	# State
	Statistic.IS_IN_HAND : false,
	Statistic.IS_ON_FIELD : false,
	Statistic.IS_IN_DECK : false,
	Statistic.IS_MARKED : false,
	Statistic.WAS_JUST_MARKED : false,
	Statistic.WAS_JUST_UNMARKED : false,
	Statistic.IS_FROZEN : false,
	Statistic.WAS_JUST_FROZEN : false,
	Statistic.WAS_JUST_UNFROZEN : false,
	Statistic.WAS_JUST_PLAYED : false,
	Statistic.WAS_JUST_BURNED : false,
	Statistic.WAS_JUST_DISCARDED : false,
	Statistic.JUST_ATTACKED : false,
	Statistic.WAS_JUST_ATTACKED : false,
	Statistic.WAS_JUST_ACTIVATED : false,
	Statistic.JUST_TARGETED : false,
	Statistic.WAS_JUST_TARGETED : false,
	Statistic.JUST_KILLED : false,
	Statistic.WAS_JUST_KILLED : false,
	Statistic.WAS_JUST_SACRIFICED : false,
	Statistic.HAS_TARGET : false,
	# References
	Statistic.TARGET : null,
	Statistic.MOST_RECENT_ATTACKED : null,
	Statistic.MOST_RECENT_ATTACKED_BY : null,
	Statistic.HAND_VISIBLE_PLAYERS : [],
	Statistic.DECK_TOPCARD_VISIBLE_PLAYERS : [],
	Statistic.CURRENT_COOLDOWNS : {},
	# Ability
	Statistic.CAN_ATTACK : true,
	Statistic.CAN_BE_ATTACKED : true,
	Statistic.CAN_BE_ACTIVATED : true,
	Statistic.CAN_TARGET : true,
	Statistic.CAN_TARGET_ATTACKERS : true,
	Statistic.CAN_TARGET_INSTANTS : true,
	Statistic.CAN_TARGET_SUPPORTS : true,
	Statistic.CAN_TARGET_SELF : false,
	Statistic.CAN_BE_TARGETED : true,
	Statistic.CAN_BE_TARGETED_OPPONENTS_ONLY : false,
	Statistic.CAN_BE_TARGETED_FRIENDLIES_ONLY : false,
	Statistic.CAN_BE_SACRIFICED : true,
	Statistic.CAN_HAVE_MOODS : true,
	Statistic.CAN_BE_KILLED : true,
	Statistic.ACTS_AS_BLOCKER : false,
	Statistic.ACTS_AS_UNMARKED : false,
	Statistic.IS_TRANSIENT : false,
	# Counts
	Statistic.NUM_ATTACKS_MADE : 0,
	Statistic.NUM_ATTACKS_RECIEVED : 0,
	Statistic.NUM_ACTIVATIONS : 0,
	Statistic.NUM_MOODS : 0,
	Statistic.NUM_MOOD_CHANGES : 0,
	# Player
	Statistic.MAX_HAND_SIZE : 10,
	Statistic.MAX_ENERGY : 10,
	Statistic.NUM_INSTANTS_PLAYED: 10,
	Statistic.NUM_CREATURES_PLAYED: 0,
	Statistic.NUM_SUPPORTS_PLAYED: 0,
	Statistic.NUM_CARDS_PLAYED: 0,
	Statistic.NUM_CARDS_DRAWN: 0,
	Statistic.NUM_CARDS_BURNED: 0,
	Statistic.NUM_CARDS : 0,
	Statistic.NUM_CARDS_MARKED_IN_DECK : 0,
	Statistic.NUM_CARDS_LEFT_IN_DECK: 0,
	Statistic.HAND_VISIBLE: false,
	Statistic.HAND_VISIBLE_TO_OPPONENTS: false,
	Statistic.HAND_VISIBLE_RARITY_ONLY: false,
	Statistic.HAND_VISIBLE_TYPE_ONLY: false,
	Statistic.HAND_VISIBLE_TO_OPPONENTS_RARITY_ONLY: false,
	Statistic.HAND_VISIBLE_TO_OPPONENTS_TYPE_ONLY: false,
	Statistic.DECK_TOPCARD_VISIBLE: false,
	Statistic.DECK_TOPCARD_VISIBLE_TO_OPPONENTS: false,
	Statistic.DECK_TOPCARD_VISIBLE_RARITY_ONLY: false,
	Statistic.DECK_TOPCARD_VISIBLE_TYPE_ONLY: false,
	Statistic.DECK_TOPCARD_VISIBLE_TO_OPPONENTS_RARITY_ONLY: false,
	Statistic.DECK_TOPCARD_VISIBLE_TO_OPPONENTS_TYPE_ONLY: false,
}
