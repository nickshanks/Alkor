#import <Foundation/Foundation.h>

@interface Mercenary : NSObject
{
	BOOL active;
	NSNumber *unknown0_0;
	NSNumber *unknown1_0;
	NSNumber *dead;
	NSNumber *unknown2_1;
	NSNumber *unknown3_0;
	NSNumber *guid;
	NSNumber *name;
	NSNumber *type;
	NSNumber *experience;
	NSMutableArray *items;
}
- (void)setTypeForClass:(unsigned short)value;
- (void)setTypeForClass:(unsigned short)value withAttribute:(unsigned short)attribute;
- (void)setTypeForClass:(unsigned short)value withDifficulty:(unsigned short)difficulty;
- (void)setTypeForClass:(unsigned short)value withAttribute:(unsigned short)attribute andDifficulty:(unsigned short)difficulty;
- (unsigned short)mercClass;
- (unsigned short)mercClassForType:(unsigned short)value;
- (void)setMercClass:(unsigned short)value;
- (unsigned short)name;
- (void)setName:(unsigned short)value;
- (void)setName:(unsigned short)value forClass:(unsigned short)mercClass;
- (unsigned short)attribute;
- (void)setAttribute:(unsigned short)value;
- (void)setAttribute:(unsigned short)value forClass:(unsigned short)mercClass;
- (unsigned short)difficulty;
- (void)setDifficulty:(unsigned short)value;
- (void)setDifficulty:(unsigned short)value forClass:(unsigned short)mercClass;
- (NSArray *)mercClasses;
- (void)setMercClasses:(NSArray *)value;
- (NSArray *)names;	
- (void)setNames:(NSArray *)value;
- (NSArray *)attributes;
- (void)setAttributes:(NSArray *)value;
- (unsigned long)level;
- (void)setLevel:(unsigned long)value;
- (unsigned long)experienceForCurrentLevel;
- (unsigned long)experienceForNextLevel;
- (NSMutableArray *)items;
- (void)setItems:(NSMutableArray *)i;
@end

inline unsigned long merc_experience_for_level(unsigned char merc_type, unsigned long level);
inline unsigned long merc_level_for_experience(unsigned char merc_type, unsigned long exp);
