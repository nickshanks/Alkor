#import "CharacterDocument_Stats.h"

#import "Act.h"
#import "Corpse.h"
#import "NPC.h"
#import "Quest.h"
#import "Waypoint.h"

#import "Property.h"
#import "MPQReader.h"
#import "NGSCategories.h"

#import "Localization.h"

extern NSDictionary *allWarnings;

@implementation CharacterDocument (Stats)
- (unsigned long)experience
{
	NSArray *array = [[stats objectAtIndex:kExperienceKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setExperience:(unsigned long)value
{
	[self willChangeValueForKey:@"experience"];
	[[[stats objectAtIndex:kExperienceKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"experience"];
	
	if (maintainLegitimacy)
	{
		maintainLegitimacy = NO;
		NSNumber *newLevel = [NSNumber numberWithUnsignedLong:level_for_experience(value)];
		[self setValue:newLevel forKey:@"level"];
		[self setValue:newLevel forKey:@"selectionLevel"];
		maintainLegitimacy = YES;
	}
}

- (unsigned long)level
{
	NSArray *array = [[stats objectAtIndex:kLevelKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setLevel:(unsigned long)value
{
	[self willChangeValueForKey:@"level"];
	[[[stats objectAtIndex:kLevelKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"level"];
	
	if (maintainLegitimacy)
	{
		maintainLegitimacy = NO;
		[self setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"selectionLevel"];
		[self setValue:[NSNumber numberWithUnsignedLong:experience_for_level[value]] forKey:@"experience"];
		maintainLegitimacy = YES;
	}
}

- (unsigned long)carriedGold
{
	NSArray *array = [[stats objectAtIndex:kCarriedGoldKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setCarriedGold:(unsigned long)value
{
	if (maintainLegitimacy)
	{
		// carried gold and stashed gold do this different ways - neither work as of 10.3.2
		unsigned long limit = max_carried_gold_for_level([self level]);
		if (value > limit) value = limit;
	}
	
	[self willChangeValueForKey:@"carriedGold"];
	[[[stats objectAtIndex:kCarriedGoldKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"carriedGold"];
}

- (unsigned long)stashedGold
{
	NSArray *array = [[stats objectAtIndex:kStashedGoldKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setStashedGold:(unsigned long)value
{
	if (maintainLegitimacy)
	{
		// carried gold and stashed gold do this different ways - neither work as of 10.3.2
		unsigned long limit = max_stashed_gold_for_level[[self level]];
		if (value > limit)
		{
			maintainLegitimacy = NO;
			[self setValue:[NSNumber numberWithUnsignedLong:limit] forKey:@"stashedGold"];
			maintainLegitimacy = YES;
			return;
		}
	}
	
	[self willChangeValueForKey:@"stashedGold"];
	[[[stats objectAtIndex:kStashedGoldKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"stashedGold"];
}

- (unsigned long)strength
{
	NSArray *array = [[stats objectAtIndex:kStrengthKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setStrength:(unsigned long)value
{
	[self willChangeValueForKey:@"strength"];
	[[[stats objectAtIndex:kStrengthKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"strength"];
}

- (unsigned long)energy
{
	NSArray *array = [[stats objectAtIndex:kEnergyKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setEnergy:(unsigned long)value
{
	[self willChangeValueForKey:@"energy"];
	[[[stats objectAtIndex:kEnergyKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"energy"];
}

- (unsigned long)dexterity
{
	NSArray *array = [[stats objectAtIndex:kDexterityKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setDexterity:(unsigned long)value
{
	[self willChangeValueForKey:@"dexterity"];
	[[[stats objectAtIndex:kDexterityKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"dexterity"];
}

- (unsigned long)vitality
{
	NSArray *array = [[stats objectAtIndex:kVitalityKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setVitality:(unsigned long)value
{
	[self willChangeValueForKey:@"vitality"];
	[[[stats objectAtIndex:kVitalityKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"vitality"];
}

- (unsigned long)unspentStats
{
	NSArray *array = [[stats objectAtIndex:kUnspentStatsKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setUnspentStats:(unsigned long)value
{
	[self willChangeValueForKey:@"unspentStats"];
	[[[stats objectAtIndex:kUnspentStatsKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"unspentStats"];
}

- (unsigned long)unspentSkills
{
	NSArray *array = [[stats objectAtIndex:kUnspentSkillsKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue];
}

- (void)setUnspentSkills:(unsigned long)value
{
	[self willChangeValueForKey:@"unspentSkills"];
	[[[stats objectAtIndex:kUnspentSkillsKey] stats] setValue:[NSNumber numberWithUnsignedLong:value] forKey:@"value"];
	[self didChangeValueForKey:@"unspentSkills"];
}

- (unsigned long)life
{
	NSArray *array = [[stats objectAtIndex:kCurrentLifeKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setLife:(unsigned long)value
{
	[self willChangeValueForKey:@"life"];
	[[[stats objectAtIndex:kCurrentLifeKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"life"];
}

- (unsigned long)lifeMax
{
	NSArray *array = [[stats objectAtIndex:kMaximumLifeKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setLifeMax:(unsigned long)value
{
	[self willChangeValueForKey:@"lifeMax"];
	[[[stats objectAtIndex:kMaximumLifeKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"lifeMax"];
}

- (unsigned long)mana
{
	NSArray *array = [[stats objectAtIndex:kCurrentManaKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setMana:(unsigned long)value
{
	[self willChangeValueForKey:@"mana"];
	[[[stats objectAtIndex:kCurrentManaKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"mana"];
}

- (unsigned long)manaMax
{
	NSArray *array = [[stats objectAtIndex:kMaximumManaKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setManaMax:(unsigned long)value
{
	[self willChangeValueForKey:@"manaMax"];
	[[[stats objectAtIndex:kMaximumManaKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"manaMax"];
}

- (unsigned long)stamina
{
	NSArray *array = [[stats objectAtIndex:kCurrentStaminaKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setStamina:(unsigned long)value
{
	[self willChangeValueForKey:@"stamina"];
	[[[stats objectAtIndex:kCurrentStaminaKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"stamina"];
}

- (unsigned long)staminaMax
{
	NSArray *array = [[stats objectAtIndex:kMaximumStaminaKey] stats];
	return [[[array objectAtIndex:0] valueForKey:@"value"] unsignedLongValue] >> 8;
}

- (void)setStaminaMax:(unsigned long)value
{
	[self willChangeValueForKey:@"staminaMax"];
	[[[stats objectAtIndex:kMaximumStaminaKey] stats] setValue:[NSNumber numberWithUnsignedLong:value << 8] forKey:@"value"];
	[self didChangeValueForKey:@"staminaMax"];
}

// KVC accessor methods
- (void)setName:(NSString *)newName
{
	[self willChangeValueForKey:@"name"];
	id old = name;
	name = newName;					// sets the d2s variable
	[old release];
	[self setFileName:[[[[self fileName]	// sets the file name too
		stringByDeletingLastPathComponent]
		stringByAppendingPathComponent:name]
		stringByAppendingPathExtension:@"d2s"]];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
	[self didChangeValueForKey:@"name"];
}

- (NSString *)titleAsString
{
	unsigned char titleVal = [title unsignedCharValue];
	if (titleVal)
		return [NSString stringWithCString: title_names[[expansion intValue]][[hardcore intValue]][class_genders[[characterClass intValue]]][titleVal -1] encoding:NSASCIIStringEncoding];
	else return nil;
}

- (int)experienceForCurrentLevel
{
	return experience_for_level[[self level]];
}

- (int)experienceForNextLevel
{
	return experience_for_level[[self level]+1];
}

- (void)setCharacterClass:(int)value
{
	[self willChangeValueForKey:@"skillsForDisplay"];
	characterClass = [[NSNumber alloc] initWithInt:value];
	[self didChangeValueForKey:@"skillsForDisplay"];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
}

- (int)characterClassForScripting
{
	switch ([characterClass intValue])
	{
		case kClassAmazon:		return kClassScriptAmazon;
		case kClassAssassin:	return kClassScriptAssassin;
		case kClassBarbarian:	return kClassScriptBarbarian;
		case kClassDruid:		return kClassScriptDruid;
		case kClassNecromancer:	return kClassScriptNecromancer;
		case kClassPaladin:		return kClassScriptPaladin;
		case kClassSorceress:	return kClassScriptSorceress;
		default:				return kClassScriptAmazon;
	}
}

- (void)setCharacterClassForScripting:(int)value
{
	switch (value)
	{
		case kClassScriptAmazon:		[self setValue:[NSNumber numberWithUnsignedInt:kClassAmazon] forKey:@"characterClass"]; break;
		case kClassScriptAssassin:		[self setValue:[NSNumber numberWithUnsignedInt:kClassAssassin] forKey:@"characterClass"]; break;
		case kClassScriptBarbarian:		[self setValue:[NSNumber numberWithUnsignedInt:kClassBarbarian] forKey:@"characterClass"]; break;
		case kClassScriptDruid:			[self setValue:[NSNumber numberWithUnsignedInt:kClassDruid] forKey:@"characterClass"]; break;
		case kClassScriptNecromancer:	[self setValue:[NSNumber numberWithUnsignedInt:kClassNecromancer] forKey:@"characterClass"]; break;
		case kClassScriptPaladin:		[self setValue:[NSNumber numberWithUnsignedInt:kClassPaladin] forKey:@"characterClass"]; break;
		case kClassScriptSorceress:		[self setValue:[NSNumber numberWithUnsignedInt:kClassSorceress] forKey:@"characterClass"]; break;
		default:						[self setValue:[NSNumber numberWithUnsignedInt:kClassAmazon] forKey:@"characterClass"]; break;
	}
}

- (NSArray *)characterClasses
{
	NSString *entry;
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *enumerator = [[[[MPQReader defaultReader] entriesForFile:@"data/global/excel/PlayerClass.txt"] valueForKey:@"player class"] objectEnumerator];
	while (entry = [enumerator nextObject])
		[array addObject:Localise(entry)];
	return array;
}

- (void)setCharacterClasses:(NSArray *)value
{
#pragma unused(value)
}

- (void)setExpansion:(BOOL)flag
{
	[self willChangeValueForKey:@"expansion"];
	id old = expansion;
	expansion = [[NSNumber alloc] initWithBool:flag];
	[old release];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
	[self didChangeValueForKey:@"expansion"];
}

- (void)setHardcore:(BOOL)flag
{
	[self willChangeValueForKey:@"hardcore"];
	id old = hardcore;
	hardcore = [[NSNumber alloc] initWithBool:flag];
	[old release];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
	[self didChangeValueForKey:@"hardcore"];
}

- (void)setDied:(BOOL)flag
{
	[self willChangeValueForKey:@"died"];
	id old = died;
	died = [[NSNumber alloc] initWithBool:flag];
	[old release];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
	[self didChangeValueForKey:@"died"];
}

- (int)progression
{
	return [currentDifficulty intValue]*5 + [currentAct intValue];
}

- (void)setProgression:(int)value
{
	[self willChangeValueForKey:@"progression"];
	[self setValue:[NSNumber numberWithInt:value/5] forKey:@"currentDifficulty"];
	[self setValue:[NSNumber numberWithInt:value%5] forKey:@"currentAct"];
	[self setValue:[NSNumber numberWithInt:value/5] forKey:@"title"];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
	[self didChangeValueForKey:@"progression"];
}

- (NSArray *)difficulties
{
	return difficulties;
}

- (void)setDifficulties:(NSArray *)value
{
}

- (void)setSelectedDifficulty:(NSNumber *)difficulty
{
	[self willChangeValueForKey:@"selectedDifficulty"];
	id old = selectedDifficulty;
	selectedDifficulty = [difficulty retain];
	[old release];
	[self didChangeValueForKey:@"selectedDifficulty"];
	
	// update UI
	[self willChangeValueForKey:@"acts"];
	[self willChangeValueForKey:@"quests"];
	[self willChangeValueForKey:@"waypoints"];
	[self willChangeValueForKey:@"npcs"];
	[self didChangeValueForKey:@"acts"];
	[self didChangeValueForKey:@"quests"];
	[self didChangeValueForKey:@"waypoints"];
	[self didChangeValueForKey:@"npcs"];
}

- (NSArray *)acts
{
	return [[difficulties objectAtIndex:[selectedDifficulty intValue]] valueForKey:@"acts"];
}

- (void)setActs:(NSArray *)value
{
}

- (NSArray *)quests
{
	Act *act;
	NSMutableArray *quests = [[[NSMutableArray alloc] init] autorelease];
	NSEnumerator *enumerator = [[self acts] objectEnumerator];
	while (act = [enumerator nextObject])
		[quests addObjectsFromArray:[act valueForKey:@"quests"]];
	return [NSArray arrayWithArray:quests];
}

- (void)setQuests:(NSArray *)value
{
}

- (NSArray *)waypoints
{
	Act *act;
	NSMutableArray *waypoints = [[[NSMutableArray alloc] init] autorelease];
	NSEnumerator *enumerator = [[self acts] objectEnumerator];
	while (act = [enumerator nextObject])
		[waypoints addObjectsFromArray:[act valueForKey:@"waypoints"]];
	return [NSArray arrayWithArray:waypoints];
}

- (void)setWaypoints:(NSArray *)value
{
}

- (NSArray *)npcs
{
	Act *act;
	NSMutableArray *npcs = [[[NSMutableArray alloc] init] autorelease];
	NSEnumerator *enumerator = [[self acts] objectEnumerator];
	while (act = [enumerator nextObject])
	{
		NPC *npc;
		NSEnumerator *npcEnumerator = [[act valueForKey:@"npcs"] objectEnumerator];
		while (npc = [npcEnumerator nextObject])
			if (![[npc valueForKey:@"name"] hasPrefix:@"Unknown"])
				[npcs addObject:npc];
	}
	return [NSArray arrayWithArray:npcs];
}

- (void)setNpcs:(NSArray *)value
{
}

- (void)setFilterSkills:(BOOL)flag
{
	[self willChangeValueForKey:@"skillsForDisplay"];
	filterSkills = flag;
	[self didChangeValueForKey:@"skillsForDisplay"];
}

- (NSArray *)skillsForDisplay
{
	if (filterSkills)
	{
		NSArray *playerClasses = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/PlayerClass.txt"];
		return [skills objectsReturningValue:[[playerClasses objectAtIndex:[characterClass charValue]] valueForKey:@"code"] forKey:@"charclass"];
	}
	else return skills;
}

- (void)setSkillsForDisplay:(NSArray *)value
{
}

// indexed accessors for itemsForDisplay
- (unsigned int)countOfItemsForDisplay
{
    return [items count];
}

- (id)objectInItemsForDisplayAtIndex:(unsigned int)index 
{
    return [items objectAtIndex:index];
}

- (void)insertObject:(id)object inItemsForDisplayAtIndex:(unsigned int)index 
{
    [items insertObject:object atIndex:index];
}

- (void)removeObjectFromItemsForDisplayAtIndex:(unsigned int)index 
{
    [items removeObjectAtIndex:index];
}

- (void)replaceObjectInItemsForDisplayAtIndex:(unsigned int)index withObject:(id)object 
{
    [items replaceObjectAtIndex:index withObject:object];
}

// custom mappers
- (IBAction)reloadItemList:(id)sender
{
	// cheat
	[self setValue:[self itemsForDisplay] forKey:@"itemsForDisplay"];
}

- (NSArray *)itemsForDisplay
{
	switch ([[itemPopup selectedItem] tag])
	{
		case 0:		// all
		{	NSMutableArray *array = [NSMutableArray arrayWithArray:items];
			if (mercenary)   [array addObjectsFromArray:[mercenary items]];
			if (golemItem)   [array addObject:golemItem];
			if (corpses && [corpses count] > 0)
				[array addObjectsFromArray:[(Corpse *)[corpses objectAtIndex:0] items]];
			return array;
		}
		case 1:		// player
			return items;
		case 2:		// merc
			if (mercenary)
				return [mercenary items];
			else break;
		case 3:		// golem
			if (golemItem)
				return [NSArray arrayWithObject:golemItem];
			else break;
		case 4:		// corpse
			if (corpses && [corpses count] > 0)
				return [(Corpse *)[corpses objectAtIndex:0] items];
			else break;
	}
	return nil;
}

- (void)setItemsForDisplay:(NSArray *)value
{
}

- (NSArray *)warnings
{
	return [allWarnings allValues];
}

// action methods for UI buttons - would like to make these applescripts one day
- (IBAction)activateAllWaypoints:(id)sender
{
	Waypoint *wp;
	NSEnumerator *enumerator = [[self waypoints] objectEnumerator];
	while (wp = [enumerator nextObject])
		[wp setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
}

- (IBAction)receiveAllQuests:(id)sender
{
	Quest *q;
	NSEnumerator *enumerator = [[self quests] objectEnumerator];
	while (q = [enumerator nextObject])
	{
		[q willChangeValueForKey:@"progressBools"];
		[q setValue:[NSNumber numberWithShort:(1 << 2)] forKey:@"progress"];
		[q didChangeValueForKey:@"progressBools"];
	}
}

- (IBAction)completeAllQuests:(id)sender
{
	Quest *q;
	NSEnumerator *enumerator = [[self quests] objectEnumerator];
	while (q = [enumerator nextObject])
	{
		[q willChangeValueForKey:@"progressBools"];
		[q setValue:[NSNumber numberWithShort:(1 << 1)] forKey:@"progress"];
		[q didChangeValueForKey:@"progressBools"];
	}
}

- (IBAction)closeAllQuests:(id)sender
{
	Quest *q;
	NSEnumerator *enumerator = [[self quests] objectEnumerator];
	while (q = [enumerator nextObject])
	{
		[q willChangeValueForKey:@"progressBools"];
		[q setValue:[NSNumber numberWithShort:(1 << 0) | (1 << 12)] forKey:@"progress"];
		[q didChangeValueForKey:@"progressBools"];
	}
}

- (IBAction)activateImbue:(id)sender
{
	Quest *q = [[[[[difficulties objectAtIndex:[selectedDifficulty intValue]] valueForKey:@"acts"] objectAtIndex:0] valueForKey:@"quests"] objectAtIndex:2];
	[q willChangeValueForKey:@"progressBools"];
	[q setValue:[NSNumber numberWithShort:([[q valueForKey:@"progress"] shortValue] & 0xFFFC) +2] forKey:@"progress"];
	[q didChangeValueForKey:@"progressBools"];
}

- (IBAction)resetAllNPCs:(id)sender
{
	NPC *npc;
	NSEnumerator *enumerator = [[self npcs] objectEnumerator];
	while (npc = [enumerator nextObject])
	{
		[npc setValue:[NSNumber numberWithBool:NO] forKey:@"introduction"];
		[npc setValue:[NSNumber numberWithBool:NO] forKey:@"congratulation"];
	}	
}

- (IBAction)generateMercGUID:(id)sender
{
	[mercenary setValue:[NSNumber numberWithLong:random()] forKey:@"guid"];
}

- (IBAction)selectMercItems:(id)sender
{
	[itemPopup selectItemAtIndex:[itemPopup indexOfItemWithTag:2]];
	[self reloadItemList:nil];
	[mainTabs selectTabViewItemAtIndex:2];
}

@end
