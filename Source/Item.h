#import <Foundation/Foundation.h>

BOOL item_is_of_type(NSString *item_type, NSArray *type_array);

/*  Compact Structure:

	bit offset  size	field				conditionals
	+0000		2		unknown0_0
	+0002		3		location
	+0005		4		equip_position
	+0009		4		y_pos
	+000D		4		x_pos
	+0011		3		grid_page
	+0014		32		type
	+0034		1		gold_data			type = gold
				12		gold				type = gold
				1		super_guid_flag
				96		super_guid			super_guid_flag = 1

	Extended Structure:

	bit offset  size	field				conditionals
	+0000		2		unknown0_0
	+0002		3		location
	+0005		4		equip_position
	+0009		4		y_pos
	+000D		4		x_pos
	+0011		3		grid_page
	+0014		32		type
	+0034		3		num_gems
	+0037		32		guid
	+0057		7		drop_level
	+005E		4		quality
	+0062		1		graphic_flag
	+0063		3		graphic				graphic_flag = 1
				1		automagic_flag
				11		automagic_affix		automagic_flag = 1
				3		low_quality_subtype	quality = 1
				5		spell_id			quality = 2; type = any scroll or tome	(index into books.txt)
				10		monster_id			quality = 2; type = monster bodypart (index into monstats.txt)
				1		charm_affix_type	quality = 2; type = charm
				11		charm_affix			quality = 2; type = charm
				3		hi_quality_subtype	quality = 3
				11		macic_prefix		quality = 4
				11		magic_suffix		quality = 4
				12		set_id				quality = 5
				8		first_name			quality = 6 or 8
				8		second_name			quality = 6 or 8
				1		prefix1_flag		quality = 6 or 8
				11		prefix1				quality = 6 or 8 and prefix1_flag = 1
				1		suffix1_flag		quality = 6 or 8
				11		suffix1				quality = 6 or 8 and suffix1_flag = 1
				1		prefix2_flag		quality = 6 or 8
				11		prefix2				quality = 6 or 8 and prefix2_flag = 1
				1		suffix2_flag		quality = 6 or 8
				11		suffix2				quality = 6 or 8 and suffix2_flag = 1
				1		prefix3_flag		quality = 6 or 8
				11		prefix3				quality = 6 or 8 and prefix3_flag = 1
				1		suffix3_flag		quality = 6 or 8
				11		suffix3				quality = 6 or 8 and suffix3_flag = 1
				12		unique_id			quality = 7
				12		runeword_id			flags.runeword = 1
				4		runeword_data		flags.runeword = 1
				105		inscription			flags.inscribed = 1
				
				1		gold_data			type = gold
				12		gold_qty			type = gold
				1		super_guid_flag
				96		super_guid			super_guid_flag = 1
				
				11		defence				type = any armour
				8		durability_max		type = any armour or weapon (0 for indestructable items)
				9		durability			type = any armour or weapon; durability_max > 0
				9		quantity			type = stacked weapon, quiver of arrows/bolts, key or tome
				4		num_sockets			flags.socketed = 1
				1		plist1_flag			quality = 5
				1		plist2_flag			quality = 5
				1		plist3_flag			quality = 5
				1		plist4_flag			quality = 5
				1		plist5_flag			quality = 5
				9+		plist0
				9+		plist1				plist1_flag = 1
				9+		plist2				plist2_flag = 1
				9+		plist3				plist3_flag = 1
				9+		plist4				plist4_flag = 1
				9+		plist5				plist5_flag = 1
				9+		plist6				flags.runeword = 1

	Ear Structure:

	bit offset  size	field				conditionals
	+0000		2		unknown0_0
	+0002		3		location
	+0005		4		equip_position
	+0009		4		y_pos
	+000D		4		x_pos
	+0011		3		grid_page
	+0014		3		victim_class
	+0017		7		victim_level
	+001E		126		victim_name
*/

