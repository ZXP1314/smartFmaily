//
//  STPingTool.h
//  SmartHome
//
//  Created by zhaona on 2018/4/3.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDPingServices.h"


/**
 ping结果的回调block

 @param hostIP 服务器ip地址
 @param lossPresent 丢包率（整型，最大为100）
 */
typedef void(^PingHostResultBlock)(NSString *hostIP,CGFloat lossPresent);

@interface STPingTool : NSObject

@property (nonatomic,copy) PingHostResultBlock block;

/**
 ping服务器工具方法
 
 @param hostIP 需要ping的主机ip
 @param block 回调结果。
 */
-(void)pingHostWithHostIP:(NSString *)hostIP andBlock:(PingHostResultBlock)block;

/**
 单例方法

 @return 当前对象
 */
+ (instancetype)shareInstance;
@end
