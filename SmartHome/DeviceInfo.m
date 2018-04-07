//
//  IBeacon.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"
#import "PackManager.h"
#import "MBProgressHUD+NJ.h"
#import "FMDatabase.h"
#import "SQLManager.h"

@implementation DeviceInfo

+ (instancetype)defaultManager
{
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+(UIViewController *)calcController:(NSUInteger)uid
{
    
    NSString *targetName=@"";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    
    switch (uid) {
        case light:
            targetName = @"LightController";
            break;
            
        case dimmarLight:
            targetName = @"LightController";
            break;
            
        case colorLight:
            targetName = @"LightController";
            break;
            
        case curtain:
            targetName = @"CurtainController";
            break;
            
        case DVDtype:
            targetName = @"DVDController";
            break;
        case TVtype:
            targetName = @"TVController";
            break;
        case FM:
            targetName = @"FMController";
            break;
        case amplifier:
            targetName = @"AmplifierController";
            break;
        case projector:
            targetName = @"ProjectorController";
            break;
        case screen:
            targetName = @"ScreenController";
            break;
        case bgmusic:
            targetName = @"BgMusicController";
            break;
            
        case plugin:
            targetName = @"PluginController";
            break;
        case windowOpener:
            targetName = @"WindowSlidingController";
            break;
        case flowering:
            targetName = @"FloweringController";
            break;
        case feeding:
            targetName = @"FeedingController";
            break;
        case doorclock:
            targetName = @"GuardController";
            break;
        case Wetting:
            targetName = @"WettingController";
            break;
        case air:
            targetName = @"AirController";
            break;
        case newWind:
            targetName = @"NewWindController";
            break;
            
        default:
            break;
    }
    return [storyboard instantiateViewControllerWithIdentifier:targetName];
}

-(void)initConfig
{
    NSString  *oldVersion = [UD objectForKey:@"AppVersion"];
    NSString *oldVersionStr = [oldVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *newVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *newVersionStr = [newVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    if ([newVersionStr intValue] > [oldVersionStr intValue] && oldVersion.length > 0) {
        NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:SMART_DB];
        [IOManager removeFile:dbPath];
        
        [UD removeObjectForKey:@"AuthorToken"];
        [UD removeObjectForKey:@"room_version"];
        [UD removeObjectForKey:@"equipment_version"];
        [UD removeObjectForKey:@"scence_version"];
        [UD removeObjectForKey:@"tv_version"];
        [UD removeObjectForKey:@"fm_version"];
        [UD removeObjectForKey:@"source_version"];
        [UD synchronize];
        
    }
    
    [IOManager writeUserdefault:newVersion forKey:@"AppVersion"];
    
    //创建sqlite数据库及结构
    [SQLManager initSQlite];
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
} 

//取设备机型
- (void) deviceGenaration
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    self.genaration = iPhone;
    if ([deviceString isEqualToString:@"iPhone1,2"])    self.genaration = iPhone3G;
    if ([deviceString isEqualToString:@"iPhone2,1"])    self.genaration = iPhone3GS;
    if ([deviceString isEqualToString:@"iPhone3,1"])    self.genaration = iPhone4;
    if ([deviceString isEqualToString:@"iPhone4,1"])    self.genaration = iPhone4S;
    if ([deviceString isEqualToString:@"iPhone5,2"] || [deviceString isEqualToString:@"iPhone5,2"])    self.genaration = iPhone5;
    if ([deviceString isEqualToString:@"iPhone5,3"] || [deviceString isEqualToString:@"iPhone5,4"])   self.genaration = iPhone5C;
    if ([deviceString isEqualToString:@"iPhone6,1"] || [deviceString isEqualToString:@"iPhone6,2"])   self.genaration = iPhone5S;
    if ([deviceString isEqualToString:@"iPhone8,4"])  self.genaration = iPhoneSE;
    if ([deviceString isEqualToString:@"iPhone7,1"])   self.genaration = iPhone6Plus;
    if ([deviceString isEqualToString:@"iPhone7,2"])    self.genaration = iPhone6;
    if ([deviceString isEqualToString:@"iPhone8,1"])    self.genaration = iPhone6S;
    if ([deviceString isEqualToString:@"iPhone8,2"])    self.genaration = iPhone6SPlus;
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])   self.genaration = iPhone7;
    if ([deviceString isEqualToString:@"iPhone9,2"])   self.genaration = iPhone7Plus;
    if ([deviceString isEqualToString:@"iPhone9,3"])   self.genaration = iPhone7;
    if ([deviceString isEqualToString:@"iPhone9,4"])   self.genaration = iPhone7Plus;
    if ([deviceString isEqualToString:@"iPhone10,1"])  self.genaration = iPhone8;
    if ([deviceString isEqualToString:@"iPhone10,4"])  self.genaration = iPhone8Plus;
    if ([deviceString isEqualToString:@"iPhone10,2"])  self.genaration = iPhone8;
    if ([deviceString isEqualToString:@"iPhone10,5"])  self.genaration = iPhone8Plus;
    if ([deviceString isEqualToString:@"iPhone10,3"])  self.genaration = iPhoneX;
    if ([deviceString isEqualToString:@"iPhone10,6"])  self.genaration = iPhoneX;
    
    if ([deviceString isEqualToString:@"iPod1,1"])      self.genaration = iPod;
    if ([deviceString isEqualToString:@"iPod2,1"])      self.genaration = iPod2;
    if ([deviceString isEqualToString:@"iPod3,1"])      self.genaration = iPod3;
    if ([deviceString isEqualToString:@"iPod4,1"])      self.genaration = iPod4;
    if ([deviceString isEqualToString:@"iPod5,1"])      self.genaration = iPod5;
    
    if ([deviceString isEqualToString:@"iPad1,1"])      self.genaration = iPad;
    if ([deviceString isEqualToString:@"iPad2,1"] || [deviceString isEqualToString:@"iPad2,2"] || [deviceString isEqualToString:@"iPad2,3"] || [deviceString isEqualToString:@"iPad2,4"])      self.genaration = iPad2;
    if ([deviceString isEqualToString:@"iPad2,5"] || [deviceString isEqualToString:@"iPad2,6"] || [deviceString isEqualToString:@"iPad2,7"] )      self.genaration = iPadMini;
    if ([deviceString isEqualToString:@"iPad3,1"] || [deviceString isEqualToString:@"iPad3,2"] || [deviceString isEqualToString:@"iPad3,3"])
        self.genaration = iPad3;
    if( [deviceString isEqualToString:@"iPad3,4"] || [deviceString isEqualToString:@"iPad3,5"] || [deviceString isEqualToString:@"iPad3,6"])      self.genaration = iPad4;
    if ([deviceString isEqualToString:@"iPad4,1"] || [deviceString isEqualToString:@"iPad4,2"] || [deviceString isEqualToString:@"iPad4,3"])    self.genaration = iPadAir;
    if ([deviceString isEqualToString:@"iPad5,3"] || [deviceString isEqualToString:@"iPad5,4"])      self.genaration = iPadAir2;
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      self.genaration = iPadMini2;
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      self.genaration = iPadMini3;
    
    if ([deviceString isEqualToString:@"iPad6,3"] || [deviceString isEqualToString:@"iPad6,4"] || [deviceString isEqualToString:@"iPad6,7"] || [deviceString isEqualToString:@"iPad6,8"]) self.genaration = iPadPro;

    NSLog(@"NOTE: device type: %@", deviceString);
}

