#import "CharacterDocument.h"
#import "CharacterDocument_Stats.h"

#import "Act.h"
#import "Corpse.h"
#import "Mercenary.h"
#import "NPC.h"
#import "Quest.h"
#import "Skill.h"
#import "Waypoint.h"

#import "ItemDocument.h"
#import "Item.h"
#import "Property.h"

#import "AppDelegate.h"
#import "MPQReader.h"
#import "LegitamacyWarning.h"

#import "Localization.h"
#import "PropertyLists.h"
#include "bits.h"

unsigned long level_for_experience(unsigned long exp)
{
	for (int i = 99; i > 0; i--)
		if (experience_for_level[i] < exp)
			return i;
	return 1;
}

@implementation CharacterDocument

- (id)init
{
    self = [super init];
    if (!self) return nil;
	
	// init variables with defaults
	unknown10 = [[NSNumber alloc] initWithUnsignedLong:0];
	name = @"";
	newChar = [[NSNumber alloc] initWithBool:false];
	unknown24_1 = [[NSNumber alloc] initWithBool:false];
	hardcore = [[NSNumber alloc] initWithBool:false];
	died = [[NSNumber alloc] initWithBool:false];
	unknown24_4 = [[NSNumber alloc] initWithBool:false];
	expansion = [[NSNumber alloc] initWithBool:false];
	unknown24_6 = [[NSNumber alloc] initWithBool:false];
	unknown24_7 = [[NSNumber alloc] initWithUnsignedChar:0];
	title = [[NSNumber alloc] initWithUnsignedChar:0];
	unknown25_5 = [[NSNumber alloc] initWithUnsignedChar:0];
	selectedWeapon = [[NSNumber alloc] initWithUnsignedShort:0];
	characterClass = [[NSNumber alloc] initWithUnsignedChar:0];
	unknown29 = [[NSNumber alloc] initWithUnsignedChar:16];
	unknown30 = [[NSNumber alloc] initWithUnsignedShort:30];
	selectionLevel = [[NSNumber alloc] initWithUnsignedChar:1];
	createdTimestamp = [[NSDate date] retain];
	modifiedTimestamp = [createdTimestamp copy];
	unknown34 = [[NSNumber alloc] initWithLong:-1];
	for (int i = 0; i < 16; i++)
	{
		hotkey[i] = [[NSNumber alloc] initWithShort:-1];
		hotkey_b[i] = [[NSNumber alloc] initWithUnsignedShort:0];
	}
	for (int i = 16; i < 20; i++)
	{
		hotkey[i] = [[NSNumber alloc] initWithShort:0];
		hotkey_b[i] = [[NSNumber alloc] initWithUnsignedShort:0];
	}
	for (int i = 0; i < 32; i++)
		appearance[i/16][i%16] = [[NSNumber alloc] initWithChar:-1];
	currentAct = [[NSNumber alloc] initWithUnsignedChar:0];
	currentDifficulty = [[NSNumber alloc] initWithUnsignedChar:0];
	mapSeed = [[NSNumber alloc] initWithUnsignedLong:0];
	mercenary = [[Mercenary alloc] init];
	unknownBF = [[NSMutableData alloc] initWithLength:144];
	
	// difficulty structures (including acts, waypoints, npcs etc.)
	difficulties = [[NSMutableArray alloc] init];
	NSArray *difficultyTable = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/difficultylevels.txt"];
	for (unsigned i = 0; i < [difficultyTable count]; i++)
		// normal, nightmare and hell have key "x" (indexed access) - my localisation thing doesn't work for them :o(
		[difficulties addObject:[[[Difficulty alloc] initWithName:Localise([[difficultyTable objectAtIndex:i] valueForKey:@"name"])] autorelease]];
	
	// stats
	stats = [read_property_list(NULL, NULL, true) retain];
	[self setLevel:1];
	[self setLife:1];
	[self setLifeMax:1];
	
	// skills
	skills = [[NSMutableArray alloc] init];
	NSArray *skillTable = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/skills.txt"];
	for (unsigned i = 0; i < [skillTable count]; i++)
		[skills addObject:[Skill skillWithID:i]];
	
	// items
	items = [[NSMutableArray alloc] init];
	
	selectedDifficulty = [[NSNumber alloc] initWithInt:0];
	itemEnhancedStats = false;
	filterSkills = true;
	maintainLegitimacy = true;
	return self;
}

