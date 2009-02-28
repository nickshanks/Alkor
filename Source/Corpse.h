#import <Foundation/Foundation.h>

@interface Corpse : NSObject
{
	NSNumber *unknown0;
	NSNumber *xPos;
	NSNumber *yPos;
	NSMutableArray *items;
}
- (id)initWithUnknown:(unsigned long)unk xpos:(unsigned int)x ypos:(unsigned int)y;
- (unsigned long)unknown0;
- (void)setUnknown0:(unsigned long)unk;
- (unsigned long)xPos;
- (void)setXPos:(unsigned long)x;
- (unsigned long)yPos;
- (void)setYPos:(unsigned long)y;
- (NSMutableArray *)items;
- (void)setItems:(NSMutableArray *)newItems;
- (NSData *)data;
@end
