//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "public.h"
#import "SceneManager.h"
#import "Light.h"
#import "ColourTableViewCell.h"
#import "Device.h"
#import "SocketManager.h"
#import "CustomNaviBarView.h"
#import "CustomViewController.h"

#define MAX_ROTATE_DEGREE 175

@interface LightController : CustomViewController<TcpRecvDelegate>

@property (nonatomic, readonly) CustomNaviBarView *viewNaviBar;

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;
@property (weak, nonatomic) IBOutlet UIButton *sLightBtn;
@property (weak, nonatomic) IBOutlet UIButton *ddLightBtn;
@property (weak, nonatomic) IBOutlet UIButton *cLightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightTitleBottomConstraint;

-(void)visibleUI:(Device *)device;

@end
