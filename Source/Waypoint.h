#import <Foundation/Foundation.h>

@interface Waypoint : NSObject
{
	NSString *name;		// e.g Stony Field
	NSNumber *active;	// boolean
}
+ (Waypoint *)waypointWithName:(NSString *)wp_name;
- (Waypoint *)initWithName:(NSString *)wp_name;
@end