- (void)dealloc
{
	// bug: should release all variables here
	[super dealloc];
}

- (NSString *)windowNibName
{
    return @"CharacterDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller
{
#pragma unused(controller)
	[itemTable setTarget:self];
	[itemTable setDoubleAction:@selector(openSelection:)];
	[[legitTable tableColumnWithIdentifier:@"description"] setDataCell:[[[MultilineTextCell alloc] init] autorelease]];
}

- (void)openSelection:(id)sender
{
#pragma unused(sender)
	Item *item;
	NSEnumerator *enumerator = [[itemsArrayController selectedObjects] objectEnumerator];
	while (item = [enumerator nextObject])
	{
		// loop through all open item documents looking for correct one if already open
		
		// otherwise create a new document and set it up
		ItemDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:@"Diablo II Item File" display:NO];
		if (doc)
		{
			[doc setOwner:self];
			[doc setItem:item];
			[doc showWindows];
			if ([item valueForKey:@"set_id"])	[doc selectNodeWithID:[item valueForKey:@"set_id"]];
			if ([item valueForKey:@"unique_id"])	[doc selectNodeWithID:[item valueForKey:@"unique_id"]];
			else								[doc selectNodeWithCode:[item code]];
		}
	}
}

- (NSString *)displayName
{
	unsigned char titleVal = [title unsignedCharValue];
	if (titleVal && name && [name length] > 0)
		return [NSString stringWithFormat:@"%s %@", title_names[[expansion intValue]][[hardcore intValue]][class_genders[[characterClass intValue]]][titleVal -1] , name];
	else if (name && [name length] > 0)
		return name;
	else return [super displayName];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	if ([item action] == @selector(saveDocument:) || [item action] == @selector(saveDocumentAs:))
		return [self validateCharacterForSave];
	else return [super validateUserInterfaceItem:item];
}

- (BOOL)validateCharacterForSave
{
	// it would be nice if this method could display little icons next to things that are wrong, and was called after values get set
	
	// perform validations of the character name
	if (!name)
			return NO;
	if (([[name componentsSeparatedByString:@"_"] count] == 1 && [name cStringLength] < 2) || 
		([[name componentsSeparatedByString:@"_"] count] == 2 && [name cStringLength] < 3) )
			return NO;
	if (([name cString][0] == '_') || ([name cString][[name cStringLength]-1] == '_') )
			return NO;
	
	// all tests passed
	return YES;
}

