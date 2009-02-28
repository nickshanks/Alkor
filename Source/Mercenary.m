#import "Mercenary.h"
#import "CharacterDocument.h"
#import "MPQReader.h"
#import "AppDelegate.h"

static NSArray *mercClassNames = [[NSArray alloc] initWithObjects:@"Rogue Scout", @"Desert Wolf", @"Iron Mage", @"Barbarian", nil];
static NSArray *rogueNames = [[NSArray alloc] initWithObjects:@"Aliza", @"Amplisa", @"Annor", @"Abhaya", @"Elly", @"Paige", @"Basanti", @"Blaise", @"Kyoko", @"Klaudia", @"Kundri", @"Kyle", @"Visala", @"Elexa", @"Floria", @"Fiona", @"Gwinni", @"Gaile", @"Hannah", @"Heather", @"Iantha", @"Diane", @"Isolde", @"Divo", @"Ithera", @"Itonya", @"Liene", @"Maeko", @"Mahala", @"Liaza", @"Meghan", @"Olena", @"Oriana", @"Ryann", @"Rozene", @"Raissa", @"Sharyn", @"Shikha", @"Debi", @"Tylena", @"Wendy", nil];
static NSArray *wolfNames = [[NSArray alloc] initWithObjects:@"Hazade", @"Alhizeer", @"Azrael", @"Ahsab", @"Chalan", @"Haseen", @"Razan", @"Emilio", @"Pratham", @"Fazel", @"Jemali", @"Kasim", @"Gulzar", @"Mizan", @"Leharas", @"Durga", @"Neeraj", @"Ilzan", @"Zanarhi", @"Waheed", @"Vikhyat", nil];
static NSArray *mageNames = [[NSArray alloc] initWithObjects:@"Jelani", @"Barani", @"Jabari", @"Devak", @"Raldin", @"Telash", @"Ajheed", @"Narphet", @"Khaleel", @"Phaet", @"Geshef", @"Vanji", @"Haphet", @"Thadar", @"Yatiraj", @"Rhadge", @"Yashied", @"Jarulf", @"Flux", @"Scorch", nil];
static NSArray *barbNames = [[NSArray alloc] initWithObjects:@"Varaya", @"Khan", @"Klisk", @"Bors", @"Brom", @"Wiglaf", @"Hrothgar", @"Scyld", @"Healfdane", @"Heorogar", @"Halgaunt", @"Hygelac", @"Egtheow", @"Bohdan", @"Wulfgar", @"Hild", @"Heatholaf", @"Weder", @"Vikhyat", @"Unferth", @"Sigemund", @"Heremod", @"Hengest", @"Folcwald", @"Frisian", @"Hnaef", @"Guthlaf", @"Oslaf", @"Yrmenlaf", @"Garmund", @"Freawaru", @"Eadgils", @"Onela", @"Damien", @"Erfor", @"Weohstan", @"Wulf", @"Bulwye", @"Lief", @"Magnus", @"Klatu", @"Drus", @"Hoku", @"Kord", @"Uther", @"Ip", @"Ulf", @"Tharr", @"Kaelim", @"Ulric", @"Alaric", @"Ethelred", @"Caden", @"Elgifu", @"Tostig", @"Alcuin", @"Emund", @"Sigurd", @"Gorm", @"Hollis", @"Ragnar", @"Torkel", @"Wulfstan", @"Alban", @"Barloc", @"Bill", @"Theodoric", nil];
static NSArray *rogueSkillNames = [[NSArray alloc] initWithObjects:@"Fire Arrow", @"Cold Arrow", nil];
static NSArray *wolfSkillNames = [[NSArray alloc] initWithObjects:@"Combat", @"Defensive", @"Offensive", nil];
static NSArray *mageSkillNames = [[NSArray alloc] initWithObjects:@"Fire Spells", @"Cold Spells", @"Lightning Spells", nil];
static NSArray *barbSkillNames = [[NSArray alloc] initWithObjects:@"Bash & Stun", nil];

