/* NOTES TO SELF:

These structures store all values in little-endien format. You must convert to/from little endien when reading and storing multi-byte values into this structure.
I ought to wrap these in a class that does that automatically.
A little clarification of charatcter descriptions used:
	ultra-newbie:   character created but never "save & exited" (i.e. by force-quitting the game) - saves a d2s_header structure - this is the minimum known file structure allowed
	newbie:			character created then immediatly "save & exited". Woo!, WS, .w, gf and JM fields get added.

*/

// file format version numbers 
enum d2s_version
{
	kVersion106 = 71,   // all previous public versions of diablo 2 used this format
	kVersion107 = 87,
	kVersion108e = 87,  // 1.08 expansion (same as 1.07)
	kVersion108n = 89,  // 1.08 normal
	kVersion109 = 92,
	kVersion110 = 96
};

// class values as stored in character file
enum d2s_class
{
	kClassAmazon = 0,
	kClassSorceress,
	kClassNecromancer,
	kClassPaladin,
	kClassBarbarian,
	kClassDruid,
	kClassAssassin
};

// basic header structure compleatly describing an ultra-newbie character
struct d2s_header
{
	unsigned char magic[4];					// "UªUª" (0x55AA55AA)
	unsigned long version;					// enum d2s_version
	unsigned long length;					// length of whole file
	unsigned long checksum;					// set this to 0 before computing it!
	unsigned long unknown10;				// zero (or sometimes 1)
	         char name[16];					// null-terminated character name
	unsigned char unknown24_7:1;			// zero
	unsigned char unknown24_6:1;			// !! causes game to fail to load if set to 1 !!	  // sloan says this bit is for ladder characters
	unsigned char expansion:1;				// expansion char
	unsigned char unknown24_4:1;			// zero
	unsigned char died:1;					// player has died at some point before (makes hc chars unplayable)
	unsigned char hardcore:1;				// player is hardcore
	unsigned char unknown24_1:1;			// zero
	unsigned char newChar:1;				// 1 if character has never been loaded (ultra-newbie - only d2s_header present in file)
	unsigned char unknown25_5:3;			// zero
	unsigned char title:3;					// 0 = no title; 1 = slayer; 2 = champion; 3+ = patriarch etc.
	unsigned char unknown25_0:2;			// zero
	unsigned short selected_weapon;			// selected weapon/shield set (either 0 or 1) for expansion chars, zero in normal chars
	unsigned char char_class;				// enum d2s_class
	unsigned char unknown29;				// 16 (0x10)
	unsigned char unknown30;				// 30 (0x1E) - if any other value, char fails to load with "bad inventory data"
	unsigned char level;					// level as shown on character selection screen
	unsigned long createdTimestamp;			// zero for files that have been played & saved; this could actually be "saved_timestamp"; (possibly non-zero on b.net, used for char expiration?)
	unsigned long modifiedTimestamp;		// never zero; this could actually be "loaded_timestamp" - need to play a char for a while
	signed long unknown34;					// zero for ultra-newbie; otherwise -1
	struct {
		signed short skill;					// low 15 bits = skill ID; 16th bit either 1 or 0, unknown use; -1 if no action assigned
		signed short unknown2;				// always 0
	} actions[20];							// 16 fkeys, left mouse, right mouse, alt left mouse, alt right mouse
	struct {
		signed char head;
		signed char torso;
		signed char legs;
		signed char rightArm;
		signed char leftArm;
		signed char rightHand;
		signed char leftHand;				// leftHand & shield are mutually exclusive - at least one must be -1
		signed char shield;
		signed char rightShoulder;
		signed char leftShoulder;
		signed char unknown0A[6];
	} appearance[2];						// first array is base graphic, second array is tint colour
	unsigned char currentAct[3];			// low 7-bits = 0-4 depending on act + bit 7 set on byte to read; one byte per difficulty level
	unsigned long map_seed;					// a seed value for randomising the maps, also saved to .map file, specifying a MA0-MA3 file to use
	struct {
//		unsigned char unknown0_0:8;			// zero
//		unsigned char unknown1_0:8;			// zero
//		unsigned char unknown2_1:7;			// zero
		unsigned long unknown0_0:23;		// zero
		unsigned char dead:1;				// set to 1 when your merc is dead, cleared when merc is resurrected (unlike character dead flag, which is never cleared)
		unsigned char unknown3_0:8;			// zero
		unsigned long merc_ai;				// random value? (controlling merc behaviour perhaps?)
		unsigned short name;				// index into a string table somewhere (hireling.txt ?)
		unsigned short type;				// http://www.xmission.com/~trevin/DiabloIIv1.09_Mercenaries.html#code
		unsigned long experience;			// integer
	} __attribute__ ((packed)) mercenary;
	unsigned char unknownBF[144];			// zeroes
} __attribute__ ((packed));

