//
//  NewColourCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/19.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewColourCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"

@implementation NewColourCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
 
//   [IOManager removeTempFile];
    [self.colourSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.colourSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.colourSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
//    self.colourSlider.layer.borderWidth = 3;
    //设置结点左边背景
    UIImage *trackLeftImage = [[UIImage imageNamed:@"corSlider"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.colourSlider setMinimumTrackImage:trackLeftImage forState:UIControlStateNormal];
    //设置结点右边背景
    UIImage *trackRightImage = [[UIImage imageNamed:@"corSlider"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.colourSlider setMaximumTrackImage:trackRightImage forState:UIControlStateNormal];
    [self.AddColourLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
    [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
    if (ON_IPAD) {
        self.SupImageViewHeight.constant = 85;
        self.colourNameLabel.font = [UIFont systemFontOfSize:17];
       [self.AddColourLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
    }
}
-(void) query:(NSString *)deviceid delegate:(id)delegate
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=delegate;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
- (IBAction)save:(id)sender {
     _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        Light *device=[[Light alloc] init];
    
    if (sender == self.colourBtn) {
        if (ON_IPAD) {
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddColourLightBtn.selected = YES;
        self.colourBtn.selected = !self.colourBtn.selected;
        if (self.colourBtn.selected) {
            [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
        }else{
            
            [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
        }
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.colourBtn.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onColourSwitchBtnClicked:deviceID:)]) {
            [_delegate onColourSwitchBtnClicked:self.colourBtn deviceID:self.deviceid.intValue];
        }
        
    }else if (sender == self.AddColourLightBtn){
        self.AddColourLightBtn.selected = !self.AddColourLightBtn.selected;
        if (self.AddColourLightBtn.selected) {
            
            if (ON_IPAD) {
                 [self.AddColourLightBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
            
        }else{
            
            if (ON_IPAD) {
                 [self.AddColourLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:[self.deviceid intValue]];
            [_scene setDevices:devices];
             [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        }
        
    }else if (sender == self.colourSlider){
        if (ON_IPAD) {
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddColourLightBtn.selected = YES;

    }if (self.AddColourLightBtn.selected == NO) {
        return;
    }else{
        [device setDeviceID:[self.deviceid intValue]];
        [device setIsPoweron:self.colourBtn.selected];
        [device setColor:@[]];
        [_scene setSceneID:[self.sceneid intValue]];
        [_scene setRoomID:self.roomID];
        [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
        [_scene setReadonly:NO];
        NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
        [_scene setDevices:devices];
        
        [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    }
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01){
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                self.colourBtn.selected = proto.action.state;
            }
//            else if(proto.action.state == 0x1A){
//                int brightness_f = proto.action.RValue;
//                float degree = M_PI*brightness_f/100;
//                self.tranformView.transform = CGAffineTransformMakeRotation(degree);
//            }else if(proto.action.state == 0x1B){
//                self.base.backgroundColor=[UIColor colorWithRed:proto.action.RValue/255.0 green:proto.action.G/255.0  blue:proto.action.B/255.0  alpha:1];
//            }
            
        }
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
