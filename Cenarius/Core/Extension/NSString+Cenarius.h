//
//  NSString+Cenarius.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSString (Cenarius)

/**
 * url 字符串编码
 */
- (NSString *)encodingStringUsingURLEscape;

/**
 * url 字符串解码
 */
- (NSString *)decodingStringUsingURLEscape;

/**
 * 将 query 以字典形式返回。
 */
- (NSDictionary *)queryDictionary;

/**
 *  转换为Base64编码
 */

- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;


/**
 版本号比较

 @param version 当String > version 则为true
 */
- (int)compareVersion:(NSString *)version;
@end