- (NSData *)dataRepresentationOfType:(NSString *)type
{
#pragma unused(type)
	uint32_t bit_offset = 0;
	uint8_t *buffer = (uint8_t *) calloc(32*1024, 1);		// the largest characters i've seen are ~4 KB, so 32 should be enough :)
	set_bits(buffer, CFSwapInt32LittleToHost('UªUª'), &bit_offset, 32);
	set_bits(buffer, kVersion110, &bit_offset, 32);
	// length & checksum calculated at the end
	set_bits(buffer, 0, &bit_offset, 32);	// length
	set_bits(buffer, 0, &bit_offset, 32);	// checksum
	set_bits(buffer, [unknown10 unsignedLongValue], &bit_offset, 32);	// unknown10
	for (unsigned i = 0; i < 16; i++)
	{
		// write 16 char c-string (zero-paddded)
		if (i < [name cStringLength])
				set_bits(buffer, [name cString][i], &bit_offset, 8);
		else	set_bits(buffer, 0, &bit_offset, 8);
	}
	set_bits(buffer, 0, &bit_offset, 1);	// newChar, never save these, so it's set to zero regardless
	set_bits(buffer, [unknown24_1 unsignedLongValue], &bit_offset, 1);	// unknown24_1
	set_bits(buffer, [hardcore boolValue], &bit_offset, 1);
	set_bits(buffer, [died boolValue], &bit_offset, 1);
	set_bits(buffer, [unknown24_4 unsignedLongValue], &bit_offset, 1);	// unknown24_4
	set_bits(buffer, [expansion boolValue], &bit_offset, 1);
	set_bits(buffer, [unknown24_6 boolValue], &bit_offset, 1);	// unknown24_6
	set_bits(buffer, [unknown24_7 charValue], &bit_offset, 3);	// unknown24_7
	set_bits(buffer, [title charValue], &bit_offset, 3);
	set_bits(buffer, [unknown25_5 charValue], &bit_offset, 3);	// unknown25_4
	set_bits(buffer, [selectedWeapon unsignedShortValue], &bit_offset, 16);
	set_bits(buffer, [characterClass charValue], &bit_offset, 8);
	set_bits(buffer, [unknown29 unsignedCharValue], &bit_offset, 8);	// unknown29 = 16
	set_bits(buffer, [unknown30 unsignedCharValue], &bit_offset, 8);	// unknown30 = 30
	set_bits(buffer, [self level], &bit_offset, 8);
	set_bits(buffer, (unsigned long)[createdTimestamp timeIntervalSince1970], &bit_offset, 32);
	set_bits(buffer, (unsigned long)[modifiedTimestamp timeIntervalSince1970], &bit_offset, 32);
	set_bits(buffer, [unknown34 unsignedLongValue], &bit_offset, 32);	// unknown34 = (long) -1 (except for newbies, when = 0)
	for (int i = 0; i < 20; i++)
	{
		set_bits(buffer, [hotkey[i] shortValue], &bit_offset, 16);
		set_bits(buffer, [hotkey_b[i] shortValue], &bit_offset, 16);
	}
	for (int i = 0; i < 32; i++)
	{
		set_bits(buffer, [appearance[i/16][i%16] charValue], &bit_offset, 8);
	}
	for (int i = 0; i < 3; i++)
	{
		if ([currentDifficulty intValue] == i)
			set_bits(buffer, [currentAct charValue] | 0x80, &bit_offset, 8);
		else set_bits(buffer, 0, &bit_offset, 8);
	}
	set_bits(buffer, [mapSeed unsignedLongValue], &bit_offset, 32);
	if ([[mercenary valueForKey:@"active"] boolValue] == true)
	{
		set_bits(buffer, [[mercenary valueForKey:@"unknown0_0"] charValue], &bit_offset, 8);
		set_bits(buffer, [[mercenary valueForKey:@"unknown1_0"] charValue], &bit_offset, 8);
		set_bits(buffer, [[mercenary valueForKey:@"dead"] boolValue], &bit_offset, 1);
		set_bits(buffer, [[mercenary valueForKey:@"unknown2_1"] charValue], &bit_offset, 7);
		set_bits(buffer, [[mercenary valueForKey:@"unknown3_0"] charValue], &bit_offset, 8);
		set_bits(buffer, [[mercenary valueForKey:@"guid"] unsignedLongValue], &bit_offset, 32);
		set_bits(buffer, [[mercenary valueForKey:@"name"] unsignedShortValue], &bit_offset, 16);
		set_bits(buffer, [[mercenary valueForKey:@"type"] unsignedShortValue], &bit_offset, 16);
		set_bits(buffer, [[mercenary valueForKey:@"experience"] unsignedLongValue], &bit_offset, 32);
	}
	else for (int i = 0; i < 4; i++)
		set_bits(buffer, 0, &bit_offset, 32);
	memcpy(buffer + bit_offset/8, [unknownBF bytes], 144);	// unknownBF (144 bytes, 36 longs)
	bit_offset += 144*8;
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// quests
	set_bits(buffer, NSSwapLittleLongToHost('Woo!'), &bit_offset, 32);
	set_bits(buffer, 6, &bit_offset, 32);		// version
	set_bits(buffer, 298, &bit_offset, 16);		// length
	for (int d = 0; d < 3; d++)					// each difficulty is 96 bytes
	{
		for (int a = 0; a < 5; a++)
		{
			Quest *quest;
			Act *act = [[[difficulties objectAtIndex:d] valueForKey:@"acts"] objectAtIndex:a];
//			set_bits(buffer, [[act valueForKey:@"introduction"] unsignedShortValue], &bit_offset, 16);
			NSEnumerator *questEnum = [[act valueForKey:@"quests"] objectEnumerator];
			while (quest = [questEnum nextObject])
				set_bits(buffer, [[quest valueForKey:@"progress"] unsignedShortValue], &bit_offset, 16);
//			if (a == 3)  // act IV
//			{
//				set_bits(buffer, 0, &bit_offset, 16);   // have seen 1 at this location (char had compleated act, unknown value before)
//				set_bits(buffer, 0, &bit_offset, 16);
//				set_bits(buffer, 0, &bit_offset, 16);
//			}
//			set_bits(buffer, [[act valueForKey:@"completion"] unsignedShortValue], &bit_offset, 16);	// move above 3 unused acts?
//			if (a == 3)  // act IV
//			{
//				set_bits(buffer, 0, &bit_offset, 16);   // talked to cain
//				set_bits(buffer, 0, &bit_offset, 16);   // unknown4C
//			}
		}
//		set_bits(buffer, 0, &bit_offset, 96);	// unknown5E ignored
	}
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// waypoints
	Difficulty *diff;
	set_bits(buffer, NSSwapLittleShortToHost('WS'), &bit_offset, 16);
	set_bits(buffer, 1, &bit_offset, 32);		// version
	set_bits(buffer, 80, &bit_offset, 16);		// length
	NSEnumerator *diffEnum = [difficulties objectEnumerator];
	while (diff = [diffEnum nextObject])
	{
		Act *act;
		set_bits(buffer, 2, &bit_offset, 8);	// unknown0[0] = 2
		set_bits(buffer, 1, &bit_offset, 8);	// unknown0[1] = 1
		NSEnumerator *actEnum = [[diff valueForKey:@"acts"] objectEnumerator];
		while (act = [actEnum nextObject])
		{
			// should write 39 bits out
			Waypoint *wp;
			NSEnumerator *wpEnum = [[act valueForKey:@"waypoints"] objectEnumerator];
			while (wp = [wpEnum nextObject])
				set_bits(buffer, [[wp valueForKey:@"active"] boolValue], &bit_offset, 1);
		}
		set_bits(buffer, 0, &bit_offset, 137);	// points[4.875] and onwards I just assume are zero :)
	}
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// npcs
	set_bits(buffer, NSSwapLittleShortToHost(0x0177), &bit_offset, 16);
	set_bits(buffer, 52, &bit_offset, 16);
	for (int i = 0; i < 2; i++)
	{
		NSString *key;
		switch (i)
		{
			case 0:	key = @"introduction"; break;
			case 1:	key = @"congratulation"; break;
			default: key = nil; break;
		}
		
		diffEnum = [difficulties objectEnumerator];
		while (diff = [diffEnum nextObject])
		{
			Act *act;
			NSEnumerator *actEnum = [[diff valueForKey:@"acts"] objectEnumerator];
			while (act = [actEnum nextObject])
			{
				NPC *npc;
				NSEnumerator *npcEnum = [[act valueForKey:@"npcs"] objectEnumerator];
				while (npc = [npcEnum nextObject])
					set_bits(buffer, [[npc valueForKey:key] boolValue], &bit_offset, 1);
			}
			
			set_bits(buffer, 0, &bit_offset, 29);	// unknown4_3
		}
	}
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// stats
	set_bits(buffer, NSSwapLittleShortToHost('gf'), &bit_offset, 16);
	write_property_list(buffer, &bit_offset, stats, true);
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// skills
	Skill *skill;
	char c = [characterClass charValue];
	NSEnumerator *enumerator = [skills objectEnumerator];
	set_bits(buffer, NSSwapLittleShortToHost('if'), &bit_offset, 16);
	while (skill = [enumerator nextObject])
		if ([skill charclassAsInt] == c)
			set_bits(buffer, [[skill valueForKey:@"points"] unsignedCharValue], &bit_offset, 8);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// items
	Item *current_item;
	set_bits(buffer, NSSwapLittleShortToHost('JM'), &bit_offset, 16);
	set_bits(buffer, [items count], &bit_offset, 16);
	enumerator = [items objectEnumerator];
	while (current_item = [enumerator nextObject])
	{
		NSData *item_data = [current_item data];
		unsigned long item_length = [item_data length];
		memcpy(buffer + (bit_offset / 8), [item_data bytes], item_length);
		bit_offset += item_length * 8;
	}
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// corpses
	Corpse *corpse;
	set_bits(buffer, NSSwapLittleShortToHost('JM'), &bit_offset, 16);
	set_bits(buffer, [corpses count], &bit_offset, 16);
	enumerator = [corpses objectEnumerator];
	while (corpse = [enumerator nextObject])
	{
		set_bits(buffer, [corpse unknown0], &bit_offset, 32);
		set_bits(buffer, [corpse xPos], &bit_offset, 32);
		set_bits(buffer, [corpse yPos], &bit_offset, 32);
		
		set_bits(buffer, NSSwapLittleShortToHost('JM'), &bit_offset, 16);
		set_bits(buffer, [[corpse items] count], &bit_offset, 16);
		NSEnumerator *enumerator2 = [[corpse items] objectEnumerator];
		while (current_item = [enumerator2 nextObject])
		{
			NSData *item_data = [current_item data];
			unsigned long item_length = [item_data length];
			memcpy(buffer + (bit_offset / 8), [item_data bytes], item_length);
			bit_offset += item_length * 8;
		}
	}
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// merc
	if ([expansion boolValue])
	{
		set_bits(buffer, NSSwapLittleShortToHost('jf'), &bit_offset, 16);
		if ([[mercenary valueForKey:@"active"] boolValue])
		{
			set_bits(buffer, NSSwapLittleShortToHost('JM'), &bit_offset, 16);
			set_bits(buffer, [[mercenary items] count], &bit_offset, 16);
			enumerator = [[mercenary items] objectEnumerator];
			while (current_item = [enumerator nextObject])
			{
				NSData *item_data = [current_item data];
				unsigned long item_length = [item_data length];
				memcpy(buffer + (bit_offset / 8), [item_data bytes], item_length);
				bit_offset += item_length * 8;
			}
		}
	}
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// golem
	if ([expansion boolValue])
	{
		set_bits(buffer, NSSwapLittleShortToHost('kf'), &bit_offset, 16);
		set_bits(buffer, (golemItem? 1:0), &bit_offset, 8);
		if (golemItem)
		{
			NSData *item_data = [golemItem data];
			unsigned long item_length = [item_data length];
			memcpy(buffer + (bit_offset / 8), [item_data bytes], item_length);
			bit_offset += item_length * 8;
		}
	}
	
	// advance bit_offset to start of next byte
	bit_offset += ((bit_offset % 8)? 8-(bit_offset % 8):0);
	
	// verify bit_offset is at start of next byte
	NSParameterAssert(bit_offset % 8 == 0);
	
	// length
	uint32_t new_offset = 64;
	uint32_t file_length = bit_offset / 8;
	set_bits(buffer, file_length, &new_offset, 32);	// go back and fill in file length
	
	// calculate and set the checksum
	uint32_t checksum = 0;
	for (uint32_t i = 0; i < file_length; i++)
		checksum = (checksum << 1) + (checksum >> 31) + *((uint8_t *) buffer+i);
	set_bits(buffer, checksum, &new_offset, 32);
	
	// create and return the NSData object
	return [NSData dataWithBytesNoCopy:buffer length:file_length freeWhenDone:YES];
}

- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)docPath ofType:(NSString *)docType saveOperation:(NSSaveOperationType)saveOp
{
	NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:[super fileAttributesToWriteToFile:docPath ofType:docType saveOperation:saveOp]];
	[newAttributes setObject:[NSNumber numberWithUnsignedLong:'Dbl2'] forKey:NSFileHFSCreatorCode];
	[newAttributes setObject:[NSNumber numberWithUnsignedLong:'D2sv'] forKey:NSFileHFSTypeCode];
	return newAttributes;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type
{
	const unsigned long length = [data length];
	const unsigned char *d2s = (const unsigned char *) [data bytes];
	NSParameterAssert(NSSwapLittleLongToHost(*(unsigned long *)(d2s+4)) == kVersion110);
	NSParameterAssert(NSSwapLittleLongToHost(*(unsigned long *)(d2s+8)) == length);
	
	// read data
	uint32_t bit_offset = 0;
	[self readHeaderWithBytes:d2s		bitOffset:&bit_offset];		// UªUª
	if (type && ![newChar boolValue]) {	// type == nil for mdimports, which doesn't need items
	[self readQuestsWithBytes:d2s		bitOffset:&bit_offset];		// Woo!
	[self readWaypointsWithBytes:d2s	bitOffset:&bit_offset];		// WS
	[self readNPCsWithBytes:d2s			bitOffset:&bit_offset];		// .w
	[self readStatsWithBytes:d2s		bitOffset:&bit_offset];		// gf
	[self readSkillsWithBytes:d2s		bitOffset:&bit_offset];		// if
	[self readItemsWithBytes:d2s		bitOffset:&bit_offset];		// JM
	[self readCorpsesWithBytes:d2s		bitOffset:&bit_offset];		// JM too
	if ([expansion boolValue]) {
	[self readMercItemsWithBytes:d2s	bitOffset:&bit_offset];		// jf
	[self readGolemWithBytes:d2s		bitOffset:&bit_offset]; }}	// kf
	return YES;
}

