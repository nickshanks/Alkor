#import "MPQReader.h"
#include "bits.h"  // for read_bits()
#include <unistd.h>  // for getcwd() and chdir()

// externs
extern NSMutableDictionary *indexedStrings;

// function prototypes
typedef unsigned int (*SFileGetLocalePtr)(void);
typedef unsigned int (*SFileSetLocalePtr)(unsigned int);
typedef BOOL (*SFileGetBasePathPtr)(unsigned char*, int);
typedef BOOL (*SFileSetBasePathPtr)(char*);
typedef BOOL (*SFileOpenArchivePtr)(const char*, unsigned int, unsigned int, char***);
typedef BOOL (*SFileCloseArchivePtr)(char**);
typedef BOOL (*SFileFileExistsPtr)(char**, const char*, BOOL*);		// unknown parameters, this is a guess
typedef BOOL (*SFileOpenFileExPtr)(char**, const char*, unsigned int, char***);
typedef BOOL (*SFileCloseFilePtr)(char**);
typedef unsigned int (*SFileGetFileSizePtr)(char**, unsigned int*);
typedef BOOL (*SFileReadFilePtr)(char**, void*, unsigned int, unsigned int*, void*);
typedef int (*GetLastErrorPtr)(void);

// variables that look like functions
static SFileGetLocalePtr		SFileGetLocale = NULL;
static SFileSetLocalePtr		SFileSetLocale = NULL;
static SFileGetBasePathPtr		SFileGetBasePath = NULL;
static SFileSetBasePathPtr		SFileSetBasePath = NULL;
static SFileOpenArchivePtr		SFileOpenArchive = NULL;
static SFileCloseArchivePtr		SFileCloseArchive = NULL;
static SFileFileExistsPtr		SFileFileExists = NULL;
static SFileOpenFileExPtr		SFileOpenFileEx = NULL;
static SFileCloseFilePtr		SFileCloseFile = NULL;
static SFileGetFileSizePtr		SFileGetFileSize = NULL;
static SFileReadFilePtr			SFileReadFile = NULL;
static GetLastErrorPtr			GetLastError = NULL;

