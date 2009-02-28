#import <Cocoa/Cocoa.h>

/*!
    @class		ItemDocument
    @abstract   An NSDocument subclass representing a .d2i file.
    @discussion Discussion forthcoming.
*/
@class Item, Node;
@interface ItemDocument : NSDocument
{
	IBOutlet NSBrowser	*typeBrowser;
	IBOutlet NSTableView *gemTable;
	
	NSDocument *owner;		// either a CharacterDocument or another ItemDocument (for socketed items); nil for d2i files
	Item *item;
	
	// item type browser
	Node *normalRootNode;
	Node *setRootNode;
	Node *uniqueRootNode;
	
	// document tab manegment
	signed int selectedPlist;
}
- (NSDocument *)owner;
- (void)setOwner:(NSDocument *)newOwner;
- (Item *)item;
- (void)setItem:(Item *)newItem;
- (IBAction)browserCellSelected:(NSBrowser *)sender;
- (Node *)selectedNode;
- (Node *)selectedNodeInColumn:(int)column;
- (Node *)parentNodeOfColumn:(int)column;
- (int)selectNode:(Node *)node;
- (void)selectNodeWithCode:(NSString *)code;
- (void)selectNodeWithID:(NSNumber *)itemID;
- (Node *)findChildOfNode:(Node *)parent withCode:(NSString *)code;
- (Node *)findChildOfNode:(Node *)parent withID:(NSNumber *)itemID;
@end

@interface StringFromItemVersionTransformer : NSValueTransformer
@end

@interface NormalNameFromCodeTransformer : NSValueTransformer
@end