- (void)readHeaderWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	// verify constants
	unsigned long magic = NSSwapLittleLongToHost(read_bits(data, bit_offset, 32));
	unsigned long version = read_bits(data, bit_offset, 32);
	unsigned long length = read_bits(data, bit_offset, 32);
	unsigned long checksum = read_bits(data, bit_offset, 32);
	NSParameterAssert(magic == 0x55AA55AA);
	NSParameterAssert(version == kVersion110);
	NSParameterAssert(length > 0);
	NSParameterAssert(checksum != 0);
	
	// read variables (40 bytes)
	unknown10 = [[NSNumber alloc] initWithUnsignedLong:read_bits(data, bit_offset, 32)];
	char cName[17] = { 0 };
	memcpy(cName, data + (*bit_offset/8), 16);
	name = [[NSString alloc] initWithCString:cName]; *bit_offset += 16*8;
	newChar = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	unknown24_1 = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	hardcore = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	died = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	unknown24_4 = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	expansion = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	unknown24_6 = [[NSNumber alloc] initWithBool:read_bits(data, bit_offset, 1)];
	unknown24_7 = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 3)];
	title = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 3)];
	unknown25_5 = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 3)];
	selectedWeapon = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 16)];
	characterClass = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 8)];
	unknown29 = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 8)];
	unknown30 = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 8)];
	selectionLevel = [[NSNumber alloc] initWithUnsignedChar:read_bits(data, bit_offset, 8)];
	createdTimestamp = [[NSDate dateWithTimeIntervalSince1970:read_bits(data, bit_offset, 32)] retain];
	modifiedTimestamp = [[NSDate dateWithTimeIntervalSince1970:read_bits(data, bit_offset, 32)] retain];
	unknown34 = [[NSNumber alloc] initWithLong:read_bits(data, bit_offset, 32)];
	
	// read skill hotkeys (80 bytes)
	for (int i = 0; i < 20; i++)
	{
		hotkey[i] = [[NSNumber alloc] initWithShort:read_bits(data, bit_offset, 16)];
		hotkey_b[i] = [[NSNumber alloc] initWithUnsignedShort:read_bits(data, bit_offset, 16)];
	}
	
	// read appearance data (32 bytes)
	for (int i = 0; i < 32; i++)
	{
		appearance[i/16][i%16] = [[NSNumber alloc] initWithChar:read_bits(data, bit_offset, 8)];
	}
	
	// read more header variables (7 bytes)
	for (unsigned char i = 0; i < 3; i++)
	{
		char byte = read_bits(data, bit_offset, 8);
		if (byte & 0x80)
		{
			currentAct = [[NSNumber alloc] initWithUnsignedChar:byte & 0x7F];
			currentDifficulty = [[NSNumber alloc] initWithUnsignedChar:i];
		}
	}
	mapSeed = [[NSNumber alloc] initWithUnsignedLong:read_bits(data, bit_offset, 32)];
	
	// mercenary
	[mercenary setValue:[NSNumber numberWithChar:read_bits(data, bit_offset, 8)] forKey:@"unknown0_0"];
	[mercenary setValue:[NSNumber numberWithChar:read_bits(data, bit_offset, 8)] forKey:@"unknown1_0"];
	[mercenary setValue:[NSNumber numberWithBool:read_bits(data, bit_offset, 1)] forKey:@"dead"];
	[mercenary setValue:[NSNumber numberWithChar:read_bits(data, bit_offset, 7)] forKey:@"unknown2_1"];
	[mercenary setValue:[NSNumber numberWithChar:read_bits(data, bit_offset, 8)] forKey:@"unknown3_0"];
	[mercenary setValue:[NSNumber numberWithUnsignedLong:read_bits(data, bit_offset, 32)] forKey:@"guid"];
	[mercenary setValue:[NSNumber numberWithShort:read_bits(data, bit_offset, 16)] forKey:@"name"];
	[mercenary setValue:[NSNumber numberWithShort:read_bits(data, bit_offset, 16)] forKey:@"type"];
	unsigned long merc_xp = read_bits(data, bit_offset, 32);
	[mercenary setValue:[NSNumber numberWithUnsignedLong:merc_xp] forKey:@"experience"];
	[mercenary setValue:[NSNumber numberWithBool:merc_xp? true:false] forKey:@"active"];
	unknownBF = [[NSData alloc] initWithBytes:data + *bit_offset/8 length:144];		// 144 aparently empty bytes (36 longs)
	*bit_offset += 144*8;
	
	// unsaved vars
	selectedDifficulty = [currentDifficulty copy];
}

