#import <Foundation/Foundation.h>

@interface Quest : NSObject
{
	NSString *name;			// e.g. Den of Evil
	NSArray *options;		// strings representing meaning if bit set
	NSNumber *progress;		// quest bitfield (16 bits)
}
+ (Quest *)questWithName:(NSString *)q_name options:(NSArray *)q_options;
- (Quest *)initWithName:(NSString *)q_name options:(NSArray *)q_options;
@end
