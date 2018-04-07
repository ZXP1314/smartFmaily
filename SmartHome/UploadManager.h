//
//  UploadFile.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//
@interface UploadManager : NSObject

+ (instancetype)defaultManager;
//- (void)uploadImage:(UIImage *) img url:(NSString *) url dic:(NSDictionary *)dic completion:(void (^)(id responseObject))completion;

- (void)uploadScene:(NSData *)sceneData url:(NSString *) url dic:(NSDictionary *)dic fileName:(NSString *)fileName imgData:(NSData *)imgData imgFileName:(NSString *)imgFileName completion:(void (^)(id responseObject))completion;

- (void)uploadImage:(UIImage *) img url:(NSString *) url dic:(NSDictionary *)dic fileName:(NSString *)fileName completion:(void (^)(id responseObject))completion;

//上传设备定时器plist文件
- (void)uploadDeviceTimer:(NSData *)timerData url:(NSString *) url dic:(NSDictionary *)dic fileName:(NSString *)fileName completion:(void (^)(id responseObject))completion;
@end