/* SFile functions taken from Storm (Mac):

SFileLoadDump
SFileUnloadFile
SFileSetPlatform
SFileGetLocale
SFileSetLocale
SFileSetIOErrorMode
SFileSetFilePointer
SFileSetDataChunkSize
SFileSetBasePath
SFileSetAsyncBudget
SFileReadFileEx2
SFileReadFileEx
SFileReadFile
SFilePrioritizeRequest
SFileOpenFileEx
SFileOpenFileAsArchive
SFileOpenFile
SFileOpenArchive
SFileLoadFileEx2
SFileLoadFileEx
SFileLoadFile
SFileGetFileSize
SFileGetFileCompressedSize
SFileGetFileName
SFileGetFileArchive
SFileGetBasePath
SFileGetArchiveStartingLocation
SFileGetArchiveName
SFileGetArchiveInfo
SFileFileExistsEx
SFileFileExists
SFileEnableSeekOptimization
SFileEnableDirectAccess
SFileDestroy
SFileDdaSetVolume	// dda = direct data access?
SFileDdaInitialize
SFileDdaGetVolume
SFileDdaGetPos
SFileDdaEnd
SFileDdaDestroy
SFileDdaBeginEx
SFileDdaBegin
SFileRegisterLoadNotifyProc
SFileCloseFile
SFileCloseArchive
SFileCancelRequest
SFileAuthenticateArchiveEx (blue)
SFileAuthenticateArchive

int ORDINAL(0x1CF) SErrGetLastError();
void ORDINAL(0x1D1) SErrSetLastError(int nErrCode);

bool ORDINAL(0x107) SFileEnableDirectAccess(int grfDefaultSearchScope);	// Default SFILE_SCOPE_MPQ_ONLY
bool ORDINAL(0x11E) SFileEnableSeekOptimization(bool bEnable);	// Enabled by default
bool ORDINAL(0x112) SFileSetIoErrorMode(int grfErrorMode, LPSFILE_ERROR_CALLBACK lpErrorCallback);
// Not extremely sure what SFileSetAsyncBudget does. 0 bytes (disabled) by default
bool ORDINAL(0x11C) SFileSetAsyncBudget(int dwAsyncBudget);
bool ORDINAL(0x11D) SFileSetDataChunkSize(int nDataChunkBytes);
void ORDINAL(0x127) SFileRegisterLoadNotifyProc(LPSFILE_LOAD_NOTIFY_PROC lpLoadNotifyProc, void *lpParam);

LANGID ORDINAL(0x126) SFileGetLocale();
void ORDINAL(0x110) SFileSetLocale(LANGID lnNewLanguage);
void ORDINAL(0x116) SFileSetPlatform(int dwPlatform);
bool ORDINAL(0x111) SFileGetBasePath(unsigned char *lpszBasePath, int nBufferSize);
bool ORDINAL(0x10E) SFileSetBasePath(char *lpszBasePath);

int ORDINAL(UNKNOWN) SFileCalcFileCrc(char *lpFileName);

bool ORDINAL(0x10A) SFileOpenArchive(char *lpFileName, int nArchivePriority, int grfArchiveFlags, HSARCHIVE *lphMPQ);
bool ORDINAL(0x125) SFileOpenFileAsArchive(HSARCHIVE hParentMPQ, char *lpFileName, int nArchivePriority, int grfArchiveFlags, HSARCHIVE *lphChildMPQ);
bool ORDINAL(0x12C) SFileOpenPathAsArchive(HSARCHIVE hParentMPQ, char *lpszPath, int nArchivePriority, int dwUnused, HSARCHIVE *lphChildArchive);
bool ORDINAL(0xFC) SFileCloseArchive(HSARCHIVE hMPQ);

bool ORDINAL(0xFB) SFileAuthenticateArchive(HSARCHIVE hMPQ, int *lpdwAuthenticationStatus);
bool ORDINAL(0x12B) SFileAuthenticateArchiveEx(HSARCHIVE hMPQ, int *lpdwAuthenticationStatus, LPBYTE lpbyModulus, int dwModLength, LPBYTE lpbyExponent, int dwExpLength);
bool ORDINAL(UNKNOWN) SFileEnableArchive(HSARCHIVE hMPQ, bool bEnable);
bool ORDINAL(0x113) SFileGetArchiveName(HSARCHIVE hMPQ, unsigned char *lpszArchiveName, int nBufferSize);
bool ORDINAL(0x115) SFileGetArchiveInfo(HSARCHIVE hMPQ, int *lpnArchivePriority, int *lpgrfArchiveFlags);

int ORDINAL(0x120) SFileFileExists(char *lpszFileName);
int ORDINAL(0x121) SFileFileExistsEx(HSARCHIVE hMPQ, char *lpszFileName, int grfSearchScope);
bool ORDINAL(0x117) SFileLoadFile(char *lpszFileName, void **lplpFileData, int *lpnFileSize, int nExtraBytesToAllocateAtEnd, LPOVERLAPPED lpOverlapped);
bool ORDINAL(0x119) SFileLoadFileEx(HSARCHIVE hMPQ, char *lpszFileName, void **lplpFileData, int *lpnFileSize, int nExtraBytesToAllocateAtEnd, int grfSearchScope, LPOVERLAPPED lpOverlapped);
bool ORDINAL(0x124) SFileLoadFileEx2(HSARCHIVE hMPQ, char *lpszFileName, void **lplpFileData, int *lpnFileSize, int nExtraBytesToAllocateAtEnd, int grfSearchScope, LPOVERLAPPED lpOverlapped, int dwUnused);
bool ORDINAL(0x118) SFileUnloadFile(void *lpFileData);

bool ORDINAL(0x10B) SFileOpenFile(char *lpFileName, HSFILE *lphFile);
bool ORDINAL(0x10C) SFileOpenFileEx(HSARCHIVE hMPQ, char *lpFileName, int grfSearchScope, HSFILE *lphFile);
bool ORDINAL(0xFD) SFileCloseFile(HSFILE hFile);

int ORDINAL(0x109) SFileGetFileSize(HSFILE hFile, int *lpnFileSizeHigh);
int ORDINAL(0x128) SFileGetFileCompressedSize(HSFILE hFile, int *lpnFileSizeHigh);
bool ORDINAL(0x114) SFileGetFileName(HSFILE hFile, unsigned char *lpszFileName, int nBufferSize);
bool ORDINAL(UNKNOWN) SFileGetActualFileName(HSFILE hFile, unsigned char *lpszFileName, int nBufferSize);
bool ORDINAL(0x108) SFileGetFileArchive(HSFILE hFile, HSARCHIVE *lphMPQ);
int ORDINAL(UNKNOWN) SFileGetFileCrc(HSFILE hFile);
bool ORDINAL(UNKNOWN) SFileGetFileMD5(HSFILE hFile, void *lpMD5);
bool ORDINAL(UNKNOWN) SFileGetFileTime(HSFILE hFile, FILETIME *lpFileTime);

int ORDINAL(0x10F) SFileSetFilePointer(HSFILE hFile, long nDistanceToMove, LPLONG lpnDistanceToMoveHigh, int dwMoveMethod);

bool ORDINAL(0x10D) SFileReadFile(HSFILE hFile, void *lpBuffer, int nNumberOfBytesToRead, int *lpnNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
bool ORDINAL(0x11F) SFileReadFileEx(HSFILE hFile, void *lpBuffer, int nNumberOfBytesToRead, int *lpnNumberOfBytesRead, LPOVERLAPPED lpOverlapped, LPSFILE_COMPLETION_ROUTINE lpCompletionRoutine);
bool ORDINAL(0x123) SFileReadFileEx2(HSFILE hFile, void *lpBuffer, int nNumberOfBytesToRead, int *lpnNumberOfBytesRead, LPOVERLAPPED lpOverlapped, int dwUnused, LPSFILE_COMPLETION_ROUTINE lpCompletionRoutine);

bool ORDINAL(0x11A) SFilePrioritizeRequest(LPCVOID lpReadBuffer, bool bHighPriority);
bool ORDINAL(0x11B) SFileCancelRequest(LPCVOID lpReadBuffer);
// The WoW version of Ex is identical to the original. *shrug*
bool ORDINAL(UNKNOWN) SFileCancelRequestEx(LPCVOID lpReadBuffer);

bool ORDINAL(0x104) SFileDdaInitialize(IDirectSound *lpDirectSound);
bool ORDINAL(0x100) SFileDdaDestroy();

bool ORDINAL(0xFE) SFileDdaBegin(HSFILE hFile, int nBufferSize, int grfStreamFlags);
bool ORDINAL(0xFF) SFileDdaBeginEx(HSFILE hFile, int nBufferSize, int grfStreamFlags, int nWAVStartOffset, long nVolume, long nPanPos, IDirectSoundBuffer *lpSoundBuffer);
bool ORDINAL(0x101) SFileDdaEnd(HSFILE hFile);

bool ORDINAL(0x102) SFileDdaGetPos(HSFILE hFile, int *lpnCurPos, int *lpnTotalLength);
bool ORDINAL(0x103) SFileDdaGetVolume(HSFILE hFile, int *lpnVolume, int *lpnPanPos);
bool ORDINAL(0x105) SFileDdaSetVolume(HSFILE hFile, int nVolume, int nPanPos);
*/

