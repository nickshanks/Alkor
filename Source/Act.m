#import "Act.h"
#import "NPC.h"
#import "Quest.h"
#import "Waypoint.h"

#import "CharacterDocument.h"
#import "AppDelegate.h"
#import "MPQReader.h"
#import "Item.h"

#import "Localization.h"

@implementation Difficulty
- (Difficulty *)initWithName:(NSString *)theName
{
	self = [super init];
	if (!self) return nil;
	name = [theName retain];
	acts = [[NSMutableArray alloc] init];
	for (int i = 0; i < 5; i++)
		[acts addObject:[[[Act alloc] initWithValue:i] autorelease]];
	return self;
}
- (NSString *)description
{
	// until i figure out how to bind a popup button's items to the name key i'll just do this:
	return name;
}
@end

@implementation Act
- (Act *)initWithValue:(int)value
{
	self = [super init];
	if (!self) return nil;
	quests = [[NSMutableArray alloc] init];
	waypoints = [[NSMutableArray alloc] init];
	npcs = [[NSMutableArray alloc] init];
//	introduction = [[NSNumber alloc] initWithInt:0];
//	completion = [[NSNumber alloc] initWithInt:0];
	
	// create quests
	switch (value)
	{
		case 0:
			// order is altered for act 1
			[quests addObject:[Quest questWithName:@"Act I Introduction" options:[NSArray arrayWithObjects:@"Greeted by Warriv", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q1") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Killed All Monsters)", @"Received Quest (Informed of Den by Akara)", @"", @"Entered Den", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q2") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Killed Blood Raven)", @"Received Quest (Informed of Blood Raven by Kashya)", @"(Set on Receiving Quest)", @"Entered Burial Grounds", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q3") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Returned Malus)", @"Received Quest (Informed of Malus by Charsi)", @"Entered Barracks", @"", @"", @"Picked Up Horadric Malus", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"Quest Success (Item Imbued)", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q4") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Rescued Cain)", @"Received Quest (Informed of Cain by Akara)", @"Picked Up Scroll of Inifuss", @"Opened Tristram Portal", @"", @"", @"", @"", @"", @"Killed Cow King", @"", @"Closed", @"Completed in Current Game", @"Quest Failure (Charge For Identify)", @"Quest Success (Identify For Free)", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q5") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest (Read Moldy Tome)", @"", @"Entered Forgotten Tower", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa1q6") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Killed Andariel)", @"Received Quest (Informed of Andariel by Cain)", @"", @"Entered Catacombs Level 4", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"Quest Success (Allows Passage Eastwards)", nil]]];
			[quests addObject:[Quest questWithName:@"Act I Conclusion" options:[NSArray arrayWithObjects:@"Act II Tabs Available", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			break;
		
		case 1:
			[quests addObject:[Quest questWithName:@"Act II Introduction" options:[NSArray arrayWithObjects:@"Greeted by Jerhyn", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q1") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest (Informed of Radament by Atma)", @"", @"Found Radament", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q2") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"", @"", @"Informed of Viper Amulet", @"Informed of Staff of Kings", @"", @"", @"", @"", @"Informed of Horodric Staff", @"Horodric Staff Recreated", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q3") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest (Darkness Has Come)", @"Darkness Explained by Drognan", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q4") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q5") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa2q6") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"Spoken To Tyrael", @"Spoken To Jerhyn", @"Duriel Kiled", @"Spoken To Atma", @"Spoken To Warriv", @"Spoken To Drognan", @"Spoken To Lysander", @"Spoken To Cain", @"Spoken To Fara", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Act II Conclusion" options:[NSArray arrayWithObjects:@"Act III Tabs Available", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			break;
		
		case 2:
			[quests addObject:[Quest questWithName:@"Act III Introduction" options:[NSArray arrayWithObjects:@"Greeted by Hratli", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q1") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q2") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"Khalim's Eye Discussed by Cain", @"Khalim's Brain Discussed by Cain", @"Khalim's Flail Discussed by Cain", @"Khalim's Heart Discussed by Cain", @"Khalim's Will Discussed by Cain", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q3") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"", @"Asked to Find Gidbinn by Hratli", @"(Set on Picking Up Gidbinn)", @"(Set on Picking Up Gidbinn)", @"Given Gidbinn To Ormus", @"Received Mercenary from Asheara", @"Received Ring from Ormus", @"(Set on Picking Up Gidbinn)", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q4") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Given Golden Bird to Alkor)", @"Jade Figurine Explained by Cain", @"", @"Golden Bird Explained by Cain", @"Possess Potion of Life", @"Possess Jade Figurine or Golden Bird", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"Quest Success (Received Potion of Life)", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q5") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"Entered Travincal", @"Killed High Council", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa3q6") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"Entered Durance of Hate Level 3", @"", @"Killed Mephisto", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Act III Conclusion" options:[NSArray arrayWithObjects:@"Act IV Tabs Available", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"(Set on Stepping Through Heaven's Gate)", @"", @"", nil]]];
			break;
		
		case 3:
			[quests addObject:[Quest questWithName:@"Act IV Introduction" options:[NSArray arrayWithObjects:@"Greeted by Tyrael", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa4q1") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Killed Isual)", @"Received Quest (Informed of Isual by Tyrael)", @"Encountered Isual on the Plains of Despair", @"", @"Spoken to Isual", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa4q2") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest from Tyrael", @"(Set on Receiving Quest)", @"", @"", @"(Cleared When Talking to Cain After Killing Diablo)", @"(Cleared When Talking to Tyrael After Killing Diablo)", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa4q3") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria (Destroyed Soulstone)", @"Received Quest", @"Left the Pandemonium Fortress", @"", @"Given Soulstone By Cain", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"Quest Success (Destroyed Soulstone)", nil]]];
			[quests addObject:[Quest questWithName:@"Act IV Conclusion" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 1" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 2" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 3" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Act III Extra" options:[NSArray arrayWithObjects:@"Witnessed Dark Wanderer Outside Docks", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 4" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			break;
		
		case 4:
			[quests addObject:[Quest questWithName:@"Act V Introduction" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q1") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"Shenk Found", @"", @"Add Sockets Offered by Larzuk", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q2") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q3") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"Scroll of Resistance Read", @"Talked to Malah after Rescuing Anya", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q4") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"Offered Item Inscription by Anya", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q5") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:Localise(@"qstsa5q6") options:[NSArray arrayWithObjects:@"Completed", @"Met Completion Criteria", @"Received Quest", @"", @"Spoken To Larzuk", @"Spoken To Cain", @"Spoken To Malah", @"Spoken To Tyrael", @"Spoken To Qual-Kehk", @"Spoken To Anya", @"", @"", @"Closed", @"Completed in Current Game", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Act V Conclusion" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 5" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 6" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 7" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 8" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 9" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			[quests addObject:[Quest questWithName:@"Unused 10" options:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil]]];
			break;
	}
	
	// create waypoints
	switch (value)
	{
		case 0:
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Rogue Encampment")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Cold Plains")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Stony Field")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Dark Wood")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Black Marsh")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Outer Cloister")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Jail Level 1")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Inner Cloister")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Catacombs Level 2")]];
			break;
		
		case 1:
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Lut Gholein")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Sewers Level 2")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Dry Hills")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Halls of the Dead Level 2")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Far Oasis")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Lost City")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Palace Cellar Level 1 ")]];  // note: in tbl file this key really has a space after it!
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Arcane Sanctuary")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Canyon of the Magi")]];
			break;
		
		case 2:
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Kurast Docktown")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Spider Forest")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Great Marsh")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Flayer Jungle")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Lower Kurast")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Kurast Bazaar")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Upper Kurast")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Travincal")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Durance of Hate Level 2")]];
			break;
		
		case 3:
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"The Pandemonium Fortress")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"City of the Damned")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"River of Flame")]];
			break;
		
		case 4:
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Harrogath")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Rigid Highlands")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Arreat Plateau")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Crystalized Cavern Level 1")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Crystalized Cavern Level 2")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Halls of Death's Calling")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Tundra Wastelands")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"Glacial Caves Level 1")]];
			[waypoints addObject:[Waypoint waypointWithName:Localise(@"The Worldstone Keep Level 2")]];
			break;
	}
	
	// create NPCs  -- note each act has 1 unknown bit at the start (except act 4)
	switch (value)
	{
		case 0:
			[npcs addObject:[NPC npcWithName:@"Unknown 0.0"]];
			[npcs addObject:[NPC npcWithName:Localise(@"Gheed")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Akara")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Kashya")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Warriv")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Charsi")]];