- (void)readQuestsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	// verify constants
	unsigned long magic = NSSwapLittleLongToHost(read_bits(data, bit_offset, 32));
	unsigned long version = read_bits(data, bit_offset, 32);
	unsigned short length = read_bits(data, bit_offset, 16);
	NSParameterAssert(magic == 'Woo!');
	NSParameterAssert(version == 6);
	NSParameterAssert(length == 298);
	
	// read variables
	for (int d = 0; d < 3; d++)
	{
		for (int a = 0; a < 5; a++)
		{
			Quest *quest;
			Act *act = [[[difficulties objectAtIndex:d] valueForKey:@"acts"] objectAtIndex:a];
//			[act setValue:[NSNumber numberWithShort:read_bits(data, bit_offset, 16)] forKey:@"introduction"];
			NSEnumerator *questEnum = [[act valueForKey:@"quests"] objectEnumerator];
			while (quest = [questEnum nextObject])
				[quest setValue:[NSNumber numberWithShort:read_bits(data, bit_offset, 16)] forKey:@"progress"];
//			if (a == 3)  // act IV
//			{
//				*bit_offset += 16;	// quest 4 ignored
//				*bit_offset += 16;	// quest 5 ignored
//				*bit_offset += 16;	// quest 6 ignored
//			}
//			[act setValue:[NSNumber numberWithShort:read_bits(data, bit_offset, 16)] forKey:@"completion"];
//			if (a == 3)  // act IV
//			{
//				*bit_offset += 16;	// talked to cain
//				*bit_offset += 16;	// unknown4C
//			}
		}
//		*bit_offset += 96;			// unknown5E ignored
	}
}