// act description
struct d2s_act
{
	unsigned short introduced;	// set to 1 when introduced to act
	struct {
		unsigned char bit7:1;
		unsigned char bit6:1;
		unsigned char bit5:1;
		unsigned char bit4:1;
		unsigned char bit3:1;
		unsigned char received:1;			// bit 2
		unsigned char requirements_met:1;	// bit 1
		unsigned char complete:1;			// bit 0
		unsigned char bit15:1;
		unsigned char bit14:1;
		unsigned char done_recently:1;		// bit 13 (compleated in current game - or does it mean compleated in previous game?)
		unsigned char closed:1;				// bit 12 (swirling fire animation seen)
		unsigned char bit11:1;
		unsigned char bit10:1;
		unsigned char bit9:1;
		unsigned char bit8:1;
	} __attribute__ ((packed)) quest[6];
	unsigned short completed;	// taken necessary action to advance to next act
} __attribute__ ((packed));

// acts structure
struct d2s_acts
{
	unsigned char magic[4];		// "Woo!" (0x576F6F21)
	unsigned long version;		// always 6
	unsigned short length;		// always 298 (0x012A); length of whole d2s_quests structure
	struct {
		struct d2s_act act[4];
		unsigned short talked_to_cain_in_act_IV;
		unsigned short unknown4C;
		struct d2s_act act_5;
		unsigned short unknown5E[6];	// all zeroes
	} difficulty[3];					// one structure per difficulty level
} __attribute__ ((packed));

struct d2s_waypoints
{
	unsigned char magic[2];		// "WS" (0x5753)
	unsigned long version;		// always 1
	unsigned short length;		// always 80 (0x5000); length of whole d2s_waypoints structure
	struct {
		unsigned char unknown0[2];			// {2, 1} (258 as a swapped decimal short)
		unsigned char waypoints[22];		// least significant bit is first waypoint of act 1 and is always set (even for acts you've not reached)
											// continues consecutively to bit 29 = last waypoint of act 4 (9 each in acts 1-3, 3 in act 4), and bit 30 = first waypoint of act 5
											// first waypoint in acts 2-5 set automatically as soon as that act is entered
	} __attribute__ ((packed)) difficulty[3];// one structure per difficulty level
} __attribute__ ((packed));

// eight bytes of NPC flags
struct d2s_npc_list
{
	char warriv_act2:1;
	char unknown0_6:1;		// cain_act1?
	char charsi:1;
	char warriv_act1:1;
	char kashya:1;
	char akara:1;
	char gheed:1;
	char unknown0_0:1;		// cain_act1?
	char greiz:1;
	char jerhyn:1;
	char meshif_act2:1;
	char geglash:1;
	char lysander:1;
	char fara:1;
	char drognan:1;
	char unknown1_0:1;		// atma?
	char alkor:1;
	char hratli:1;
	char asheara:1;
	char unknown2_4:1;
	char unknown2_3:1;
	char cain_act3:1;
	char unknown2_1:1;		// cain_act2?
	char elzix:1;
	char malah:1;
	char anya:1;			// drehay?
	char unknown3_5:1;		// larzuk?
	char natalya:1;
	char meshif_act3:1;
	char unknown3_2:1;
	char unknown3_1:1;
	char ormus:1;
	char unknown4_3:5;
	char cain_act5:1;
	char qualkehk:1;
	char nihlathak:1;
	long unknown5:24;
} __attribute__ ((packed));