//			[npcs addObject:[NPC npcWithName:@"Deckard Cain"]];
//			[npcs addObject:[NPC npcWithName:@"Flavie"]];
			break;
		
		case 1:
			[npcs addObject:[NPC npcWithName:@"Unknown 0.6"]];
			[npcs addObject:[NPC npcWithName:Localise(@"Warriv")]];
			[npcs addObject:[NPC npcWithName:@"Unknown 1.0"]];
			[npcs addObject:[NPC npcWithName:Localise(@"Drognan")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Fara")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Lysander")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Geglash")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Meshif")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Jerhyn")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Greiz")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Elzix")]];
//			[npcs addObject:[NPC npcWithName:@"Atma"]];
//			[npcs addObject:[NPC npcWithName:@"Kaelan"]];
			break;
		
		case 2:
			[npcs addObject:[NPC npcWithName:@"Unknown 2.1"]];
			[npcs addObject:[NPC npcWithName:Localise(@"DeckardCain")]];
			[npcs addObject:[NPC npcWithName:@"Unknown 2.3"]];
			[npcs addObject:[NPC npcWithName:@"Unknown 2.4"]];
			[npcs addObject:[NPC npcWithName:Localise(@"asheara")]];
			[npcs addObject:[NPC npcWithName:Localise(@"hratli")]];
			[npcs addObject:[NPC npcWithName:Localise(@"alkor")]];
			[npcs addObject:[NPC npcWithName:Localise(@"ormus")]];
			[npcs addObject:[NPC npcWithName:@"Unknown 3.1"]];
			[npcs addObject:[NPC npcWithName:@"Unknown 3.2"]];
			[npcs addObject:[NPC npcWithName:Localise(@"Meshif")]];
			[npcs addObject:[NPC npcWithName:Localise(@"nikita")]];
