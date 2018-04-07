//
//  ScreenCurtainController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScreenCurtainController.h"
#import "IphoneRoomView.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Amplifier.h"
#import "Scene.h"
#import "SceneManager.h"
#import "UIViewController+Navigator.h"

@interface ScreenCurtainController ()<IphoneRoomViewDelegate>

@property (nonatomic,strong) NSMutableArray *screenCurtainNames;
@property (nonatomic,strong) NSMutableArray *screenCurtainIds;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet UIButton *btnUP;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;

@end

@implementation ScreenCurtainController

-(NSMutableArray *)screenCurtainIds
{
    if(!_screenCurtainIds)
    {
        _screenCurtainIds = [NSMutableArray array];
        if(self.sceneid > 0 && !_isAddDevice )
        {
            NSArray *screenCurtain = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < screenCurtain.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[screenCurtain[i] intValue]];
                if([typeName isEqualToString:@"幕布"])
                {
                    [_screenCurtainIds addObject:screenCurtain[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_screenCurtainIds addObject:[SQLManager singleDeviceWithCatalogID:amplifier byRoom:self.roomID]];
        }else{
            [_screenCurtainIds addObject:self.deviceid];
        }
    }
    return _screenCurtainIds;
}
-(NSMutableArray *)screenCurtainNames
{
    if(!_screenCurtainNames)
    {
        _screenCurtainNames = [NSMutableArray array];
        for(int i = 0; i < self.screenCurtainIds.count; i++)
        {
            int screenCurtainID = [self.screenCurtainIds[i] intValue];
            [_screenCurtainNames addObject:[SQLManager deviceNameByDeviceID:screenCurtainID]];
        }
 
    }
    return _screenCurtainNames;
}

- (IBAction)upBtnAction:(UIButton *)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] upScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)stopBtnAction:(UIButton *)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] stopScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)downBtnAction:(UIButton *)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] downScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    int index = 0,i = 0;
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
        if (device.hTypeId == screen) {
            index = i;
        }
        i++;
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 40)];
    
    menu.dataArray = deviceNames;
    menu.delegate = self;
    
    [menu setSelectButton:index];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 幕布",roomName];
    [self setNaviBarTitle:self.title];
    self.deviceid =[SQLManager singleDeviceWithCatalogID:screen byRoom:self.roomID];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    [self.btnPause setImage:[UIImage imageNamed:@"screen_pause_red"] forState:UIControlStateHighlighted];
    [self.btnUP setImage:[UIImage imageNamed:@"screen_up_red"] forState:UIControlStateHighlighted];
    [self.btnDown setImage:[UIImage imageNamed:@"screen_down_red"] forState:UIControlStateHighlighted];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(IBAction)save:(id)sender
{
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
