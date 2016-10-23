//
//  UIColor+Cenarius.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "UIColor+Cenarius.h"

@implementation UIColor (Cenarius)

+ (instancetype)cnrs_colorWithComponent:(NSString *)colorComponents
{
  UIColor *color = nil;

  NSScanner *scanner = [NSScanner scannerWithString:colorComponents];
  scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];

  NSString *colorType = nil;
  if ([scanner scanUpToString:@"(" intoString:&colorType] && colorType // 解析颜色值类型
      && scanner.scanLocation < (scanner.string.length - 1) && ++scanner.scanLocation && !scanner.atEnd // 跳过类型后的 `(`
      ) {
    NSUInteger length = colorType.length;
    if (length <= 4) {
      // RGB / HSL 三部分 + alpha
      NSInteger components[4] = {-1, -1, -1, 255};
      for (NSUInteger index = 0; index < length; ++index) {
        if (index > 0) {
          [scanner scanString:@"," intoString:nil];
        }
        [scanner scanInteger:&components[index]];
      }

      if (components[0] >= 0 && components[1] >= 0 && components[2] >= 0 && components[3] >= 0
          && [colorType hasPrefix:@"rgb"]) {
        color = [UIColor colorWithRed:(components[0] / 255.f)
                                green:(components[1] / 255.f)
                                 blue:(components[2] / 255.f)
                                alpha:(components[3] / 255.f)];
      }
    }
  }

  if (color == nil) {
    NSLog(@"Unknown color: %@", colorComponents);
  }

  return color;
}

@end
