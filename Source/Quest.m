#import "Quest.h"

@implementation Quest

+ (Quest *)questWithName:(NSString *)q_name options:(NSArray *)q_options
{
	Quest *q = [[Quest alloc] initWithName:q_name options:q_options];
	return [q autorelease];
}

- (Quest *)initWithName:(NSString *)q_name options:(NSArray *)q_options
{
	self = [super init];
	if (!self) return nil;
	name = [q_name retain];
	options = [q_options retain];
	progress = [[NSNumber alloc] initWithShort:0];
	return self;
}

- (void)dealloc
{
	[name autorelease];
	[options autorelease];
	[progress autorelease];
	[super dealloc];
}

- (NSMutableArray *)progressBools
{
	NSMutableArray *array = [NSMutableArray array];
	for (int i = 0; i < 16; i++)
	{
		NSDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:([progress intValue] >> i) & 1], @"progress", [options objectAtIndex:i], @"options", nil];
		[dict addObserver:self forKeyPath:@"progress" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:array];
		[array addObject:dict];
	}
	return array;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) return;
	unsigned index = [(id)context indexOfObjectIdenticalTo:object];
	BOOL flag = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
	[self setValue:[NSNumber numberWithUnsignedShort:(flag << index) | ([progress shortValue] & ~(1 << index))] forKey:@"progress"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Quest { name = %@; progress = %@ }", name, progress];
}

@end
