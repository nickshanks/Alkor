#import "Item.h"
#import "Property.h"
#import "AppDelegate.h"
#import "CharacterDocument.h"

#include <stdio.h>
#include "bits.h"
#import "Localization.h"
#import "PropertyLists.h"

extern globals g;
extern NSArray *armour, *weapons, *misc, *itemTable;
extern NSArray *bodypartCodes, *charmCodes, *spellCodes, *stackableCodes;
extern NSArray *automagic, *lowqualityitems, *magicprefix, *magicsuffix, *magicaffix, *rareaffix, *setitems, *uniqueitems;

// C routines
inline BOOL item_is_of_type(NSString *item_type, NSArray *type_array)
{
	return ([type_array indexOfObject:item_type] != NSNotFound);
}

@implementation Item
+ (Item *)item
{
	return [[[Item alloc] init] autorelease];
}

+ (Item *)itemWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	return [[[Item alloc] initWithBytes:data bitOffset:bit_offset] autorelease];
}

+ (NSMutableArray *)itemsFromList:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	NSParameterAssert(data != NULL);
	NSParameterAssert(bit_offset != NULL);
	
	// check for item list 'JM' header
	short magic = CFSwapInt16LittleToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'JM');
	
	// add items to array
	NSMutableArray *items = [NSMutableArray array];
	short num_items = read_bits(data, bit_offset, 16);
	for (int i = 0; i < num_items; i++)
		[items addObject:[Item itemWithBytes:data bitOffset:bit_offset]];
	return items;
}

- (id)init
{
	self = [super init];
	if (!self) return nil;
	// new item being created, set values to defaults
	code			= @"hp1";
	compact			= [[NSNumber alloc] initWithBool:true];
	location		= [[NSNumber alloc] initWithUnsignedChar:0];
	grid_position	= [[NSValue valueWithPoint:NSMakePoint(0,0)] retain];
	grid_page		= [[NSNumber alloc] initWithUnsignedChar:1];
	version			= [[NSNumber alloc] initWithUnsignedChar:101];
	properties		= [[NSMutableArray alloc] init];
	for (int i = 0; i < 7; i++)
		[properties addObject:[NSMutableArray array]];
	[self setName];
	return self;
}

