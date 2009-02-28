#import <Cocoa/Cocoa.h>
#import "structs.h"

enum d2s_class_scripting
{
	kClassScriptAmazon		= FOUR_CHAR_CODE('cAma'),
	kClassScriptAssassin	= FOUR_CHAR_CODE('cAss'),
	kClassScriptBarbarian	= FOUR_CHAR_CODE('cBar'),
	kClassScriptDruid		= FOUR_CHAR_CODE('cDru'),
	kClassScriptNecromancer	= FOUR_CHAR_CODE('cNec'),
	kClassScriptPaladin		= FOUR_CHAR_CODE('cPal'),
	kClassScriptSorceress	= FOUR_CHAR_CODE('cSor')
};

// male = 0; female = 1 (can be passed as gender to title_names below)
const int class_genders[7] = { 1, 1, 0, 0, 0, 0, 1 };
const int merc_class_genders[4] = { 1, 0, 0, 0 };

// expansion (0/1), hardcore (0/1), gender (0/1), difficulty (0-2)
const char * const title_names[2][2][2][3] = {
{{{ "Sir", "Lord", "Baron" },
  { "Dame", "Lady", "Baroness" }},
 {{ "Count", "Duke", "King" },
  { "Countess", "Duchess", "Queen" }}},
{{{ "Slayer", "Champion", "Patriarch" },
  { "Slayer", "Champion", "Matriarch" }},
 {{ "Destroyer", "Conqueror", "Guardian" },
  { "Destroyer", "Conqueror", "Guardian" }}}};

// from data/global/excel/experience.txt
unsigned long level_for_experience(unsigned long exp);
const unsigned long experience_for_level[] = { 0, 0, 500, 1500, 3750, 7875, 14175, 22680, 32886, 44396, 57715, 72144, 90180, 112725, 140906, 176132, 220165, 275207, 344008, 430010, 537513, 671891, 839864, 1049830, 1312287, 1640359, 2050449, 2563061, 3203826, 3902260, 4663553, 5493363, 6397855, 7383752, 8458379, 9629723, 10906488, 12298162, 13815086, 15468534, 17270791, 19235252, 21376515, 23710491, 26254525, 29027522, 32050088, 35344686, 38935798, 42850109, 47116709, 51767302, 56836449, 62361819, 68384473, 74949165, 82104680, 89904191, 98405658, 107672256UL, 117772849UL, 128782495UL, 140783010UL, 153863570UL, 168121381UL, 183662396UL, 200602101UL, 219066380UL, 239192444UL, 261129853UL, 285041630UL, 311105466UL, 339515048UL, 370481492UL, 404234916UL, 441026148UL, 481128591UL, 524840254UL, 572485967UL, 624419793UL, 681027665UL, 742730244UL, 809986056UL, 883294891UL, 963201521UL, 1050299747UL, 1145236814UL, 1248718217UL, 1361512946UL, 1484459201UL, 1618470619UL, 1764543065UL, 1923762030UL, 2097310703UL, 2286478756UL, 2492671933UL, 2717422497UL, 2962400612UL, 3229426756UL, 3520485254UL, 3837739017UL };

// not sure where these come from
inline unsigned long max_carried_gold_for_level(unsigned int level) { return 10000 * level; };
const unsigned long max_stashed_gold_for_level[] = { 50000, 50000, 50000, 50000, 50000, 50000, 50000, 50000, 50000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 150000, 150000, 150000, 150000, 150000, 150000, 150000, 150000, 150000, 150000, 200000, 800000, 850000, 850000, 900000, 900000, 950000, 950000, 1000000, 1000000, 1050000, 1050000, 1100000, 1100000, 1150000, 1150000, 1200000, 1200000, 1250000, 1250000, 1300000, 1300000, 1350000, 1350000, 1400000, 1400000, 1450000, 1450000, 1500000, 1500000, 1550000, 1550000, 1600000, 1600000, 1650000, 1650000, 1700000, 1700000, 1750000, 1750000, 1800000, 1800000, 1850000, 1850000, 1900000, 1900000, 1950000, 1950000, 2000000, 2000000, 2050000, 2050000, 2100000, 2100000, 2150000, 2150000, 2200000, 2200000, 2250000, 2250000, 2300000, 2300000, 2350000, 2350000, 2400000, 2400000, 2450000, 2450000, 2500000, 2500000 };

const unsigned int skill_map[7][30] = {				// maps order in save file to skill number for display
{20,21,10,11,0,22,23,12,1,2,24,13,14,3,4,25,26,15,5,6,27,28,16,17,7,29,18,19,8,9},
{20,21,10,0,1,22,11,12,2,3,23,24,13,14,4,25,26,15,16,5,27,17,18,6,7,28,29,19,8,9},
{20,10,11,0,1,21,22,12,13,2,23,24,14,3,4,25,26,15,16,5,27,28,17,6,7,29,18,19,8,9},
{20,21,10,0,1,22,11,12,2,3,23,24,13,4,5,25,26,14,15,6,27,28,16,17,7,29,18,19,8,9},
{20,10,11,12,0,1,21,22,13,14,15,2,3,23,24,16,4,25,26,17,5,27,18,6,7,28,29,19,8,9},
{20,21,10,11,0,22,23,12,1,2,24,13,14,3,4,25,26,15,16,5,27,17,18,6,7,28,29,19,8,9},
{20,10,11,0,1,21,22,12,2,3,23,24,13,14,4,25,15,16,5,26,27,17,6,7,28,29,18,8,19,9}};

