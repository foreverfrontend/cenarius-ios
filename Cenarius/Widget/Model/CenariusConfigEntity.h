//
//  CenariusConfigEntity.h
//  CTCattsoft
//
//  Created by Frank on 14-1-13.
//  Copyright (c) 2014年 gdcattsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CenariusConfigEntity : NSObject


@property (nonatomic, strong) NSString *androidMinVersion;
@property (nonatomic, strong) NSString *releaseVersion;
@property (nonatomic, strong) NSString *iosMinVersion;
@property (nonatomic, strong) NSString *name;


- (id)initWithData:(NSData *)data;

@end
