#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

enum SeverityLevels
{
	kErrorLevel,
	kWarningLevel,
	kNoteLevel
};

@interface LegitamacyWarning : NSObject
{
	NSNumber *severity;		// 0 = error, 1 = warning, 2 = note
	NSString *description;
}
+ (LegitamacyWarning *)warningWithSeverity:(int)s description:(NSString *)d;
- (LegitamacyWarning *)initWithSeverity:(int)s description:(NSString *)d;
@end

@interface MultilineTextCell : NSTextFieldCell
@end