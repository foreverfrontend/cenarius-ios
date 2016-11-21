//
//  CNRSProgressViewWidget.m
//  Cenarius
//
//  Created by M on 2016/11/21.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSProgressViewWidget.h"

@interface CNRSProgressViewWidget()

@property (nonatomic) BOOL isFinishLoad;
@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation CNRSProgressViewWidget

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.trackTintColor = [UIColor clearColor];
    }
    return self;
}

- (void)startLoad
{
    _isFinishLoad = NO;
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)finishLoad
{
    _isFinishLoad = YES;
}

-(void)timerCallback
{
    if (_isFinishLoad)
    {
        if (self.progress >= 1)
        {
            self.hidden = YES;
            [_progressTimer invalidate];
        }
        else
        {
            self.progress += 0.1;
        }
    }
    else
    {
        self.progress += 0.05;
        if (self.progress >= 0.95)
        {
            self.progress = 0.95;
        }
    }
}


@end