-(NSData *)startScenenAtMaster:(int)sceneid
{
    NSString *snumber=[SQLManager getSnumber:sceneid];
    uint16_t sid=[PackManager NSDataToUint16:snumber];
    
    uint8_t cmd=0x89;//场景控制的cmd(本地和云端都是同一个cmd)新的tcp的cmd：本地02、云端05
    Proto proto=createProto();
    proto.cmd=cmd;
    proto.deviceID=CFSwapInt16BigToHost(sid);
    proto.deviceType=cmd;
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;//设备本地控制的cmd新的tcp的cmd：本地01、云端04
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;//设备云端控制的cmd
    }
    proto.action.state=action;

    proto.deviceType=BGMUSIC_DEVICE_TYPE;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action value:(uint8_t)value
{
    NSData *data = [self action:action];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=value;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;//设备本地控制的cmd新的tcp的cmd：本地01、云端04
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;//设备云端控制的cmd
    }
    proto.action.state=action;
    NSString *enumber=[SQLManager getENumber:[deviceID integerValue]];
    NSString *eid=[SQLManager getEType:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=value;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.B=roomID;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID deviceType:(uint8_t)deviceType
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.deviceType=deviceType;
    return dataFromProtocol(proto);
}
-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value roomID:(uint8_t)roomID
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=value;
    proto.action.B=roomID;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=red;
    proto.action.B=blue;
    proto.action.G=green;

    return dataFromProtocol(proto);
}

