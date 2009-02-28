#import "Stat.h"
#import "MPQReader.h"
#import "Localization.h"
#import "NGSCategories.h"

@implementation Stat

+ (Stat *)statWithIndex:(signed short)i value:(unsigned long)v param:(unsigned long)p
{
	Stat *stat = [[Stat alloc] initWithIndex:i value:v param:p];
	return [stat autorelease];
}

- (Stat *)initWithIndex:(signed short)i value:(unsigned long)v param:(unsigned long)p
{
	self = [super init];
	if (!self) return nil;
	self->index = i;
	value = v;
	param = p;
	return self;
}

- (signed short)index
{
	return self->index;
}

- (unsigned long)value
{
	return value;
}

- (unsigned long)param
{
	return param;
}

- (NSString *)name
{
	if (self->index == -1) return @"Unused Stat";
	NSArray *itemstatcost = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/ItemStatCost.txt"];
//	id cost = [itemstatcost firstObjectReturningValue:[NSString stringWithFormat:@"%d", self->index] forKey:@"id"];
	id cost = [itemstatcost objectAtIndex:self->index];
	int descfunc = [[cost valueForKey:@"descfunc"] intValue], descval = [[cost valueForKey:@"descval"] intValue];
	NSString *descstr  = Localise([cost valueForKey:(self->value < 0)? @"descstrneg":@"descstrpos"]);
	NSString *descstr2 = Localise([cost valueForKey:@"descstr2"]);
	
/*	http://phrozenkeep.it-point.com/forum/viewtopic.php?p=112243&highlight=ItemStatCost+txt+guide#112243
	
	descpriority	priority of the description on the item. The higher this, the earlier will the stat be displayed on your item. Probably. 
	dgrp			Display group. If all stats of a display group have the same stats, they will be displayed together. 
	dgrpfunc		Same as descfunc, but for display groups 
	dgrpval			Same as descval, but for display groups 
	dgrpstrpos		Same as descstrpos, but for display groups 
	dgrpstrneg		Same as descstrneg, but for display groups 
	dgrpstr2		Same as descstr2, but for display groups 
*/	
	
	switch (descfunc)
	{
		case 0: return [NSString stringWithFormat:@"No description for stat %@", [cost valueForKey:@"stat"]];
		case 1: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"+%d %@", self->value, descstr];
			case 2:		return [NSString stringWithFormat:@"%@ +%d", descstr, self->value];
			default:	return descstr;
		}
		case 2: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d%% %@", self->value, descstr];
			case 2:		return [NSString stringWithFormat:@"%@ %d%%", descstr, self->value];
			default:	return descstr;
		}
		case 3: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d %@", self->value, descstr];
			case 2:		return [NSString stringWithFormat:@"%@ %d", descstr, self->value];
			default:	return descstr;
		}
		case 4: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"+%d%% %@", self->value, descstr];
			case 2:		return [NSString stringWithFormat:@"%@ +%d%%", descstr, self->value];
			default:	return descstr;
		}
		case 5: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d%% %@", (int)(self->value/1.28), descstr];
			case 2:		return [NSString stringWithFormat:@"%@ %d%%", descstr, (int)(self->value/1.28)];
			default:	return descstr;
		}
		case 6: switch (descval)		// 1-5 repeated with descstr2 appended
		{
			// doesn't work for +to max damage! mult factor is 0.125 not 0.5 (like e.g. ar/lvl is)
			// from itemstatcost:   op	op param	op base		op stat1	op stat2			op stat3
			//	maxdam/level		4	3			level		maxdamage	secondary_maxdamage	item_throw_maxdamage
			//  ar/level			2	1			level		tohit
			case 1:		return [NSString stringWithFormat:@"+%d %@ %@", (int)(self->value*0.5), descstr, descstr2];
			case 2:		return [NSString stringWithFormat:@"%@ +%d %@", descstr, (int)(self->value*0.5), descstr2];
			default:	return descstr;
		}
		case 7: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d%% %@ %@", self->value, descstr, descstr2];
			case 2:		return [NSString stringWithFormat:@"%@ %d%% %@", descstr, self->value, descstr2];
			default:	return descstr;
		}
		case 8: switch (descval)		// are 8 and 9 supposed to be the opposite way round compared to 3 and 4 ?
		{
			case 1:		return [NSString stringWithFormat:@"+%d%% %@ %@", self->value, descstr, descstr2];
			case 2:		return [NSString stringWithFormat:@"%@ +%d%% %@", descstr, self->value, descstr2];
			default:	return descstr;
		}
		case 9: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d %@ %@", self->value, descstr, descstr2];
			case 2:		return [NSString stringWithFormat:@"%@ %d %@", descstr, self->value, descstr2];
			default:	return descstr;
		}
		case 10: switch (descval)
		{
			case 1:		return [NSString stringWithFormat:@"%d%% %@ %@", (int)(self->value/1.28), descstr, descstr2];
			case 2:		return [NSString stringWithFormat:@"%@ %d%% %@", descstr, (int)(self->value/1.28), descstr2];
			default:	return descstr;
		}
		case 11:		// used for 251 item_replenish_durability: "Repairs %d durability per second" or "Repairs %d durability in %d seconds"
		{
			// should first number always be 1 to the below?
			if (self->value/100.0 < 1.0)
				return [NSString stringWithFormat:Localise(@"ModStre9u"), 1, (int)(100/self->value)];
			else return [NSString stringWithFormat:descstr, (int)(self->value/100)];
		}
		case 12:		// used for item_stupidity (hit blinds target), item_freeze
		{
			return [NSString stringWithFormat:@"%@ %d%%", descstr, self->value];
		}
		case 13:		// used for +to all skills
		{
//			unsigned short points = (self->value & 0xFFFFF8) >> 3;
//			unsigned short charclass = (self->value & 0x07);
			unsigned short points = self->value;
			unsigned short charclass = self->param;
			id charstat = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/charstats.txt"] objectAtIndex:charclass];
			descstr = Localise([charstat valueForKey:@"strallskills"]);
			return [NSString stringWithFormat:@"+%d %@", points, descstr];
		}
		case 14:		// used for +to skill tab
		{
//			unsigned short points = (self->value & 0xFFFF0000) >> 16;
//			unsigned short charclass = (self->value & 0xFFF8) >> 3;
//			unsigned short tab = (self->value & 0x07);
			unsigned short points = self->value;
			unsigned short charclass = (self->param & 0xFFF8) >> 3;
			unsigned short tab = (self->param & 0x07);
			id charstat = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/charstats.txt"] objectAtIndex:charclass];
			descstr = Localise([charstat valueForKey:[NSString stringWithFormat:@"strskilltab%d", tab+1]]);
			descstr = [NSString stringWithFormat:descstr, points];
			return [NSString stringWithFormat:@"%@ %@", descstr, Localise([charstat valueForKey:@"strclassonly"])];
		}
		case 15:		// used for 195-199,201; e.g. "%d%% Chance to cast level %d %s when struck"
		{
//			unsigned short chance = (self->value & 0xFFFF0000) >> 16;
//			unsigned short spell = (self->value & 0xFFC0) >> 6;
//			unsigned short level = (self->value & 0x3F);
			unsigned short chance = self->value;
			unsigned short spell = (self->param & 0xFFC0) >> 6;
			unsigned short level = (self->param & 0x3F);
			id skill = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skills.txt"] firstObjectReturningValue:[NSString stringWithFormat:@"%d", spell] forKey:@"id"];
			id desc = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skilldesc.txt"] firstObjectReturningValue:[skill valueForKey:@"skilldesc"] forKey:@"skilldesc"];
			return [NSString stringWithFormat:descstr, chance, level, [Localise([desc valueForKey:@"str name"]) cString]];
		}
		case 16:		// used for item_aura: "Level %d %s Aura When Equipped"
		{
			return [NSString stringWithFormat:descstr, self->value, "Cheeseburger"];
		}