// CFM pointer to Mach-O pointer conversion
unsigned long macho_template[6] = {0x3D800000, 0x618C0000, 0x800C0000, 0x804C0004, 0x7C0903A6, 0x4E800420};
static void* MachOPtrFromCFMPtr(void *cfmfp)
{
    UInt32	*mfp = (UInt32*) malloc(sizeof(macho_template));
    mfp[0] = macho_template[0] | ((UInt32)cfmfp >> 16);
    mfp[1] = macho_template[1] | ((UInt32)cfmfp & 0xFFFF);
    mfp[2] = macho_template[2];
    mfp[3] = macho_template[3];
    mfp[4] = macho_template[4];
    mfp[5] = macho_template[5];
    MakeDataExecutable(mfp, sizeof(macho_template));
    return mfp;
}

Boolean GetHFSPath(const FSRef *inFSRef, CFMutableStringRef ioPath)
{
	int           i, n;
	HFSUniStr255  names[100];
	FSCatalogInfo catalogInfo;
	FSRef         localRef  = *inFSRef;
	OSStatus      err       = noErr;

	CFStringDelete(ioPath, CFRangeMake(0, CFStringGetLength(ioPath)));
	for (n=0 ; err==noErr && catalogInfo.nodeID != fsRtDirID && n < 100; n++)
		err = FSGetCatalogInfo(&localRef, kFSCatInfoNodeID, &catalogInfo, &names[n], nil, &localRef);
	
	for (i = n-1; i >= 0; --i)
	{
		UniChar colon = ':';
		CFStringAppendCharacters(ioPath, names[i].unicode, names[i].length);
		if (i > 0) CFStringAppendCharacters(ioPath, &colon, 1);
	}
	return (err == noErr);
}
/*
NSString *GetRelativeHFSPath(const FSRef *inRef)
{
	FSRef localRef = *inRef;
	FSCatalogInfo catalogInfo;
}*/

