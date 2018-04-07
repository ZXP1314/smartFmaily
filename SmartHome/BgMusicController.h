//
//  BgMusicController.h
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#include "CustomNaviBarView.h"
#include "CustomViewController.h"

@interface BgMusicController : CustomViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL animating;
@property (nonatomic,assign) BOOL isAddDevice;

@property (nonatomic, readonly) CustomNaviBarView *viewNaviBar;

@end
