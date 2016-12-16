//
//  NSData+Cenarius.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSData+Cenarius.h"
#include <CommonCrypto/CommonDigest.h>

#define CNRS_DIGEST_PERFORM(_LENGTH, _FUNCTION) \
  NSMutableString *result; \
  do { \
    size_t i; \
    unsigned char md[(_LENGTH)]; \
    \
    bzero(md, sizeof(md)); \
    (_FUNCTION)([self bytes], (CC_LONG)[self length], md); \
    \
    result = [NSMutableString stringWithCapacity:(_LENGTH) * 2]; \
    for (i = 0; i < (_LENGTH); ++i) { \
      [result appendFormat:@"%02x", md[i]]; \
    } \
  } while (0); \
  return [result copy]

@implementation NSData (Cenarius)

- (NSString *)md5
{
  CNRS_DIGEST_PERFORM(CC_MD5_DIGEST_LENGTH, CC_MD5);
}

- (NSString *)sha1
{
  CNRS_DIGEST_PERFORM(CC_SHA1_DIGEST_LENGTH, CC_SHA1);
}

- (NSString *)sha256
{
  CNRS_DIGEST_PERFORM(CC_SHA256_DIGEST_LENGTH, CC_SHA256);
}

- (NSString *)sha512
{
  CNRS_DIGEST_PERFORM(CC_SHA512_DIGEST_LENGTH, CC_SHA512);
}

@end
