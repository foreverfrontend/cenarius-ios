//
//  NSString+CNRSURLEscape.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSString (CNRSURLEscape)

/**
 * url 字符串编码
 */
- (NSString *)cnrs_encodingStringUsingURLEscape;

/**
 * url 字符串解码
 */
- (NSString *)cnrs_decodingStringUsingURLEscape;

@end
