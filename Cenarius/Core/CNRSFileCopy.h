//
//  CNRSFileCopy.h
//  GbssApps-IOS
//
//  Created by james on 16/3/28.
//
//

#import <Foundation/Foundation.h>
typedef void(^finishCoy)(int d);
typedef void (^finishAllCopy)();

@interface CNRSFileCopy : NSObject
@property (nonatomic,copy) finishCoy finishCopy;
@property (nonatomic,copy) finishAllCopy finishAllCopy;

/**
 将www目录下的文件拷贝至Documents www 目录
 
 @param fileNames     格式{key,value} value == 1 强制覆盖 ， value == 0 已存在不覆盖
 */
- (void)moveFileToDocumentPath:(NSDictionary *)fileNames;

/**
 拷贝文件Resrouse/www到Library/www目录下

 @param finishCopy    拷贝完成一个就回调一次
 @param finishAllCopy 拷贝所有流程都完成才回调
 @param countBlock www目录下的文件数
 */
+ (void)resourceMoveToLibraryFinish:(void(^)(int d))finishCopy finishAll:(void(^)())finishAllCopy countBlock:(void(^)(NSInteger))countBlock;

/**
 解压Resrouse/www目录下的zip到Library目录
 */
+ (void)resourceUnzipToLibraeyWithProgress:(void(^)(long entryNumber, long total))progresshandler completionHandler:(void(^)(NSString *  path, BOOL succeeded, NSError * error))completionHandler;
@end
