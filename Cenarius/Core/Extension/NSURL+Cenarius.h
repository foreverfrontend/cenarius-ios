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
 * 将一个字典内容转换成 url 的 query 的形式。
 *
 * @param dict 需要转换成的 query 的 dictionary。
 */
+ (NSString *)cnrs_queryFromDictionary:(NSDictionary *)dict;

/**
 * 该 url 的 scheme 是否是 http 或 https？
 */
- (BOOL)cnrs_isHttpOrHttps;

/**
 * 将该 url 的 query 以字典形式返回。
 */
- (NSDictionary *)cnrs_queryDictionary;

/**
 从url的query中取出key为data的value（json格式），把value转成字典
 
 @return value的字典
 */
- (NSDictionary *)cnrs_jsonDictionary;

@end
