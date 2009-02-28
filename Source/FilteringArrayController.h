#import <Foundation/Foundation.h>

@interface FilteringArrayController : NSArrayController
{
	id latestAddition;
	NSMutableDictionary *substringFilters;
	NSMutableDictionary *valueFilters;
}
@end

@interface ItemArrayController : FilteringArrayController
{
}
- (IBAction)search:(id)sender;
- (IBAction)location:(id)sender;
@end
