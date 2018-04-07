//
//  AppDelegate.h
//  SmartHome
//
//  Created by Brustar on 16/4/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "LeftSlideViewController.h"
#import "BaseTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LeftSlideViewController *LeftSlideVC;//侧滑视图VC
@property (strong, nonatomic) BaseTabBarController *mainTabBarController;//主视图TabBarVC
@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) int RoomID;
@property (nonatomic,strong) LeftViewController * leftview;

@end
