#import "Waypoint.h"

@implementation Waypoint

+ (Waypoint *)waypointWithName:(NSString *)wp_name
{
	Waypoint *wp = [[Waypoint alloc] initWithName:(NSString *)wp_name];
	return [wp autorelease];
}

- (Waypoint *)initWithName:(NSString *)wp_name
{
	self = [super init];
	if (!self) return nil;
	name = [wp_name retain];
	active = [[NSNumber alloc] initWithBool:false];
	return self;
}

- (void)dealloc
{
	[name autorelease];
	[active autorelease];
	[super dealloc];
}

- (void)activate:(NSScriptCommand *)command
{
	[self setValue:[[NSNumber alloc] initWithBool:true] forKey:@"active"];
}

- (void)deactivate:(NSScriptCommand *)command
{
	[self setValue:[[NSNumber alloc] initWithBool:false] forKey:@"active"];
}

@end
