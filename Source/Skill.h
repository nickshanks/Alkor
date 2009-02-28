#import <Foundation/Foundation.h>

@interface Skill : NSObject
{
	NSDictionary *skill;
	NSNumber *points;	// points allocated to skill
}
+ (Skill *)skillWithID:(unsigned long)s_id;
- (Skill *)initWithID:(unsigned long)s_id;
- (id)charclass;
- (int)charclassAsInt;
@end
