#import "Property.h"
#import "Stat.h"
#import "CharacterDocument.h"
#import "MPQReader.h"
#import "AppDelegate.h"

#import "Localization.h"
#import "PropertyLists.h"

@implementation Property

+ (Property *)property
{
	Property *property = [[Property alloc] init];
	return [property autorelease];
}

- (Property *)init
{
	self = [super init];
	if (!self) return nil;
	stats = [[NSMutableArray alloc] initWithCapacity:7];
	for (int i = 0; i < 7; i++)
	{
		if (i == 0) [stats addObject:[Stat statWithIndex: 0 value:0 param:0]];
		else		[stats addObject:[Stat statWithIndex:-1 value:0 param:0]];
	}
	return self;
}

- (void)dealloc
{
	[stats release];
	[super dealloc];
}

- (NSMutableArray *)stats
{
	return stats;
}

- (NSString *)name
{
	signed short index0 = [(Stat *)[stats objectAtIndex:0] index];
	unsigned long value0 = [(Stat *)[stats objectAtIndex:0] value];
	unsigned long value1 = [(Stat *)[stats objectAtIndex:1] value];
	unsigned long value2 = [(Stat *)[stats objectAtIndex:2] value];
	switch (index0)
	{
		case 17:	// enhanced damage
		{
			unsigned short maxdamage = value0;
			unsigned short mindamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModEnhancedDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModEnhancedDamageRange"), mindamage, maxdamage];
		}
/*		case 23?:	// physical damage
		{
			unsigned short maxdamage = value0;
			unsigned short mindamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModMinDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModMinDamageRange"), mindamage, maxdamage];
		}
*/		case 48:	// fire damage
		{
			unsigned short mindamage = value0;
			unsigned short maxdamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModFireDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModFireDamageRange"), mindamage, maxdamage];
		}
		
		case 50:	// lightning damage
		{
			unsigned short mindamage = value0;
			unsigned short maxdamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModLightningDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModLightningDamageRange"), mindamage, maxdamage];
		}
		
		case 52:	// magic damage
		{
			unsigned short mindamage = value0;
			unsigned short maxdamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModMagicDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModMagicDamageRange"), mindamage, maxdamage];
		}
		
		case 54:	// cold damage
		{
			unsigned short mindamage = value0;
			unsigned short maxdamage = value1;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModColdDamage"), mindamage];
			else return [NSString stringWithFormat:Localise(@"strModColdDamageRange"), mindamage, maxdamage];
		}
		
		case 57:	// poison damage
		{
			unsigned short mindamage = value0 * value2 / 256;
			unsigned short maxdamage = value1 * value2 / 256;
			unsigned short duration  = value2 / 25;
			if (mindamage == maxdamage)
				return [NSString stringWithFormat:Localise(@"strModPoisonDamage"), mindamage, duration];
			else return [NSString stringWithFormat:Localise(@"strModPoisonDamageRange"), mindamage, maxdamage, duration];
		}
		
		default:
			return [(Stat *)[stats objectAtIndex:0] name];
	}
}

- (signed short)index
{
	return [(Stat *)[stats objectAtIndex:0] index];
}

- (void)setIndex:(signed short)new_index
{
	int i;
	for (i = 0; i < item_property_stat_count[new_index]; i++)
		[[stats objectAtIndex:i] setValue:[NSNumber numberWithShort:new_index+i] forKey:@"index"];
	for ( ; i < 7; i++)
		[[stats objectAtIndex:i] setValue:[NSNumber numberWithShort:-1] forKey:@"index"];
}

- (NSString *)description
{
	return [stats description];
}

@end