@implementation MPQReader
- (id)init
{
	self = [super init];
	if (!self) return nil;
	
	// load Storm
	FSRef diabloRef;
	OSStatus error = LSFindApplicationForInfo('Dbl2', NULL, NULL, &diabloRef, NULL);
	NSAssert(error == noErr, @"LSFindApplicationForInfo() failed finding Diablo II");
	
	if (!error)
	{
		short fileID = FSOpenResFile(&diabloRef, fsRdPerm);
		CFragResourceHandle cfrg = (CFragResourceHandle) Get1Resource('cfrg', 0);
		NSAssert(cfrg != NULL, @"Get1Resource() failed getting Diablo II's CFrag resource");
		
		if (cfrg)
		{
			HLock((Handle) cfrg);
			FSSpec diabloSpec = {};
			CFragResourceMemberPtr firstMember = &((** cfrg).firstMember);
			CFragResourceMemberPtr stormCFrag = NextCFragResourceMemberPtr(firstMember);
			error = FSGetCatalogInfo(&diabloRef, kFSCatInfoNone, NULL, NULL, &diabloSpec, NULL);
			NSAssert(error == noErr, @"FSGetCatalogInfo() failed getting Diablo II FSSpec");
			error = GetDiskFragment(&diabloSpec, stormCFrag->offset, stormCFrag->length, "\pStormCarbon", kReferenceCFrag, &storm, NULL, NULL);
			NSAssert(error == noErr && storm != NULL, @"GetDiskFragment() failed getting Storm fragment");
			ReleaseResource((Handle) cfrg);
			
			if (storm)
			{
#if 0
				// interate all functions just to see what's there
				long count;
				error = CountSymbols(storm, &count);
				if (!error)
				{
					NSMutableArray *array = [NSMutableArray array];
					for (int i = 0; i < count; i++)
					{
						Str255 name;
						char *cfClass;
						CFragSymbolClass symClass;
						error = GetIndSymbol(storm, i, name, NULL, &symClass);
						CopyPascalStringToC(name, (char *)name);
						[array addObject:[NSString stringWithFormat:@"%s", name]];
					}
					[array sortUsingSelector:@selector(compare:)];
					NSLog([array description]);
				}
#endif
				
				// get function pointers I actually want
				Ptr getLocale, setLocale, getBasePath, setBasePath, openArchive, closeArchive, fileExists, openFileEx, closeFile, getFileSize, readFile, lastError;
				FindSymbol(storm, "\pSFileGetLocale", &getLocale, NULL);
				FindSymbol(storm, "\pSFileSetLocale", &setLocale, NULL);
				FindSymbol(storm, "\pSFileGetBasePath", &getBasePath, NULL);
				FindSymbol(storm, "\pSFileSetBasePath", &setBasePath, NULL);
				FindSymbol(storm, "\pSFileOpenArchive", &openArchive, NULL);
				FindSymbol(storm, "\pSFileCloseArchive", &closeArchive, NULL);
				FindSymbol(storm, "\pSFileFileExists", &fileExists, NULL);
				FindSymbol(storm, "\pSFileOpenFileEx", &openFileEx, NULL);
				FindSymbol(storm, "\pSFileCloseFile", &closeFile, NULL);
				FindSymbol(storm, "\pSFileGetFileSize", &getFileSize, NULL);
				FindSymbol(storm, "\pSFileReadFile", &readFile, NULL);
				FindSymbol(storm, "\pGetLastError", &lastError, NULL);
				SFileGetLocale = (SFileGetLocalePtr) MachOPtrFromCFMPtr(getLocale);
				SFileSetLocale = (SFileSetLocalePtr) MachOPtrFromCFMPtr(setLocale);
				SFileGetBasePath = (SFileGetBasePathPtr) MachOPtrFromCFMPtr(getBasePath);
				SFileSetBasePath = (SFileSetBasePathPtr) MachOPtrFromCFMPtr(setBasePath);
				SFileOpenArchive = (SFileOpenArchivePtr) MachOPtrFromCFMPtr(openArchive);
				SFileCloseArchive = (SFileCloseArchivePtr) MachOPtrFromCFMPtr(closeArchive);
				SFileFileExists = (SFileFileExistsPtr) MachOPtrFromCFMPtr(fileExists);
				SFileOpenFileEx = (SFileOpenFileExPtr) MachOPtrFromCFMPtr(openFileEx);
				SFileCloseFile = (SFileCloseFilePtr) MachOPtrFromCFMPtr(closeFile);
				SFileGetFileSize = (SFileGetFileSizePtr) MachOPtrFromCFMPtr(getFileSize);
				SFileReadFile = (SFileReadFilePtr) MachOPtrFromCFMPtr(readFile);
				GetLastError = (GetLastErrorPtr) MachOPtrFromCFMPtr(lastError);
				
				// symbols to examine for debugging the path problem
				// GetCurrentDirectory GetWindowsDirectory IsFilepath MakeFilepath SFileDdaGetVolume
			}
		}
		FSClose(fileID);
	}
	
	
	// locate MPQ files - check they are present before trying to use them
	SFileSetBasePath("\\{MacPath01}\\");
	NSString *archivename;
	NSArray *archives = [NSArray arrayWithObjects:@"Diablo II Patch (Carbon)", @"Diablo II Expansion Data", @"Diablo II Game Data", nil];
	NSEnumerator *enumerator = [archives objectEnumerator];
	while (archivename = [enumerator nextObject])
	{
		Handle archive;
		if (SFileOpenArchive([archivename cString], 0, 0, &archive))
			SFileCloseArchive(archive);
#warning display error message here instead of logging
		else NSLog(@"Error %d: SFileOpenArchive(%@)", GetLastError(), archivename);
	}
	
	// create empty cache
	entryCache = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dealloc
{
	// release instance variables
	[entryCache release];
	
	// free function pointers & close connection to Storm
	free((void*)SFileGetLocale);
	free((void*)SFileSetLocale);
	free((void*)SFileGetBasePath);
	free((void*)SFileSetBasePath);
	free((void*)SFileOpenArchive);
	free((void*)SFileCloseArchive);
	free((void*)SFileFileExists);
	free((void*)SFileOpenFileEx);
	free((void*)SFileCloseFile);
	free((void*)SFileGetFileSize);
	free((void*)SFileReadFile);
	free((void*)GetLastError);
	CloseConnection(&storm);
	
	[super dealloc];
}

+ (MPQReader *)defaultReader
{
	static MPQReader *defaultReader = NULL;
	if (!defaultReader)
		defaultReader = [[MPQReader alloc] init];
	return defaultReader;
}

- (NSArray *)entriesForFile:(NSString *)filename
{
	NSArray *cachedEntries = [entryCache objectForKey:filename];
	if (cachedEntries) return cachedEntries;
	
	NSData *data = [self dataWithContentsOfFile:filename];
	if (!data)
	{
		NSLog(@"blergh!");
		return nil;
	}
	NSMutableArray *headers = [NSMutableArray array];
	const char *bytes = (const char *)[data bytes];
	unsigned long offset = 0, start;
	while (true)
	{
		// note: diablo actually does this by converting all 0x09s and 0x0Ds to 0x00, then reading consecutive C strings!
		// copying that would avoid me having to create NSData objects for each string, but would give less control for Japanese etc.
		
		// scan until tab or return & add to headers
		start = offset;
		while (*(char *)(bytes+offset) != 0x09 && *(short *)(bytes+offset) != 0x0D0A) offset++;
		[headers addObject:[[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSWindowsCP1252StringEncoding] autorelease]];
		if (*(bytes+offset) == 0x09) offset++;   // skip tab
		else break;								// end of headers
	}
	
	// create keys from headers
	NSString *header;
	NSMutableArray *keys = [NSMutableArray array];
	NSEnumerator *enumerator = [headers objectEnumerator];
	while (header = [enumerator nextObject])
		if (![header isEqualToString:@""])
			[keys addObject:[header lowercaseString]];
	
	// read in values from each row
	NSMutableArray *entries = [NSMutableArray array];
	while (true)
	{
		offset += 2;	// skip newline
		if (offset >= [data length]) break;	// end of file
		
		NSMutableArray *values = [NSMutableArray array];
		for (unsigned i = 0; i < [headers count]; i++)
		{
			// scan until tab or return & add to values
			start = offset;
			while (*(char *)(bytes+offset) != 0x09 && *(short *)(bytes+offset) != 0x0D0A) offset++;
			if (![[headers objectAtIndex:i] isEqualToString:@""])
				[values addObject:[[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSWindowsCP1252StringEncoding] autorelease]];
			if (*(bytes+offset) == 0x09) offset++;	// skip tab
			else while (++i < [headers count])		// row ended early, fill in empty values
				[values addObject:@""];
		}
		
		// check first column is not 'Expansion'
		if ([[values objectAtIndex:0] isEqualToString:@"Expansion"]) continue;
		
		// create dictionary and add to new entries
		[entries addObject:[NSDictionary dictionaryWithObjects:values forKeys:keys]];
	}
	
	// save immutable copy of new entries to cache
	entries = [NSArray arrayWithArray:entries];
	[entryCache setObject:entries forKey:filename];
	return entries;
}

- (FileLocale)defaultLocale
{
	// get language from user defaults
	FileLocale locale = kFileLocaleNeutral;
	NSArray *languages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"AppleLanguages"];
	NSEnumerator *enumerator = [languages objectEnumerator];
	NSString *lang = [enumerator nextObject];
	while (lang)
	{
		short langPrefix = *(short *)[lang cString];
		switch (langPrefix)
		{
			case 'de':  locale = kFileLocaleGerman;			lang = nil; break;
			case 'en':	locale = kFileLocaleEnglish;		lang = nil; break;
			case 'es':	locale = kFileLocaleSpanish;		lang = nil; break;
			case 'fr':	locale = kFileLocaleFrench;			lang = nil; break;
			case 'it':	locale = kFileLocaleItalian;		lang = nil; break;
			case 'ja':  locale = kFileLocaleJapanese;		lang = nil; break;
			case 'ko':  locale = kFileLocaleKorean;			lang = nil; break;
			case 'pl':  locale = kFileLocalePolish;			lang = nil; break;
			case 'pt':	locale = kFileLocalePortuguese;		lang = nil; break;
			case 'ru':	locale = kFileLocaleRussian;		lang = nil; break;
			case 'zh':  locale = kFileLocaleChinese;		lang = nil; break;
			default:	lang = [enumerator nextObject];					break;
		}
	}
	return locale;
}

