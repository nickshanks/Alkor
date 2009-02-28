#import "PropertyLists.h"
#import "MPQReader.h"
#import "Property.h"
#import "Stat.h"
#import "CharacterDocument.h"
#include "bits.h"

NSMutableArray *read_property_list(const uint8_t *data, uint32_t *bit_offset, bool csave)
{
	NSArray *itemstatcost = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/ItemStatCost.txt"];
	NSMutableArray *array = [NSMutableArray array];
	
	bool done = false;
	unsigned short savetest = 0;
	while (!done && data && bit_offset)
	{
		// read the 9-bit key
		short key = read_bits(data, bit_offset, 9);
		switch (key)
		{
			case 511:
				done = true;
				break;
			
			default:
				Property *p = [Property property];
				NSMutableArray *stats = [p stats];
				for (int i = 0; i < 7; i++)
				{
					if (i < item_property_stat_count[key] && data && bit_offset)
					{
						id cost = [itemstatcost objectAtIndex:key+i];
						unsigned savebits = csave?  [[cost valueForKey:@"csvbits"] intValue]  : [[cost valueForKey:@"save bits"] intValue];
						unsigned parambits = csave? [[cost valueForKey:@"csvparam"] intValue] : [[cost valueForKey:@"save param bits"] intValue];
						unsigned valadd = csave?											0 : [[cost valueForKey:@"save add"] intValue];
						unsigned long param = read_bits(data, bit_offset, parambits);
						unsigned long value = read_bits(data, bit_offset, savebits) - valadd;
						[stats replaceObjectAtIndex:i withObject:[Stat statWithIndex:key+i value:value param:param]];
					}
				}
				[array addObject:p];
				if (csave) savetest |= 1 << key;
				break;
		}
	}
	
	// fill in empty ones if we're reading in character stats (bit of a hack to help the UI)
	if (csave)
	{
		for (int i = 0; i < 16; i++)
		{
			if (!((savetest >> i) & 1))
			{
				Property *p = [Property property];   // property property, property property property. Property property property property property!
				[[p stats] replaceObjectAtIndex:0 withObject:[Stat statWithIndex:i value:0 param:0]];
				[array insertObject:p atIndex:i];
			}
		}
	}
	return array;
}

void write_property_list(uint8_t *buffer, uint32_t *bit_offset, NSArray *plist, bool csave)
{
	NSArray *itemstatcost = [[MPQReader defaultReader] entriesForFile:@"data/global/excel/ItemStatCost.txt"];
	NSEnumerator *enumerator = [plist objectEnumerator];
	while (Property *p = [enumerator nextObject])
	{
		NSEnumerator *statEnumerator = [[p stats] objectEnumerator];
		while (Stat *s = [statEnumerator nextObject])
		{
			signed short index = [s index];
			unsigned long value = [s value];
			unsigned long param = [s param];
			
			// don't save properties with a value of 0
			if (index != -1 && !(s == [[p stats] objectAtIndex:0] && value == 0))
			{
				// write values for subsequent keys
				id cost = [itemstatcost objectAtIndex:index];
				unsigned savebits = csave?  [[cost valueForKey:@"csvbits"] intValue]  : [[cost valueForKey:@"save bits"] intValue];
				unsigned parambits = csave? [[cost valueForKey:@"csvparam"] intValue] : [[cost valueForKey:@"save param bits"] intValue];
				unsigned valadd = csave?											0 : [[cost valueForKey:@"save add"] intValue];
				if (s == [[p stats] objectAtIndex:0])	// only save key for first stat
					set_bits(buffer, index, bit_offset, 9);
				set_bits(buffer, param, bit_offset, parambits);
				set_bits(buffer, value + valadd, bit_offset, savebits);
			}
		}
	}
	
	// property list terminator
	set_bits(buffer, 511, bit_offset, 9);
}
