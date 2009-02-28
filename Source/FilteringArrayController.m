#import "FilteringArrayController.h"
#import <Foundation/NSKeyValueObserving.h>

@implementation FilteringArrayController
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (!self) return nil;
	substringFilters = [[NSMutableDictionary alloc] init];
	valueFilters = [[NSMutableDictionary alloc] init];
	return self;
}
- (void)dealloc
{
	[substringFilters release];
	[valueFilters release];
	[super dealloc];
}

- (id)newObject
{
	latestAddition = [super newObject];
	return latestAddition;
}
- (NSArray *)arrangeObjects:(NSArray *)objects
{
	// iterates through string filters, removing items which don't contain the substring
	id key, item;
	NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
	NSEnumerator *filterEnumerator = [substringFilters keyEnumerator];
	while (key = [filterEnumerator nextObject])
	{
		// iterates through filtered objects, only objects which match all filters survive
		NSEnumerator *objectsEnumerator = [objects objectEnumerator];
		while (item = [objectsEnumerator nextObject])
		{
			NSRange range = [[item valueForKeyPath:key] rangeOfString:[substringFilters valueForKey:key] options:NSCaseInsensitiveSearch];
			if (range.location != NSNotFound || item == latestAddition)
				[filteredObjects addObject:item];
		}
		objects = filteredObjects;
		filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
	}
	
	// iterates through value filters, removing items which don't match (according to isEqual:)
	filterEnumerator = [valueFilters keyEnumerator];
	while (key = [filterEnumerator nextObject])
	{
		// iterates through filtered objects, only objects which match all filters survive
		NSEnumerator *objectsEnumerator = [objects objectEnumerator];
		while (item = [objectsEnumerator nextObject])
		{
			BOOL equal = [[item valueForKeyPath:key] isEqual:[valueFilters valueForKey:key]];
			if (equal || item == latestAddition)
				[filteredObjects addObject:item];
		}
		objects = filteredObjects;
		filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
	}
	latestAddition = nil;
	return [super arrangeObjects:objects];
}
@end

@implementation ItemArrayController
- (void)search:(id)sender
{
	if ([[sender stringValue] isEqualToString:@""])
		[substringFilters setValue:nil forKey:@"name"];
	else [substringFilters setValue:[sender stringValue] forKey:@"name"];
	[self rearrangeObjects];
}
- (void)location:(id)sender
{
	switch ([[sender selectedItem] tag])
	{
		case 0:		// all locations
			[valueFilters setValue:nil forKey:@"location"];
			[valueFilters setValue:nil forKey:@"grid_page"];
			break;
		case 1:		// equipped
			[valueFilters setValue:[NSNumber numberWithInt:1] forKey:@"location"];
			[valueFilters setValue:nil forKey:@"grid_page"];
			break;
		case 2:		// inventory
			[valueFilters setValue:[NSNumber numberWithInt:0] forKey:@"location"];
			[valueFilters setValue:[NSNumber numberWithInt:1] forKey:@"grid_page"];
			break;
		case 3:		// stash
			[valueFilters setValue:[NSNumber numberWithInt:0] forKey:@"location"];
			[valueFilters setValue:[NSNumber numberWithInt:5] forKey:@"grid_page"];
			break;
		case 4:		// cube
			[valueFilters setValue:[NSNumber numberWithInt:0] forKey:@"location"];
			[valueFilters setValue:[NSNumber numberWithInt:4] forKey:@"grid_page"];
			break;
		case 5:		// belt
			[valueFilters setValue:[NSNumber numberWithInt:2] forKey:@"location"];
			[valueFilters setValue:nil forKey:@"grid_page"];
			break;
		case 6:		// cursor
			[valueFilters setValue:[NSNumber numberWithInt:4] forKey:@"location"];
			[valueFilters setValue:nil forKey:@"grid_page"];
			break;
	}
	[self rearrangeObjects];
}
@end
