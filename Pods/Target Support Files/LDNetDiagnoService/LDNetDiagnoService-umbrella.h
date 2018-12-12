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

#import "LDNetConnect.h"
#import "LDNetDiagnoService.h"
#import "LDNetGetAddress.h"
#import "LDNetPing.h"
#import "LDNetTimer.h"
#import "LDNetTraceRoute.h"
#import "LDSimplePing.h"
#import "Route.h"

FOUNDATION_EXPORT double LDNetDiagnoServiceVersionNumber;
FOUNDATION_EXPORT const unsigned char LDNetDiagnoServiceVersionString[];

