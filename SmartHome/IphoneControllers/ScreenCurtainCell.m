//
//  ScreenCurtainCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ScreenCurtainCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "Amplifier.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"

@implementation ScreenCurtainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//     [IOManager removeTempFile];
   
    [self.AddScreenCurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.ScreenCurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.UPBtn setImage:[UIImage imageNamed:@"icon_up_prd"] forState:UIControlStateHighlighted];
    [self.DownBtn setImage:[UIImage imageNamed:@"icon_dw_prd"] forState:UIControlStateHighlighted];
    [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    
    if (ON_IPAD) {
        
        self.upBtnLeadingConst.constant = 100;
        self.downBtnConst.constant = 100;
        self.upBtnConstraint.constant = 100;
        self.downBtnConstraint.constant = 100;
        self.ImageSupViewHeightConstraint.constant = 85;
        self.stopBtnHeightConst.constant = 60;
        self.ScreenCurtainLabel.font = [UIFont systemFontOfSize:17];
        [self.UPBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_selete_nol"] forState:UIControlStateNormal];
        [self.DownBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_selete_nol"] forState:UIControlStateNormal];
        [self.stopBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_selete_nol"] forState:UIControlStateNormal];
        [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
      
    }
}
-(void) query:(NSString *)deviceid
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    //sock.delegate=self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
- (IBAction)save:(id)sender {
     _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        Amplifier *device=[[Amplifier alloc] init];
    if (sender == self.ScreenCurtainBtn) {
        [[DeviceInfo defaultManager] playVibrate];
        
        if (ON_IPAD) {
            [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.ScreenCurtainBtn.selected = YES;
        self.ScreenCurtainBtn.selected = !self.ScreenCurtainBtn.selected;
        if (self.ScreenCurtainBtn.selected) {
            [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }else{
            
            [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
            NSData *data=[[DeviceInfo defaultManager] toogle:device.waiting deviceID:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }else if (sender == self.AddScreenCurtainBtn){
        self.AddScreenCurtainBtn.selected = !self.AddScreenCurtainBtn.selected;
        if (self.AddScreenCurtainBtn.selected) {
            if (ON_IPAD) {
                 [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
        }else{
           
            if (ON_IPAD) {
                   [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:[self.deviceid intValue]];
            [_scene setDevices:devices];
             [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        }
    }
    if (self.AddScreenCurtainBtn.selected == NO) {
        return;
    }else{
        [device setDeviceID:[self.deviceid intValue]];
        [device setWaiting: self.ScreenCurtainBtn.selected];
        [_scene setSceneID:[self.sceneid intValue]];
        [_scene setRoomID:self.roomID];
        [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
        [_scene setReadonly:NO];
        NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
        [_scene setDevices:devices];
        
        [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    }
  
}
//升
- (IBAction)upBtn:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] upScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];//up
    
    if (_delegate && [_delegate respondsToSelector:@selector(onUPBtnClicked:)]) {
        [_delegate onUPBtnClicked:sender];
    }
}
//降
- (IBAction)downBtn:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] downScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDownBtnClicked:)]) {
        [_delegate onDownBtnClicked:sender];
    }
}
//停
- (IBAction)stopBtn:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    self.stopBtn.selected = !self.stopBtn.selected;
    if (self.stopBtn.selected) {
        
        [self.stopBtn setImage:[UIImage imageNamed:@"icon_stp_nol"] forState:UIControlStateNormal];
        NSData *data = [[DeviceInfo defaultManager] drop:self.stopBtn.selected deviceID:self.deviceid];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
    }else{
        [self.stopBtn setImage:[UIImage imageNamed:@"icon_st_nol"] forState:UIControlStateNormal];
        NSData *data = [[DeviceInfo defaultManager] stopScreenByDeviceID:self.deviceid];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onStopBtnClicked:)]) {
        [_delegate onStopBtnClicked:sender];
    }
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
//            self.switcher.isOn=proto.action.state;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
