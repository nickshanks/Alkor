#import "LegitamacyWarning.h"

@implementation LegitamacyWarning
+ (LegitamacyWarning *)warningWithSeverity:(int)s description:(NSString *)d
{
	LegitamacyWarning *warning = [[[LegitamacyWarning alloc] initWithSeverity:s description:d] autorelease];
	return warning;
}
- (LegitamacyWarning *)initWithSeverity:(int)s description:(NSString *)d
{
	self = [super init];
	if (!self) return nil;
	severity = [[NSNumber alloc] initWithInt:s];
	description = [d retain];
	return self;
}
- (NSString *)description
{
	return description;
}
- (NSImage *)icon
{
	switch ([severity intValue])
	{
		case kErrorLevel:		return [NSImage imageNamed:@"Error"];
		case kWarningLevel:		return [NSImage imageNamed:@"Warning"];
		case kNoteLevel:		return [NSImage imageNamed:@"Note"];
		default:				return nil;
	}
}
@end

@implementation MultilineTextCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if ([controlView lockFocusIfCanDraw])
	{
		NSDictionary *attributes;
		if ([self isHighlighted])	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont labelFontOfSize:9.0], @"NSFont", [NSColor whiteColor], @"NSColor", nil];
		else						attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont labelFontOfSize:9.0], @"NSFont", nil];
		NSSize size = [[self stringValue] sizeWithAttributes:attributes];
		[[self stringValue] drawInRect:cellFrame withAttributes:attributes];
		[controlView unlockFocus];
	}
}
@end