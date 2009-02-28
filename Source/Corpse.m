#import "Corpse.h"
#import "Item.h"

@implementation Corpse

- (id)initWithUnknown:(unsigned long)unk xpos:(unsigned int)x ypos:(unsigned int)y
{
	self = [super init];
	if (!self) return nil;
	unknown0 = [[NSNumber alloc] initWithUnsignedLong:unk];
	xPos = [[NSNumber alloc] initWithUnsignedLong:x];
	yPos = [[NSNumber alloc] initWithUnsignedLong:y];
	items = nil;
	return self;
}

- (NSData *)data
{
	Item *item;
	unsigned long temp;
	NSEnumerator *enumerator = [items objectEnumerator];
	NSMutableData *data = [NSMutableData data];
	temp = NSSwapHostLongToLittle([unknown0 unsignedLongValue]);	[data appendBytes:&temp length:4];
	temp = NSSwapHostLongToLittle([xPos unsignedLongValue]);		[data appendBytes:&temp length:4];
	temp = NSSwapHostLongToLittle([yPos unsignedLongValue]);		[data appendBytes:&temp length:4];
	while (item = [enumerator nextObject])
		[data appendData:[item data]];
	return data;
}

- (unsigned long)unknown0
{
	return [unknown0 unsignedLongValue];
}

- (void)setUnknown0:(unsigned long)unk
{
	id old = unknown0; unknown0 = [[NSNumber alloc] initWithUnsignedLong:unk]; [old release];
}

- (unsigned long)xPos
{
	return [xPos unsignedLongValue];
}

- (void)setXPos:(unsigned long)x
{
	id old = xPos; xPos = [[NSNumber alloc] initWithUnsignedLong:x]; [old release];
}

- (unsigned long)yPos
{
	return [yPos unsignedLongValue];
}

- (void)setYPos:(unsigned long)y
{
	id old = yPos; yPos = [[NSNumber alloc] initWithUnsignedLong:y]; [old release];
}

- (NSMutableArray *)items
{
	return items;
}

- (void)setItems:(NSMutableArray *)i
{
	id old = items; items = [i retain]; [old release];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"{\nunknown0 = %@; xPos = %@; yPos = %@;\nitems = %@\n}", unknown0, xPos, yPos, items];
}

@end