-(NSData *) author
{
    Proto proto=createProto();
    if (self.connectState==outDoor) {
        if (self.masterPort == [IOManager tcpPort]) {
            proto.cmd=0x82;//APP获取服务器IP新的tcp的cmd：20
        }else{
            proto.cmd=0x85;//APP连云端认证新的tcp的cmd：22
        }
    }else if (self.connectState==atHome){
        proto.cmd=0x84;//APP连主机认证新的tcp的cmd：21
    }
    proto.version = PROTOCOL_VERSION;
    NSData* bytesData = [[UD objectForKey:@"mac_address"] dataUsingEncoding:NSUTF8StringEncoding];
//    Byte * myByte = (Byte *)[bytes bytes];
    NSString *dataStr = [[NSString alloc] initWithData:bytesData encoding:NSUTF8StringEncoding];
    int j = 0;
//    Byte bytes[6];
    for (int i=0; i<[dataStr length]; i++) {
        int int_ch;///两位16禁止数转话后的10进制
        unichar hex_char1 = [dataStr characterAtIndex:i];///两位16进制数中的第一个（高伟*16）
        int int_ch1;
        if(hex_char1>='0' && hex_char1 <= '9'){
            int_ch1 = (hex_char1-48)*16;////0 的ASCII-48
        }else if(hex_char1 >='A' && hex_char1 <='F'){
            int_ch1 = (hex_char1-55)*16;//// A 的 ASCII-65
        }else {
            int_ch1 = (hex_char1-87)*16;///a的ASCII-97
        }
        i++;
        unichar hex_char2 = [dataStr characterAtIndex:i];//两位16进制数中的第二位（低位）
        int int_ch2;
        if(hex_char2>='0' && hex_char2<='9'){
            int_ch2 = (hex_char2-48);
        }else if(hex_char2 >='A' && hex_char2 <='F'){
            int_ch2 = hex_char2-55;
        }else{
            int_ch2 = hex_char2-87;
        }
        int_ch = int_ch1+int_ch2;
        proto.macAddress[j] = int_ch;///将转化后的数放入Byte数组里
        j++;
    }
    proto.deviceType=0x00;
    proto.deviceID= CFSwapInt16BigToHost([[UD objectForKey:@"UserID"] integerValue]);//存用户ID，服务端用来统计用户行为数据
    
    proto.action.state=0x00;
    proto.action.RValue = 0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    return dataFromProtocol(proto);
}

-(NSData *)query:(NSString *)deviceID
{
    Proto proto=createProto();

    proto.cmd=0x9A;//查询单个设备的状态新的tcp的cmd：10
    
    NSString *enumber=[SQLManager getENumber:[deviceID integerValue]];
    NSString *eid=[SQLManager getEType:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}
-(NSData *)heartbeat
{
    Proto proto=createProto();
    proto.cmd=0x31;//心跳指令cmd：31
    proto.masterID = CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue]);
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    proto.deviceType = 0x00;
    return dataFromProtocol(proto);
    
}
//查询场景的状态
-(NSData *)inquiry:(NSArray *)sceneArr sceneCount:(int)sceneCount
{
    Proto proto=createProto();
    proto.cmd=0xA0;//批量查询场景的状态新的tcp的cmd：13
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    return dataFromProtocol(proto);
}

