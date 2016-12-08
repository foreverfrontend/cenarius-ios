//
//  NSURL+Cenarius.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSURL (Cenarius)

/**
 * 该 url 的 scheme 是否是 http 或 https？
 */
- (BOOL)isHttpOrHttps;

/**
 * 将该 url 的 query 以字典形式返回。
 */
- (NSDictionary *)queryDictionary;

/**
 从url的query中取出key为data的value（json格式），把value转成字典
 
 @return value的字典
 */
- (NSDictionary *)jsonDictionary;

@end