const unsigned int reverse_skill_map[7][3][10] = {	// maps tree & skill number from display to order in save file
{{4,8,9,13,14,18,19,24,28,29}, {2,3,7,11,12,17,22,23,26,27}, {0,1,5,6,10,15,16,20,21,25}},		// amazon
{{3,4,8,9,14,19,23,24,28,29}, {2,6,7,12,13,17,18,21,22,27}, {0,1,5,10,11,15,16,20,25,26}},		// sorceress
{{3,4,9,13,14,19,23,24,28,29}, {1,2,7,8,12,17,18,22,26,27}, {0,5,6,10,11,15,16,20,21,25}},		// necromancer
{{3,4,8,9,13,14,19,24,28,29}, {2,6,7,12,17,18,22,23,26,27}, {0,1,5,10,11,15,16,20,21,25}},		// paladin
{{4,5,11,12,16,20,23,24,28,29}, {1,2,3,8,9,10,15,19,22,27}, {0,6,7,13,14,17,18,21,25,26}},		// barbarian
{{4,8,9,13,14,19,23,24,28,29}, {2,3,7,11,12,17,18,21,22,27}, {0,1,5,6,10,15,16,20,25,26}},		// druid
{{3,4,8,9,14,19,23,24,28,29}, {1,2,7,12,13,16,17,22,27,28}, {0,5,6,10,11,15,20,21,25,26}}};		// assassin
/*
const char * const tree_names[7][3] = {
{"Javelin & Spear", "Passive & Magic", "Bow & Crossbow"},
{"War Cries", "Combat Masteries", "Combat Skills"},
{"Summoning", "Poison & Bone", "Curses"},
{"Defensive Auras", "Offensive Auras", "Combat Skills"},
{"Cold Spells", "Lightning Spells", "Fire Spells"},
{"Martial Arts", "Shadow Disciplines", "Traps"},
{"Elemental", "Shape Shifting", "Summoning"}};

const unsigned int skill_req_level[7][30] = {
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,30,30,30,30,30},	// amazon
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,30,30,30,30,30},	// sorceress
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,24,30,30,30,30},	// necromancer
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,30,30,30,30,30},	// paladin
{1,1,1,1,1,1,6,6,6,6,6,6,6,12,12,12,12,18,18,18,18,24,24,24,24,30,30,30,30,30},		// barbarian
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,30,30,30,30,30},	// druid
{1,1,1,1,1,6,6,6,6,6,12,12,12,12,12,18,18,18,18,18,24,24,24,24,24,30,30,30,30,30}};	// assassin
*/
#define numberof(array) (const short)(sizeof(array)/sizeof(array[0]))

@class Item, Mercenary;

/*!
    @class		CharacterDocument
    @abstract   An NSDocument subclass representing a .d2s character.
    @discussion Discussion forthcoming.
*/
@interface CharacterDocument : NSDocument
{
	// header variables
	NSNumber *unknown10;
	NSString *name;
	NSNumber *newChar;
	NSNumber *unknown24_1;
	NSNumber *hardcore;
	NSNumber *died;
	NSNumber *unknown24_4;
	NSNumber *expansion;
	NSNumber *unknown24_6;  // sloan says this bit is for ladder characters
	NSNumber *unknown24_7;
	NSNumber *title;
	NSNumber *unknown25_5;
	NSNumber *selectedWeapon;
	NSNumber *characterClass;
	NSNumber *unknown29;
	NSNumber *unknown30;
	NSNumber *selectionLevel;
	NSDate   *createdTimestamp;
	NSDate   *modifiedTimestamp;
	NSNumber *unknown34;
	NSNumber *hotkey[20];
	NSNumber *hotkey_b[20];
	NSNumber *appearance[2][16];
	NSNumber *currentAct;
	NSNumber *currentDifficulty;
	NSNumber *mapSeed;
	Mercenary *mercenary;
	NSMutableData *unknownBF;
	
	// primary data arrays
	NSMutableArray *difficulties;
	NSMutableArray *stats;
	NSMutableArray *skills;
	NSMutableArray *items;
	NSMutableArray *corpses;
	Item *golemItem;
	
	// gui stuff
	IBOutlet NSArrayController *itemsArrayController;
	IBOutlet NSTableView *itemTable;
	IBOutlet NSPopUpButton *itemPopup;
	IBOutlet NSTabView *mainTabs;
	IBOutlet NSTableView *legitTable;
	
	// unsaved variables
	NSNumber *selectedDifficulty;	// pop-up menu
	BOOL	  itemEnhancedStats;
	BOOL	  filterSkills;
	BOOL	  maintainLegitimacy;	// editing values should cause dependant values to change too
}

- (BOOL)validateCharacterForSave;
- (void)readHeaderWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readQuestsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readWaypointsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readNPCsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readStatsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readSkillsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readItemsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readCorpsesWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readMercItemsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (void)readGolemWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
@end