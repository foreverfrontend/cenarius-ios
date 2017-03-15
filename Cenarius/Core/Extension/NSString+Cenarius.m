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
    
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        
        pairString = [pairString stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
        pairString = [pairString decodingStringUsingURLEscape];
        
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        
        NSString *key = (NSString *)[kvPair firstObject];
        NSString *value = [pairString substringFromIndex:key.length + 1];
        
        [pairs addItem:value forKey:key];
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

- (int)compareVersion:(NSString *)version{
    if (self && version) {
        const char *v1 = [self UTF8String];
        const char *v2 = [version UTF8String];
        return compareVersion(v1, v2);
    }
    return 0;
}

int compareVersion(const char *v1, const char *v2)
{
    assert(v1);
    assert(v2);
    
    const char *p_v1 = v1;
    const char *p_v2 = v2;
    
    while (*p_v1 && *p_v2) {
        char buf_v1[32] = {0};
        char buf_v2[32] = {0};
        
        char *i_v1 = strchr(p_v1, '.');
        char *i_v2 = strchr(p_v2, '.');
        
        if (!i_v1 || !i_v2) break;
        
        if (i_v1 != p_v1) {
            strncpy(buf_v1, p_v1, i_v1 - p_v1);
            p_v1 = i_v1;
        }
        else
        p_v1++;
        
        if (i_v2 != p_v2) {
            strncpy(buf_v2, p_v2, i_v2 - p_v2);
            p_v2 = i_v2;
        }
        else
        p_v2++;
        
        
        
        int order = atoi(buf_v1) - atoi(buf_v2);
        if (order != 0)
        return order < 0 ? -1 : 1;
    }
    
    double res = atof(p_v1) - atof(p_v2);
    
    if (res < 0) return -1;
    if (res > 0) return 1;
    return 0;
}
@end
