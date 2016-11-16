//
//  NSMutableDictionary+CNRSMultipleItems.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSMutableDictionary (CNRSMultipleItems)

/**
 * 在字典以关键字添加一个元素。
 *
 * @param item 待添加的元素
 * @param aKey 关键字
 */
- (void)cnrs_addItem:(id)item forKey:(id<NSCopying>)aKey;

@end
