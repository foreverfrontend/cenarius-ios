//
//  CNRSLogging.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#ifdef DEBUG
#define CNRSLog(...) NSLog(@"[Cenarius] " __VA_ARGS__)
#else /* DEBUG */
#define CNRSLog(...)
#endif /* DEBUG */

#define CNRSDebugLog(...)  CNRSLog(@"[DEBUG] " __VA_ARGS__)
#define CNRSWarnLog(...)   CNRSLog(@"[WARN] " __VA_ARGS__)
#define CNRSErrorLog(...)  CNRSLog(@"[ERROR] " __VA_ARGS__)
