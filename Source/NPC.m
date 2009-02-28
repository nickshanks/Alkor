#import "NPC.h"

@implementation NPC
+ (NPC *)npcWithName:(NSString *)npc_name
{
	NPC *npc = [[NPC alloc] initWithName:(NSString *)npc_name];
	return [npc autorelease];
}
- (NPC *)initWithName:(NSString *)npc_name
{
	self = [super init];
	if (!self) return nil;
	name = [npc_name retain];
	introduction = [[NSNumber alloc] initWithBool:false];
	congratulation = [[NSNumber alloc] initWithBool:false];
	return self;
}
- (void)dealloc
{
	[name autorelease];
	[introduction autorelease];
	[congratulation autorelease];
	[super dealloc];
}
@end