@interface Item : NSObject
{
	NSString *name;					// user-readable name for object, calculated last
	NSNumber *quest;
	NSNumber *unknown2_1;
	NSNumber *identified;
	NSNumber *unknown2_5;
	NSNumber *unknown3_0;
	NSNumber *duplicate;			// may be incorrect
	NSNumber *socketed;
	NSNumber *unknown3_4;
	NSNumber *unknown3_5;			// 1 on about half of items (trevin says "This bit is set on items which you have picked up since the last time the game was saved.") 1 on the golden bird given to me by meshif
	NSNumber *illegal;				// item appears red if equipped; may be incorrect
	NSNumber *unknown3_7;
	NSNumber *ear;
	NSNumber *starter;
	NSNumber *unknown4_2;
	NSNumber *compact;
	NSNumber *ethereal;
	NSNumber *unknown4_7;			// always 1 on items I've seen (visibility flag?)
	NSNumber *inscribed;
	NSNumber *unknown5_1;
	NSNumber *runeword;
	NSNumber *unknown5_3;
	NSNumber *version;				// 0, 1, 2, 100 & 101
	NSNumber *unknown7_0;
	NSNumber *location;				// 0 = grid; 1 = equipped; 2 = belt; 3 = ground; 4 = cursor; 5 = unknown; 6 = socket; 7 = unknown
	NSNumber *equip_position;		// if location = equipped: 1 = head; 2 = neck; 3 = torso; 4 = right hand; 5 = left hand; 6 = left finger; 7 = right finger; 8 = waist; 9 = feet; 10 = hands; 11 = alt right hand; 12 = alt left hand; otherwise 0
	NSValue *grid_position;			// xy-position if location = grid or belt (belt is treated as 1x16 grid); otherwise junk
	NSNumber *grid_page;			// if location = grid: 1 = inventory; 2 = unknown; 3 = unknown; 4 = cube; 5 = stash; otherwise 0
	
	// NON-EAR ITEMS (SIMPLE & EXTENDED) ONLY
	NSString *code;					// four 8-bit packed chars; item type (e.g. 'hax ' = hand axe)
	
	// EXTENDED ITEMS ONLY
	NSData *guid;
	NSNumber *drop_level;			// level of monster that dropped the item, chest that was opened, or char level of player who generated it (e.g. in horodric cube)
	NSNumber *quality;				// 1 = low; 2 = normal; 3 = high; 4 = magic; 5 = set; 6 = rare; 7 = unique; 8 = crafted
	NSNumber *graphic;
	NSNumber *automagic_affix;
	NSNumber *low_quality_subtype;
	NSNumber *spell_id;
	NSNumber *monster_id;
	NSNumber *charm_affix_type;		// 0: charm_affix = prefix; 1: charm_affix = suffix
	NSNumber *charm_affix;
	NSNumber *high_quality_subtype;	// ignored
	NSNumber *set_id;
	NSNumber *first_name;
	NSNumber *second_name;
	NSNumber *prefix1;
	NSNumber *suffix1;
	NSNumber *prefix2;
	NSNumber *suffix2;
	NSNumber *prefix3;
	NSNumber *suffix3;
	NSNumber *unique_id;
	NSNumber *runeword_id;
	NSNumber *runeword_data;			// trevin says this always seems to be 5
	NSString *inscription;
	
	// NON-EAR ITEMS (SIMPLE & EXTENDED) ONLY
	NSNumber *gold_data;
	NSNumber *gold_qty;
	NSData *super_guid;
	
	// EXTENDED ITEMS ONLY
	NSNumber *defence;
	NSNumber *durability_max;
	NSNumber *durability;
	NSNumber *quantity;
	NSNumber *num_sockets;
	NSMutableArray *properties;
	NSMutableArray *gems;
	
	// EAR ITEMS ONLY
	NSNumber *victim_class;
	NSNumber *victim_level;
	NSString *victim_name;
}
+ (Item *)item;
+ (Item *)itemWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
+ (NSMutableArray *)itemsFromList:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (id)initWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset;
- (NSData *)data;
- (void)setName;
- (NSString *)code;
- (void)setCode:(NSString *)value;
- (void)setID:(NSNumber *)value;
- (NSNumber *)uniqueness;
- (NSNumber *)quality;
- (NSArray *)properties;
@end