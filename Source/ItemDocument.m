#import "ItemDocument.h"
#import "Item.h"
#import "Node.h"
#import "AppDelegate.h"

#import "Localization.h"

extern NSArray *armour, *weapons, *misc, *itemTable;
extern NSArray *setitems, *uniqueitems;

@implementation ItemDocument
- (id)init
{
	self = [super init];
	if (!self) return nil;
	
	// create arrays of browser cells
	normalRootNode = [[Node alloc] initWithCode:nil];
	Node *armourNode = [[Node alloc] initWithName:@"Armour"];
	Node *weaponsNode = [[Node alloc] initWithName:@"Weapons"];
	Node *miscNode = [[Node alloc] initWithName:@"Miscellaneous"];
	[normalRootNode addChild:armourNode];
	[normalRootNode addChild:weaponsNode];
	[normalRootNode addChild:miscNode];
	[armourNode addChildrenWithCodes:[armour valueForKey:@"code"]];
	[weaponsNode addChildrenWithCodes:[weapons valueForKey:@"code"]];
	[miscNode addChildrenWithCodes:[misc valueForKey:@"code"]];
	
	// create dictionary of set items
	NSString *currentKey = nil, *currentSet = nil, *currentItem = nil;
	NSMutableDictionary *sets = [NSMutableDictionary dictionary];
	NSMutableArray *currentValue = [NSMutableArray array];
	for (unsigned i = 0; i < [setitems count]; i++)
	{
		currentSet = [[setitems objectAtIndex:i] valueForKey:@"set"];
		currentItem = [[setitems objectAtIndex:i] valueForKey:@"index"];
		if (![currentKey isEqualToString:currentSet])
		{
			// we have a new set, save old one, initalise values for next set
			if (currentKey)
				[sets setValue:currentValue forKey:currentKey];
			currentKey = currentSet;
			currentValue = [NSMutableArray array];
		}
		[currentValue addObject:[setitems objectAtIndex:i]];
	}
	// save last set
	if (currentKey)
		[sets setValue:currentValue forKey:currentKey];
	
	// loop through sets and make nodes
	NSString *setName;
	setRootNode = [[Node alloc] initWithCode:nil];
	NSEnumerator *setEnumerator = [[[sets allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectEnumerator];
	while (setName = [setEnumerator nextObject])
	{
		NSDictionary *itemEntry;
		Node *setNode = [[Node alloc] initWithName:setName];
		NSEnumerator *itemEnumerator = [[sets valueForKey:setName] objectEnumerator];
		while (itemEntry = [itemEnumerator nextObject])
			[setNode addChild:[[Node alloc] initWithCode:[itemEntry valueForKey:@"item"] name:[itemEntry valueForKey:@"index"] itemID:[NSNumber numberWithUnsignedInt:[setitems indexOfObjectIdenticalTo:itemEntry]]]];
		[setRootNode addChild:setNode];
	}
	
	NSDictionary *itemEntry;
	uniqueRootNode = [[Node alloc] initWithCode:nil];
	NSEnumerator *uniqueEnumerator = [uniqueitems objectEnumerator];
	while (itemEntry = [uniqueEnumerator nextObject])
		[uniqueRootNode addChild:[[Node alloc] initWithCode:[itemEntry valueForKey:@"code"] name:[itemEntry valueForKey:@"index"] itemID:[NSNumber numberWithUnsignedInt:[uniqueitems indexOfObjectIdenticalTo:itemEntry]]]];
	
	// set default property list to 'all'
	selectedPlist = -1;
	
	owner = nil;
	item = [[Item alloc] init];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self]; // is this necesary?
	[item release];
	[normalRootNode release];
	[setRootNode release];
	[uniqueRootNode release];
	[super dealloc];
}

- (NSString *)windowNibName
{
	return @"ItemDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
#pragma unused(windowController)
	[gemTable setTarget:self];
	[gemTable setDoubleAction:@selector(openSelection:)];
}

- (void)openSelection:(id)sender
{
#pragma unused(sender)
	NSIndexSet *selection = [gemTable selectedRowIndexes];
	if ([selection firstIndex] != NSNotFound)
	{
		ItemDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:@"Diablo II Item File" display:NO];
		if (doc)
		{
			[doc setOwner:self];
			[doc setItem:[[item valueForKey:@"gems"] objectAtIndex:[selection firstIndex]]];
			[doc showWindows];
		}
	}
}

