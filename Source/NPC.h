#import <Foundation/Foundation.h>

@interface NPC : NSObject
{
	NSString *name;				// e.g Deckard Cain
	NSNumber *introduction;		// boolean
	NSNumber *congratulation;	// boolean
}
+ (NPC *)npcWithName:(NSString *)npc_name;
- (NPC *)initWithName:(NSString *)npc_name;
@end
