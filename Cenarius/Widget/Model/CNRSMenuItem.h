//
//  CNRSMenuItem.h
//  Cenarius
//
//  Created by M on 2016/10/18.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSModel.h"

@interface CNRSMenuItem : CNRSModel

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) UIColor *color;
@property (nonatomic, copy, readonly) NSURL *uri;
@property (nonatomic, copy, readonly) NSString *action;


@end