- (NSString *)defaultLocaleString
{
	// get language from user defaults
	FileLocale locale = kFileLocaleNeutral;
	NSString *lang;
	NSArray *appleLanguages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"AppleLanguages"];
	NSArray *diabloLanguages = [NSArray arrayWithObjects:@"de",@"en",@"es",@"fr",@"it",@"ja",@"ko",@"pl",@"pt",@"ru",@"zh",nil];
	NSEnumerator *enumerator = [appleLanguages objectEnumerator];
	#warning FIXME Should be something like -[NSString substringToCharacter:@"-"]
	while (lang = [[enumerator nextObject] substringToIndex:2])
	{
		if ([diabloLanguages containsObject:lang])
			return lang;
	}
	return @"";
}

- (NSDictionary *)stringTable
{
	// first reads english, then overrides with native language if present
	FileLocale locale = [self defaultLocale];
	NSMutableDictionary *strings = [NSMutableDictionary dictionary];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"string.tbl" locale:kFileLocaleNeutral]];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"expansionstring.tbl" locale:kFileLocaleNeutral]];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"patchstring.tbl" locale:kFileLocaleNeutral]];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"string.tbl" locale:locale]];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"expansionstring.tbl" locale:locale]];
	[strings addEntriesFromDictionary:[self _stringTableForTableName:@"patchstring.tbl" locale:locale]];
	return [NSDictionary dictionaryWithDictionary:strings];
}

