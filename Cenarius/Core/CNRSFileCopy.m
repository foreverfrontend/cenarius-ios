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

#import <SSZipArchive/SSZipArchive.h>

@implementation CNRSFileCopy
#define LAST_VERSION @"__LAST_VERSION"

+ (void)resourceUnzipToLibraeyWithProgress:(void(^)(long entryNumber, long total))progresshandler completionHandler:(void(^)(NSString * path, BOOL succeeded, NSError * error))completionHandler{
    NSFileManager *fm                  = [NSFileManager defaultManager];
//    NSMutableDictionary *copyFileNames = [NSMutableDictionary dictionary];
    NSDictionary *infoDictionary       = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion           = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:nil];
    NSArray *contents      = [fm contentsOfDirectoryAtPath:resourcePath error:nil];
    NSString *lastVersion  = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_VERSION];
    
    for (NSString *fileName in contents) {
        if ([[fileName pathExtension] isEqualToString:@"zip"]) {
            resourcePath = [resourcePath stringByAppendingPathComponent:fileName];
        }
    }
    
    if ((lastVersion && [currentVersion isEqualToString:lastVersion])) {
        if(completionHandler)completionHandler(nil,true,nil);
    }else{
        NSString *dstPath = [[CNRSRouteFileCache sharedInstance] cachePath];
        BOOL isDirectory = NO;
        [fm fileExistsAtPath:dstPath isDirectory:&isDirectory];
        if (isDirectory) {
            [fm removeItemAtPath:dstPath error:nil];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SSZipArchive unzipFileAtPath:resourcePath toDestination:dstPath
                          progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total)
             {
                 if(progresshandler)progresshandler(entryNumber,total);
             } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
                 if (succeeded) {
                     //拷贝完成，写入版本号
                     NSDictionary *infoDictionary =[[NSBundle mainBundle] infoDictionary];
                     NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
                     [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:LAST_VERSION];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 if(completionHandler)completionHandler(path,succeeded,error);
             }];
        });
    }
}
/**
 将www目录下的文件拷贝至Documents www 目录
 格式{key,value} value == 1 强制覆盖 ， value == 0 已存在不覆盖
 */
+ (void)resourceMoveToLibraryFinish:(void(^)(int d))finishCopy finishAll:(void(^)())finishAllCopy countBlock:(void(^)(NSInteger))countBlock{
    CNRSFileCopy *moduleCopy           = [[CNRSFileCopy alloc] init];
    moduleCopy.finishCopy              = finishCopy;
    moduleCopy.finishAllCopy           = finishAllCopy;
    
    NSFileManager *fm                  = [NSFileManager defaultManager];
    NSMutableDictionary *copyFileNames = [NSMutableDictionary dictionary];
    NSDictionary *infoDictionary       = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion           = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSArray *contents     = [fm contentsOfDirectoryAtPath:[[NSBundle mainBundle] pathForResource:@"www" ofType:nil] error:nil];
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_VERSION];
    
    if ((lastVersion && [currentVersion isEqualToString:lastVersion])) {
        if(countBlock) countBlock(0);
        if(finishAllCopy)finishAllCopy();
    }else{
        if(countBlock) countBlock([contents count]);
        NSNumber *number      = (lastVersion && [currentVersion isEqualToString:lastVersion]) ? @(0) : @(1);
        for (NSString *fileName in contents) {
            copyFileNames[fileName] = number;
        }
        [moduleCopy moveFileToDocumentPath:copyFileNames];
    }
}
/**
 将www目录下的文件拷贝至Documents www 目录
 
 @param fileNames     格式{key,value} value == 1 强制覆盖 ， value == 0 已存在不覆盖
 */
- (void)moveFileToDocumentPath:(NSDictionary *)fileNames{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    NSArray *copyIendx = [fileNames allKeys];
    
    dispatch_group_async(group, queue, ^{
        for (int d=0;d<copyIendx.count;d++) {
            NSString *identify = copyIendx[d];
            [self copyIdentifyFile:identify  index:d isCover:[fileNames[identify] intValue] == 1];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.finishCopy) {
                    self.finishCopy(d);
                }
            });
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        //拷贝完成，写入版本号
        NSDictionary *infoDictionary =[[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:LAST_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.finishAllCopy) {
           self.finishAllCopy();
        }
    });
}



/**

 @param Identify www目录的包名
 @param index    index description
 @param isCover  是否强制覆盖
 */
-(void)copyIdentifyFile:(NSString *)Identify  index:(NSInteger)index isCover:(BOOL)isCover{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:[@"www" stringByAppendingPathComponent:Identify] ofType:nil];
    NSString *dstPath = [[CNRSRouteFileCache sharedInstance] cachePath];
    
    //目标源文件没有
    if (srcPath == nil) {
        return;
    }
    
    NSArray *contents = nil;
    BOOL isDirectory = NO;
    [fm fileExistsAtPath:srcPath isDirectory:&isDirectory];
    if (isDirectory) {
        contents = [fm contentsOfDirectoryAtPath:srcPath error:&error];
    }else{
        Identify = @"";
        contents = @[[srcPath lastPathComponent]];
        srcPath = [srcPath stringByDeletingLastPathComponent];
    }
    
    void (^copyItem)(NSString *path,NSString *toPath,BOOL isCover,NSError *error) =
    ^(NSString *path,NSString *toPath,BOOL isCover,NSError *error){
       BOOL isExist =  [fm fileExistsAtPath:toPath];
        if (!(isExist && !isCover)) {
            BOOL result = [fm copyItemAtPath:path toPath:toPath error:&error];
            if (!result) {
                CNRSDebugLog(@"复制文件失败,%@,[%@]", error, path);
            }
        }
    };
    
    for (NSString *subfile in contents) {
        NSString *fullSrc = [srcPath stringByAppendingPathComponent:subfile];
        NSString *fullDst = [dstPath stringByAppendingPathComponent:[Identify stringByAppendingPathComponent:subfile]];//目标目录
        
        BOOL srcItem_isDirectory = NO;
        [fm fileExistsAtPath:fullDst isDirectory:&srcItem_isDirectory];
        if (srcItem_isDirectory) {
            //srcItem_exists == YES 文件存在，且属于目录
            //srcItem_exists == NO 文件不存在，且属于目录
            if(isCover)[fm removeItemAtPath:fullDst error:nil];
            copyItem(fullSrc,fullDst,isCover,error);
        }else {
            //属于文件，查看上一级是否创建
            NSString *superFilePath = fullDst.stringByDeletingLastPathComponent;
            if ([fm fileExistsAtPath:superFilePath]) {
                copyItem(fullSrc,fullDst,isCover,error);
            }else{
                if ([fm createDirectoryAtPath:superFilePath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    copyItem(fullSrc,fullDst,isCover,error);
                }
            }
            if (error != nil) {
                break;
            }
        }
    }
}

@end