struct d2s_npcs
{
	// trivia note: a lot of people call this the 'w4' structure, and incorrectly think the 0x01 byte belongs to the previous structure :-)
	unsigned char magic[2];					// ".w" (0x0177)
	unsigned short length;					// always 52; length of whole d2s_npcs structure (52 = 0x34, i.e. '4' - giving the 'w4' false header identifier)
	struct d2s_npc_list introductions[3];	// npc introduces him/herself if bit is clear
	struct d2s_npc_list congratulations[3];	// npc congratulated you for killing boss on that act (all bits are set when moving to next act anyway); each bit is then *cleared* when you return to the act and are welcomed back by that NPC
} __attribute__ ((packed));

struct d2s_skills
{
	unsigned char magic[2];		// "if" (0x0x6966)
	unsigned char skill[30];	// base skill level
} __attribute__ ((packed));

/*
	// vital stats
	16		magic;			// "gf" (0x6766)
	0+		plist;			// 9-bit keys followed by variable-bit data (same format as item property lists)
	
	// skills
	16		magic;			// "if" (0x6966)
	240		skills;			// one byte per skill
	
	// item list
	16		magic;			// "JM" (0x4A4D)
	16		item_count;
	0+		items;
	
	// corpse list
	16		magic;			// "JM" (0x4A4D)
	16		corpse_count;	// D2 only saves one corpse when writing to disk
	0+		corpses;
	
	// corpse
	32		unknown0;		// set to uninitalised local variable by D2, possibly used to be the map this corpse is on (ignored)
	32		y_pos;			// y-position of corpse on map (ignored)
	32		x_pos;			// x-position of corpse on map (ignored)
	0+		item_list;
	
	// merc items
	16		magic;			// "jf" (0x6A66)
	0+		item_list;
	
	// golem
	16		magic;			// "kf" (0x6B66)
	1		data;			// one bit, a zero or one, indicating the presence of a following d2s_item
	0+		item;
*/

/*! .BIN FILE STRUCTURES */

// structures common to several bin files
typedef struct {
	signed long code;   // -1 for unused property
	long param;
	long min;
	long max;
} __attribute__ ((packed)) property_desc;

// data/global/excel formats
struct armtype_bin
{
	long entries;
	struct {
		char name[32];
		char code[4];
		long unknown[4];
	} __attribute__ ((packed)) armour_type[];
} __attribute__ ((packed));

struct bodylocs_bin
{
	long entries;
	struct {
		char code[4];
	} __attribute__ ((packed)) bodyloc[];
} __attribute__ ((packed));

struct books_bin
{
	long entries;
	struct {
		short unknown;			// always 0x0915 = 5385
		signed short spell_icon;
		long p_spell;
		signed long scroll_spell_id;	// -1 for invalid
		signed long book_spell_id;		// -1 for invalid
		long base_cost;
		long cost_per_charge;
		char scroll_item_code[4];		// padded with spaces
		char book_item_code[4];			// padded with spaces
	} __attribute__ ((packed)) book[];
} __attribute__ ((packed));

struct charstats_bin
{
	long entries;
	struct {
		long unknown1[8];	// always all 0
		char name[16];
		char strength;
		char dexterity;
		char energy;
		char vitality;
		char stamina;
		char hpadd;
		char percent_strength;
		char percent_energy;
		char percent_dexterity;
		char percent_vitality;
		short mana_regen;
		long to_hit;
		char walk_speed;
		char run_speed;
		char run_drain;
		char life_per_level;		// in fourths
		char stamina_per_level;		// in fourths
		char mana_per_level;		// in fourths
		char life_per_vitality;		// in fourths
		char stamina_per_vitality;	// in fourths
		char mana_per_energy;		// in fourths
		char block_factor;
		short unknown;  // 4-byte alignment?
		char base_weap_class[4];
		short stat_per_level;
		short unknown2;  //  all_skills_desc? index into tbl file?
		short unknown3;  //  skilltab1_desc?
		short unknown4;  //  skilltab2_desc?
		short unknown5;  //  skilltab3_desc?
		short unknown6;  //  class_only_desc?
		struct {
			char item_code[4];  // '0   ' (0x30202020) for unused items
			char body_loc;		// index into bodylocs_dat.location[]
			char count;
			short unknown1;
		} __attribute__ ((packed)) starter_items[10];
		signed short start_skill_id;
		signed short skill_id[10];
		signed short unknown7;   // always 0 
	} __attribute__ ((packed)) charstat[];
} __attribute__ ((packed));

