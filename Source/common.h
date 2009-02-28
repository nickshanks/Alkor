/* from </usr/include/AvailabilityMacros.h> */

#ifndef MAC_OS_X_VERSION_10_0
	#define MAC_OS_X_VERSION_10_0 1000
#endif
#ifndef MAC_OS_X_VERSION_10_1
	#define MAC_OS_X_VERSION_10_1 1010
#endif
#ifndef MAC_OS_X_VERSION_10_2
	#define MAC_OS_X_VERSION_10_2 1020
#endif
#ifndef MAC_OS_X_VERSION_10_3
	#define MAC_OS_X_VERSION_10_3 1030
#endif
#ifndef MAC_OS_X_VERSION_10_4
	#define MAC_OS_X_VERSION_10_4 1040
#endif
#ifndef MAC_OS_X_VERSION_10_5
	#define MAC_OS_X_VERSION_10_5 1050
#endif
#ifndef MAC_OS_X_VERSION_10_6
	#define MAC_OS_X_VERSION_10_6 1060
#endif


/* from <Foundation/NSObjCRuntime.h> */

#ifndef NSINTEGER_DEFINED
	#if __LP64__ || NS_BUILD_32_LIKE_64
	typedef long NSInteger;
	typedef unsigned long NSUInteger;
	#else
	typedef int NSInteger;
	typedef unsigned int NSUInteger;
	#endif

	#define NSIntegerMax    LONG_MAX
	#define NSIntegerMin    LONG_MIN
	#define NSUIntegerMax   ULONG_MAX

	#define NSINTEGER_DEFINED 1
#endif