- (id)initWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	if (!data || !bit_offset)
		return [self init];
	self = [super init];
	if (!self) return nil;
	
	unsigned long start_offset = *bit_offset/8;
	short magic = read_bits(data, bit_offset, 16);
	if (magic != CFSwapInt16LittleToHost('JM'))
	{
		NSLog(@"Item doesn't begin with 'JM'");
		Debugger();
	}
	quest =				[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// quest item (does this cause "cannot be sold here" ?)
	unknown2_1 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
	identified =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// has been identified
	unknown2_5 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
	unknown3_0 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 2)];
	duplicate =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// may be incorrect
	socketed =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	unknown3_4 =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	unknown3_5 =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// always 1 on items I've seen (trevin says "This bit is set on items which you have picked up since the last time the game was saved.")
	illegal =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// item appears red if equipped; may be incorrect
	unknown3_7 =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	ear =				[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// mutually exclusive with simple_item
	starter =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// buy, sell & repair all cost 1 gold
	unknown4_2 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
	compact =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// mutually exclusive with ear
	ethereal =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	unknown4_7 =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// always 1 on items I've seen
	inscribed =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	unknown5_1 =		[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];	// sloan says 'causes bad inv data if set to 1'
	runeword =			[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
	unknown5_3 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 5)];
	version =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 8)];	// 0 = pre-1.08; 1 = 1.08/1.09 normal; 2 = 1.10 normal; 100 = 1.08/1.09 expansion; 101 = 1.10 expansion
	unknown7_0 =		[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 2)];
	location =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
	equip_position =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 4)];
	int y =														read_bits(data, bit_offset, 4);
	int x =														read_bits(data, bit_offset, 4);
	grid_position =		[[NSValue valueWithPoint:NSMakePoint(x,y)] retain];
	grid_page =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];

	// NON-EAR ITEMS (SIMPLE & EXTENDED) ONLY
	if (![ear boolValue])
	{
		unsigned char num_gems = 0;
		unsigned char plist_flags = 0;
//		unsigned char tempchar = 0;
		unsigned long templong = CFSwapInt32LittleToHost(read_bits(data, bit_offset, 32));
		code = [[NSString alloc] initWithCString:(char *)&templong length:3];	// contains first 3 chars only (i.e. excludes space char)
	
		// EXTENDED ITEMS ONLY
		if (![compact boolValue])
		{
			plist_flags |= 1 << 0;
			num_gems =														read_bits(data, bit_offset, 3);
			templong =														read_bits(data, bit_offset, 32);
			guid =					[[NSData alloc] initWithBytes:&templong length:4];
			drop_level =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 7)];
			quality =				[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 4)];
			// items with different graphics (e.g. rings & amulets) specify the image to be used here
			if (read_bits(data, bit_offset, 1))
				graphic =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
			// "automagic" (index into automagic.txt?)
			if (read_bits(data, bit_offset, 1))
				automagic_affix =   [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
			
			// quality info
			switch ([quality intValue])
			{
				case 1:		// low
					low_quality_subtype =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
					break;
				case 2:		// normal
					if (item_is_of_type(code, spellCodes))
						spell_id =			[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 5)];
					if (item_is_of_type(code, bodypartCodes))	// bodyparts are unused in the game
						monster_id =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 10)];
					if (item_is_of_type(code, charmCodes))		// quality = 2 charms are rather rare :o)
					{
						charm_affix_type =	[[NSNumber alloc] initWithBool:			read_bits(data, bit_offset, 1)];
						charm_affix =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					}
					break;
				case 3:		// high
					high_quality_subtype =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 3)];
					break;
				case 4:		// magic
					prefix1 =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					suffix1 =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					break;
				case 5:		// set
					set_id =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 12)];
					break;
				case 7:		// unique
					unique_id =		[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 12)];
					break;
				case 6:		// rare
				case 8:		// crafted
					first_name =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 8)];
					second_name =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 8)];
					if (read_bits(data, bit_offset, 1))
						prefix1 =   [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					if (read_bits(data, bit_offset, 1))
						suffix1 =	[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					if (read_bits(data, bit_offset, 1))
						prefix2 =	[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					if (read_bits(data, bit_offset, 1))
						suffix2 =	[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					if (read_bits(data, bit_offset, 1))
						prefix3 =	[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					if (read_bits(data, bit_offset, 1))
						suffix3 =	[[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11)];
					break;
				case 9:		// tempered
					first_name =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 8)];
					second_name =	[[NSNumber alloc] initWithUnsignedChar:	read_bits(data, bit_offset, 8)];
					break;
			}
			
			// runeword info
			if ([runeword boolValue])
			{
				runeword_id = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 12)];
				runeword_data = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 4)];
				plist_flags |= 1 << 6;
			}
			
			// personalisation info
			if ([inscribed boolValue])
			{
				int i = 0;
				char insc[17];
				while ((insc[i] = (char) read_bits(data, bit_offset, 7)) && i < 16) i++;
				if (i == 16) insc[i] = 0;
				inscription = [[NSString alloc] initWithCString:insc];
			}
		}
		
		// NON-EAR ITEMS (SIMPLE & EXTENDED) ONLY
		if ([code isEqualToString:@"gld"])
		{
			// read gold quantity
			gold_data = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 1)];
			gold_qty = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 12)];
		}
		if (read_bits(data, bit_offset, 1))
		{
			// read super_guid
			unsigned long sg[3];
			sg[0] = read_bits(data, bit_offset, 32);
			sg[1] = read_bits(data, bit_offset, 32);
			sg[2] = read_bits(data, bit_offset, 32);
			super_guid = [[NSData alloc] initWithBytes:&sg[0] length:12];
		}
		
		// EXTENDED ITEMS ONLY
		if (![compact boolValue])
		{
			if (item_is_of_type(code, [armour valueForKey:@"code"]))
				defence = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 11) -10];	// eleven bits in 1.10, ten bits in 1.09; also value read is defence +10
			if (item_is_of_type(code, [armour valueForKey:@"code"]) || item_is_of_type(code, [weapons valueForKey:@"code"]))
				durability_max = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 8)];
			if ((item_is_of_type(code, [armour valueForKey:@"code"]) || item_is_of_type(code, [weapons valueForKey:@"code"])) && [durability_max intValue] > 0)
				durability = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 9)];	// eight bits in 1.09, nine bits in 1.10
			if (item_is_of_type(code, stackableCodes))
				quantity = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 9)];
			if ([socketed boolValue])
				num_sockets = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 4)];
			
			// read plist presence flags
			if ([quality intValue] == 5)
				plist_flags |= read_bits(data, bit_offset, 5) << 1;
			
			// read plists (between 1 and 7 of them)
			properties = [[NSMutableArray alloc] init];
			for (int i = 0; i < 7; i++)
			{
				if ((plist_flags >> i) & 1)
					[properties addObject:read_property_list(data, bit_offset)];
				else [properties addObject:[NSMutableArray array]];
			}
		}
			
		// advance bit_offset to start of next byte
		*bit_offset += ((*bit_offset % 8)? 8-(*bit_offset % 8):0);
		
		// socketed gems
		gems = [[NSMutableArray alloc] init];
		for (int i = 0; i < num_gems; i++)
			[gems addObject:[Item itemWithBytes:data bitOffset:bit_offset]];
	}
	
	// EAR ITEMS ONLY
	else
	{
		int i = 0;
		char victim[19];
		victim_class = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 3)];
		victim_level = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 7)];
		while (victim[i] = read_bits(data, bit_offset, 7) && i < 18) i++;
		if (i == 18) victim[i] = 0;
		victim_name = [[NSString alloc] initWithCString:victim];
	}
	
	// calculate item's name
	[self setName];
	
	if (g.debug)
	{
//		NSLog(@"Properties for %@: %@", name, [properties description]);
		
		// verify item matches input data
		NSData *outputData = [self data];
		NSData *inputData = [NSData dataWithBytes:(data + start_offset) length:(*bit_offset/8 - start_offset)];
		if (![outputData isEqualToData:inputData])
		{
			NSLog(@"Item data for %@ does not match input data:\n input: %@\noutput: %@\nproperties: %@", name, inputData, outputData, [properties description]);
			Debugger();
		}
	}
	return self;
}

