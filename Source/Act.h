#import <Foundation/Foundation.h>

@interface Difficulty : NSObject
{
	NSString *name;
	NSMutableArray *acts;
}
@end

@interface Act : NSObject
{
	NSMutableArray *quests;
	NSMutableArray *waypoints;
	NSMutableArray *npcs;
	
	NSNumber *introduction;
	NSNumber *completion;
}
- (Act *)initWithValue:(int)value;
@end


// value transformers
@interface LevelFromExperienceTransformer : NSValueTransformer
@end
