//
//  CNRSRoute.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSRoute` 路由信息对象。
 */
@interface CNRSRoute : NSObject

/**
 * 以一个字典初始化路由信息对象。
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * 该路由对应的 html 文件地址。
 */
@property (nonatomic, readonly) NSURL *remoteHTML;

/**
 * 该路由对应的文件 hash 值。
 */
@property (nonatomic, readonly) NSString *fileHash;

/**
 * 该路由对应的 uri 文件地址。
 */
@property (nonatomic, readonly) NSURL *uri;

@end

NS_ASSUME_NONNULL_END
