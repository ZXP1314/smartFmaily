//
//  PluginViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "UIView+Popup.h"
#import "PluginViewController.h"
#import "SocketManager.h"
#import "UIViewController+Navigator.h"
#import "PackManager.h"
#import "PluginCell.h"
#import "SQLManager.h"
#import "SceneManager.h"
#import "Plugin.h"
#import "ORBSwitch.h"


@interface PluginViewController ()<ORBSwitchDelegate,TcpRecvDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
//@property (nonatomic,strong) PluginCell *cell;

@property (nonatomic,strong) ORBSwitch *switcher;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@end

@implementation PluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSArray *menus = [SQLManager singleProductByRoom:self.roomID];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:[[DeviceInfo defaultManager] deviceType] byRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    NSString *deviceName = [SQLManager deviceNameByDeviceID:[self.deviceid intValue]];
    if ([deviceName isEqualToString:@""]) {
        deviceName = @"智能插座";
    }
    self.title = [NSString stringWithFormat:@"%@ - %@",roomName,deviceName];
    [self setNaviBarTitle:self.title];
    if (ON_IPAD) {
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
    
    [self initSwitcher];

    //[self setupSegment];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    
    self.menuContainer.hidden = ON_IPAD;
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"plugin_off"] activeBackgroundImage:[UIImage imageNamed:@"plugin_on"] frame:CGRectMake(0, 0, SWITCH_SIZE, SWITCH_SIZE)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
    [self.switcher constraintToCenter:SWITCH_SIZE];
}

/*
-(void)initHomekitPlugin
{
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
    
    self.devices=[NSMutableArray new];
}

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
    if (manager.primaryHome) {
        self.primaryHome = manager.primaryHome;
        self.primaryHome.delegate = self;
        
        for (HMAccessory *accessory in self.homeManager.primaryHome.accessories) {
            for (HMService *service in accessory.services) {
                if ([service.serviceType isEqualToString:HMServiceTypeOutlet]) {
                    //self.deviceLabel.text=service.name;
                    [self.devices addObject: [NSString stringWithFormat:@"%@(浇花)", service.name]];
                    for (HMCharacteristic *characterstic in service.characteristics) {
                        if ([characterstic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
                            //self.powerSwitch.on=[characterstic.value boolValue];
                            self.characteristic=characterstic;
                        }
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}

-(void)initPlugin
{
    self.devices=[NSMutableArray new];
    [[SocketManager defaultManager] connectUDP:4156 delegate:self];
}

#pragma mark  - UDP delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onUdpSocket:%@",data);
    [self handleUDP:data];
    return YES;
}

-(void)handleUDP:(NSData *)data
{
    NSData *ip=[data subdataWithRange:NSMakeRange(8, 4)];
    SocketManager *sock=[SocketManager defaultManager];
    [sock initTcp:[PackManager NSDataToIP:ip] port:1234 delegate:self];
    
    [self sendCmd:nil];
}
*/
-(IBAction)sendCmd:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    NSString *cmd=@"fe000001000000000100ff";
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:-1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:1];
}

-(void)discoveryDevice:(NSData *)data
{
    [self.devices removeAllObjects];
    //fe01 0001 0016 0002 313710c8a5a505004b1200 98831069354304004b1200 de00ff
    NSData *length=[data subdataWithRange:NSMakeRange(6, 2)];
    for (int i = 0; i<[PackManager dataToUInt16:length]; i++) {
        NSData *addr=[data subdataWithRange:NSMakeRange(8+11*i, 2)];
        //NSData *macAddr=[data subdataWithRange:NSMakeRange(11+11*i, 2)];
        [self.devices addObject:addr];//[NSString stringWithFormat:@"%ld",[PackManager NSDataToUInt:addr] ]];
    }
    //[self.tableView reloadData];
}
/*
-(IBAction)switchHomekitDevice:(id)sender
{

        if ([self.characteristic.characteristicType isEqualToString:HMCharacteristicTypeTargetLockMechanismState]  || [self.characteristic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
            
            BOOL changedLockState = ![self.characteristic.value boolValue];
            
            [self.characteristic writeValue:[NSNumber numberWithBool:changedLockState] completionHandler:^(NSError *error){
                
                if(error != nil){
                    NSLog(@"error in writing characterstic: %@",error);
                }
            }];
        }
}
*/
-(IBAction)switchDevice:(id)sender{
    UISwitch *sw=(UISwitch *)sender;
    /*
    NSString *cmd=@"FE00000000040001";//
    NSMutableData *data=[NSMutableData new];
    [data appendData:[PackManager dataFormHexString:cmd]];
    Byte array[] = {0x00};
    if (sw.on) {
        array[0] = 0x01;
    }
    [data appendBytes:array length:1];
    NSData *addr=[self.devices objectAtIndex:sw.tag];
    [data appendData:addr];
    NSString *tail=@"011e00ff";
    [data appendData:[PackManager dataFormHexString:tail]];
     */
    NSData *data=[[DeviceInfo defaultManager] toogle:sw.on deviceID:_deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:-1 tag:1];
    
}

-(IBAction)save:(id)sender
{
    Plugin *device=[[Plugin alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setSwitchon: self.switcher.isOn];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
}

#pragma mark  - TCP delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    uint8_t stateOn = 1;/// 表示打开状态
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
//    [[SocketManager defaultManager] cutOffSocket];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    
}

@end
