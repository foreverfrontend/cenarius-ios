//
//  NSURL+Cenarius.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSURL+Cenarius.h"
#import "NSString+CNRSURLEscape.h"
#import "NSDictionary+CNRSMultipleItems.h"
#import "NSString+CNRSURLEscape.h"

@implementation NSURL (Cenarius)

+ (NSString *)queryFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    NSString *query = nil;
    if (pairs.count > 0) {
        query = [pairs componentsJoinedByString:@"&"];
    }
    return query;
}

- (BOOL)isHttpOrHttps
{
    NSString *scheme = [self.scheme uppercaseString];
    if ([scheme isEqualToString:@"HTTP"] || [scheme isEqualToString:@"HTTPS"])
    {
        return YES;
    }
    return NO;
}

- (NSDictionary *)queryDictionary {
    NSString *query = [self query];
    return [query queryDictionary];
}

- (NSDictionary *)jsonDictionary
{
    NSString *string = [[self queryDictionary] itemForKey:@"data"];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return jsonDic;
}


@end
