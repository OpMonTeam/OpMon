extends Node

# File containing several enumerations used in the different objects

enum Type {	NONE = 18,
			LIQUID = 3,
			BURNING = 6,
			VEGETAL = 10,
			ELECTRON = 4,
			MENTAL = 12,
			BAD = 16,
			DRAGON = 2,
			FIGHT = 1,
			MINERAL = 13,
			GROUND = 14,
			NEUTRAL = 9,
			MAGIC = 5,
			GHOST = 15,
			TOXIC = 11,
			METAL = 0,
			BUG = 8,
			SKY = 17,
			COLD = 7 }
			
enum Status {
			BURNING,
			PARALYSED,
			SLEEPING,
			FROZEN,
			POISONED,
			NOTHING }
			
enum Stats {
			ATK = 0,  
			DEF = 1,
			ATKSPE = 2,
			DEFSPE = 3,
			SPE = 4,
			HP = 5,
			ACC = 6,
			EVA = 7,
			NOTHING = -1 }
	
# Enumerates the categories available for the bag. Their associated number defines
# the order in which they appear in the bag interface.
enum BagCategory {
	BATTLE = 0, # Items that can be used in battle (except balls)
	BALLS = 1, # "Balls" that can capture OpMons (the name might be changed later in the development)
	HELD = 2, # Items that have an effect when held
	OTHER = 3, # This one might be renamed later, will at least contain a repel equivalent
	KEY = 4 # Key items for the adventure
}

# Array of effectiveness : TYPE_EFFECTIVENESS[TYPE_1][TYPE_2] gives the effectiveness of
# a move of type TYPE_1 on an OpMon of type TYPE_2.
const TYPE_EFFECTIVENESS = [[0.5, 2.0, 0.5, 1.0, 1.0, 0.5, 2.0, 0.5, 0.5, 0.5, 0.5, 0.0, 0.5, 0.5, 2.0, 1.0, 1.0, 0.5, 1.0],
							[1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 0.5, 2.0, 1.0],
							[1.0, 1.0, 2.0, 0.5, 0.5, 2.0, 0.5, 2.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
							[0.5, 1.0, 1.0, 0.5, 2.0, 1.0, 0.5, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
							[0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 1.0],
							[2.0, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0],
							[0.5, 1.0, 1.0, 2.0, 1.0, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0],
							[2.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0],
							[1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 2.0, 1.0],
							[1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0],
							[1.0, 1.0, 1.0, 0.5, 0.5, 1.0, 2.0, 2.0, 2.0, 1.0, 0.5, 2.0, 1.0, 1.0, 0.5, 1.0, 1.0, 2.0, 1.0],
							[1.0, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 0.5, 1.0, 0.5, 0.5, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
							[1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 2.0, 2.0, 0.5, 1.0],
							[2.0, 2.0, 1.0, 2.0, 1.0, 1.0, 0.5, 1.0, 1.0, 0.5, 2.0, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 0.5, 1.0],
							[1.0, 1.0, 1.0, 2.0, 0.0, 1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 0.5, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0],
							[1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, 1.0, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0],
							[1.0, 2.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0],
							[1.0, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 0.5, 1.0, 0.5, 1.0, 1.0, 2.0, 0.0, 1.0, 1.0, 1.0, 1.0],
							[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]]

# Associative array containing named move animation sequences
const MOVE_ANIMATIONS = {

	# Example and notes
	# This move will have an animation in 2 parts:
	# 	1. Mon will rotate and scale at the same time, then rotate and scale back to original transform values
	# 	2. Mon will scale only, then revert back
	# "MOVE_NAME" :
	# 	[[{"transform":"ROTATE","value":10,"speed":10},
	# 		{{"transform":"SCALE","value":Vector2(1.3,1.3),"speed":10}}],
	# 	[{"transform":"SCALE","value":Vector2(1.3,1.3),"speed":10}]]

	# Default animation (no animation)
	"NONE":
		[[]]

	# Basic animations that are easy to combine
	,"NOD":
		[[{"transform":"ROTATE","value":10,"speed":10}]]
	,"JUMP":
		[[{"transform":"TRANSLATE","value":Vector2(0,-30),"speed":10}]]
	,"DIP":
		[[{"transform":"TRANSLATE","value":Vector2(0,30),"speed":10}]]
	,"SCOOT":
		[[{"transform":"TRANSLATE","value":Vector2(30,0),"speed":10}]]
	,"PULSE":
		[[{"transform":"SCALE","value":Vector2(1.3,1.3),"speed":10}]]

	# Variations on the basics
	,"BIG_NOD":
		[[{"transform":"ROTATE","value":15,"speed":10},
			{"transform":"SCALE","value":Vector2(1.1,1.1),"speed":10},
			{"transform":"TRANSLATE","value":Vector2(10,0),"speed":10}]]
	,"SLOW_DOUBLE_DIP":
		[[{"transform":"TRANSLATE","value":Vector2(0,30),"speed":5}],
		[{"transform":"TRANSLATE","value":Vector2(0,30),"speed":5}]]
	,"PULSE_THEN_SCOOT":
		[[{"transform":"SCALE","value":Vector2(1.3,1.3),"speed":10}],
		[{"transform":"TRANSLATE","value":Vector2(30,0),"speed":10}]]
	,"PULSING_SCOOT":
		[[{"transform":"SCALE","value":Vector2(1.3,1.3),"speed":10},
			{"transform":"TRANSLATE","value":Vector2(30,0),"speed":10}]]
	,"SLOW_DIP_THEN_SCOOT":
		[[{"transform":"TRANSLATE","value":Vector2(0,30),"speed":5}],
		[{"transform":"TRANSLATE","value":Vector2(30,0),"speed":10}]]
	,"SWAY":
		[[{"transform":"TRANSLATE","value":Vector2(-30,0),"speed":5}],
		[{"transform":"TRANSLATE","value":Vector2(30,0),"speed":5}]]
	}
