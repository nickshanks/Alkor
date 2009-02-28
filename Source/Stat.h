#import <Foundation/Foundation.h>

@interface Stat : NSObject
{
	signed short index;		// index into itemstatcost.txt, -1 if unused
	unsigned long param;	// param e.g. spell to cast, gets saved though
	unsigned long value;	// value for this stat
}
+ (Stat *)statWithIndex:(signed short)i value:(unsigned long)v param:(unsigned long)p;
- (Stat *)initWithIndex:(signed short)i value:(unsigned long)v param:(unsigned long)p;
- (signed short)index;
- (unsigned long)param;
- (unsigned long)value;
- (NSString *)name;
@end