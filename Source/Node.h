#import <Foundation/Foundation.h>

@interface Node : NSObject
{
	NSString *code;		// code of object, e.g. 'hax'
	NSString *name;		// custom name for nodes that need it
	NSNumber *itemID;   // set or unique ID for item
	Node *parent;
	NSMutableArray *children;
}

- (id)initWithCode:(NSString *)c;
- (id)initWithName:(NSString *)n;
- (id)initWithCode:(NSString *)c name:(NSString *)n;
- (id)initWithID:(NSNumber *)i name:(NSString *)n;
- (id)initWithCode:(NSString *)c name:(NSString *)n itemID:(NSNumber *)i;
- (void)setParent:(Node *)p;
- (void)addChildrenWithCodes:(NSArray *)array;
- (void)addChild:(Node *)child;
- (BOOL)hasChildren;
- (int)numChildren;
- (Node *)childAt:(int)index;
- (int)indexOfChild:(Node *)node;
- (NSString *)code;
- (NSString *)name;
- (NSNumber *)itemID;
- (Node *)parent;
- (NSArray *)children;
@end