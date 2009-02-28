#import <Foundation/Foundation.h>
#import "NGSCategories.h"

typedef struct _globals
{
	BOOL debug;
} globals;


@interface AppDelegate : NSObject
{
	IBOutlet NSWindow *notesWindow;
	IBOutlet NSTextView *notesView;
	NSString *currentNote;
	NSNumber *editableNotes;
}
@end

@interface NSApplication (AlkorScriptingExtensions)
- (NSArray *)characterDocuments;
- (NSArray *)itemDocuments;
@end

@interface NSString (AlkorFormatExtensions)
+ (id)stringWithDiabloFormat:(NSString *)format, ...;
@end

@interface Zig : NSObject
@end