static const char * const merc_class_names[4] = { "Rogue Scout", "Desert Wolf", "Iron Mage", "Barbarian" };
static const char merc_exp[] = {	100, 105, 110, 115, 120, 125,					// rogue scout
									110, 110, 110, 120, 120, 120, 130, 130, 130,	// desert wolf
									110, 120, 110, 120, 130, 120, 130, 140, 130,	// iron mage
									120, 120, 130, 130, 140, 140 };					// barbarian

@implementation Mercenary

- (void)setTypeForClass:(unsigned short)value
{
	[self setTypeForClass:value withAttribute:[self attribute] andDifficulty:[self difficulty]];
}

- (void)setTypeForClass:(unsigned short)value withAttribute:(unsigned short)attribute
{
	[self setTypeForClass:value withAttribute:attribute andDifficulty:[self difficulty]];
}

- (void)setTypeForClass:(unsigned short)value withDifficulty:(unsigned short)difficulty
{
	[self setTypeForClass:value withAttribute:[self attribute] andDifficulty:difficulty];
}

- (void)setTypeForClass:(unsigned short)value withAttribute:(unsigned short)attribute andDifficulty:(unsigned short)difficulty
{
	id old = type;
	switch (value)
	{
		case 0: type = [[NSNumber alloc] initWithUnsignedShort:( 0 + 2*difficulty + attribute)]; break;
		case 1: type = [[NSNumber alloc] initWithUnsignedShort:( 6 + 3*difficulty + attribute)]; break;
		case 2: type = [[NSNumber alloc] initWithUnsignedShort:(15 + 3*difficulty + attribute)]; break;
		case 3: type = [[NSNumber alloc] initWithUnsignedShort:(24 + 2*difficulty + attribute)]; break;
		default: old = nil; break;
	}
	[old release];
}

- (unsigned short)mercClass
{
	return [self mercClassForType:[type unsignedShortValue]];
}

- (unsigned short)mercClassForType:(unsigned short)value
{
	switch (value)
	{
		case 0: case 1: case 2: case 3: case 4: case 5:										return 0;
		case 6: case 7: case 8: case 9: case 10: case 11: case 12: case 13: case 14:		return 1;
		case 15: case 16: case 17: case 18: case 19: case 20: case 21: case 22: case 23:	return 2;
		case 24: case 25: case 26: case 27: case 28: case 29:								return 3;
		default:																			return USHRT_MAX;
	}
}

- (void)setMercClass:(unsigned short)value
{
	if (value > 3) value = 3;
	
	// check current name & attribute is within new class' bounds
	[self setName:[self name] forClass:value];
	[self setAttribute:[self attribute] forClass:value];
	[self setDifficulty:[self difficulty] forClass:value];
	[self setTypeForClass:value];
	
	// recalculate names & attributes for new class
	[self willChangeValueForKey:@"names"];
	[self willChangeValueForKey:@"attributes"];
	[self willChangeValueForKey:@"difficulties"];
	[self didChangeValueForKey:@"names"];
	[self didChangeValueForKey:@"attributes"];
	[self didChangeValueForKey:@"difficulties"];
}

- (unsigned short)name
{
	return [name unsignedShortValue];
}

- (void)setName:(unsigned short)value
{
	[self setName:value forClass:[self mercClass]];
}

- (void)setName:(unsigned short)value forClass:(unsigned short)mercClass
{
	switch (mercClass)
	{
		case 0: if (value > 40) value = 40; break;
		case 1: if (value > 20) value = 20; break;
		case 2: if (value > 19) value = 19; break;
		case 3: if (value > 66) value = 66; break;
	}
	id old = name;
	name = [[NSNumber alloc] initWithUnsignedShort:value];
	[old release];
}

