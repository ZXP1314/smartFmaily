
//
//  AirController.h
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoadMaskHelper.h"
#import "UIViewController+Navigator.h"
#import "IphoneRoomView.h"
//#include "CustomViewController.h"

typedef NS_ENUM(NSUInteger,mode)
{
    heat,
    cool
};

typedef NS_ENUM(NSUInteger,wind)
{
    speed=1,
    direction
};

@interface AirController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,weak) NSString *Currentdeviceid;
@property (nonatomic,strong)NSArray * deviceidArr;
@property (nonatomic,weak) NSString *actKey;
@property (nonatomic,strong) NSArray *params;

@property (nonatomic) int currentButton;

@property (nonatomic) int currentMode;
@property (nonatomic) int airMode;
@property (nonatomic) int currentLevel;
@property (nonatomic) int currentDirection;
@property (nonatomic) int currentTiming;

@property (nonatomic) int currentDegree;

@property (nonatomic,assign) int roomID;
@property (weak, nonatomic) IBOutlet UILabel *currentDeviceName;

@property (nonatomic,assign) BOOL isAddDevice;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuContainerTopConstraint;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *control_bannerConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *control_banner;
@property (weak, nonatomic) IBOutlet UIButton *windSpeedBtn;

@end
