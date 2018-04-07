//
//  CurtainTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainTableViewCell.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"


@interface CurtainTableViewCell ()


@end
@implementation CurtainTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.slider.continuous = NO;
    [self.slider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.open addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.close addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddcurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [self.slider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    self.slider.userInteractionEnabled = ![[UD objectForKey:@"HostType"] intValue];
    [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
    [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
    if (ON_IPAD) {
        self.supImageViewHeight.constant = 85;
        self.label.font = [UIFont systemFontOfSize:17];
        [self.AddcurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
    }
}

-(void) query:(NSString *)deviceid delegate:(id)delegate
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate= delegate;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(IBAction)save:(id)sender
{
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    Curtain *device=[[Curtain alloc] init];
    if ([sender isEqual:self.slider]) {
        if (ON_IPAD) {
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddcurtainBtn.selected = YES;
        if (self.slider.value > 0) {
            self.open.selected = YES;
        }else{
            self.open.selected = NO;
        }
        NSData *data=[[DeviceInfo defaultManager] roll:self.slider.value * 100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onCurtainSliderBtnValueChanged:deviceID:)]) {
            [_delegate onCurtainSliderBtnValueChanged:self.slider deviceID:self.deviceid.intValue];
        }
    }
    
    if ([sender isEqual:self.open]) {
        [[DeviceInfo defaultManager] playVibrate];
        if (ON_IPAD) {
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddcurtainBtn.selected = YES;
        self.open.selected = !self.open.selected;
        if (self.open.selected) {
            self.slider.value=1;
//            [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
        }else{
            self.slider.value=0;
//            [self.open setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
        }
        NSData *data=[[DeviceInfo defaultManager] toogle:self.open.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onCurtainOpenBtnClicked:deviceID:)]) {
            [_delegate onCurtainOpenBtnClicked:self.open deviceID:self.deviceid.intValue];
        }
    }
  
    
    if ([sender isEqual:self.open]) {
        [device setOpenvalue:100];
    }
   
    if ([sender isEqual:self.AddcurtainBtn]) {
        
        self.AddcurtainBtn.selected = !self.AddcurtainBtn.selected;
        NSLog(@"%d",self.AddcurtainBtn.selected);
        if (self.AddcurtainBtn.selected) {
            if (ON_IPAD) {
                [self.AddcurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
           
        }else{
            
            if (ON_IPAD) {
                 [self.AddcurtainBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddcurtainBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:[self.deviceid intValue]];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        }
      
    }if (self.AddcurtainBtn.selected == NO) {
        return;
    }else{
        [device setDeviceID:[self.deviceid intValue]];
        [device setOpenvalue:self.slider.value * 100];
        [_scene setSceneID:[self.sceneid intValue]];
        [_scene setRoomID:self.roomID];
        [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
        [_scene setReadonly:NO];
        NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
        [_scene setDevices:devices];
        [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    }
}


- (IBAction)brightValueChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f%%",self.slider.value *100];
    if([self.open isSelected])
    {
        self.valueLabel.text = @"100%";
        
    }
    if([self.close isSelected])
    {
        self.valueLabel.text = @"0%";
    }
}

- (IBAction)AddcurtainBtn:(id)sender {
    

}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01 && proto.action.state == 0x2A){
        self.slider.value = proto.action.RValue/100.0;
        NSString *icon = self.slider.value == 0 ? @"bd_icon_wd_off": @"bd_icon_wd_on";
        [self.open setImage:[UIImage imageNamed: icon] forState:UIControlStateNormal];
    }
    
    if (tag==0 && (proto.action.state == 0x2A || proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        
//        if (devID==[self.deviceid intValue]) {
            self.slider.value=proto.action.RValue/100.0;
            if (proto.action.state == PROTOCOL_ON) {
                self.slider.value=1;
//            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
