//
//  CenariusConfigEntity.m
//  CTCattsoft
//
//  Created by Frank on 14-1-13.
//  Copyright (c) 2014年 gdcattsoft. All rights reserved.
//

#import "CenariusConfigEntity.h"

@implementation CenariusConfigEntity

- (id)initWithData:(NSData *)data
{
	if ((self = [super init]))
	{
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
		self.androidMinVersion = [self convertNull:[dict objectForKey:@"android_min_version"]];
		self.releaseVersion = [self convertNull:[dict objectForKey:@"release"]];
		self.iosMinVersion = [self convertNull:[dict objectForKey:@"ios_min_version"]];
		self.name = [self convertNull:[dict objectForKey:@"name"]];
	}
	return self;
}

- (id)convertNull:(id)value
{
	if (value != [NSNull null])
		return value;
	return nil;
}

@end
