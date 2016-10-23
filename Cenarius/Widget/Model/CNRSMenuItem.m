//
//  CNRSMenuItem.m
//  Cenarius
//
//  Created by M on 2016/10/18.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSMenuItem.h"

@implementation CNRSMenuItem

- (NSString *)type
{
    return [self.dictionary objectForKey:@"type"];
}

- (NSString *)title
{
    return [self.dictionary objectForKey:@"title"];
}

- (NSString *)color
{
    return [self.dictionary objectForKey:@"color"];
}

- (NSURL *)uri
{
    return [NSURL URLWithString:[self.dictionary objectForKey:@"uri"]];
}

- (NSString *)action
{
    return [self.dictionary objectForKey:@"action"];
}

@end