- (void)readWaypointsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	// verify constants
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	unsigned long version = read_bits(data, bit_offset, 32);
	unsigned short length = read_bits(data, bit_offset, 16);
	NSParameterAssert(magic == 'WS');
	NSParameterAssert(version == 1);
	NSParameterAssert(length == 80);
	
	// read variables
	Difficulty *diff;
	NSEnumerator *diffEnum = [difficulties objectEnumerator];
	while (diff = [diffEnum nextObject])
	{
		Act *act;
		unsigned short unknown0 = read_bits(data, bit_offset, 16);
		NSParameterAssert(unknown0 == 258);
		NSEnumerator *actEnum = [[diff valueForKey:@"acts"] objectEnumerator];
		while (act = [actEnum nextObject])
		{
			// should read 39 bits total
			Waypoint *wp;
			NSEnumerator *wpEnum = [[act valueForKey:@"waypoints"] objectEnumerator];
			while (wp = [wpEnum nextObject])
				[wp setValue:[NSNumber numberWithBool:read_bits(data, bit_offset, 1)] forKey:@"active"];
		}
		*bit_offset += 137;		// (22*8 -39); points[4.875] and onwards I just assume are zero :)
	}
}

- (void)readNPCsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	// verify constants
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	unsigned short length = read_bits(data, bit_offset, 16);
	NSParameterAssert(magic == 0x0177);
	NSParameterAssert(length == 52);
	
	// read variables
