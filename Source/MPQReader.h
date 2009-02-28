#import <Foundation/Foundation.h>

// SFileSetFileLocale enumeration 
//	these values are Windows Locale IDs, see http://www.microsoft.com/globaldev/reference/lcid-all.mspx
typedef enum _FileLocale
{
	kFileLocaleChinese		= 1028,	// Blizzard use this in D2 to mean variously "Chinese", "Mandarin" and "Taiwanese"
//	kFileLocaleChineseTrad	= 1028,
//	kFileLocaleChineseSimp	= 2052,
//	kFileLocaleCzech		= 1029,
	kFileLocaleGerman		= 1031,
	kFileLocaleEnglish		= 1033,	// en-US
	kFileLocaleSpanish		= 1034,
	kFileLocaleFrench		= 1036,
	kFileLocaleItalian		= 1040,
	kFileLocaleJapanese		= 1041,
	kFileLocaleKorean		= 1042,
	kFileLocalePolish		= 1045,
	kFileLocalePortuguese	= 1046,	// pt-BR
	kFileLocaleRussian		= 1049,
	kFileLocaleNeutral		= 0
} FileLocale;

// From http://www.battle.net/diablo2exp/faq/general.shtml
//	What languages is Diablo II fully localized for?
//		Diablo II is currently offered in English, French, German, Italian, Japanese, Mandarin, Polish, Spanish, and Korean.
//		We are working on complete localizations into Brazilian Portuguese as well.
// LoD: JUNE 21, 2001 - The expansion will be available in English, French, German, Spanish, Italian, Polish, Korean, Japanese and Chinese language versions, on June 29, 2001
// older notes: Diablo II is now available in stores. The game is currently (28 June 2000) available in six different languages including English, German, French, Spanish, Italian and Polish. Korean, Japanese and Taiwanese translated editions will be available soon, as well as a Macintosh version.
// StarCraft apparently supports zh-Hans and ru: http://www.blizzard.com/support/?id=mwr0738p
// WarCraft III on Windows supports zh-Hans, zh-Hant, ru and cz: http://www.blizzard.com/support/?id=mwr0738p

@interface MPQReader : NSObject
{
	CFragConnectionID storm;
	NSMutableDictionary *tableCache;
	NSMutableDictionary *entryCache;
}
+ (MPQReader *)defaultReader;
- (NSArray *)entriesForFile:(NSString *)filename;
- (FileLocale)defaultLocale;
- (NSString *)defaultLocaleString;
- (NSDictionary *)stringTable;
- (NSDictionary *)_stringTableForTableName:(NSString *)filename locale:(FileLocale)locale;
- (NSDictionary *)_stringTableForFile:(NSString *)filename;
- (NSDictionary *)stringTableValuesBetweenKey:(NSString *)key1 andKey:(NSString *)key2;
- (NSArray *)_stringTableValuesBetweenKey:(NSString *)key1 andKey:(NSString *)key2 forTableName:(NSString *)filename locale:(FileLocale)locale;
- (NSData *)dataWithContentsOfFile:(NSString *)filename;
- (NSData *)dataWithContentsOfFile:(NSString *)filename inArchive:(NSString *)archivename;
- (NSData *)dataWithContentsOfLooseFile:(NSString *)filename;
@end