//		case 17:		// used for 268: item_armor_bytime, subesequent _bytime ones
//		case 18:		// used for 269: item_armorpercent_bytime, subsequent percent_bytime ones
//		case 19:		// unknown usage
		case 20: switch (descval)	// used for item_fractionaltargetac, 307-310: item_pierce_cold/fire/lght/pois, 335-228: passive_fire_pierce etc.
		{
			case 1:		return [NSString stringWithFormat:@"-%d%% %@", self->value, descstr];
			case 2:		return [NSString stringWithFormat:@"%@ -%d%%", descstr, self->value];
			default:	return descstr;
		}
//		case 21:		// unknown usage
//		case 22:		// used for attack_vs_montype, damage_vs_montype
//		case 23:		// used for item_reanimate
		case 24:		// used for 204: item_charged_skill
		{
			unsigned short max = (self->value & 0xFF000000) >> 24;
			unsigned short count = (self->value & 0x00FF0000) >> 16;
			unsigned short spell = (self->value & 0xFFC0) >> 6;
			unsigned short level = (self->value & 0x3F);
			id skill = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skills.txt"] firstObjectReturningValue:[NSString stringWithFormat:@"%d", spell] forKey:@"id"];
			id desc = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skilldesc.txt"] firstObjectReturningValue:[skill valueForKey:@"skilldesc"] forKey:@"skilldesc"];
			return [NSString stringWithFormat:@"%@ %d %@ %@", Localise(@"ModStre10b"), level, Localise([desc valueForKey:@"str name"]), [NSString stringWithFormat:descstr, count, max]];
		}
//		case 25:		// unknown usage
//		case 26:		// unknown usage
		case 27:		// used for +to single skill
		{
			unsigned short points = self->value;
			unsigned short spell = self->param;
			id skill = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skills.txt"] firstObjectReturningValue:[NSString stringWithFormat:@"%d", spell] forKey:@"id"];
			id desc = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/skilldesc.txt"] firstObjectReturningValue:[skill valueForKey:@"skilldesc"] forKey:@"skilldesc"];
			id pc = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/PlayerClass.txt"] firstObjectReturningValue:[skill valueForKey:@"charclass"] forKey:@"code"];
			id charstat = [[[MPQReader defaultReader] entriesForFile:@"data/global/excel/charstats.txt"] firstObjectReturningValue:[pc valueForKey:@"player class"] forKey:@"class"];
			return [NSString stringWithFormat:@"+%d %@ %@ %@", points, Localise(@"to"), Localise([desc valueForKey:@"str name"]), Localise([charstat valueForKey:@"strclassonly"])];
		}
//		case 28:		// used for item_nonclassskill
	}
	return [NSString stringWithFormat:@"%@: Unknown descfunc(%d,%d)", descstr, descfunc, descval];
//	return [self description];
}

- (NSString *)description
{
	NSArray *itemstatcost = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/ItemStatCost.txt"];
	if (self->index != -1)
	{
		id cost = [itemstatcost objectAtIndex:self->index];
		return [NSString stringWithFormat:@"%d = %d,%d (%d,%d)", self->index, value, param, [[cost valueForKey:@"save bits"] intValue], [[cost valueForKey:@"save param bits"] intValue]];
	}
	else return [NSString stringWithFormat:@"%d", self->index];
}

@end
