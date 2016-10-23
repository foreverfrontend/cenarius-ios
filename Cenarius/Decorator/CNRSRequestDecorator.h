//
//  CNRSRequestDecorator.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

#import "CNRSDecorator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSRequestDecorator` 是一个具体的请求装修器。
 * 通过该装修器对 Cenarius-Conntainer 中发出的请求作修改。增加其 url 参数，以及增添自定义 header。
 */
@interface CNRSRequestDecorator : NSObject<CNRSDecorator>

/**
 * 需要为请求增添的自定义 header。
 */
@property (nonatomic, strong) NSDictionary *headers;

/**
 * 需要为请求增添的 url 参数。
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 * 初始化一个请求装修器。
 *
 * @param headers 需要为请求增添的自定义 header
 * @param parameters 需要为请求增添的 url 参数
 */
- (instancetype)initWithHeaders:(NSDictionary *)headers
                     parameters:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