- (NSDictionary *)_stringTableForTableName:(NSString *)filename locale:(FileLocale)locale
{
	NSString *path, *filepath;
	switch (locale)
	{
		case kFileLocaleChinese:		path = @"data/local/LNG/CHI/";  break;
		case kFileLocaleGerman:			path = @"data/local/LNG/DEU/";  break;
		case kFileLocaleEnglish:		path = @"data/local/LNG/ENG/";  break;
		case kFileLocaleSpanish:		path = @"data/local/LNG/ESP/";  break;
		case kFileLocaleFrench:			path = @"data/local/LNG/FRA/";  break;
		case kFileLocaleItalian:		path = @"data/local/LNG/ITA/";  break;
		case kFileLocaleJapanese:		path = @"data/local/LNG/JPN/";  break;
		case kFileLocaleKorean:			path = @"data/local/LNG/KOR/";  break;
		case kFileLocalePolish:			path = @"data/local/LNG/POL/";  break;
		case kFileLocalePortuguese:		path = @"data/local/LNG/POR/";  break;
		case kFileLocaleRussian:		path = @"data/local/LNG/RUS/";  break;
		case kFileLocaleNeutral:
		default:						path = @"data/local/LNG/ENG/";  break;
	}
	filepath = [NSString stringWithFormat:@"%@%@", path, filename];
	
	// try to load data for specified locale, failure is handled upstream
	return [self _stringTableForFile:filepath];
}

- (NSDictionary *)_stringTableForFile:(NSString *)filename
{
	// load and parse specific tbl
	NSString *key, *value;
	NSData *fileData = [self dataWithContentsOfFile:filename];
	if (fileData)
	{
		uint8_t *data = (uint8_t *) [fileData bytes];
		uint32_t bit_offset = 0;
		
		// verify table header validity and count entries
		unsigned short crc = read_bits(data, &bit_offset, 16);
		unsigned short element_count = read_bits(data, &bit_offset, 16);
		unsigned short hash_count = read_bits(data, &bit_offset, 16);
		unsigned short version = read_bits(data, &bit_offset, 16);
		NSParameterAssert(crc != 0);
		NSParameterAssert(hash_count >= element_count);
		NSParameterAssert(version == 0);
		
		// get offset of first key in file
		unsigned char string_num = read_bits(data, &bit_offset, 8);
		unsigned long string_offset = read_bits(data, &bit_offset, 32);
		NSParameterAssert(string_num == 1);
		NSParameterAssert(string_offset != 0);
		
		// skip hash tables & iterate through strings
		NSMutableDictionary *strings = [NSMutableDictionary dictionary];
		unsigned long offset = string_offset, start, index = 0;
		for (unsigned i = 0; i < element_count; i++)
		{
			// scan key until null char
			start = offset;
			while (*(char *)(data+offset) != 0x00) offset++;
			key = [[[NSString alloc] initWithData:[fileData subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSUTF8StringEncoding] autorelease];
			offset++;

			// scan value until null char
			start = offset;
			while (*(char *)(data+offset) != 0x00) offset++;
			value = [[[NSString alloc] initWithData:[fileData subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSUTF8StringEncoding] autorelease];
			offset++;
			
			// check for indexed value and save with custom key, english string is used to retreive it
			if ([key isEqualToString:@"x"])
			{
				// ignore any strings with key "x" but not in file eng/string.tbl
				if ([filename isEqualToString:@"data/local/LNG/ENG/string.tbl"])
				{
					NSString *indexKey = [NSString stringWithFormat:@"index%d", index++];
					[indexedStrings setValue:indexKey forKey:value];
					[strings setValue:value forKey:indexKey];
				}
			}
			// add string to table
			else [strings setValue:value forKey:key];
		}
		return strings;
	}
	else
	{
		NSLog(@"Error: tried to get file %@ in -_stringTableForFile:", filename);
		return nil;
	}
}

// specialised functions for returning consecutive values, duplicates most of the above with minor changes
- (NSDictionary *)stringTableValuesBetweenKey:(NSString *)key1 andKey:(NSString *)key2
{
	FileLocale locale = [self defaultLocale];
	NSMutableArray *strings = [NSMutableArray array];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"string.tbl" locale:kFileLocaleNeutral]];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"expansionstring.tbl" locale:kFileLocaleNeutral]];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"patchstring.tbl" locale:kFileLocaleNeutral]];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"string.tbl" locale:locale]];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"expansionstring.tbl" locale:locale]];
	[strings addObjectsFromArray:[self _stringTableValuesBetweenKey:key1 andKey:key2 forTableName:@"patchstring.tbl" locale:locale]];
	return [NSArray arrayWithArray:strings];
}

