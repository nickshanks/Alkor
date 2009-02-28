#include "Localization.h"
#include "MPQReader.h"

NSDictionary *stringTable;
NSMutableDictionary *indexedStrings;

NSString *Localise(NSString *key, NSString **gender)
{
	if (!key || [key isEqualToString:@""]) return nil;
	if (!indexedStrings) indexedStrings = [[NSMutableDictionary alloc] init];
	if (!stringTable)    stringTable = [[[MPQReader defaultReader] stringTable] retain];
	
	// get value for input key, via indexedStrings if necessary
	if (NSString *testKey = [indexedStrings valueForKey:key]) key = testKey;
	NSString *translation = [stringTable valueForKey:key];
	if (translation == nil || translation == @"")
	{
//		NSLog(@"No translation for %@, returning itself.", key);
		return key;
	}
	
	// if input gender is present, return substring for that gender if present
	if (gender && *gender)
	{
		NSRange range = [translation rangeOfString:*gender];
		if (range.location != NSNotFound)
		{
			unsigned start = range.location + range.length +1;
			unsigned length = 0;
			while (start+length < [translation length] && [translation characterAtIndex:(start+length)] != '[') length++;
			return [translation substringWithRange:NSMakeRange(start,length)];
		}
	}
	
	// if no input gender given, or gender doesn't match anything in the translation, return translation, stripping any gender present, and returning it if requested
	if ([translation characterAtIndex:0] == '[' && [translation characterAtIndex:3] == ']')
	{
		if (gender && *gender == NULL)
			*gender = [translation substringToIndex:3];
		translation = [translation substringFromIndex:4];
	}
	return translation;
}
