//
//  CameraController.h
//  SmartHome
//
//  Created by Brustar on 16/6/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "RTSPPlayer.h"

@interface CameraController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;

@property (nonatomic,strong) RTSPPlayer *video;
@property (nonatomic,assign) int roomID;
@property (nonatomic) float lastFrameTime;
@property (nonatomic,assign) BOOL isAddDevice;

@end
