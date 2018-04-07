
//
//  OtherTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "OtherTableViewCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "Amplifier.h"
#import "PackManager.h"

@implementation OtherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//     [IOManager removeTempFile];
    
    [self.OtherSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddOtherBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
      if (ON_IPAD) {
          
          self.NameLabel.font = [UIFont systemFontOfSize:17];
          [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
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
    
    if (sender == self.OtherSwitchBtn) {
        if (ON_IPAD) {
            
            [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            
            [self.AddOtherBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            
        }
        self.AddOtherBtn.selected = YES;
        self.OtherSwitchBtn.selected = !self.OtherSwitchBtn.selected;
        if (self.OtherSwitchBtn.selected) {
            [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }else{
            [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }
        
        if (self.hTypeId == 30) { //新风
          if (self.OtherSwitchBtn.selected) {
            //发开指令
            NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x01 deviceID:self.deviceid deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
            //发送风指令
            data = [[DeviceInfo defaultManager] changeMode:0x41 deviceID:self.deviceid deviceType:0x30];
            [sock.socket writeData:data withTimeout:1 tag:1];
          }else {
              //发关指令
              NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x00 deviceID:self.deviceid deviceType:0x30];
              SocketManager *sock = [SocketManager defaultManager];
              [sock.socket writeData:data withTimeout:1 tag:1];
          }
            
        }else {
           NSData *data = [[DeviceInfo defaultManager] toogle:self.OtherSwitchBtn.selected deviceID:self.deviceid];
           SocketManager *sock = [SocketManager defaultManager];
           [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onOtherSwitchBtnClicked:deviceID:)]) {
            [_delegate onOtherSwitchBtnClicked:self.OtherSwitchBtn deviceID:self.deviceid.intValue];
        }
        
    }else if (sender == self.AddOtherBtn){
        self.AddOtherBtn.selected = !self.AddOtherBtn.selected;
        if (self.AddOtherBtn.selected) {
             if (ON_IPAD) {
                 
                  [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
             }else{
                
                 [self.AddOtherBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
                 
             }
            
        }else{
           
             if (ON_IPAD) {
                 
                  [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
             }else{
                [self.AddOtherBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
             }
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:[self.deviceid intValue]];
            [_scene setDevices:devices];
             [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
           
        }
       
    }
    if (self.AddOtherBtn.selected == NO) {
        return;
    }else{
        [device setDeviceID:[self.deviceid intValue]];
        [device setWaiting: self.OtherSwitchBtn.selected];
        [_scene setSceneID:[self.sceneid intValue]];
        [_scene setRoomID:self.roomID];
        [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
        [_scene setReadonly:NO];
        NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
        [_scene setDevices:devices];
        [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    }
}

- (IBAction)AddOtherBtn:(id)sender {
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
            self.OtherSwitchBtn.selected = proto.action.state;
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