- (NSData *)data
{
	uint32_t bit_offset = 0;
	uint8_t *buffer = (uint8_t *) calloc(256, 1);		// the largest items i've seen are ~80 bytes, so 256 should be enough :)
	set_bits(buffer, NSSwapLittleShortToHost('JM'), &bit_offset, 16);
	set_bits(buffer, [quest unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown2_1 unsignedIntValue], &bit_offset, 3);	// unknown2_1
	set_bits(buffer, [identified unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown2_5 unsignedIntValue], &bit_offset, 3);	// unknown2_5
	set_bits(buffer, [unknown3_0 unsignedIntValue], &bit_offset, 2);	// unknown3_0
	set_bits(buffer, [duplicate unsignedIntValue], &bit_offset, 1);		// 'duplicate'
	set_bits(buffer, [socketed unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown3_4 unsignedIntValue], &bit_offset, 1);	// unknown3_4
	set_bits(buffer, [unknown3_5 unsignedIntValue], &bit_offset, 1);	// unknown3_5, often 1
	set_bits(buffer, [illegal unsignedIntValue], &bit_offset, 1);		// 'illegal'?
	set_bits(buffer, [unknown3_7 unsignedIntValue], &bit_offset, 1);	// unknown3_7
	set_bits(buffer, [ear unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [starter unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown4_2 unsignedIntValue], &bit_offset, 3);	// unknown4_2
	set_bits(buffer, [compact unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [ethereal unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown4_7 unsignedIntValue], &bit_offset, 1);	// unknown4_7, always 1
	set_bits(buffer, [inscribed unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown5_1 unsignedIntValue], &bit_offset, 1);	// unknown5_1
	set_bits(buffer, [runeword unsignedIntValue], &bit_offset, 1);
	set_bits(buffer, [unknown5_3 unsignedIntValue], &bit_offset, 5);	// unknown5_3
	set_bits(buffer, [version unsignedIntValue], &bit_offset, 8);
	
	set_bits(buffer, [unknown7_0 unsignedIntValue], &bit_offset, 2);	// unknown7_0
	set_bits(buffer, [location unsignedIntValue], &bit_offset, 3);
	set_bits(buffer, [equip_position unsignedIntValue], &bit_offset, 4);
	set_bits(buffer, (unsigned int)[grid_position pointValue].y, &bit_offset, 4);
	set_bits(buffer, (unsigned int)[grid_position pointValue].x, &bit_offset, 4);
	set_bits(buffer, [grid_page unsignedIntValue], &bit_offset, 3);
	
	if (![ear boolValue])
	{
		unsigned int codeAsInt = ((*(unsigned int *)[code cString]) & 0xFFFFFF00) + 0x20;
		set_bits(buffer, CFSwapInt32HostToLittle(codeAsInt), &bit_offset, 32);
		
		if (![compact boolValue])
		{
			set_bits(buffer, [gems count], &bit_offset, 3);
			set_bits(buffer, *(unsigned int *)[guid bytes], &bit_offset, 32);
			set_bits(buffer, [drop_level unsignedIntValue], &bit_offset, 7);
			set_bits(buffer, [quality unsignedIntValue], &bit_offset, 4);
			set_bits(buffer, graphic? 1:0, &bit_offset, 1);
			if (graphic)			set_bits(buffer, [graphic unsignedIntValue], &bit_offset, 3);
								set_bits(buffer, automagic_affix? 1:0, &bit_offset, 1);
			if (automagic_affix) set_bits(buffer, [automagic_affix shortValue], &bit_offset, 11);
			switch ([quality intValue])
			{
				case 1:
					set_bits(buffer, [low_quality_subtype unsignedIntValue], &bit_offset, 3);
					break;
				case 2:
					if (item_is_of_type(code, spellCodes))
						set_bits(buffer, [spell_id unsignedIntValue], &bit_offset, 5);
					if (item_is_of_type(code, bodypartCodes))
						set_bits(buffer, [monster_id unsignedIntValue], &bit_offset, 10);
					if (item_is_of_type(code, charmCodes))
					{
						set_bits(buffer, [charm_affix_type boolValue], &bit_offset, 1);
						set_bits(buffer, [charm_affix shortValue], &bit_offset, 11);
					}
					break;
				case 3:
					set_bits(buffer, [high_quality_subtype unsignedIntValue], &bit_offset, 3);
					break;
				case 4:
					set_bits(buffer, [prefix1 shortValue], &bit_offset, 11);
					set_bits(buffer, [suffix1 shortValue], &bit_offset, 11);
					break;
				case 5:
					set_bits(buffer, [set_id unsignedIntValue], &bit_offset, 12);
					break;
				case 7:
					set_bits(buffer, [unique_id unsignedIntValue], &bit_offset, 12);
					break;
				case 6:
				case 8:
								set_bits(buffer, [first_name unsignedIntValue], &bit_offset, 8);
								set_bits(buffer, [second_name unsignedIntValue], &bit_offset, 8);
								set_bits(buffer, prefix1? 1:0, &bit_offset, 1);
					if (prefix1)	set_bits(buffer, [prefix1 shortValue], &bit_offset, 11);
								set_bits(buffer, suffix1? 1:0, &bit_offset, 1);
					if (suffix1)	set_bits(buffer, [suffix1 shortValue], &bit_offset, 11);
								set_bits(buffer, prefix2? 1:0, &bit_offset, 1);
					if (prefix2)	set_bits(buffer, [prefix2 shortValue], &bit_offset, 11);
								set_bits(buffer, suffix2? 1:0, &bit_offset, 1);
					if (suffix2)	set_bits(buffer, [suffix2 shortValue], &bit_offset, 11);
								set_bits(buffer, prefix3? 1:0, &bit_offset, 1);
					if (prefix3)	set_bits(buffer, [prefix3 shortValue], &bit_offset, 11);
								set_bits(buffer, suffix3? 1:0, &bit_offset, 1);
					if (suffix3)	set_bits(buffer, [suffix3 shortValue], &bit_offset, 11);
					break;
				case 9:
					set_bits(buffer, [first_name unsignedIntValue], &bit_offset, 8);
					set_bits(buffer, [second_name unsignedIntValue], &bit_offset, 8);
					break;
				default:
					NSLog(@"Saving item with invalid quality: %d", [quality intValue]);
					break;
			}
			
			if ([runeword boolValue])
			{
				set_bits(buffer, [runeword_id unsignedIntValue], &bit_offset, 12);
				if (runeword_data)
					set_bits(buffer, [runeword_data unsignedIntValue], &bit_offset, 4);
				else set_bits(buffer, 5, &bit_offset, 4);   // seems to always be 5, set it to that if making non-rune item into runeword item
			}
			
			if ([inscribed boolValue])
			{
				for (int i = 0; i < 15; i++)
				{
					char c = [inscription cString][i];
					set_bits(buffer, c, &bit_offset, 7);
					if (!c) break;
				}
			}
		}
		
		if (codeAsInt == 'gld ')
		{	set_bits(buffer, [gold_data unsignedIntValue], &bit_offset, 1);
			set_bits(buffer, [gold_qty unsignedIntValue], &bit_offset, 12); }
		
		set_bits(buffer, super_guid? 1:0, &bit_offset, 1);
		if (super_guid)
		{	set_bits(buffer, *((unsigned long *)[super_guid bytes]), &bit_offset, 32);
			set_bits(buffer, *((unsigned long *)[super_guid bytes] +1), &bit_offset, 32);		// relies on C advancing the pointer 4 bytes when you do long*++
			set_bits(buffer, *((unsigned long *)[super_guid bytes] +2), &bit_offset, 32); }
		
		if ( ![compact boolValue] )
		{
			if (item_is_of_type(code, [armour valueForKey:@"code"]))
				set_bits(buffer, [defence unsignedIntValue] +10, &bit_offset, 11);
			if (item_is_of_type(code, [armour valueForKey:@"code"]) || item_is_of_type(code, [weapons valueForKey:@"code"]))
				set_bits(buffer, [durability_max unsignedIntValue], &bit_offset, 8);
			if ((item_is_of_type(code, [armour valueForKey:@"code"]) || item_is_of_type(code, [weapons valueForKey:@"code"])) && [durability_max unsignedIntValue] > 0)
				set_bits(buffer, [durability unsignedIntValue], &bit_offset, 9);
			if (item_is_of_type(code, stackableCodes))
				set_bits(buffer, [quantity unsignedIntValue], &bit_offset, 9);
			if ([socketed boolValue])
				set_bits(buffer, [num_sockets unsignedIntValue], &bit_offset, 4);
			
			int i = 0;
			NSArray *array;
			NSEnumerator *enumerator;
			if ([quality intValue] == 5)
			{
				unsigned char plist_flags = 0;
				enumerator = [properties objectEnumerator];
				while (array = [enumerator nextObject])
				{
					if (i > 0 && i < 6 && [array count] > 0)
						plist_flags |= 1 << (i-1);
					i++;
				}
				set_bits(buffer, plist_flags, &bit_offset, 5);
			}
			
			i = 0;
			enumerator = [properties objectEnumerator];
			while (array = [enumerator nextObject])
			{
				// write property list if it has keys, or it's the first property list (regardless of key count), or it's the runeword (last) property list (even if it has no keys - unusual runeword!)
				if ([array count] > 0 || i == 0 || ([runeword intValue] == 1 && i == 6))
					write_property_list(buffer, &bit_offset, array);
				i++;
			}
			
			// advance bit_offset to start of next byte
			bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
			
			Item *gem;
			enumerator = [gems objectEnumerator];
			while (gem = [enumerator nextObject])
			{
				NSData *gem_data = [gem data];
				unsigned long gem_length = [gem_data length];
				unsigned long byte_offset = bit_offset / 8;
				realloc(buffer, byte_offset + gem_length);
				memcpy(buffer + byte_offset, [gem_data bytes], gem_length);
				bit_offset += gem_length * 8;
			}
		}
	}
	
	// EAR ITEMS ONLY
	else
	{
		set_bits(buffer, [victim_class unsignedIntValue], &bit_offset, 3);
		set_bits(buffer, [victim_level unsignedIntValue], &bit_offset, 7);
		for (int i = 0; i < 18; i++)
		{
			char c = [victim_name cString][i];
			set_bits(buffer, c, &bit_offset, 7);
			if (!c) break;
		}
	}
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// create and return NSData!
	return [NSData dataWithBytesNoCopy:buffer length:bit_offset/8 freeWhenDone:YES];
}

- (void)setName
{
	// generate user-visable name for list view
	NSString *prefix = @"", *base, *suffix = @"", *gender = NULL;
	id entry = [itemTable firstObjectReturningValue:code forKey:@"code"];
	base = Localise([entry valueForKey:@"namestr"], &gender);
	if (!base)
	{
		NSLog(@"Name for item with code '%@' not found!", code);
		base = code; 	// use plain code for unknown items
	}
	
	// read formats
	NSString *lowQualFormat = Localise(@"LowqualityFormat");
	NSString *gemmedFormat = Localise(@"GemmedNormalName");
	NSString *highQualFormat = Localise(@"HiqualityFormat");
	NSString *magicFormat = Localise(@"MagicFormat");
	NSString *setFormat = Localise(@"SetItemFormatX");
	NSString *rareFormat = Localise(@"RareFormat");
	
/*	ScrollFormat
	BookFormat
	HerbFormat
	BodyPartsFormat
	PlayerBodyPartFormat
	SetItemFormat = %0 %1
	SetItemFormatX = %0
*/	
	// mutate name based on quality
	if (![compact boolValue])
	{
		switch ([quality intValue])
		{
			case 1:
				// bug: doesn't check subtype# < name count
				prefix = Localise([[lowqualityitems valueForKey:@"name"] objectAtIndex:[low_quality_subtype intValue]], &gender);
				base = [NSString stringWithDiabloFormat:lowQualFormat, prefix, base];
				break;
			case 2:
				if ([gems count] > 0)
				{
					prefix = Localise(@"Gemmed", &gender);
					base = [NSString stringWithDiabloFormat:gemmedFormat, prefix, base];
				}
				break;
			case 3:
				prefix = Localise(@"Hiquality", &gender);
				base = [NSString stringWithDiabloFormat:highQualFormat, prefix, base];
				break;
			case 4:
				if (prefix1 && [prefix1 shortValue] > 0) prefix = Localise([[magicprefix objectAtIndex:[prefix1 intValue]-1] valueForKey:@"name"], &gender);
				if (suffix1 && [suffix1 shortValue] > 0) suffix = Localise([[magicsuffix objectAtIndex:[suffix1 intValue]-1] valueForKey:@"name"], &gender);
				base = [NSString stringWithDiabloFormat:magicFormat, prefix, base, suffix];
				break;
			case 5:	
				// bug: doesn't check set_id# < setitem count
				base = Localise([[setitems valueForKey:@"index"] objectAtIndex:[set_id intValue]], &gender);
				base = [NSString stringWithDiabloFormat:setFormat, base];
				break;
			case 7:
				// bug: doesn't check unique_id# < setitem count
				if ([unique_id unsignedIntValue] == 0x0FFF) break;   // -1 (12 bits) for some quest items
				if ([unique_id unsignedIntValue] < [[uniqueitems valueForKey:@"index"] count])
					base = Localise([[uniqueitems valueForKey:@"index"] objectAtIndex:[unique_id intValue]], &gender);
				break;
			case 6:
			case 8:
			case 9:
			{	NSArray *rareNames = [rareaffix valueForKey:@"name"];
				long rareNameCount = [rareNames count];
				char name1 = [first_name unsignedCharValue]  -1;
				char name2 = [second_name unsignedCharValue] -1;
				if (name1 >= 0 && name1 < rareNameCount && name2 >= 0 && name2 < rareNameCount)
				{
					prefix = Localise([rareNames objectAtIndex:name1], &gender);
					suffix = Localise([rareNames objectAtIndex:name2], &gender);
					base   = [NSString stringWithDiabloFormat:rareFormat, prefix, suffix];
				}
			}	break;
			default:
				base = [NSString stringWithFormat:@"Unknown Quality (%@) %@", quality, base];
				break;
		}
	}
	
	// set inscription if present (this ought to be only done if item is not compact, but diablo will still name compact items with the inscribed flag set!)
	if ([inscribed boolValue])
	{
		//	PlayerNameOnItemstring = %s's
		//	PlayerNameOnItemstringX = %s'
		base = [NSString stringWithFormat:@"%@ %@", Localise(@"PlayerNameOnItemstring"), base];
		base = [NSString stringWithFormat:base, inscription? [inscription cString]:""];
	}
	
	// set name
	[self setValue:base forKey:@"name"];
}

- (void)setValue:(id)value forKey:(id)key
{
	[super setValue:value forKey:key];
	if (![key isEqualToString:@"name"])
		[self setName];
}

- (NSString *)code
{
	return code;
}

- (void)setCode:(NSString *)value
{
	[self willChangeValueForKey:@"grade"];
	[self willChangeValueForKey:@"stackable"];
	[self willChangeValueForKey:@"isArmour"];
	[self willChangeValueForKey:@"isWeapon"];
	[self willChangeValueForKey:@"isArmourOrWeapon"];
	[self willChangeValueForKey:@"isRareCraftedOrTempered"];
	[self willChangeValueForKey:@"isGold"];
	[self willChangeValueForKey:@"isCharm"];
	[self willChangeValueForKey:@"isBodyPart"];
	
	// swap code
	id old = code;
	code = [value copy];
	
	// set/clear vars for new code
	BOOL flag = [code isEqualToString:@"ear"];
	if (flag)
		[self setValue:[NSNumber numberWithBool:flag] forKey:@"ear"];
	int compact_flag = [[[itemTable firstObjectReturningValue:code forKey:@"code"] valueForKey:@"compactsave"] intValue];
	int old_compact_flag = [[[itemTable firstObjectReturningValue:old forKey:@"code"] valueForKey:@"compactsave"] intValue];
	[self setValue:[NSNumber numberWithInt:compact_flag] forKey:@"compact"];
	if (compact_flag || (old_compact_flag != compact_flag))
	{
		[self setValue:[NSNumber numberWithBool:false] forKey:@"quest"];
		[self setValue:[NSNumber numberWithBool:false] forKey:@"ethereal"];
		[self setValue:[NSNumber numberWithBool:false] forKey:@"inscribed"];
		[self setValue:[NSNumber numberWithBool:false] forKey:@"socketed"];
		[self setValue:[NSNumber numberWithBool:false] forKey:@"runeword"];
		[self setValue:nil forKey:@"inscription"];
		[self setValue:nil forKey:@"runeword_id"];
	}
	if (old_compact_flag && !compact_flag)
	{
		[self setValue:[NSNumber numberWithInt:4] forKey:@"quality"];
	}
	
	[self didChangeValueForKey:@"grade"];
	[self didChangeValueForKey:@"stackable"];
	[self didChangeValueForKey:@"isArmour"];
	[self didChangeValueForKey:@"isWeapon"];
	[self didChangeValueForKey:@"isArmourOrWeapon"];
	[self didChangeValueForKey:@"isRareCraftedOrTempered"];
	[self didChangeValueForKey:@"isGold"];
	[self didChangeValueForKey:@"isCharm"];
	[self didChangeValueForKey:@"isBodyPart"];
	
	// release old code now
	[old release];
}

- (void)setID:(NSNumber *)value
{
	// swap id
	switch ([quality intValue])
	{
		case 5: // set item
			code = [[[setitems objectAtIndex:[value intValue]] valueForKey:@"item"] copy];
			[self setValue:[value copy] forKey:@"set_id"];
			break;
		case 7: // unique item
			code = [[[uniqueitems objectAtIndex:[value intValue]] valueForKey:@"code"] copy];
			[self setValue:[value copy] forKey:@"unique_id"];
			break;
	}
	
	// set/clear vars for new code
	[self willChangeValueForKey:@"grade"];
	[self willChangeValueForKey:@"stackable"];
	[self willChangeValueForKey:@"isArmour"];
	[self willChangeValueForKey:@"isWeapon"];
	[self willChangeValueForKey:@"isArmourOrWeapon"];
	[self willChangeValueForKey:@"isRareCraftedOrTempered"];
	[self willChangeValueForKey:@"isCharm"];
	[self willChangeValueForKey:@"isBodyPart"];
	[self didChangeValueForKey:@"grade"];
	[self didChangeValueForKey:@"stackable"];
	[self didChangeValueForKey:@"isArmour"];
	[self didChangeValueForKey:@"isWeapon"];
	[self didChangeValueForKey:@"isArmourOrWeapon"];
	[self didChangeValueForKey:@"isRareCraftedOrTempered"];
	[self didChangeValueForKey:@"isCharm"];
	[self didChangeValueForKey:@"isBodyPart"];
}

- (BOOL)stackable
{
	return ([[[itemTable firstObjectReturningValue:code forKey:@"code"] valueForKey:@"stackable"] intValue] != 0);
}

- (BOOL)isArmour
{
	return ([armour indexOfFirstObjectReturningValue:code forKey:@"code"] != NSNotFound);
}

- (BOOL)isWeapon
{
	return ([weapons indexOfFirstObjectReturningValue:code forKey:@"code"] != NSNotFound);
}

- (BOOL)isArmourOrWeapon
{
	if ([armour indexOfFirstObjectReturningValue:code forKey:@"code"] != NSNotFound) return true;
	if ([weapons indexOfFirstObjectReturningValue:code forKey:@"code"] != NSNotFound) return true;
	return false;
}

- (BOOL)isRareCraftedOrTempered
{
	int q = [quality intValue];
	return (q == 6 || q == 8 || q == 9);
}

- (BOOL)isGold
{
	return [code isEqualToString:@"gld"];
}

- (BOOL)isCharm
{
	return ([code isEqualToString:@"cm1"] || [code isEqualToString:@"cm2"] || [code isEqualToString:@"cm3"]);
}

- (BOOL)isBodyPart
{
	id item = [misc firstObjectReturningValue:code forKey:@"code"];
	if (item && [[item valueForKey:@"type"] isEqualToString:@"body"])
		return true;
	else return false;
}

- (NSNumber *)uniqueness
{
	// convert set/unique/other quality into {0, 1, 2}
	switch ([quality intValue])
	{
		case 7:  return [NSNumber numberWithInt:2];
		case 5:  return [NSNumber numberWithInt:1];
		default: return [NSNumber numberWithInt:0];
	}
}
- (void)setUniqueness:(NSNumber *)value
{
	// convert {0, 1, 2} into normal/set/unique quality
	id old = quality;
	[self willChangeValueForKey:@"quality"];
	switch ([value intValue])
	{
		case 0:
			quality = [[NSNumber alloc] initWithChar:2];
			[self setValue:nil forKey:@"set_id"];
			[self setValue:nil forKey:@"unique_id"];
			break;
		case 1:
			quality = [[NSNumber alloc] initWithChar:5];
			code = [[[setitems objectAtIndex:0] valueForKey:@"item"] copy];
			[self setValue:[NSNumber numberWithInt:0] forKey:@"set_id"];
			[self setValue:nil forKey:@"unique_id"];
			[self setValue:code forKey:@"code"];
			break;
		case 2:
			quality = [[NSNumber alloc] initWithChar:7];
			code = [[[uniqueitems objectAtIndex:0] valueForKey:@"code"] copy];
			[self setValue:nil forKey:@"set_id"];
			[self setValue:[NSNumber numberWithInt:0] forKey:@"unique_id"];
			[self setValue:code forKey:@"code"];
			break;
	}
	[self didChangeValueForKey:@"quality"];
	[old release];
}

- (NSNumber *)quality
{
	// convert item's quality, quality_subtypes etc into value for pop-up
	switch ([quality intValue])
	{
		case 1:		// low
			return [self valueForKey:@"low_quality_subtype"];
		case 2:		// normal
			return [NSNumber numberWithInt:4];
		case 3:		// high
			return [NSNumber numberWithInt:5];
		case 4:		// magic
			return [NSNumber numberWithInt:6];
		case 5:		// set
			return [NSNumber numberWithInt:4];
		case 6:		// rare
			return [NSNumber numberWithInt:7];
		case 7:		// unique
			return [NSNumber numberWithInt:4];
		case 8:		// crafted
			return [NSNumber numberWithInt:8];
		case 9:		// tempered
			return [NSNumber numberWithInt:9];
		default:
			return [NSNumber numberWithInt:4];
	}
}

- (void)setQuality:(NSNumber *)value
{
	// clear vars not relavent to new quality
	[self setValue:nil forKey:@"low_quality_subtype"];
	[self setValue:nil forKey:@"high_quality_subtype"];
	[self setValue:nil forKey:@"set_id"];
	[self setValue:nil forKey:@"unique_id"];
	
	// swap quality
	id old = quality;
	[self willChangeValueForKey:@"quality"];
	switch ([value intValue])
	{
		case 0:		// crude
			quality = [[NSNumber alloc] initWithChar:1];
			[self setValue:[NSNumber numberWithInt:0] forKey:@"low_quality_subtype"];
			break;
		case 1:		// cracked
			quality = [[NSNumber alloc] initWithChar:1];
			[self setValue:[NSNumber numberWithInt:1] forKey:@"low_quality_subtype"];
			break;
		case 2:		// damaged
			quality = [[NSNumber alloc] initWithChar:1];
			[self setValue:[NSNumber numberWithInt:2] forKey:@"low_quality_subtype"];
			break;
		case 3:		// low quality
			quality = [[NSNumber alloc] initWithChar:1];
			[self setValue:[NSNumber numberWithInt:3] forKey:@"low_quality_subtype"];
			break;
		case 4:		// normal
			quality = [[NSNumber alloc] initWithChar:2];
			break;
		case 5:		// superior
			quality = [[NSNumber alloc] initWithChar:3];
			[self setValue:[NSNumber numberWithInt:0] forKey:@"high_quality_subtype"];
			break;
		case 6:		// magic
			quality = [[NSNumber alloc] initWithChar:4];
			break;
		case 7:		// rare
			quality = [[NSNumber alloc] initWithChar:6];
			break;
		case 8:		// crafted
			quality = [[NSNumber alloc] initWithChar:8];
			break;
		case 9:		// tempered
			quality = [[NSNumber alloc] initWithChar:9];
			break;
	}
	[self didChangeValueForKey:@"quality"];
	[old release];
	
	[self willChangeValueForKey:@"uniqueness"];
	[self willChangeValueForKey:@"isRareCraftedOrTempered"];
	[self didChangeValueForKey:@"uniqueness"];
	[self didChangeValueForKey:@"isRareCraftedOrTempered"];
}

- (NSNumber *)grade
{
	// convert normal/exceptional/unique code into {0, 1, 2}
	id entry = [itemTable firstObjectReturningValue:code forKey:@"code"];
	if ([[entry valueForKey:@"ultracode"] isEqualToString:code])	return [NSNumber numberWithInt:2];
	if ([[entry valueForKey:@"ubercode"]  isEqualToString:code])	return [NSNumber numberWithInt:1];
																return [NSNumber numberWithInt:0];
}

- (void)setGrade:(NSNumber *)value
{
	// convert {0, 1, 2} into new normal/exceptional/unique code
	NSString *newCode = nil;
	id entry = [itemTable firstObjectReturningValue:code forKey:@"code"];
	switch ([value intValue])
	{
		case 0: newCode = [entry valueForKey:@"normcode"];	break;
		case 1: newCode = [entry valueForKey:@"ubercode"];	break;
		case 2: newCode = [entry valueForKey:@"ultracode"];	break;
	}
	
	// abort if cannot upgrade (should disable menu items instead)
	if (!newCode || [newCode isEqualToString:@""] || [newCode isEqualToString:@"xxx"]) return;
	
	// set code to newcode
	[self setValue:newCode forKey:@"code"];
}

- (NSString *)displayPosition
{
//	NSNumber *location;				// 0 = grid; 1 = equipped; 2 = belt; 3 = ground; 4 = cursor; 5 = unknown; 6 = socket; 7 = unknown
//	NSNumber *equip_position;		// if location = equipped: 1 = head; 2 = neck; 3 = torso; 4 = right hand; 5 = left hand; 6 = left finger; 7 = right finger; 8 = waist; 9 = feet; 10 = hands; 11 = alt right hand; 12 = alt left hand; otherwise 0
//	NSValue *grid_position;			// xy-position if location = grid or belt (belt is treated as 1x16 grid); otherwise junk
//	NSNumber *grid_page;			// if location = grid: 1 = inventory; 2 = unknown; 3 = unknown; 4 = cube; 5 = stash; otherwise 0
	switch ([location intValue])
	{
		case 0:		switch ([grid_page intValue])
		{
			case 1:		return [NSString stringWithFormat:@"Inventory %@", NSStringFromPoint([grid_position pointValue])];
			case 4:		return [NSString stringWithFormat:@"Cube %@", NSStringFromPoint([grid_position pointValue])];
			case 5:		return [NSString stringWithFormat:@"Stash %@", NSStringFromPoint([grid_position pointValue])];
			default:	return [NSString stringWithFormat:@"UnknownGrid (%@) %@", grid_page, NSStringFromPoint([grid_position pointValue])];
		}	break;
		case 1:		switch ([equip_position intValue])
		{
			case 1:		return @"Head";
			case 2:		return @"Neck";
			case 3:		return @"Torso";
			case 4:		return @"R Hand (1)";
			case 5:		return @"L Hand (1)";
			case 6:		return @"L Finger";
			case 7:		return @"R Finger";
			case 8:		return @"Waist";
			case 9:		return @"Feet";
			case 10:	return @"Hands";
			case 11:	return @"R Hand (2)";
			case 12:	return @"L Hand (2)";
			default:	return [NSString stringWithFormat:@"UnknownEP (%@)", equip_position];
		}	break;
		case 2:		return [NSString stringWithFormat:@"Belt %@", NSStringFromPoint([grid_position pointValue])];
		case 3:		return @"Ground";
		case 4:		return @"Cursor";
		case 6:		return @"Socket";
		default:	return [NSString stringWithFormat:@"UnknownLoc (%@)", location];
	}
}

- (NSNumber *)gridXPos
{
	int loc = [location intValue];
	if (loc == 2)		// belt
	{
		NSPoint point = [grid_position pointValue];
		return [NSNumber numberWithInt:static_cast<int>(point.y) % 4];
	}
	else if (loc == 0)   // grid
	{
		NSPoint point = [grid_position pointValue];
		return [NSNumber numberWithInt:static_cast<int>(point.x)];
	}
	else return nil;
}

- (NSNumber *)gridYPos
{
	int loc = [location intValue];
	if (loc == 2)
	{
		NSPoint point = [grid_position pointValue];
		return [NSNumber numberWithInt:static_cast<int>(point.y / 4)];
	}
	else if (loc == 0)
	{
		NSPoint point = [grid_position pointValue];
		return [NSNumber numberWithInt:static_cast<int>(point.y)];
	}
	else return nil;
}

- (void)setGridXPos:(NSNumber *)newPos
{
	int loc = [location intValue];
	if (loc == 2)
	{
		long new_pos = [newPos intValue];
		if (new_pos < 0 || new_pos > 3) return;
		
		NSPoint old_pos = [grid_position pointValue];
		[self setValue:[NSValue valueWithPoint:NSMakePoint(0,4*new_pos+((int)old_pos.y%4))] forKey:@"grid_position"];
	}
	else if (loc == 0)
	{
		long new_pos = [newPos intValue];
		NSPoint old_pos = [grid_position pointValue];
		[self setValue:[NSValue valueWithPoint:NSMakePoint(new_pos,old_pos.y)] forKey:@"grid_position"];
	}
}

- (void)setGridYPos:(NSNumber *)newPos
{
	int loc = [location intValue];
	if (loc == 2)
	{
		long new_pos = [newPos intValue];
		if (new_pos < 0 || new_pos > 3) return;  // prohibits belts of more than 4x4! should read belts.txt's 'numboxes' column
		
		NSPoint old_pos = [grid_position pointValue];
		[self setValue:[NSValue valueWithPoint:NSMakePoint(0,new_pos+(4*(int)(old_pos.y/4)))] forKey:@"grid_position"];
	}
	else if (loc == 0)
	{
		long new_pos = [newPos intValue];
		NSPoint old_pos = [grid_position pointValue];
		[self setValue:[NSValue valueWithPoint:NSMakePoint(old_pos.x,new_pos)] forKey:@"grid_position"];
	}
}

// description
- (NSString *)description
{
	if (gems && [gems count] > 0)
		return [NSString stringWithFormat:@"%@ with %d gems", name, [gems count]];
	else return name;
}

- (NSArray *)allAffixes
{
	// get gender for item
	NSString *affixname = nil, *gender = nil;
	NSMutableArray *array = [NSMutableArray array];
	id entry = [itemTable firstObjectReturningValue:code forKey:@"code"];
	Localise([entry valueForKey:@"namestr"], &gender);
	
	// add dictionaries of affix info to array
	if (automagic_affix && [automagic_affix shortValue] > 0) affixname = Localise([[automagic objectAtIndex:[automagic_affix intValue]-1] valueForKey:@"name"], &gender);
	if (automagic_affix && [automagic_affix shortValue] > 0)	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:automagic_affix, @"id", affixname, @"affix", @"Automagic", @"location", nil]];
	if (charm_affix && [charm_affix shortValue] > 0)			affixname = Localise([[magicprefix objectAtIndex:[charm_affix intValue]-1] valueForKey:@"name"], &gender);
	if (charm_affix && [charm_affix shortValue] > 0)			[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:charm_affix, @"id", affixname, @"affix", @"Charm", @"location", nil]];
	if (prefix1 && [prefix1 shortValue] > 0)					affixname = Localise([[magicprefix objectAtIndex:[prefix1 intValue]-1] valueForKey:@"name"], &gender);
	if (prefix1 && [prefix1 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:prefix1, @"id", affixname, @"affix", @"Prefix 1", @"location", nil]];
	if (prefix2 && [prefix2 shortValue] > 0)					affixname = Localise([[magicprefix objectAtIndex:[prefix2 intValue]-1] valueForKey:@"name"], &gender);
	if (prefix2 && [prefix2 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:prefix2, @"id", affixname, @"affix", @"Prefix 2", @"location", nil]];
	if (prefix3 && [prefix3 shortValue] > 0)					affixname = Localise([[magicprefix objectAtIndex:[prefix3 intValue]-1] valueForKey:@"name"], &gender);
	if (prefix3 && [prefix3 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:prefix3, @"id", affixname, @"affix", @"Prefix 3", @"location", nil]];
	if (suffix1 && [suffix1 shortValue] > 0)					affixname = Localise([[magicsuffix objectAtIndex:[suffix1 intValue]-1] valueForKey:@"name"], &gender);
	if (suffix1 && [suffix1 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:suffix1, @"id", affixname, @"affix", @"Suffix 1", @"location", nil]];
	if (suffix2 && [suffix2 shortValue] > 0)					affixname = Localise([[magicsuffix objectAtIndex:[suffix2 intValue]-1] valueForKey:@"name"], &gender);
	if (suffix2 && [suffix2 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:suffix2, @"id", affixname, @"affix", @"Suffix 2", @"location", nil]];
	if (suffix3 && [suffix3 shortValue] > 0)					affixname = Localise([[magicsuffix objectAtIndex:[suffix3 intValue]-1] valueForKey:@"name"], &gender);
	if (suffix3 && [suffix3 shortValue] > 0)					[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:suffix3, @"id", affixname, @"affix", @"Suffix 3", @"location", nil]];
	return array;
}

- (NSArray *)properties
{
	return properties;
}
@end