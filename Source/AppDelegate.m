#import "AppDelegate.h"
#import "CharacterDocument.h"
#import "ItemDocument.h"
#import "Act.h"
#import "MPQReader.h"
#import "LegitamacyWarning.h"

globals g;

NSDictionary *allWarnings;
NSArray *armour, *misc, *weapons, *itemTable;
NSArray *bodypartCodes, *charmCodes, *spellCodes, *stackableCodes;
NSArray *gems, *lowqualityitems, *automagic, *magicprefix, *magicsuffix, *magicaffix, *rareaffix, *runes, *setitems, *uniqueitems;

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
#pragma unused(notification)
	// initalise globals
	g.debug = false;
	
	// create value transformers
	NSValueTransformer *transformer;
	transformer = [[[LevelFromExperienceTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"LevelFromExperience"];
	transformer = [[[StringFromItemVersionTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"StringFromItemVersion"];
	transformer = [[[NormalNameFromCodeTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NormalNameFromCode"];
	
	// load mopaq data
	armour = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/armor.txt"] retain];
	automagic = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/automagic.txt"];
	gems = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/gems.txt"] retain];
	lowqualityitems = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/lowqualityitems.txt"] retain];
	misc = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/misc.txt"] retain];
	magicprefix = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/MagicPrefix.txt"];
	magicsuffix = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/MagicSuffix.txt"];
	magicaffix = [[magicprefix arrayByAddingObjectsFromArray:magicsuffix] retain];
	NSArray *rareprefix = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/RarePrefix.txt"];
	NSArray *raresuffix = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/RareSuffix.txt"];
	rareaffix = [[raresuffix arrayByAddingObjectsFromArray:rareprefix] retain];
	runes = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/runes.txt"] retain];
	setitems = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/setitems.txt"] retain];
	uniqueitems = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/uniqueitems.txt"] retain];
	weapons = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/weapons.txt"] retain];
	itemTable = [[armour arrayByAddingObjectsFromArray:[weapons arrayByAddingObjectsFromArray:misc]] retain];
	
	// get special codes lists
	bodypartCodes = [[[misc objectsReturningValue:@"body" forKey:@"type"] valueForKey:@"code"] retain];
	
	// should do: scha is type given in misc.txt, take that typ ItemTypes, convert it to 'cham' then match on that
	NSArray *smallCharmCodes = [[misc objectsReturningValue:@"scha" forKey:@"type"] valueForKey:@"code"];
	NSArray *mediumCharmCodes = [[misc objectsReturningValue:@"mcha" forKey:@"type"] valueForKey:@"code"];
	NSArray *largeCharmCodes = [[misc objectsReturningValue:@"lcha" forKey:@"type"] valueForKey:@"code"];
	charmCodes = [[smallCharmCodes arrayByAddingObjectsFromArray:[mediumCharmCodes arrayByAddingObjectsFromArray:largeCharmCodes]] retain];
	
	NSArray *tomeCodes = [[misc objectsReturningValue:@"book" forKey:@"type"] valueForKey:@"code"];
	NSArray *scrollCodes = [[misc objectsReturningValue:@"scro" forKey:@"type"] valueForKey:@"code"];
	spellCodes = [[tomeCodes arrayByAddingObjectsFromArray:scrollCodes] retain];
	
/*	NSArray gemCodes = [[gems valueForKey:@"code"] retain];	// only gets gems & runes (missing jewel) - should use socketFillerCodes for checking socketability
	NSArray *gema = [[misc objectsReturningValue:@"gema" forKey:@"type"] valueForKey:@"code"];
	NSArray *gemt = [[misc objectsReturningValue:@"gemt" forKey:@"type"] valueForKey:@"code"];
	NSArray *gems = [[misc objectsReturningValue:@"gems" forKey:@"type"] valueForKey:@"code"];
	NSArray *geme = [[misc objectsReturningValue:@"geme" forKey:@"type"] valueForKey:@"code"];
	NSArray *gemr = [[misc objectsReturningValue:@"gemr" forKey:@"type"] valueForKey:@"code"];
	NSArray *gemd = [[misc objectsReturningValue:@"gemd" forKey:@"type"] valueForKey:@"code"];
	NSArray *gemz = [[misc objectsReturningValue:@"gemz" forKey:@"type"] valueForKey:@"code"];
	NSArray *rune = [[misc objectsReturningValue:@"rune" forKey:@"type"] valueForKey:@"code"];
	NSArray *jewl = [[misc objectsReturningValue:@"jewl" forKey:@"type"] valueForKey:@"code"];
	socketFillerCodes = [[gema arrayByAddingObjectsFromArray:
						 [gemt arrayByAddingObjectsFromArray:
						 [gems arrayByAddingObjectsFromArray:
						 [geme arrayByAddingObjectsFromArray:
						 [gemr arrayByAddingObjectsFromArray:
						 [gemd arrayByAddingObjectsFromArray:
						 [gemz arrayByAddingObjectsFromArray:
						 [rune arrayByAddingObjectsFromArray:jewl]]]]]]]] retain];	*/
	
	stackableCodes = [[[itemTable objectsReturningValue:@"1" forKey:@"stackable"] valueForKey:@"code"] retain];
	
	// create warnings array
	allWarnings = [[NSDictionary alloc] initWithObjectsAndKeys:
	[LegitamacyWarning warningWithSeverity:kErrorLevel		description:@"Character names must not begin or end with an underscore."],									@"CharNameBeginEndUnderscore",
	[LegitamacyWarning warningWithSeverity:kErrorLevel		description:@"Character names must have two or more letters."],												@"CharNameMinTwoLetters",
	[LegitamacyWarning warningWithSeverity:kWarningLevel	description:@"Your character is not an expansion character, their mercenary's items will not be saved."],	@"NonExpansionNoMercItems",
	[LegitamacyWarning warningWithSeverity:kWarningLevel	description:@"Your character is not an expansion character, the iron golem item will not be saved."],		@"NonExpansionNoGolemItem",
	[LegitamacyWarning warningWithSeverity:kWarningLevel	description:@"Your character is not a Necromancer, the iron golem item will not be saved."],				@"NonNecroNoGolemItem",
	[LegitamacyWarning warningWithSeverity:kNoteLevel		description:@"Your character is a dead hardcore character and cannot be played."],							@"HardcoreCharIsDead", nil];
	
	// set release note to latest
	currentNote = [[NSString alloc] initWithFormat:@"%@ %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	editableNotes = [[NSNumber alloc] initWithBool:NO];
}
/*
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	if ([[NSDate dateWithString:@"2004-09-01 00:00:00 +0000"] timeIntervalSinceNow] < 0 && !g.debug)
	{
		NSRunCriticalAlertPanel(@"Beta Expired", @"This copy of Alkor has expired. Please download the latest beta from Cognition Games.", @"Right Away", nil, nil);
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://web.nickshanks.com/alkor/"]];
		[NSApp terminate:nil];
	}
}
*/
- (IBAction)showReleaseNotes:(id)sender
{
#pragma unused(sender)
	[NSBundle loadNibNamed:@"Release Notes" owner:self];
	[notesWindow makeKeyAndOrderFront:self];
}

- (NSArray *)releaseNotes
{
	NSString *file;
	NSMutableArray *notes = [NSMutableArray array];
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[[[NSBundle mainBundle] pathForResource:currentNote ofType:@"rtf" inDirectory:@"Release Notes"] stringByDeletingLastPathComponent]];
	while (file = [enumerator nextObject])
		if (![file isEqualToString:@".DS_Store"])
			[notes insertObject:[file stringByDeletingPathExtension] atIndex:0];
	return notes;
}

- (NSString *)pathForReleaseNote
{
	return [[NSBundle mainBundle] pathForResource:currentNote ofType:@"rtf" inDirectory:@"Release Notes"];
}
- (void)setPathForReleaseNote:(NSString *)newPath
{
#pragma unused(newPath)
}

- (void)setCurrentNote:(NSString *)newNote
{
	id old = currentNote;
	currentNote = [newNote retain];
	[old release];
	[self setValue:nil forKey:@"pathForReleaseNote"];
}

@end

@implementation NSApplication (AlkorScriptingExtensions)

- (NSArray *)characterDocuments
{
	NSDocument *doc;
	NSMutableArray *docs = [NSMutableArray array];
	NSEnumerator *enumerator = [[[NSDocumentController sharedDocumentController] documents] objectEnumerator];
	while (doc = [enumerator nextObject])
	{
		if ([doc class] == [CharacterDocument class])
			[docs addObject:doc];
	}
	return docs;
}

- (NSArray *)itemDocuments
{
	NSDocument *doc;
	NSMutableArray *docs = [NSMutableArray array];
	NSEnumerator *enumerator = [[[NSDocumentController sharedDocumentController] documents] objectEnumerator];
	while (doc = [enumerator nextObject])
	{
		if ([doc class] == [ItemDocument class])
			[docs addObject:doc];
	}
	return docs;
}

- (NSArray *)zigs
{
	return [NSArray arrayWithObject:[[[Zig alloc] init] autorelease]];
}

@end

@implementation NSString (AlkorFormatExtensions)

+ (id)stringWithDiabloFormat:(NSString *)format, ...
{
	int i = 0;
	va_list list;
	va_start(list, format);
	NSMutableString *output = [NSMutableString stringWithString:format];
	 // note some formats (fr, de, po, it, es, but not en, ko, zh, jp) seem to begin with the string "a0n1:" - this needs to be stripped, I don't know what it means, possibly gender??
	if ([output hasPrefix:@"a0n1:"])
		output = [[[output substringFromIndex:5] mutableCopy] autorelease];
	
	NSString *arg;
	while (arg = va_arg(list, NSString*))
		[output replaceOccurrencesOfString:[NSString stringWithFormat:@"%%%d", i++] withString:arg options:0 range:NSMakeRange(0,[output length])];
	va_end(list);
	return [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end

@implementation Zig

- (void)takeOff:(NSScriptCommand *)command
{
	int justice = [[[command evaluatedArguments] valueForKey:@"Justice"] intValue];
	if (justice == 'GJst')
		NSBeep();
//		NSBeep();
}

@end
