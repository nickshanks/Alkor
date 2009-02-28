#import "Skill.h"
#import "MPQReader.h"
#import "Localization.h"
#import "NGSCategories.h"

@implementation Skill

+ (Skill *)skillWithID:(unsigned long)s_id
{
	Skill *s = [[Skill alloc] initWithID:s_id];
	return [s autorelease];
}

- (Skill *)initWithID:(unsigned long)s_id
{
	self = [super init];
	if (!self) return nil;
	NSArray *skillTable = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/skills.txt"];
	skill = [[skillTable firstObjectReturningValue:[NSString stringWithFormat:@"%d", s_id] forKey:@"id"] retain];
	points = [[NSNumber alloc] initWithUnsignedChar:0];
	return self;
}

- (void)dealloc
{
	[skill release];
	[points release];
	[super dealloc];
}

- (NSString *)name
{
	NSArray *skillDescs = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/skilldesc.txt"];
	// has columns: SkillPage, SkillRow, SkillColumn, str name, str short, str long, str alt
	if ([[skill valueForKey:@"skilldesc"] isEqual:@""]) return [skill valueForKey:@"skill"];
	id desc = [skillDescs firstObjectReturningValue:[skill valueForKey:@"skilldesc"] forKey:@"skilldesc"];
	return Localise([desc valueForKey:@"str name"]);
}

- (NSString *)tree
{
	NSArray *skillDescs = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/skilldesc.txt"];
	id desc = [skillDescs firstObjectReturningValue:[skill valueForKey:@"skilldesc"] forKey:@"skilldesc"];
	return [desc valueForKey:@"skillpage"];
	// the keys in the string file are:
	//  amazon: StrSklTree6 (Javelin) StrSklTree7 (and Spear) StrSklTree4 (Skills)
	//			StrSklTree8 (Passive) StrSklTree9 (and Magic) StrSklTree4 (Skills)
	//			StrSklTree10 (Bow and) StrSklTree11 (Crossbow) StrSklTree4 (Skills)		etc.  -- I don't know where these keys come from
}

- (id)charclass
{
	return [skill valueForKey:@"charclass"];
}

- (int)charclassAsInt
{
	return [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/PlayerClass.txt"] indexOfFirstObjectReturningValue:[skill valueForKey:@"charclass"] forKey:@"code"];
}

@end
