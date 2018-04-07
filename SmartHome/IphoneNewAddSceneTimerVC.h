//
//  IphoneNewAddSceneTimerVC.h
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "DeviceSchedule.h" 

@interface IphoneNewAddSceneTimerVC : CustomViewController
@property (weak, nonatomic) IBOutlet UILabel *RepetitionLable;//显示重复日期的label
@property (weak, nonatomic) IBOutlet UILabel *starTimeLabel;//开始时间
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;//结束时间
@property (nonatomic, strong) NSString *startTimeStr;
@property (nonatomic, strong) NSString *endTimeStr;
@property (nonatomic, strong) NSString *repeatitionStr;
@property (nonatomic, strong) NSString *naviTitle;
@property (nonatomic, strong) NSMutableArray *weekArray;
@property (weak, nonatomic) IBOutlet UIView *TimerView;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) int roomid;
@property (nonatomic, assign) BOOL isShowInSplitView;
@property (nonatomic, assign) BOOL isDeviceTimer;// YES: 设备定时 NO: 场景定时
@property (nonatomic,strong) DeviceSchedule *timer;  

@end
