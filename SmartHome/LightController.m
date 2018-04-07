//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightController.h"
#import "PackManager.h" 
#import "SocketManager.h"
#import "SQLManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "ORBSwitch.h"
#import "UIView+Popup.h"
#import "STColorPicker.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface LightController ()<UITableViewDelegate,UITableViewDataSource,YALContextMenuTableViewDelegate,ORBSwitchDelegate>

@property (nonatomic,assign) CGFloat brightValue;
@property (nonatomic,strong) NSMutableArray *lIDs;
@property (nonatomic,strong) NSMutableArray *lNames;
@property (nonatomic,strong) IBOutlet UIImageView *tranformView;

@property (weak, nonatomic) IBOutlet UIView *base;
@property (weak, nonatomic) IBOutlet UIButton *btnPen;
@property (nonatomic,strong) NSArray *lights;
@property (weak, nonatomic) IBOutlet UILabel *lightName;

@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) long lightCatalog;
@property (nonatomic,strong) YALContextMenuTableView* contextMenuTableView;
@property (nonatomic,strong) ORBSwitch *switcher;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;

@end

@implementation LightController

- (IBAction)pickcolor:(id)sender {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 400.0)];
    view.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    
    STColorPicker *colorPicker = [[STColorPicker alloc] initWithFrame:CGRectMake(0.0, 40.0, 300.0, 350.0)];
    
    [colorPicker setColorHasChanged:^(UIColor *color, CGPoint location) {
        NSLog(@"%@",color);
        [self.base setBackgroundColor:color];
        
        NSDictionary *colorDic = [self getRGBDictionaryByColor:color];
        int r = [colorDic[@"R"] floatValue] * 255;
        int g = [colorDic[@"G"] floatValue] * 255;
        int b = [colorDic[@"B"] floatValue] * 255;
        
        NSData *data=[[DeviceInfo defaultManager] changeColor:self.deviceid R:r G:g B:b];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:3];
        
        [view dismiss];
    }];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 80.0, 35.0)];
    title.text = @"颜色面板";
    [title setFont:[UIFont systemFontOfSize:13.0]];
    
    [title setTextColor:[UIColor blackColor]];

    [view addSubview:title];

    [view addSubview:colorPicker];
    if (ON_IPAD) {
        if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight) {
            view.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else{
            view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    }
    [view show];
}

-(NSMutableArray *)lIDs
{
    if(!_lIDs)
    {
        _lIDs = [NSMutableArray array];
       
           if(self.sceneid > 0 && !self.isAddDevice)
           {
           
               NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
               for(int i = 0; i <lightArr.count; i++)
               {
                   NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
                   if([typeName isEqualToString:@"灯光"])
                   {
                       [_lIDs addObject:lightArr[i]];
                   }
               }
           }else if(self.roomID > 0){
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:SWITCHLIGHT_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:DIMMER_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:COLORLIGHT_SUB_TYPE andRoomID:self.roomID]];

           }else{
               [_lIDs addObject:self.deviceid?self.deviceid:@"0"];
           }
        
        }
    return _lIDs;
}

-(NSMutableArray *)lNames
{
    if(!_lNames)
    {
        _lNames = [NSMutableArray array];
        for(int i = 0; i < self.lIDs.count; i++)
        {
            int lID = [self.lIDs[i] intValue];
            NSString *name = [SQLManager deviceNameByDeviceID:lID];
            [_lNames addObject:name];
        }
    }
    return _lNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 灯光",roomName]];
    [self initSwitch];
    [self showUITypeOfLight];
    Device *device = [SQLManager singleLightByRoom:self.roomID];
    self.deviceid = self.deviceid?self.deviceid:[NSString stringWithFormat:@"%d",device.eID];
    
    NSString *dviceType = [SQLManager getEType:[self.deviceid integerValue]];
    
    self.tranformView.hidden = ![dviceType isEqualToString:@"02"];
    self.base.hidden = ![dviceType isEqualToString:@"03"];
    
    self.lightName.text = device.name;
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.bottom.constant = 125.0;
        self.top.constant = 0;
    }
}

- (void)showUITypeOfLight {
    self.sLightBtn.hidden = YES;
    self.ddLightBtn.hidden = YES;
    self.cLightBtn.hidden = YES;
    
    NSMutableArray *uitypes = [NSMutableArray new];
    [uitypes addObjectsFromArray:[SQLManager getUITypeOfLightByRoomID:self.roomID]];
    [uitypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        NSString *typeName = obj;
        if ([typeName isEqualToString:@"射灯"]) {
            self.sLightBtn.hidden = NO;
        }else if([typeName isEqualToString:@"灯带"]) {
            self.ddLightBtn.hidden = NO;
        }else if ([typeName isEqualToString:@"调色灯"]) {
            self.cLightBtn.hidden = NO;
        }
        
    }];
}

- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{@"R":@(r),
             @"G":@(g),
             @"B":@(b),
             @"A":@(a)};
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    NSLog(@"recv:%@",data);
    Proto proto=protocolFromData(data);
