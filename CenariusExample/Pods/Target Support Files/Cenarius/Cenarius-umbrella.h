#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Cenarius.h"
#import "WXEventModule.h"
#import "WXNetworkModule.h"
#import "WXRouteModule.h"

FOUNDATION_EXPORT double CenariusVersionNumber;
FOUNDATION_EXPORT const unsigned char CenariusVersionString[];

