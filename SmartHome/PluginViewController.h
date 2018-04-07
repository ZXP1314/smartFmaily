
//
//  PluginViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//
//#import <HomeKit/HomeKit.h>

#define DEVICE_TYPE @"智能单品"
#import "CustomViewController.h"

@interface PluginViewController : CustomViewController//<HMHomeManagerDelegate, HMHomeDelegate>

@property (strong, nonatomic) NSMutableArray *devices;
@property (nonatomic,assign) int roomID;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
/*
@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) HMHome *primaryHome;
@property (nonatomic, strong) HMCharacteristic *characteristic;
*/
@property (nonatomic,assign) BOOL isAddDevice;

@property (strong, nonatomic) Scene *scene;

@end
