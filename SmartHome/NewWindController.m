//
//  NewWindController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/9/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewWindController.h"
//#import "ContextMenuCell.h"
//#import "AirController.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface NewWindController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headBGCenter;//父视图Y轴对称
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PowerCenterY;//开关Y轴对称
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TemCenterY;//温度LabelY轴对称
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowSpeedBottom;//低速底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highSpeedBottom;//高速底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleSpeedbottom;//中速底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highSpeedLead;//高速左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowSpeedTrail;//低速右边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleSpeedTrail;//中速与右边按钮边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highSpeedTrail;//高速与右边按钮边距

@end

@implementation NewWindController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.roomID = (int)[DeviceInfo defaultManager].roomID;
//    [self setDatasource];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.currentDeviceName.text = [SQLManager deviceNameByDeviceID:[self.deviceID intValue]];
    self.title = [NSString stringWithFormat:@"%@ - 新风",roomName];
//    [self setNaviBarTitle:self.title];
//    if (ON_IPAD) {
//        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
//    }
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:newWind roomID:self.roomID];
    self.deviceID = [NSString stringWithFormat:@"%d", device.eID];
//     [self naviToDevice];
    //查询新风的开关状态，温度
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceID];
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPONE) {
        self.highSpeedBtnLeading.constant = 20;
        self.lowSpeedBtnTrailing.constant = 20;
    }if (ON_IPAD) {
        self.headBGCenter.constant = -100;
        self.PowerCenterY.constant = -110;
        self.TemCenterY.constant = -110;
        self.lowSpeedBottom.constant = 120;
        self.middleSpeedbottom.constant = 120;
        self.highSpeedBottom.constant = 120;
        self.highSpeedLead.constant = 200;
        self.lowSpeedTrail.constant = 200;
        self.middleSpeedTrail.constant = 40;
        self.highSpeedTrail.constant = 40;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
//     [self setDatasource];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)powerBtnClicked:(id)sender {
     UIButton *btn = (UIButton *)sender;
     btn.selected = !btn.selected;
    if (btn.selected) {
        //发开指令  
        NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x01 deviceID:self.deviceID deviceType:0x30];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        //发送风指令
        //data = [[DeviceInfo defaultManager] changeMode:0x41 deviceID:self.deviceID deviceType:0x30];
        //[sock.socket writeData:data withTimeout:1 tag:1];
        
    }else {
        //发关指令
        NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x00 deviceID:self.deviceID deviceType:0x30];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
}

- (IBAction)highSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发高速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x35 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }
    }
}

- (IBAction)middleSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.highSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发中速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x36 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

- (IBAction)lowSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.highSpeedBtn.selected = NO;
            // 发低速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x37 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto = protocolFromData(data); 
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //场景、设备云端反馈状态cmd：01 ，本地反馈状态cmd：02---->新的tcp场景和设备分开了1、设备：云端反馈的cmd：E3、主机反馈的cmd：50   2、场景：云端反馈的cmd：单个场景E5、批量场景E6，主机反馈的cmd：单个场景的cmd：52、批量场景的cmd：53
    if (proto.cmd == 0x01 || proto.cmd == 0x02) {
        
        Device *device = [SQLManager getDeviceWithDeviceHtypeID:newWind roomID:self.roomID];
        NSString *devID = [SQLManager getDeviceIDByENumberForC4:CFSwapInt16BigToHost(proto.deviceID) airID:device.airID htypeID:newWind];
        
        if ([devID intValue] == [self.deviceID intValue]) {
        
            if (proto.action.state == 0x6B) { //当前室内温度
                self.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
            }
        
        
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {  //开关
                self.powerBtn.selected = proto.action.state;
            }
        }
    }
}



@end