//	unsigned long long i = read_bits(data, bit_offset, 32) << 32;   i += read_bits(data, bit_offset, 32);
//	unsigned long long c = read_bits(data, bit_offset, 32) << 32;	c += read_bits(data, bit_offset, 32);
	
	// read introductions
	Difficulty *diff;
	NSEnumerator *diffEnum = [difficulties objectEnumerator];
	while (diff = [diffEnum nextObject])
	{
		Act *act;
		NSEnumerator *actEnum = [[diff valueForKey:@"acts"] objectEnumerator];
		while (act = [actEnum nextObject])
		{
			NPC *npc;
			NSEnumerator *npcEnum = [[act valueForKey:@"npcs"] objectEnumerator];
			while (npc = [npcEnum nextObject])
				[npc setValue:[NSNumber numberWithBool:read_bits(data, bit_offset, 1)] forKey:@"introduction"];
		}
		*bit_offset += 29;
	}
	
	// read congratulations
	diffEnum = [difficulties objectEnumerator];
	while (diff = [diffEnum nextObject])
	{
		Act *act;
		NSEnumerator *actEnum = [[diff valueForKey:@"acts"] objectEnumerator];
		while (act = [actEnum nextObject])
		{
			NPC *npc;
			NSEnumerator *npcEnum = [[act valueForKey:@"npcs"] objectEnumerator];
			while (npc = [npcEnum nextObject])
				[npc setValue:[NSNumber numberWithBool:read_bits(data, bit_offset, 1)] forKey:@"congratulation"];
		}
		*bit_offset += 29;
	}
}

- (void)readStatsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'gf');
	
	id old = stats;
	stats = [read_property_list(data, bit_offset, true) retain];
	[old release];
	*bit_offset += (*bit_offset % 8)? 8-(*bit_offset % 8):0;
}

- (void)readSkillsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'if');
	
	Skill *skill;
	int c = [characterClass intValue];
	NSEnumerator *enumerator = [skills objectEnumerator];
	while (skill = [enumerator nextObject])
		if ([skill charclassAsInt] == c)
			[skill setValue:[NSNumber numberWithUnsignedChar:read_bits(data, bit_offset, 8)] forKey:@"points"];
}

- (void)readItemsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	id old = items;
	items = [[Item itemsFromList:data bitOffset:bit_offset] retain];
	[old release];
}

- (void)readCorpsesWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'JM');
	
	short corpse_count = read_bits(data, bit_offset, 16);
	if (corpse_count)
	{
		corpses = [[NSMutableArray alloc] init];
		for (short i = 0; i < corpse_count; i++)
		{
			unsigned long unknown = read_bits(data, bit_offset, 32);
			unsigned long ypos = read_bits(data, bit_offset, 32);
			unsigned long xpos = read_bits(data, bit_offset, 32);
			Corpse *corpse = [[Corpse alloc] initWithUnknown:unknown xpos:xpos ypos:ypos];
			[corpse setItems:[Item itemsFromList:data bitOffset:bit_offset]];
			[corpses addObject:corpse];
		}
	}
}

- (void)readMercItemsWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	if (!mercenary) return;
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'jf');
	
	// check next two bytes aren't the golem (i.e. there is an item list for the merc) - probably a better way to do this
	if (*(short *)(data + (*bit_offset/8)) != 'kf')
		[mercenary setItems:[Item itemsFromList:data bitOffset:bit_offset]];
}

- (void)readGolemWithBytes:(const uint8_t *)data bitOffset:(uint32_t *)bit_offset
{
	unsigned short magic = NSSwapLittleShortToHost(read_bits(data, bit_offset, 16));
	NSParameterAssert(magic == 'kf');
	
	if (read_bits(data, bit_offset, 1))
	{
		*bit_offset += 7;	// unknown flags
		golemItem = [[Item itemWithBytes:data bitOffset:bit_offset] retain];
	}
	*bit_offset += (*bit_offset % 8)? 8-(*bit_offset % 8):0;
}
@end