-(NSData *)query:(NSString *)deviceID withRoom:(uint8_t)rid
{
    Proto proto=createProto();
    
    proto.cmd=0x9A;//查询单个设备的状态新的tcp的cmd：10
    
    NSString *enumber=[SQLManager getENumber:[deviceID integerValue]];
    NSString *eid=[SQLManager getEType:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=rid;
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) scheduleScene:(uint8_t)action sceneID:(NSString *)sceneID
{
    return [self schedule:action dID:[sceneID intValue] type:0x60];//0x60 是指定时器类型为场景定时
}

-(NSData *) scheduleDevice:(uint8_t)action deviceID:(NSString *)deviceID
{
    NSString *enumber=[SQLManager getENumber:[deviceID integerValue]];
    uint16_t dID = [PackManager NSDataToUint16:enumber];
    return [self schedule:action dID:dID type:0x61];//0x61 是指定时器类型为设备定时
}

-(NSData *) schedule:(uint8_t)action dID:(uint16_t)dID type:(uint8_t)dtype
{
    Proto proto = createProto();
    proto.cmd = 0x8A;//获取温度、湿度、PM2.5
    proto.action.state = action;
    proto.action.RValue = 0x00;
    proto.action.G = 0x00;
    proto.action.B = 0x00;
    
    proto.deviceID = CFSwapInt16BigToHost(dID);
    proto.deviceType = dtype;
    return dataFromProtocol(proto);
}

#pragma mark - public
//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PREVIOUS deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PREVIOUS];
    }
}

-(NSData *) forward:(NSString *)deviceID
{
    return [self action:PROTOCOL_FORWARD deviceID:deviceID];
}

-(NSData *) backward:(NSString *)deviceID
{
    return [self action:PROTOCOL_BACKWARD deviceID:deviceID];
}

-(NSData *) next:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_NEXT deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_NEXT];
    }
}

-(NSData *) play:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PLAY deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PLAY];
    }
}

-(NSData *) pause:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PAUSE deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PAUSE];
    }
}

-(NSData *) stop:(NSString *)deviceID
{
    return [self action:PROTOCOL_STOP deviceID:deviceID];
}
-(NSData *) ON:(NSString *)deviceID
{
    return [self action:PROTOCOL_ON deviceID:deviceID];
}
-(NSData *) OFF:(NSString *)deviceID
{
   return [self action:PROTOCOL_OFF deviceID:deviceID];
}
-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_VOLUME deviceID:deviceID value:percent];
    }else{
        return [self action:PROTOCOL_VOLUME value:percent];
    }
}

- (NSData *)changeSource:(uint8_t)channelID deviceID:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_SOURCE deviceID:deviceID value:channelID];
    }else{
        return [self action:PROTOCOL_SOURCE value:channelID];
    }
}

-(NSData *) mute:(NSString *)deviceID
{
    return [self action:PROTOCOL_MUTE deviceID:deviceID];
}

-(NSData *) volumeUp:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME_UP deviceID:deviceID];
}

-(NSData *) volumeDown:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME_DOWN deviceID:deviceID];
}

//TV,DVD,NETV
-(NSData *) sweepLeft:(NSString *)deviceID
{
    return [self action:PROTOCOL_LEFT deviceID:deviceID];
}

-(NSData *) sweepRight:(NSString *)deviceID
{
    return [self action:PROTOCOL_RIGHT deviceID:deviceID];
}

-(NSData *) sweepUp:(NSString *)deviceID
{
    return [self action:PROTOCOL_UP deviceID:deviceID];
}

-(NSData *) sweepDown:(NSString *)deviceID
{
    return [self action:PROTOCOL_DOWN deviceID:deviceID];
}
-(NSData *) sweepSURE:(NSString *)deviceID
{
    return [self action:PROTOCOL_SURE deviceID:deviceID];
}

-(NSData *) menu:(NSString *)deviceID
{
    return [self action:PROTOCOL_MENU deviceID:deviceID];
}

#pragma mark - lighter
-(NSData *) toogleLight:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

-(NSData *) changeColor:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue
{
    return [self action:0x1B deviceID:deviceID R:red G:green B:blue];
}

-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID
{
    return [self action:0x1a deviceID:deviceID value:bright];
}

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0x2A deviceID:deviceID value:percent];
}

-(NSData *) open:(NSString *)deviceID
{
    return [self action:0x01 deviceID:deviceID];
}