struct colors_bin
{
	long entries;
	struct {
		char code[4];
	} __attribute__ ((packed)) transform[];
} __attribute__ ((packed));

struct elemtypes_bin
{
	long entries;
	struct {
		char code[4];
	} __attribute__ ((packed)) elemental[];
} __attribute__ ((packed));

struct experience_bin
{
	long entries;
	struct {
		unsigned long value[7];	// count of player classes, hardcoded otherwise it won't compile :-/
	} __attribute__ ((packed)) exp[];
} __attribute__ ((packed));

struct gems_bin
{
	long entries;
	struct {
		char name[32];
		char rune[8];
		short unknown1;  // index into tbl?
		long unknown2;   // always 0
		char num_mods;
		char transform;
		property_desc weapon_mods[3];
		property_desc helm_mods[3];
		property_desc shield_mods[3];
	} __attribute__ ((packed)) gem[];
} __attribute__ ((packed));

// covers both magicprefix & magicsuffix
struct magicaffix_bin
{
	long entries;
	struct {
		char name[32];
		char unknown[112];
	} __attribute__ ((packed)) playerclass[];
} __attribute__ ((packed));

struct playerclass_bin
{
	long entries;
	struct {
		char code[4];   // e.g. 'ama '
	} __attribute__ ((packed)) playerclass[];
} __attribute__ ((packed));

struct qualityitems_bin
{
	long entries;
	struct {
		char armour;	// following chars are all bools
		char weapon;
		char shield;
		char thrown;	// thrown/scepter   - there are four values for five columns here, all identical
		char scepter;   // scepter/wand
		char staff;		// wand/staff
		char bow;		// staff/bow
		char boots;
		char gloves;
		char belt;
		short num_mods;
		property_desc mods[2];
		char effect1[32];
		char effect2[32];
		long unknown;   // always 0
	} __attribute__ ((packed)) high_quality_item[];
} __attribute__ ((packed));

// covers both rareprefix & raresuffix
struct rareaffix_bin
{
	long entries;
	struct {
		char unknown[72];
	} __attribute__ ((packed)) playerclass[];
} __attribute__ ((packed));

struct sets_bin
{
	long entries;
	struct {
		short index;
		short unknown1; // name entry in tbl files? level? 0xB009 = 2480
		long version;
		long unknown2;
		long unknown3;
		property_desc mods[2][8];
		long unknown4[6];
	} __attribute__ ((packed)) set[];
} __attribute__ ((packed));

struct setitems_bin
{
	long entries;
	struct {
		short unknown1;
		char name[38];  // size is maximum, may be 32 with 6 unknown bytes after?
		char item_code[4];
		long set;  // index into sets_bin.set[]
		short level;
		short level_req;
		long rarity;
		long cost_mult;
		long cost_add;
		signed char transform;		// -1 if unused
		signed char inv_transform;  // -1 if unused
		short unknown2;
		short unknown3[17];
		property_desc mods[9];
		property_desc mods2[5][2];
	} __attribute__ ((packed)) setitem[];
} __attribute__ ((packed));

struct skills_bin
{
	long entries;
	struct {
		long index;
		long unknown1[2];
		signed char charclass;		// -1 if no associated class
		char unknown2[3];
		long unknown3[140];
	} __attribute__ ((packed)) skill[];
} __attribute__ ((packed));

// covers uniqueprefix & uniquesuffix files
struct uniqueaffix_bin
{
	long entries;
	struct {
		short index;	// index into tbl file?
	} __attribute__ ((packed)) affix[];
} __attribute__ ((packed));
