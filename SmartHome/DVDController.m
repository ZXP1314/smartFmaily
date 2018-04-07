//
//  DVDController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DVDController.h"
#import "DVD.h"
#import "SceneManager.h"
#import "DVCollectionViewCell.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "IphoneRoomView.h"
#import "SQLManager.h"
#import "PackManager.h"
#import "Light.h"
#import "UIViewController+Navigator.h"

@interface DVDController ()<IphoneRoomViewDelegate>
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnPop;
@property (weak, nonatomic) IBOutlet UIButton *btnUP;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet UIView *IRContainer;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevoius;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRight;
@end

@implementation DVDController

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager singleDeviceWithCatalogID:DVDtype byRoom:self.roomID];
    }
 
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    int index = 0,i = 0;
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
        if (device.hTypeId == DVDtype) {
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
    self.title = [NSString stringWithFormat:@"%@ - DVD",roomName];
    [self setNaviBarTitle:self.title];
    [self initSlider];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainer.hidden = NO;
    }
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    volume.upBlock = ^{
        self.volume.value += 0.01;
        NSData *data = [[DeviceInfo defaultManager] volumeUp:self.deviceid];
        [sock.socket writeData:data withTimeout:1 tag:1];
    };
    volume.downBlock = ^{
        self.volume.value -= 0.01;
        NSData *data = [[DeviceInfo defaultManager] volumeDown:self.deviceid];
        [sock.socket writeData:data withTimeout:1 tag:1];
    };
    [volume start:self.view];
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.voiceLeft.constant = self.voiceRight.constant = 100;
        self.controlLeft.constant = self.controlRight.constant = 150;
        self.controlBottom.constant = 160;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSlider
{
    [self.volume setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.volume.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.volume.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    self.volume.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.volume.value=proto.action.RValue/100.0;
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",proto.action.RValue];
            }
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        //DeviceInfo *device=[DeviceInfo defaultManager];
        //self.volume.value=[[device valueForKey:@"volume"] floatValue];
        //[self changeVolume];
    }
}

-(IBAction)control:(id)sender
{
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    UIButton *btn =(UIButton *)sender;
    
    switch (btn.tag) {
        case 0:
            data=[device backward:self.deviceid];
            break;
        case 1:
            btn.selected = !btn.selected;
            if (btn.selected) {
                data=[device play:self.deviceid];
            }else{
                data=[device pause:self.deviceid];
            }
            //[self poweroffAllLighter];
            break;
        case 2:
            data=[device forward:self.deviceid];
            break;
        case 3:
            data=[device previous:self.deviceid];
            break;
        case 4:
            data=[device pause:self.deviceid];
            //[self poweronAllLighter];
            break;
        case 5:
            data=[device next:self.deviceid];
            break;
        case 6:
            data=[device stop:self.deviceid];
            break;
        case 7:
            data=[device pop:self.deviceid];
            //[self poweronAllLighter];
            break;
        case 8:
            data=[device home:self.deviceid];
            break;
        case 9:
            data=[device menu:self.deviceid];
            break;
        case 10:
            data=[device sweepSURE:self.deviceid];
            break;
        case 11:
            data=[device sweepUp:self.deviceid];
            break;
        case 12:
            data=[device sweepLeft:self.deviceid];
            break;
        case 13:
            data=[device sweepDown:self.deviceid];
            break;
        case 14:
            data=[device sweepRight:self.deviceid];
            break;
        case 15:
        {
            int value = [self.voiceValue.text intValue]-1;
            if (value>=0) {
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
            }
            
            data=[device volumeDown:self.deviceid];
            break;
        }
        case 16:
        {
            int value = [self.voiceValue.text intValue]+1;
            if (value<=100) {
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
            }
            data=[device volumeUp:self.deviceid];
            break;
        }
        default:
            break;
    }
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume stop];
}

-(void) dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

@end
