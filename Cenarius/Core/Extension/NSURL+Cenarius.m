//
//  NSURL+Cenarius.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSURL+Cenarius.h"
#import "NSString+CNRSURLEscape.h"
#import "NSMutableDictionary+CNRSMultipleItems.h"
#import "NSDictionary+CNRSMultipleItems.h"
#import "CNRSConfig.h"
#import "CNRSLoginWidget.h"


@implementation NSURL (Cenarius)

+ (NSString *)cnrs_queryFromDictionary:(NSDictionary *)dict
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

- (BOOL)cnrs_isHttpOrHttps
{
  if ([self.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
      [self.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
    return YES;
  }
  return NO;
}

- (NSDictionary *)cnrs_queryDictionary {
  NSString *query = [self query];
  if ([query length] == 0) {
    return nil;
  }

  // Replace '+' with space
  query = [query stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];

  NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary *pairs = [NSMutableDictionary dictionary];

  NSScanner *scanner = [[NSScanner alloc] initWithString:query];
  while (![scanner isAtEnd]) {
    NSString *pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
//      [pairs cnrs_addItem:[[kvPair objectAtIndex:1] cnrs_decodingStringUsingURLEscape]
//                  forKey:[[kvPair objectAtIndex:0] cnrs_decodingStringUsingURLEscape]];
        [pairs setObject:[[kvPair objectAtIndex:1] cnrs_decodingStringUsingURLEscape] forKey:[[kvPair objectAtIndex:0] cnrs_decodingStringUsingURLEscape]];
    }
  }

  return [pairs copy];
}

- (NSDictionary *)cnrs_jsonDictionary
{
    NSString *string = [[self cnrs_queryDictionary] cnrs_itemForKey:@"data"];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return jsonDic;
}

- (NSDictionary *)cnrs_openApiQueryDictionary
{
    NSDictionary *oldParameters = self.cnrs_queryDictionary;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:oldParameters];
    NSString *access_token = [CNRSLoginWidget getAccessToken];
    NSString *app_key = [CNRSConfig loginAppKey];
    NSNumber *timestamp = [NSNumber numberWithInteger:[NSDate date].timeIntervalSince1970 * 1000];
    
    if (oldParameters[@"access_token"] == nil && access_token)
    {
        parameters[@"access_token"] = access_token;
    }
    if (oldParameters[@"app_key"] == nil && app_key)
    {
        parameters[@"app_key"] = app_key;
    }
    if (oldParameters[@"timestamp"] == nil && timestamp)
    {
        parameters[@"timestamp"] = timestamp;
    }
    
    NSString *appSecret = [CNRSConfig loginAppSecret];
    NSString *sign = [CNRSLoginWidget md5Signature:parameters secret:appSecret];
    if (oldParameters[@"sign"] == nil && sign)
    {
        parameters[@"sign"] = sign;
    }
    
    return parameters;
}


@end
