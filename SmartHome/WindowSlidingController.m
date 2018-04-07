//
//  WindowSlidingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define windowType @"智能推窗器"

#import "WindowSlidingController.h"

#import "SQLManager.h"
#import "SocketManager.h"
#import "WinOpener.h"
#import "SceneManager.h"
#import "UIViewController+Navigator.h"
#import "ORBSwitch.h"
#import "UIView+Popup.h"

@interface WindowSlidingController ()<ORBSwitchDelegate,TcpRecvDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (nonatomic,strong) NSMutableArray *windowSlidNames;
@property (nonatomic,strong) NSMutableArray *windowSlidIds;

@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (nonatomic,strong) ORBSwitch *switcher;
@end

@implementation WindowSlidingController

-(NSMutableArray *)windowSlidIds
{
    if(!_windowSlidIds)
    {
        _windowSlidIds = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *windowSlid = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < windowSlid.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[windowSlid[i] intValue]];
                if([typeName isEqualToString:windowType])
                {
                    [_windowSlidIds addObject:windowSlid[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_windowSlidIds addObject:[SQLManager singleDeviceWithCatalogID:windowOpener byRoom:self.roomID]];
        }else{
            if (self.deviceid) {
            [_windowSlidIds addObject:self.deviceid];
            }
        }

    }
    return _windowSlidIds;
}
-(NSMutableArray *)windowSlidNames
{
    if(!_windowSlidNames)
    {
        _windowSlidNames = [NSMutableArray array];
        
        for(int i = 0; i < self.windowSlidIds.count; i++)
        {
            int windSlidID = [self.windowSlidIds[i] intValue];
            [_windowSlidNames addObject:[SQLManager deviceNameByDeviceID:windSlidID]];
        }
    }
    return _windowSlidNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSArray *menus = [SQLManager singleProductByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - %@",roomName,windowType];
    [self setNaviBarTitle:self.title];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:windowOpener byRoom:self.roomID];
    [self initSwitcher];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"plugin_off"] activeBackgroundImage:[UIImage imageNamed:@"plugin_on"] frame:CGRectMake(0, 0, SWITCH_SIZE, SWITCH_SIZE)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
    [self.switcher constraintToCenter:SWITCH_SIZE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    
}
#pragma mark  - TCP delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    uint8_t stateOn = 1;/// 表示打开状态
    NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    //场景、设备云端反馈状态cmd：01 ，本地反馈状态cmd：02---->新的tcp场景和设备分开了1、设备：云端反馈的cmd：E3、主机反馈的cmd：50   2、场景：云端反馈的cmd：单个场景E5、批量场景E6，主机反馈的cmd：单个场景的cmd：52、批量场景的cmd：53
    if(proto.cmd == 0x01 || proto.cmd == 0x02){
        self.switcher.isOn = proto.action.state;
    }
    
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == stateOn)) {
        if ([devID intValue]==[self.deviceid intValue]) {
            self.switcher.isOn=proto.action.state;
        }
    }
    
}
@end
