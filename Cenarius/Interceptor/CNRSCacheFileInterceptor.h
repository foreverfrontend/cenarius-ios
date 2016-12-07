//
//  CNRSCacheFileInterceptor.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNSURLProtocol.h"

/**
 * `CNRSCacheFileInterceptor` 用于拦截进入 Cenarius Container 的请求，并可对请求做所需的变化。
 * 目前完成： 1 本地文件映射，如请求服务器上的 html 资源，先检查本地，如存在则使用本地html文件（包括本地缓存，和应用内置资源）显示。
 */
@interface CNRSCacheFileInterceptor : CNRSNSURLProtocol

@end