- (NSString *)displayName
{
	NSString *ownerName = [owner displayName];
	NSString *newName = [item valueForKey:@"name"];
	if (!newName) newName = [super displayName];
	
//	NSLog(@"ownerName = %@", ownerName);
//	NSLog(@"newName = %@", newName);
//	NSLog(@"displayName = %@ > %@", ownerName, newName);
//	NSLog(@"displayName = %@", [NSString stringWithFormat:@"%@ > %@", ownerName, newName]);
	
	if (ownerName)
		return [NSString stringWithFormat:@"%@ > %@", ownerName, newName];
	else return newName;
}

- (NSData *)dataRepresentationOfType:(NSString *)type
{
#pragma unused(type)
	return [item data];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type
{
#pragma unused(type)
	Item *old = item;
	uint32_t bit_offset = 0;
	item = [[Item alloc] initWithBytes:(const uint8_t *)[data bytes] bitOffset:&bit_offset];
	[old release];
	[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
//	[[NSValueTransformer valueTransformerForName:@"SelectedCodeIndex"] setValue:item forKey:@"item"];
	if (item) return YES;
	else return NO;
}

- (NSDocument *)owner
{
	return owner;
}

- (void)setOwner:(NSDocument *)newOwner
{
	owner = newOwner;
}

- (Item *)item
{
	return item;
}

- (void)setItem:(Item *)newItem
{
	if (newItem && newItem != item)
	{
		Item *old = item;
		item = [newItem retain];
		[old release];
		[[self windowControllers] makeObjectsPerformSelector:@selector(synchronizeWindowTitleWithDocumentName)];
//		[[NSValueTransformer valueTransformerForName:@"SelectedCodeIndex"] setValue:item forKey:@"item"];
		// watch for changes to code
		[item addObserver:self forKeyPath:@"code" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
		[item addObserver:self forKeyPath:@"set_id" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
		[item addObserver:self forKeyPath:@"unique_id" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
		[item addObserver:self forKeyPath:@"uniqueness" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
		[item addObserver:self forKeyPath:@"compact" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#pragma unused(context)
	if (object == item && [keyPath isEqualToString:@"code"])
		[self selectNodeWithCode:[change objectForKey:NSKeyValueChangeNewKey]];
	
/*	else if (object == item && ([keyPath isEqualToString:@"set_id"] || [keyPath isEqualToString:@"unique_id"]))
		[self selectNodeWithID:[change objectForKey:NSKeyValueChangeNewKey]];
*/	
	else if (object == item && ([keyPath isEqualToString:@"compact"]))
	{
		long templong = random();
		[item setValue:[[[NSData alloc] initWithBytes:&templong length:4] autorelease] forKey:@"guid"];
	}
	
	else if (object == item && [keyPath isEqualToString:@"uniqueness"])
	{
		[typeBrowser loadColumnZero];
		if ([item valueForKey:@"set_id"])			[self selectNodeWithID:[item valueForKey:@"set_id"]];
		else if ([item valueForKey:@"unique_id"])	[self selectNodeWithID:[item valueForKey:@"unique_id"]];
		else										[self selectNodeWithCode:[item code]];
		[item setName];
	}
}

- (NSString *)description
{
	return [item description];
}

// item type browser delegate methods
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
#pragma unused(sender)
	return [[self parentNodeOfColumn:column] numChildren];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
#pragma unused(sender)
	Node *node = [[self parentNodeOfColumn:column] childAt:row];
	[cell setLeaf:[node hasChildren]? NO:YES];
	[cell setTitle:[node name]];
}

// item type browser click action
- (IBAction)browserCellSelected:(NSBrowser *)sender
{
#pragma unused(sender)
	Node *node = [self selectedNode];
	[item removeObserver:self forKeyPath:@"code"];
	if ([node itemID] != nil)	[item setID:[node itemID]];
	if ([node code] != nil)		[item setCode:[node code]];
	[item addObserver:self forKeyPath:@"code" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

// item type browser helper methods
- (Node *)rootNode
{
	switch ([[item uniqueness] intValue])
	{
		case 1:		return setRootNode;
		case 2:		return uniqueRootNode;
		default:	return normalRootNode;
	}
}

- (Node *)selectedNode
{
	return [self selectedNodeInColumn:[typeBrowser selectedColumn]];
}

- (Node *)selectedNodeInColumn:(int)column
{
	Node *parent = [self parentNodeOfColumn:column];
	unsigned int index = [typeBrowser selectedRowInColumn:column];
	if (parent != nil && index >= 0 && index < [[parent children] count])
		return [parent childAt:index];
	else return nil;
}

- (Node *)parentNodeOfColumn:(int)column
{
	if (column > 0) return [self selectedNodeInColumn:column-1];
	else return [self rootNode];
}

- (int)selectNode:(Node *)node
{
	if (!node) NSLog(@"Trying to select nil node");
	if (node == normalRootNode || node == setRootNode || node == uniqueRootNode || node == nil) return -1;
	int column = [self selectNode:[node parent]] +1;
	if ([self selectedNodeInColumn:column] != node)
		[typeBrowser selectRow:[[node parent] indexOfChild:node] inColumn:column];
	return column;
}

- (void)selectNodeWithCode:(NSString *)code
{
	if (code) [self selectNode:[self findChildOfNode:[self rootNode] withCode:code]];
	else NSLog(@"Trying to select node with nil code");
}

- (void)selectNodeWithID:(NSNumber *)itemID
{
	if (itemID) [self selectNode:[self findChildOfNode:[self rootNode] withID:itemID]];
	else NSLog(@"Trying to select node with nil ID");
}

- (Node *)findChildOfNode:(Node *)parent withCode:(NSString *)code
{
	Node *node;
	NSEnumerator *enumerator = [[parent children] objectEnumerator];
	while (node = [enumerator nextObject])
	{
		if ([[node code] isEqualToString:code]) return node;
		if ([node hasChildren])
		{
			Node *result = [self findChildOfNode:node withCode:code];
			if (result) return result;
		}
	}
	NSLog(@"No child of %@ found with code %@!", parent, code);
	return nil;
}

- (Node *)findChildOfNode:(Node *)parent withID:(NSNumber *)itemID
{
	Node *node;
	NSEnumerator *enumerator = [[parent children] objectEnumerator];
	while (node = [enumerator nextObject])
	{
		if ([[node itemID] isEqual:itemID]) return node;
		if ([node hasChildren])
		{
			Node *result = [self findChildOfNode:node withID:itemID];
			if (result) return result;
		}
	}
	return nil;
}

// document tab manegemnt
- (NSMutableArray *)currentPlist
{
	return [NSMutableArray array];
//  return [[item properties] objectAtIndex:selectedPlist];
}

- (void)setSelectedPlist:(signed int)value
{
	[self willChangeValueForKey:@"allProperties"];
	selectedPlist = value;
	[self didChangeValueForKey:@"allProperties"];
}

- (NSMutableArray *)allProperties
{
	if (selectedPlist == -1)
	{
		NSArray *plist;
		NSMutableArray *array = [NSMutableArray array];
		NSEnumerator *enumerator = [[item properties] objectEnumerator];
		while (plist = [enumerator nextObject])
			[array addObjectsFromArray:plist];
		return array;
	}
	else return [[item properties] objectAtIndex:selectedPlist];
}

// indexed accessors for allProperties
- (unsigned int)countOfAllProperties
{
	if (selectedPlist == -1)
	{
		unsigned int count = 0;
		NSArray *plist;
		NSEnumerator *enumerator = [[item properties] objectEnumerator];
		while (plist = [enumerator nextObject])
			count += [plist count];
		return count;
	}
	else return [[[item properties] objectAtIndex:selectedPlist] count];
}

- (id)objectInAllPropertiesAtIndex:(unsigned int)index 
{
	if (selectedPlist == -1)
	{
		NSArray *plist;
		NSMutableArray *array = [NSMutableArray array];
		NSEnumerator *enumerator = [[item properties] objectEnumerator];
		while (plist = [enumerator nextObject])
			[array addObjectsFromArray:plist];
		return [array objectAtIndex:index];
	}
	else return [[[item properties] objectAtIndex:selectedPlist] objectAtIndex:index];
}

- (void)insertObject:(id)object inAllPropertiesAtIndex:(unsigned int)index 
{
	if (selectedPlist == -1)
	{
		NSMutableArray *plist = [[item properties] objectAtIndex:0];  // inserts new objects into main plist
		if (index < [plist count])   [plist insertObject:object atIndex:index];
		else						[plist insertObject:object atIndex:[plist count]];
	}
	else [[[item properties] objectAtIndex:selectedPlist] insertObject:object atIndex:index];
}

- (void)removeObjectFromAllPropertiesAtIndex:(unsigned int)index 
{
	if (selectedPlist == -1)
	{
		unsigned int count = 0;
		NSMutableArray *plist;
		NSEnumerator *enumerator = [[item properties] objectEnumerator];
		while (plist = [enumerator nextObject])
		{
			count += [plist count];
			if (index < count)
				[plist removeObjectAtIndex:(index-[plist count])];
		}
	}
	else [[[item properties] objectAtIndex:selectedPlist] removeObjectAtIndex:index];
}

- (void)replaceObjectInAllPropertiesAtIndex:(unsigned int)index withObject:(id)object 
{
	if (selectedPlist == -1)
	{
		unsigned int count = 0;
		NSMutableArray *plist;
		NSEnumerator *enumerator = [[item properties] objectEnumerator];
		while (plist = [enumerator nextObject])
		{
			count += [plist count];
			if (index < count)
				[plist replaceObjectAtIndex:(index-[plist count]) withObject:object];
		}
	}
	else [[[item properties] objectAtIndex:selectedPlist] replaceObjectAtIndex:index withObject:object];
}

- (void)showPropertiesHelp:(id)sender
{
#pragma unused(sender)
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.xmission.com/~trevin/DiabloIIv1.09_Magic_Properties.shtml"]];
}
@end

static NSString *kItemVersion0 = @"1.00-1.06";
static NSString *kItemVersion1 = @"1.07-1.09";
static NSString *kItemVersion2 = @"1.10";
static NSString *kItemVersion100 = @"1.07-1.09 Expansion";
static NSString *kItemVersion101 = @"1.10 Expansion";

@implementation StringFromItemVersionTransformer
+ (Class)transformedValueClass			{	return [NSString class];		}
+ (BOOL)supportsReverseTransformation	{	return YES;						}
- (id)transformedValue:(id)value
{
	switch ([value intValue])
	{
		case 0:		return kItemVersion0;
		case 1:		return kItemVersion1;
		case 2:		return kItemVersion2;
		case 100:   return kItemVersion100;
		case 101:   return kItemVersion101;
		default:	return nil;
	}
}
- (id)reverseTransformedValue:(id)value
{
	if ([value isEqual:kItemVersion0])		return [NSNumber numberWithInt:0];
	if ([value isEqual:kItemVersion1])		return [NSNumber numberWithInt:1];
	if ([value isEqual:kItemVersion2])		return [NSNumber numberWithInt:2];
	if ([value isEqual:kItemVersion100])		return [NSNumber numberWithInt:100];
	if ([value isEqual:kItemVersion101])		return [NSNumber numberWithInt:101];
											return nil;
}
@end

@implementation NormalNameFromCodeTransformer
+ (Class)transformedValueClass			{	return [NSString class];		}
+ (BOOL)supportsReverseTransformation	{	return NO;						}
- (id)transformedValue:(id)value
{
	id code = [[itemTable firstObjectReturningValue:value forKey:@"code"] valueForKey:@"normcode"];
	return Localise(code);
}
@end