//
//  CNRSFileCopy.h
//  GbssApps-IOS
//
//  Created by james on 16/3/28.
//
//

#import <Foundation/Foundation.h>

#define LAST_VERSION @"__LAST_VERSION"

typedef void(^finishCoy)(int d);
typedef void (^finishAllCopy)();

@interface CNRSFileCopy : NSObject
@property (nonatomic,copy) finishCoy finishCopy;
@property (nonatomic,copy) finishAllCopy finishAllCopy;
/**
 解压Resrouse/www目录下的zip到Library目录
 */
+ (void)resourceUnzipToLibraeyWithProgress:(void(^)(long entryNumber, long total))progresshandler completionHandler:(void(^)(NSString *  path, BOOL succeeded, NSError * error))completionHandler;

/**
 是否需要下载更新
 
 @return true 下载，false 跳过
 */
+ (BOOL)isCompareReleaseVersion:(NSData *)serverData;
/**
 H5是否支持最小版本
 
 @param serverData server cenarius-config.json
 @return true 不支持最小版本 ， false 可更新
 */
+ (BOOL)isCompareIosMinVersion:(NSData *)serverData;
/**
 是否需要解压拷贝
 @return true  需要解压拷贝， false 不拷贝
 */
+ (BOOL)isUnzipFileAtPath;
/**
 当左边操作对象 > 右边操作对象 返回true
 */
+ (BOOL)releaseVersion:(NSData *)leftData compare:(NSData *)rightData;
@end
