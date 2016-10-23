//
//  CNRSModel.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSModel` 数据对象。
 * Web 对 Native 调用时可能会出发一些结构化的数据。
 * CNRSModel 提供了对这些数据的更简便的访问方法。
 */
@interface CNRSModel : NSObject

/**
 * 数据对象的 json 字符串形式。
 */
@property (nonatomic, readonly, copy) NSString *string;

/**
 * 数据对象的字典形式。
 */
@property (nonatomic, strong) NSMutableDictionary *dictionary;

/**
 * 以 json 字符串初始化数据对象。
 *
 * @param theJsonStr 字符串
 */
- (id)initWithString:(NSString *)theJsonStr;

/**
 * 以字典初始化数据对象。
 *
 * @param theDictionary 字典
 */
- (id)initWithDictionary:(NSDictionary *)theDictionary;

@end

NS_ASSUME_NONNULL_END
