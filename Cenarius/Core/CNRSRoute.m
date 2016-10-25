//
//  CNRSRoute.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRoute.h"
#import "CNRSConfig.h"
#import "CNRSLogging.h"

@implementation CNRSRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ( (self = [super init]) )
    {
        _fileHash = dict[@"hash"];
        _uri = [NSURL URLWithString:dict[@"file"]];
        if (_uri.absoluteString != nil)
        {
            _remoteHTML = [[CNRSConfig remoteFolderUrl] URLByAppendingPathComponent:_uri.absoluteString];
        }
        else
        {
            CNRSErrorLog(@"file in route %@ is nil", dict);
        }
    }
    return self;
}

@end
