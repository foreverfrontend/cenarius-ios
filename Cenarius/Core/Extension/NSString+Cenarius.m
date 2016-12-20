//
//  NSString+Cenarius.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSString+Cenarius.h"
#import "NSMutableDictionary+Cenarius.h"

@implementation NSString (Cenarius)

- (NSString *)encodingStringUsingURLEscape
{
  CFStringRef originStringRef = (__bridge_retained CFStringRef)self;
  CFStringRef escapedStringRef = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                         originStringRef,
                                                                         NULL,
                                                                         (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                         kCFStringEncodingUTF8);
  NSString *escapedString = (__bridge_transfer NSString *)escapedStringRef;
  CFRelease(originStringRef);
  return escapedString;
}

- (NSString *)decodingStringUsingURLEscape
{
  CFStringRef originStringRef = (__bridge_retained CFStringRef)self;
  CFStringRef escapedStringRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         originStringRef,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
  NSString *escapedString = (__bridge_transfer NSString *)escapedStringRef;
  CFRelease(originStringRef);
  return escapedString;
}

- (NSDictionary *)queryDictionary {
    NSString *query = self;
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
        NSString *key = [kvPair firstObject];
        NSRange range = [pairString rangeOfString:[key stringByAppendingString:@"="]];
        NSString *value = [pairString substringFromIndex:range.length];
        [pairs addItem:[key decodingStringUsingURLEscape]
                forKey:[value decodingStringUsingURLEscape]];
    }
    
    return [pairs copy];
}

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64DecodedString
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
