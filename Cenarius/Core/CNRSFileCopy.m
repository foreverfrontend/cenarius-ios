//
//  CNRSFileCopy.m
//  GbssApps-IOS
//
//  Created by james on 16/3/28.
//
//

#import "CNRSFileCopy.h"
#import "CNRSRouteFileCache.h"
#import "Cenarius.h"
#import "CenariusConfigEntity.h"

#import <SSZipArchive/SSZipArchive.h>


@implementation CNRSFileCopy

+ (void)resourceUnzipToLibraeyWithProgress:(void(^)(long entryNumber, long total))progresshandler completionHandler:(void(^)(NSString * path, BOOL succeeded, NSError * error))completionHandler{
    NSFileManager *fm      = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"www/www.zip" ofType:nil];
    NSString *dstPath      = [[CNRSRouteFileCache sharedInstance] cachePath];
    
    if ([fm fileExistsAtPath:resourcePath]) {
        BOOL isDirectory = NO;
        [fm fileExistsAtPath:dstPath isDirectory:&isDirectory];
        if (isDirectory) {
            [fm removeItemAtPath:dstPath error:nil];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:resourcePath toDestination:dstPath
                      progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total)
         {
             if(progresshandler)progresshandler(entryNumber,total);
         } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
             if(completionHandler)completionHandler(path,succeeded,error);
         }];
    });
}


/**
 是否需要下载更新
 
 @return true 下载，false 跳过
 */
+ (BOOL)isCompareReleaseVersion:(NSData *)serverData{
    NSString *cenarius_config = @"cenarius-config.json";
    NSString *cachePath       = [[CNRSRouteFileCache sharedInstance] cachePath];
    NSData *cacheData         = [NSData dataWithContentsOfFile:[cachePath stringByAppendingPathComponent:cenarius_config]];
    if(cacheData == nil) return true;
    return [self releaseVersion:serverData compare:cacheData];
}


/**
 当左边操作对象 > 右边操作对象 返回true
 */
+ (BOOL)releaseVersion:(NSData *)leftData compare:(NSData *)rightData{
    CenariusConfigEntity *serverEntity = [[CenariusConfigEntity alloc] initWithData:leftData];
    CenariusConfigEntity *cacheEntity  = [[CenariusConfigEntity alloc] initWithData:rightData];
    
    if ([serverEntity.releaseVersion compare:cacheEntity.releaseVersion] == NSOrderedDescending) {
        return true;
    }
    return false;
}
/**
 H5是否支持最小版本

 @param serverData server cenarius-config.json
 @return true 不支持最小版本 ， false 可更新
 */
+ (BOOL)isCompareIosMinVersion:(NSData *)serverData{
    CenariusConfigEntity *serverEntity = [[CenariusConfigEntity alloc] initWithData:serverData];
    NSString *AppVersion               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    int compareResult                  = [AppVersion compareVersion:serverEntity.iosMinVersion];
    // App小于最低版本支持  左边的对象 < 右边的对象  == NSOrderedAscending
    if (compareResult < 0) {
        return true;
    }else{
        return false;
    }
}

/**
 是否需要解压拷贝
 @return true  需要解压拷贝， false 不拷贝
 */
+ (BOOL)isUnzipFileAtPath{
    NSString *cenarius_config = @"cenarius-config.json";
    NSString *resourcePath    = [[NSBundle mainBundle] pathForResource:@"www" ofType:nil];
    NSString *cachePath       = [[CNRSRouteFileCache sharedInstance] cachePath];
    
    NSData *resourceData = [NSData dataWithContentsOfFile:[resourcePath stringByAppendingPathComponent:cenarius_config]];
    NSData *cacheData    = [NSData dataWithContentsOfFile:[cachePath stringByAppendingPathComponent:cenarius_config]];
    
    //缓存没有，必需Copy
    if (cacheData == nil) {
        return true;
    }else if(resourceData == nil){
        return false;
    }else{
        return [self releaseVersion:resourceData compare:cacheData];
    }
    return false;
}
@end
