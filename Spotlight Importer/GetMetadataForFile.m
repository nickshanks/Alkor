#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>

#import "CharacterDocument.h"
#import "CharacterDocument_Stats.h"
#import "MPQReader.h"
#import "AppDelegate.h"

#include "Localization.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
	uint32_t bit_offset = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(![[NSFileManager defaultManager] isReadableFileAtPath:(NSString *) pathToFile])
	{
		[pool release];
		return false;
	}
	
	CharacterDocument *doc = [[CharacterDocument alloc] init];
	if(!doc)
	{
		[pool release];
		return false;
	}
	
	const uint8_t *d2s = (const uint8_t *) [[NSData dataWithContentsOfFile:(NSString *)pathToFile] bytes];
	if(!d2s)
	{
		[pool release];
		return false;
	}
	
	[doc readHeaderWithBytes:d2s bitOffset:&bit_offset];
	
	BOOL died = [[doc valueForKey:@"died"] boolValue];
	BOOL hardcore = [[doc valueForKey:@"hardcore"] boolValue];
	unsigned int level = [[doc valueForKey:@"selectionLevel"] unsignedIntValue];
	NSString *charClass = [[doc characterClasses] objectAtIndex:[[doc valueForKey:@"characterClass"] unsignedIntValue]];
	if(level < 1 || level > 99)
	{
		[pool release];
		return false;
	}
	
	if(!charClass)
	{
		[pool release];
		return false;
	}
	
//	NSDictionary *charClasses = [NSDictionary dictionaryWithObject:charClass forKey:[[MPQReader defaultReader] defaultLocaleString]];
//	NSLog(@"Setting character class to %@", charClasses);
//	CFDictionaryAddValue(attributes, @"com_blizzard_diablo2_characterClass", charClasses);
	CFDictionaryAddValue(attributes, @"com_blizzard_diablo2_characterClass", charClass);			// can be a localised dictionary or a string
	CFDictionaryAddValue(attributes, @"com_blizzard_diablo2_characterLevel", [doc valueForKey:@"selectionLevel"]);
	CFDictionaryAddValue(attributes, @"com_blizzard_diablo2_lastPlayed",     [doc valueForKey:@"modifiedTimestamp"]);
	CFDictionaryAddValue(attributes, @"com_blizzard_diablo2_honourific",     [doc titleAsString]);	// can be a localised dictionary or a string, currently English only
	
	// will produce strings like "Dead Level 37 Hardcore Druid" or "Level 12 Necromancer" -- there is no localisation for "Dead"
	NSString *format = [NSString stringWithFormat:@"%%@%@%%@%%@", Localise(@"strChatLevel")]; // strChatLevel gives "Level %d" in english, "%d livello" in Italian, to just get Level, you can use "strchrlvl" or it's also an indexed string
	NSString *description = [NSString stringWithFormat:format, (hardcore && died)? @"Dead ":@"", level, hardcore? [NSString stringWithFormat:@" %@ ", Localise(@"strChatHardcore")]:@" ", charClass];	// use strChatHardcore rather than the indexed string "Hardcore" which I'm not reading in translations for
//	NSDictionary *descriptions = [NSDictionary dictionaryWithObject:description forKey:[[MPQReader defaultReader] defaultLocaleString]];
//	NSLog(@"Setting descriptions to %@", descriptions);
//	CFDictionarySetValue(attributes, @"kMDItemDescription", descriptions);
	if(description)
		CFDictionarySetValue(attributes, kMDItemDescription, description);
	
	// this would make the file display in the Finder as "Sir Galahad" for file Galahad.d2s; can be a localised dictionary or a string
//	NSString *displayName = [NSString stringWithString:[doc displayName]];
//	if(displayName)
//		CFDictionarySetValue(attributes, kMDItemDisplayName, displayName);
	
	[pool release];
	return true;
}

#ifdef __cplusplus
}
#endif