//			[npcs addObject:[NPC npcWithName:@"tyrael"]];
			break;
		
		case 3:
//			[npcs addObject:[NPC npcWithName:@"Deckard Cain"]];
//			[npcs addObject:[NPC npcWithName:@"Malachai"]];  // hadriel
//			[npcs addObject:[NPC npcWithName:@"halbu"]];
//			[npcs addObject:[NPC npcWithName:@"Jamella"]];
//			[npcs addObject:[NPC npcWithName:@"tyrael"]];
			break;
		
		case 4:
			[npcs addObject:[NPC npcWithName:@"Unknown 3.5"]];
			[npcs addObject:[NPC npcWithName:Localise(@"Drehya")]];   // anya
			[npcs addObject:[NPC npcWithName:Localise(@"Malah")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Nihlathak")]];
			[npcs addObject:[NPC npcWithName:Localise(@"Qual-Kehk")]];
			[npcs addObject:[NPC npcWithName:Localise(@"DeckardCain")]];
//			[npcs addObject:[NPC npcWithName:@"Larzuk"]];
			break;
	}
	
	return self;
}
@end


/*** VALUE TRANSFORMERS ***/
@implementation LevelFromExperienceTransformer
+ (Class)transformedValueClass			{	return [NSNumber class];		}
+ (BOOL)supportsReverseTransformation	{	return YES;						}
- (id)transformedValue:(id)value		{   return [NSNumber numberWithUnsignedLong:level_for_experience([value unsignedLongValue])];		}
- (id)reverseTransformedValue:(id)value	{   return [NSNumber numberWithUnsignedLong:experience_for_level[[value unsignedLongValue]]];		}
@end