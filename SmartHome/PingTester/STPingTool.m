//
//  STPingTool.m
//  SmartHome
//
//  Created by zhaona on 2018/4/3.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import "STPingTool.h"
@interface STPingTool()
@property(nonatomic, strong) STDPingServices    *pingServices;

@end
@implementation STPingTool

+(instancetype)shareInstance{
    static STPingTool *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)pingHostWithHostIP:(NSString *)hostIP andBlock:(PingHostResultBlock)block{
    __weak STPingTool *weakSelf = self;
    self.pingServices = [STDPingServices startPingAddress:hostIP callbackHandler:^(STDPingItem *pingItem, NSArray *pingItems) {
        if (pingItem.status != STDPingStatusFinished) {//如果正在ping
//            [weakSelf.textView appendText:pingItem.description];
        } else {//ping结束
//            [weakSelf.textView appendText:[STDPingItem statisticsWithPingItems:pingItems]];
//            [button setTitle:@"Ping" forState:UIControlStateNormal];
//            button.tag = 10001;
            CGFloat lossPersent = [STDPingItem  pinglossPercentWithPingItems:pingItems];
            weakSelf.pingServices = nil;
            if (block) {
                block(hostIP,lossPersent);
            }
        }
    }];
    // 2秒后结束ping  [self.pingServices cancel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.pingServices cancel];
    });
    
}

@end