- (unsigned short)attribute
{
	switch ([type unsignedShortValue])
	{
		case 0: case 2: case 4: case 6: case 9: case 12: case 15: case 18: case 21: case 24: case 25: case 26: case 27: case 28: case 29:	return 0;
		case 1: case 3: case 5: case 7: case 10: case 13: case 16: case 19: case 22:														return 1;
		case 8: case 11: case 14: case 17: case 20: case 23:																				return 2;
		default:																															return USHRT_MAX;
	}
}

- (void)setAttribute:(unsigned short)value
{
	[self setAttribute:value forClass:[self mercClass]];
}

- (void)setAttribute:(unsigned short)value forClass:(unsigned short)mercClass
{
	switch (mercClass)
	{
		case 0: if (value > 1) value = 1; break;
		case 1: if (value > 2) value = 2; break;
		case 2: if (value > 2) value = 2; break;
		case 3: if (value > 0) value = 0; break;
	}
	[self setTypeForClass:mercClass withAttribute:value];
}

- (unsigned short)difficulty
{
	switch ([type unsignedShortValue])
	{
		case 0: case 1: case 6: case 7: case 8: case 15: case 16: case 17: case 24: case 25:		return 0;
		case 2: case 3: case 9: case 10: case 11: case 18: case 19: case 20: case 26: case 27:		return 1;
		case 4: case 5: case 12: case 13: case 14: case 21: case 22: case 23: case 28: case 29:		return 2;
		default:																					return USHRT_MAX;
	}
}

- (void)setDifficulty:(unsigned short)value
{
	[self setDifficulty:value forClass:[self mercClass]];
}

- (void)setDifficulty:(unsigned short)value forClass:(unsigned short)mercClass
{
	if (value > 2) value = 2;
	[self setTypeForClass:mercClass withDifficulty:value];
}

- (NSArray *)mercClasses
{
	return mercClassNames;
}

- (void)setMercClasses:(NSArray *)value
{
#pragma unused(value)
}

- (NSArray *)names
{
//	NSArray *hirelings = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/hireling.txt"];
//	id entry = [hirelings firstObjectReturningValue:type forKey:@"id"];
//	NSString *nameFirst = [entry valueForKey:@"namefirst"];
//	NSString *nameLast = [entry valueForKey:@"namelast"];
	
	// need to scan keys between nameFirst and nameLast *in the order they are in the tbl file*
	switch ([self mercClass])
	{
		case 0: return rogueNames;
		case 1: return wolfNames;
		case 2: return mageNames;
		case 3: return barbNames;
		default: return nil;
	}
}

- (void)setNames:(NSArray *)value
{
#pragma unused(value)
}

- (NSArray *)attributes
{
	switch ([self mercClass])
	{
		case 0: return rogueSkillNames;
		case 1: return wolfSkillNames;
		case 2: return mageSkillNames;
		case 3: return barbSkillNames;
		default: return nil;
	}
}

- (void)setAttributes:(NSArray *)value
{
#pragma unused(value)
}

- (unsigned long)level
{
	return merc_level_for_experience([type charValue], [experience unsignedLongValue]);
}

- (void)setLevel:(unsigned long)value
{
	[self setValue:[NSNumber numberWithUnsignedLong:merc_experience_for_level([type charValue], value)] forKey:@"experience"];
}

- (unsigned long)life
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"hp"];
	int colC = [table columnWithTitle:@"hp/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseHP = [table numberForRow:row column:colB];
			NSNumber *levelHP = [table numberForRow:row column:colC];
			if (baseHP && levelHP)
				return (unsigned long)([baseHP floatValue] + ([self level]-1)*[levelHP floatValue]);
		}
	}
*/	return 0;
}

- (unsigned long)resistance
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"resist"];
	int colC = [table columnWithTitle:@"resist/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseRes = [table numberForRow:row column:colB];
			NSNumber *levelRes = [table numberForRow:row column:colC];
			if (baseRes && levelRes)
				return (unsigned long)([baseRes floatValue] + ([self level]-1)*[levelRes floatValue]);
		}
	}
*/	return 0;
}

