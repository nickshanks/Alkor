#import "NameFormatter.h"

@implementation NameFormatter

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error
{
#pragma unused(error)
	*object = string;
	return YES;
}

- (NSString *)stringForObjectValue:(id)object
{
	if (![object isKindOfClass:[NSString class]]) return nil;
	else return object;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)object withDefaultAttributes:(NSDictionary *)attributes
{
	if (![object isKindOfClass:[NSString class]]) return nil;
	else return [[[NSAttributedString alloc] initWithString:object attributes:attributes] autorelease];
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
#pragma unused(newString,error)
	// note: when saving a file the following additional constraints are validated
	//	1) string length > 1 if no underscore present
	//	2) string length > 2 if underscore is present
	//	3) string does not end with an underscore
	
	// check for illegal characters
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
	NSRange range = [partialString rangeOfCharacterFromSet:[set invertedSet]];
	if (range.location != NSNotFound) return NO;
	
	// check length <= 16
	if ([partialString cStringLength] > 16) return NO;
	
	// check no more than one underscore
	if ([[partialString componentsSeparatedByString:@"_"] count] > 2) return NO;
	
	// all tests passed, return yes
	return YES;
}

@end