- (NSArray *)_stringTableValuesBetweenKey:(NSString *)key1 andKey:(NSString *)key2 forTableName:(NSString *)filename locale:(FileLocale)locale
{
#pragma unused(key1,key2)
	NSString *path, *filepath;
	switch (locale)
	{
		case kFileLocaleChinese:		path = @"data/local/LNG/CHI/";  break;
		case kFileLocaleGerman:			path = @"data/local/LNG/DEU/";  break;
		case kFileLocaleEnglish:		path = @"data/local/LNG/ENG/";  break;
		case kFileLocaleSpanish:		path = @"data/local/LNG/ESP/";  break;
		case kFileLocaleFrench:			path = @"data/local/LNG/FRA/";  break;
		case kFileLocaleItalian:		path = @"data/local/LNG/ITA/";  break;
		case kFileLocaleJapanese:		path = @"data/local/LNG/JPN/";  break;
		case kFileLocaleKorean:			path = @"data/local/LNG/KOR/";  break;
		case kFileLocalePolish:			path = @"data/local/LNG/POL/";  break;
		case kFileLocalePortuguese:		path = @"data/local/LNG/POR/";  break;
		case kFileLocaleRussian:		path = @"data/local/LNG/RUS/";  break;
		case kFileLocaleNeutral:
		default:						path = @"data/local/LNG/ENG/";  break;
	}
	filepath = [NSString stringWithFormat:@"%@%@", path, filename];
	
	NSData *fileData = [self dataWithContentsOfFile:filepath];
	if (fileData)
	{
		NSString *value;
		uint8_t *data = (unsigned char *) [fileData bytes];
		uint32_t bit_offset = 0;
		
		// verify table header validity and count entries
		unsigned short crc = read_bits(data, &bit_offset, 16);
		unsigned short element_count = read_bits(data, &bit_offset, 16);
		unsigned short hash_count = read_bits(data, &bit_offset, 16);
		unsigned short version = read_bits(data, &bit_offset, 16);
		NSParameterAssert(crc != 0);
		NSParameterAssert(hash_count >= element_count);
		NSParameterAssert(version == 0);
		
		// get offset of first key in file
		unsigned char string_num = read_bits(data, &bit_offset, 8);
		unsigned long string_offset = read_bits(data, &bit_offset, 32);
		NSParameterAssert(string_num == 1);
		NSParameterAssert(string_offset != 0);
		
		// skip hash tables & iterate through strings
		NSMutableArray *strings = [NSMutableArray array];
//		unsigned long offset = string_offset, start;
		for (unsigned i = 0; i < element_count; i++)
		{
			// scan though keys until we hit the one we want
/*			start = offset;
			while (*(char *)(data+offset) != 0x00) offset++;
			key = [[[NSString alloc] initWithData:[fileData subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSUTF8StringEncoding] autorelease];
			offset++;

			// scan value until null char
			start = offset;
			while (*(char *)(data+offset) != 0x00) offset++;
			value = [[[NSString alloc] initWithData:[fileData subdataWithRange:NSMakeRange(start,offset-start)] encoding:NSUTF8StringEncoding] autorelease];
			offset++;
*/			
			// add string to table
			[strings addObject:value];
		}
		return strings;
	}
	else return nil;
}

- (NSData *)dataWithContentsOfFile:(NSString *)filename
{
	// try to obtain file loose first, allowing override of diablo archives
	NSData *data = [self dataWithContentsOfLooseFile:filename];
	if (data) return data;
	
	NSString *archivename;
	NSArray *archives = [NSArray arrayWithObjects:@"Diablo II Patch (Carbon)", @"Diablo II Expansion Data", @"Diablo II Game Data", nil];
	NSEnumerator *enumerator = [archives objectEnumerator];
	while (archivename = [enumerator nextObject])
	{
		data = [self dataWithContentsOfFile:filename inArchive:archivename];
		if (data) return data;
	}
	if (GetLastError() == 2)
	     NSLog(@"The file %@ was not found, please verify your MPQs are in the same folder as Diablo II.", filename);
	else NSLog(@"Error: %d occured in method -dataWithContentsOfFile:%@.", GetLastError(), filename);
	return nil;
}