- (unsigned long)strength
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"str"];
	int colC = [table columnWithTitle:@"str/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseStr = [table numberForRow:row column:colB];
			NSNumber *levelStr = [table numberForRow:row column:colC];
			if (baseStr && levelStr)
				return (unsigned long)([baseStr floatValue] + ([self level]-1)*[levelStr floatValue]);
		}
	}
*/	return 0;
}

- (unsigned long)dexterity
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"dex"];
	int colC = [table columnWithTitle:@"dex/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseDex = [table numberForRow:row column:colB];
			NSNumber *levelDex = [table numberForRow:row column:colC];
			if (baseDex && levelDex)
				return (unsigned long)([baseDex floatValue] + ([self level]-1)*[levelDex floatValue]);
		}
	}
*/	return 0;
}

- (NSString *)damage
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"dmg-min"];
	int colC = [table columnWithTitle:@"dmg-max"];
	int colD = [table columnWithTitle:@"dmg/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 && colD != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *minDmg = [table numberForRow:row column:colB];
			NSNumber *maxDmg = [table numberForRow:row column:colC];
			NSNumber *levelDmg = [table numberForRow:row column:colD];
			if (minDmg && maxDmg && levelDmg)
				return [NSString stringWithFormat:@"%d-%d", (int)([minDmg floatValue] + ([self level]-1)*[levelDmg floatValue]), (int)([maxDmg floatValue] + ([self level]-1)*[levelDmg floatValue])];
		}
	}
*/	return 0;
}

- (unsigned long)defence
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"defense"];
	int colC = [table columnWithTitle:@"def/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseDef = [table numberForRow:row column:colB];
			NSNumber *levelDef = [table numberForRow:row column:colC];
			if (baseDef && levelDef)
				return (unsigned long)([baseDef floatValue] + ([self level]-1)*[levelDef floatValue]);
		}
	}
*/	return 0;
}

- (unsigned long)attackRating
{
/*	Table *table = [[MPQReader defaultReader] tableWithContentsOfFile:@"data/global/excel/hireling.txt"];
	int colA = [table columnWithTitle:@"id"];	// bug: some hirelings have multiple entries with the same type (ID)
	int colB = [table columnWithTitle:@"ar"];
	int colC = [table columnWithTitle:@"ar/lvl"];
	if ( colA != -1 && colB != -1 && colC != -1 )
	{
		int row = [table rowWithInt:[type intValue] inColumn:colA];
		if (row != -1)
		{
			NSNumber *baseAR = [table numberForRow:row column:colB];
			NSNumber *levelAR = [table numberForRow:row column:colC];
			if (baseAR && levelAR)
				return (unsigned long)([baseAR floatValue] + ([self level]-1)*[levelAR floatValue]);
		}
	}
*/	return 0;
}

- (unsigned long)experienceForCurrentLevel
{
   return merc_experience_for_level([type charValue], [self level]);
}

- (unsigned long)experienceForNextLevel
{
   return merc_experience_for_level([type charValue], [self level]+1);
}

- (NSMutableArray *)items
{
	return items;
}

- (void)setItems:(NSMutableArray *)i
{
	id old = items; items = [i retain]; [old release];
}

- (NSString *)description
{	return [NSString stringWithFormat:@"name:%@, type:%@ class:%@, attribute:%@, difficulty:%@, dead:%@, GUID:%@, exp:%@ level:%@\nitems:%@", name, type, [self mercClass], [self attribute], [self difficulty], dead, guid, experience, [self level], items];
}
@end

inline unsigned long merc_experience_for_level(unsigned char merc_type, unsigned long level)
{
	if (level < 1)  level = 1;
	if (level > 99) level = 99;
	return merc_exp[merc_type] * level * level * (level+1);
}

inline unsigned long merc_level_for_experience(unsigned char merc_type, unsigned long exp)
{
	for (int i = 99; i > 0; i--)
		if (merc_experience_for_level(merc_type, i) < exp)
			return i;
	return 1;
}