//    Proto proto = dataFromProtocol(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    //场景、设备云端反馈状态cmd：01 ，本地反馈状态cmd：02---->新的tcp场景和设备分开了1、设备：云端反馈的cmd：E3、主机反馈的cmd：50   2、场景：云端反馈的cmd：单个场景E5、批量场景E6，主机反馈的cmd：单个场景的cmd：52、批量场景的cmd：53
    if(proto.cmd == 0x02 || proto.cmd == 0x01){
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        uint8_t stateOn = 1;/// 表示打开状态
        NSLog(@"proto.action.state:%d",proto.action.state);
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == stateOn) {
                self.switcher.isOn = proto.action.state;
            }else if(proto.action.state == 0x1A){
                int brightness_f = proto.action.RValue;
                float degree = M_PI*brightness_f/100;
                self.tranformView.transform = CGAffineTransformMakeRotation(degree);
            }else if(proto.action.state == 0x1B){
                self.base.backgroundColor=[UIColor colorWithRed:proto.action.RValue/255.0 green:proto.action.G/255.0  blue:proto.action.B/255.0  alpha:1];
            }
            
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


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    
    /**
     CGRectGetHeight 返回控件本身的高度
     CGRectGetMinY 返回控件顶部的坐标
     CGRectGetMaxY 返回控件底部的坐标
     CGRectGetMinX 返回控件左边的坐标
     CGRectGetMaxX 返回控件右边的坐标
     CGRectGetMidX 表示得到一个frame中心点的X坐标
     CGRectGetMidY 表示得到一个frame中心点的Y坐标
     */
    
    CGPoint center = CGPointMake(CGRectGetMidX([touch.view bounds]), CGRectGetMidY([touch.view bounds]));
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];//上一个坐标
    
    /**
     求得每次手指移动变化的角度
     atan2f 是求反正切函数 参考:http://blog.csdn.net/chinabinlang/article/details/6802686
     */
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    NSLog(@"angel:=%f,degree:%f",angle,degree);
    if (degree<0) {
        if (angle<0) {
            return;
        }
    }else if (degree>MAX_ROTATE_DEGREE) {
        if (angle>0) {
            return;
        }
    }
    self.tranformView.transform = CGAffineTransformRotate(self.tranformView.transform, angle);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    NSLog(@"degree:%f",degree);
    int percent = degree*100/MAX_ROTATE_DEGREE;
    percent = percent < 0?0:percent;
    percent = percent > 100?100:percent;
    self.tranformView.tag = percent;
    
    if (degree>0) {
        [self.switcher setIsOn:YES];
    }else{
        self.tranformView.transform = CGAffineTransformMakeRotation(0);
        [self.switcher setIsOn:NO];
    }
    
    NSData *data=[[DeviceInfo defaultManager] changeBright:self.tranformView.tag deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
}

-(void) initSwitch
{
    self.base.layer.cornerRadius = 120;
    
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"lighting_off"] activeBackgroundImage:[UIImage imageNamed:@"lighting_on"] frame:CGRectMake(0, 0, 194, 194)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    [self.view addSubview:self.switcher];
    
    [self.switcher constraintToCenter:194];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    float degree = newValue?M_PI*3/4:0;
    self.tranformView.transform = CGAffineTransformMakeRotation(degree);
    __block NSData *data=[[DeviceInfo defaultManager] toogleLight:self.switcher.isOn deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (newValue) {
        self.tranformView.transform = CGAffineTransformMakeRotation(M_PI);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            data = [[DeviceInfo defaultManager] query:self.deviceid];
//            [sock.socket writeData:data withTimeout:1 tag:1];
        });
        
    }
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {

}

-(void)visibleUI:(Device *)device
{
    self.lightName.text = device.name;
    NSUInteger h = [SQLManager deviceHtypeIDByDeviceID:device.eID];
    self.base.hidden = self.btnPen.hidden = h!=3;
}

- (IBAction)loadCatalog:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * [self.lights count] * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
    self.lightCatalog = btn.tag;
    int htype = [[SQLManager getEType:[self.deviceid integerValue]] intValue];
    self.base.hidden = self.btnPen.hidden = (htype == 3?NO:YES);
    self.tranformView.hidden=(htype == 2?NO:YES);

    [self initiateMenuOptions:self.lightCatalog];
    // init YALContextMenuTableView tableView
    if (self.contextMenuTableView) {
        [self.contextMenuTableView dismisWithIndexPath:0];
        self.contextMenuTableView = nil;
    }else{
        if ([self.lights count]>0) {
            self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
            self.contextMenuTableView.animationDuration = 0.05;
            //optional - implement custom YALContextMenuTableView custom protocol
            self.contextMenuTableView.yalDelegate = self;
            //optional - implement menu items layout
            self.contextMenuTableView.menuItemsSide = Left;
            self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
            //register nib
            UINib *cellNib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
            [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
            if (Is_iPhoneX) {
                [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(104+22,0,0,0) animated:YES];
            }else{
                [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(80+22,0,0,0) animated:YES];
            }
        }
    }
}

#pragma mark - Local methods
- (void)initiateMenuOptions:(long)catalogID {
    self.lights = [SQLManager devicesWithCatalogID:catalogID room:self.roomID];
    [self.contextMenuTableView reloadData];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Device *device = [self.lights objectAtIndex:indexPath.row];
    self.lightName.text = device.name;
    self.deviceid = [NSString stringWithFormat:@"%d", device.eID];
    
    NSString *dviceType = [SQLManager getEType:[self.deviceid integerValue]];
    
    self.tranformView.hidden = ![dviceType isEqualToString:@"02"];
    self.base.hidden = ![dviceType isEqualToString:@"03"];
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [[SocketManager defaultManager].socket writeData:data withTimeout:1 tag:1];
    [tableView dismisWithIndexPath:indexPath];
    self.contextMenuTableView = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lights.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    Device *device = [self.lights objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.menuTitleLabel.text = device.name;
    [cell setContraint:self.lightCatalog];
    
    return cell;
}

@end
