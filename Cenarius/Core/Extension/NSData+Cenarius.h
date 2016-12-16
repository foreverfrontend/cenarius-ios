//
//  NSData+CNRSDigest.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface NSData (CNRSDigest)

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)sha256;
- (NSString *)sha512;

@end
