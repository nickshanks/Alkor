#import "Node.h"
#import "AppDelegate.h"

#import "Localization.h"

extern globals g;
extern NSDictionary *stringTable;
extern NSArray *armour, *weapons, *misc, *itemTable;

@implementation Node

- (id)initWithCode:(NSString *)c
{
	return [self initWithCode:c name:nil];
}

- (id)initWithName:(NSString *)n
{
	return [self initWithCode:nil name:n];
}

- (id)initWithCode:(NSString *)c name:(NSString *)n
{
	return [self initWithCode:c name:n itemID:nil];
}

- (id)initWithID:(NSNumber *)i name:(NSString *)n
{
	return [self initWithCode:nil name:n itemID:i];
}

- (id)initWithCode:(NSString *)c name:(NSString *)n itemID:(NSNumber *)i
{
	self = [super init];
	if (!self) return nil;
	code = [c copy];
	name = [n copy];
	itemID = [i copy];
	return self;
}

- (void)dealloc
{
	[code release];
	[name release];
	[children release];
	[super dealloc];
}

- (void)setParent:(Node *)p
{
	parent = p;
}

- (void)addChildrenWithCodes:(NSArray *)array
{
	if (children == nil)
		children = [[NSMutableArray alloc] init];
	NSString *new_code;
	NSEnumerator *enumerator = [array objectEnumerator];
	while (new_code = [enumerator nextObject])
	{
		Node *child = [[Node alloc] initWithCode:new_code];
		[children addObject:child];
		[child setParent:self];
	}
}

- (void)addChild:(Node *)child
{
	if (children == nil)
		children = [[NSMutableArray alloc] init];
	[children addObject:child];
	[child setParent:self];
}

- (BOOL)hasChildren
{
    return children != nil && [children count] > 0;
}

- (int)numChildren
{
	return (children != nil) ? [children count] : 0;
}

- (Node *)childAt:(int)index
{
	return [children objectAtIndex:index];
}

- (int)indexOfChild:(Node *)node
{
	return (children != nil)? [children indexOfObject:node] : NSNotFound;
}

// accessors
- (NSString *)code
{
	return code;
}

- (NSString *)name
{
	if (name) return Localise(name);
	else
	{
		NSString *translation = Localise(code);
		if ([translation isEqualToString:code])
			return [[itemTable firstObjectReturningValue:code forKey:@"code"] valueForKey:@"name"];
		else return translation;
	}
}

- (NSNumber *)itemID
{
	return itemID;
}

- (Node *)parent
{
	return parent;
}

- (NSArray *)children
{
	return children;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"{ “%@”, %@ %@, ‘%@’, %d }", name, code, itemID, [parent name], [children count]];
}

@end