- (NSData *)dataWithContentsOfFile:(NSString *)filename inArchive:(NSString *)archivename
{
/*	Notes on my findings about paths passed to SFileOpenArchive with SFileSetBasePath("{MacPath02}")
	None of this is known for certain, but it all seems to hold true
	
	- They must be HFS-encoded
	- If it starts with a colon, Storm interprets it as a relative path and resolves it
	- If it starts with any other character, the whole string is treated as the filename in the current folder (/Contents/MacOS, not the cwd though, getcwd() returns the bundle's parent folder)
	- There is no way to get Storm to open an absolute path.
	
	Changing the base path to "{MacPath01}" makes it use the location of Diablo II, without me having to do any relative path tricks!
	The base path is changed to this in -init above, allowing us to just use the archive name as the path.
*/	
	// open archive
	Handle archive;
	NSData *data = nil;
	if (SFileOpenArchive([archivename cString], 0, 0, &archive))
	{
		Handle file;
		SFileSetLocale([self defaultLocale]);
		NSString *filePathInArchive = [[filename pathComponents] componentsJoinedByString:@"\\"];
		if (SFileOpenFileEx(archive, [filePathInArchive cString], 0, &file))
		{
			unsigned length = SFileGetFileSize(file, NULL), read;
			if (length != 0xFFFFFFFF)
			{
				void *buffer = malloc(length);
				if (SFileReadFile(file, buffer, length, &read, NULL))
				{
					data = [NSData dataWithBytesNoCopy:buffer length:read freeWhenDone:YES];
//					NSLog(@"%@ read successfully from archive %@", [filename lastPathComponent], archivename);
				}
				else NSLog(@"Error %d: SFileReadFile(%@) from archive %@", GetLastError(), [filename lastPathComponent], archivename);
			}
			else NSLog(@"Error %d: SFileGetFileSize(%@) from archive %@", GetLastError(), [filename lastPathComponent], archivename);
			SFileCloseFile(file);
		}
		else if (GetLastError() != 2)
			NSLog(@"Error %d: SFileOpenFileEx(%@) from archive %@", GetLastError(), filePathInArchive, archivename);
		SFileCloseArchive(archive);
	}
	else NSLog(@"Error %d: SFileOpenArchive(%@)", GetLastError(), archivename);
	return data;
}

- (NSData *)dataWithContentsOfLooseFile:(NSString *)filename
{
	CFURLRef diabloURL = NULL;
	OSStatus error = LSFindApplicationForInfo('Dbl2', NULL, NULL, NULL, &diabloURL);
	NSAssert1(error == noErr, @"LSFindApplicationForInfo() failed finding Diablo II (in method -dataWithContentsOfLooseFile:\"%@\")", filename);
	if (diabloURL)
	{
		NSString *path = [[(NSURL *)diabloURL path] stringByDeletingLastPathComponent];
		[(NSURL *)diabloURL release];
		path = [path stringByAppendingPathComponent:filename];
		if ([[NSFileManager defaultManager] isReadableFileAtPath:path])
			return [NSData dataWithContentsOfFile:path];
	}
	return nil;
}
@end

/*
///////////////// 
// Hash functions 
///////////////// 

int StringTbl::GetHash(char *ptKeyString) 
{ 
 char   charValue; 
 unsigned int hashValue; 
 char   *ptKeyStringChar; 
  
 hashValue = 0; 
 ptKeyStringChar = ptKeyString; 
 while ((charValue = *ptKeyStringChar++) != '\0') 
 { 
  hashValue *= 0x10; 
  hashValue += charValue; 
  if ((hashValue & 0xF0000000) != 0) 
  { 
   unsigned int tempValue = hashValue & 0xF0000000; 
   tempValue /= 0x01000000; 
   hashValue &= 0x0FFFFFFF; 
   hashValue ^= tempValue; 
  } 
 } 
 return hashValue % iHashTableSize; 
} // getHash 


/////////////////////////////////// 
// Internal string search functions 
/////////////////////////////////// 


unsigned char *StringTbl::GetString(char *s) 
{ 
 int HashValue = GetHash(s); 

 for (int i=0;i<(int)dwMaxTries;i++) 
 { 
  if (hTable[HashValue].bUsed) { 
   if (lstrcmpi((char *)(hTable[HashValue].dwKeyOffset),s)==0) 
    return (char *)(hTable[HashValue].dwStrOffset); 
  }else 
   return 0; 

  HashValue++; 
  HashValue %= iHashTableSize; 
 } 
 return 0; 
} // getString 

unsigned char *StringTbl::GetString(int index) 
{ 
 return (char *)(hTable[usHashIndices[index]].dwStrOffset); 
} 

int StringTbl::GetIndex(char *s) 
{ 
 int HashValue = GetHash(s); 

 for (int i=0;i<(int)dwMaxTries;i++) 
 { 
  if (hTable[HashValue].bUsed) { 
   if (lstrcmpi((char *)(hTable[HashValue].dwKeyOffset),s)==0) 
    return (hTable[HashValue].index ); 
  }else 
   return -1; 

  HashValue++; 
  HashValue %= iHashTableSize; 
 } 
 return -1; 
} // getString
*/
