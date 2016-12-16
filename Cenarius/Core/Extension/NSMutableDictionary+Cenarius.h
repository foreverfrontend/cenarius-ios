//
//  NSMutableDictionary+Cenarius.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSMutableDictionary (Cenarius)

/**
 * 在字典以关键字添加一个元素。
 *
 * @param item 待添加的元素
 * @param aKey 关键字
 */
- (void)addItem:(NSString *)item forKey:(NSString *)aKey;

@end
