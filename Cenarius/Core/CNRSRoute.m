//
//  CNRSRoute.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRoute.h"
#import "CNRSConfig.h"

@implementation CNRSRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
  if ( (self = [super init]) ) {
      
    _uri = [NSURL URLWithString:dict[@"file"]];
      _remoteHTML = [[CNRSConfig remoteFolderUrl] URLByAppendingPathComponent:_uri.absoluteString];
      _fileHash = dict[@"hash"];
  }
  return self;
}

@end
