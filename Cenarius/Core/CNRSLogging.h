//
//  CNRSLogging.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#ifdef CNRSLogEnable
#define CNRSLog(format, ...) do {                                                                           \
                                fprintf(stderr, "<%s : %d> %s\n",                                           \
                                [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
                                __LINE__, __func__);                                                        \
                                (NSLog)((format), ##__VA_ARGS__);                                           \
                                fprintf(stderr, "-------\n");                                               \
                                } while (0)
#else
#define CNRSLog(format, ...) do {} while (0)
#endif

#define CNRSDebugLog(...)  CNRSLog(@"[DEBUG] " __VA_ARGS__)
#define CNRSWarnLog(...)   CNRSLog(@"[WARN] " __VA_ARGS__)
#define CNRSErrorLog(...)  CNRSLog(@"[ERROR] " __VA_ARGS__)