-(NSData *) close:(NSString *)deviceID
{
    return [self action:0x00 deviceID:deviceID];
}

#pragma mark - TV
-(NSData *) nextProgram:(NSString *)deviceID
{
    return [self action:0x18 deviceID:deviceID];
}

-(NSData *) previousProgram:(NSString *)deviceID
{
    return [self action:0x17 deviceID:deviceID];
}

-(NSData *) switchProgram:(uint16_t)program deviceID:(NSString *)deviceID
{
    uint8_t r = program/256;
    uint8_t g = program%256;
    return [self action:0x3A deviceID:deviceID R:r G:g B:0];
}

-(NSData *) changeTVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0xAA deviceID:deviceID value:percent];
}

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID
{
    return [self action:0x11 deviceID:deviceID];
}

-(NSData *) pop:(NSString *)deviceID
{
    return [self action:0x20 deviceID:deviceID];
}

#pragma mark - NETV
-(NSData *) NETVhome:(NSString *)deviceID
{
    return [self action:0x11 deviceID:deviceID];
}

-(NSData *) back:(NSString *)deviceID
{
    return [self action:0x10 deviceID:deviceID];
}

-(NSData *) confirm:(NSString *)deviceID
{
    return [self action:0x09 deviceID:deviceID];
}

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program dec:(uint8_t)dec deviceID:(NSString *)deviceID
{
    return [self action:0x3A deviceID:deviceID R:program G:dec B:0x00];
}

#pragma mark - Guard / Projector
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

#pragma mark - Screen
-(NSData *) drop:(uint8_t)droped deviceID:(NSString *)deviceID
{
    return [self action:0x34-droped deviceID:deviceID];
}

//降幕布
-(NSData *) downScreenByDeviceID:(NSString *)deviceID
{
    return [self action:0x34 deviceID:deviceID];
}

//升幕布
-(NSData *) upScreenByDeviceID:(NSString *)deviceID
{
    return [self action:0x33 deviceID:deviceID];
}

//停止幕布
-(NSData *) stopScreenByDeviceID:(NSString *)deviceID
{
    return [self action:0x32 deviceID:deviceID];
}

//停止C4窗帘
- (NSData *)stopCurtainByDeviceID:(NSString *)deviceID
{
    return [self action:0x32 deviceID:deviceID];
}


#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}
-(NSData *) changeTemperature:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)temperature
{
    return [self action:action deviceID:deviceID value:temperature];
}
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID
{
    return [self action:direct deviceID:deviceID];
}
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID
{
    return [self action:speed deviceID:deviceID];
}
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID
{
    return [self action:mode deviceID:deviceID];
}
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID
{
    return [self action:interval deviceID:deviceID];
}

-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    return [self action:toogle deviceID:deviceID roomID:roomID];
}
-(NSData *) changeTemperature:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)temperature  roomID:(uint8_t)roomID
{
    return [self action:action deviceID:deviceID value:temperature roomID:roomID];
}
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    return [self action:direct deviceID:deviceID roomID:roomID];
}
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    return [self action:speed deviceID:deviceID roomID:roomID];
}
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    return [self action:mode deviceID:deviceID roomID:roomID];
}
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID roomID:(uint8_t)roomID
{
    return [self action:interval deviceID:deviceID roomID:roomID];
}

#pragma mark - Fresh Air
-(NSData *) toogleFreshAir:(uint8_t)toogle deviceID:(NSString *)deviceID deviceType:(uint8_t)deviceType
{
    return [self action:toogle deviceID:deviceID deviceType:deviceType];
}
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID deviceType:(uint8_t)deviceType
{
    return [self action:speed deviceID:deviceID deviceType:deviceType];
}
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID deviceType:(uint8_t)deviceType
{
    return [self action:mode deviceID:deviceID deviceType:deviceType];
}

#pragma mark - bgmusic
-(NSData *) repeat:(NSString *)deviceID
{
    return [self action:0x45 deviceID:deviceID];
}


-(NSData *) shuffle:(NSString *)deviceID
{
    return [self action:0x46 deviceID:deviceID];
}

- (void)playVibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
