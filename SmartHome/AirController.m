//
//  AirController.m
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AirController.h"
#import "SceneManager.h"
#import "Aircon.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "SQLManager.h"
#import "UIImageView+Badge.h"
#import "ORBSwitch.h"

#define MAX_TEMP_ROTATE_DEGREE 330
#define MIX_TEMP_ROTATE_DEGREE 120

static NSString *const airCellIdentifier = @"airCell";
@interface AirController ()<UITableViewDataSource,UITableViewDelegate,ORBSwitchDelegate,YALContextMenuTableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;
@property (strong, nonatomic) IBOutlet YALContextMenuTableView *paramView;
@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UIImageView *pm_clock_hand;
@property (weak, nonatomic) IBOutlet UIImageView *humidity_hand;
@property (weak, nonatomic) IBOutlet UIButton *disk;

@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet UIImageView *tempreturePan;
@property (nonatomic,strong) ORBSwitch *switcher;
@property (nonatomic,strong) NSMutableArray *visitedBtns;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subControlLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subControlRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diskLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diskRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diskTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rdiskTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ldiskTop;//湿度的上边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controllerBannerConstron;//button按钮的父视图的底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windSpeedConstraint;//风速底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windSpeedLeadConstraint;//风速左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoLeadConstraint;//自动模式右边距

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windConstraint;//风向底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoContraint;//自动模式底边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlLeadConstraint;//button按钮的父视图的左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlTrailConstraint;//button按钮的父视图的友边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windBtnWidth;

@property (weak, nonatomic) IBOutlet UIButton *windBtn;//风向按钮
@property (weak, nonatomic) IBOutlet UIButton *autoBtn;//自动按钮

@end

@implementation AirController

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
//        self.deviceid = [SQLManager singleDeviceWithCatalogID:air byRoom:self.roomID];;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.roomID = (int)[DeviceInfo defaultManager].roomID;
//    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
   
//    if (ON_IPAD) {
//        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:[NSString stringWithFormat:@"%@ - 空调",roomName]];
//    }
    if (Is_iPhoneX) {
        self.menuContainerTopConstraint.constant = 88;
    }
    self.disk.enabled = NO;
    [self initSwitch];
    self.tempreturePan.transform = CGAffineTransformMakeRotation(MIX_TEMP_ROTATE_DEGREE);
    self.currentDeviceName.text = [SQLManager deviceNameByDeviceID:[self.deviceid intValue]];
    self.currentDegree = 22;
    for (int i=self.currentDegree-14; i<16; i++) {
        UIView *viewblue = [self.view viewWithTag:i+100];
        viewblue.hidden = YES;
    }
    self.visitedBtns = [NSMutableArray new];
    self.params=@[@[@"speed_fast",@"speed_middle",@"speed_slow"],@[@"speed_dir_down",@"speed_dir_up"]];
    self.paramView.scrollEnabled=NO;
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid withRoom:device.airID];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    //  PM2.5
    NSString *pmID = [SQLManager singleDeviceWithCatalogID:55 byRoom:self.roomID];
    if (pmID.length >0) {
        data = [[DeviceInfo defaultManager] query:pmID];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
    //  湿度
    NSString *humidityID = [SQLManager singleDeviceWithCatalogID:50 byRoom:self.roomID];
    
    if (humidityID.length >0) {
        data = [[DeviceInfo defaultManager] query:humidityID];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
    
    if (ON_IPAD) {
        self.menuTop.constant = self.controlBottom.constant = 20;
        self.menuLeft.constant = self.menuRight.constant =self.controlLeft.constant=self.controlRight.constant = 20;
        self.subControlLeft.constant = 20;
        self.subControlRight.constant = -20;
        self.diskLeft.constant= self.diskRight.constant = 80;
        self.ldiskTop.constant = self.rdiskTop.constant = 200;
        self.diskTop.constant = -260;
        self.controllerBannerConstron.constant = 100;
        self.windSpeedConstraint.constant = 114;
        self.windConstraint.constant = 114;
        self.autoContraint.constant = 114;
        self.windSpeedLeadConstraint.constant = 200;
        self.autoLeadConstraint.constant = 200;
        self.controlLeadConstraint.constant = 200;
        self.controlTrailConstraint.constant = 200;
    }
    
    NSInteger _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Crestron  1:C4
    if (_hostType == 1) {
        self.windBtn.hidden = YES;
        self.autoBtn.hidden = YES;
        if (ON_IPAD) {
            self.windSpeedLeadConstraint.constant = 450;
        }else{
            self.windSpeedLeadConstraint.constant = self.view.bounds.size.width/3;
        }
      
//        self.controlLeft.constant=self.controlRight.constant = 310;
//        self.subControlLeft.constant = 22;
//        self.subControlRight.constant = -20;
        //创建x居中的约束
        NSLayoutConstraint * constraintx = [NSLayoutConstraint constraintWithItem:self.windSpeedBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        //创建宽度约束
        NSLayoutConstraint * constraintw = [NSLayoutConstraint constraintWithItem:self.windSpeedBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
      
        //添加约束之前，必须将视图加在父视图上
        [self.view addSubview:self.windSpeedBtn];
        [self.view addConstraints:@[constraintx,constraintw]];
        
        if (ON_IPONE) {
            self.controlLeft.constant=self.controlRight.constant = 110;
            self.menuLeft.constant = self.menuRight.constant =self.controlLeft.constant=self.controlRight.constant = 50;
            self.subControlLeft.constant = 80;
        }
       
    }
    
//
//    if (ON_IPONE) {
//        [self setupMenu];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LoadMaskHelper showMaskWithType:DeviceAir onView:self.tabBarController.view delay:0.5 delegate:self];
}

-(void) initSwitch
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"air_control_off"] activeBackgroundImage:[UIImage imageNamed:@"air_control_cool"] frame:CGRectMake(0, 0, 122, 122)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;

    [self.container addSubview:self.switcher];
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
        
        Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
        NSString *devID = [SQLManager getDeviceIDByENumberForC4:CFSwapInt16BigToHost(proto.deviceID) airID:device.airID htypeID:air];
        if ([devID intValue] == [self.deviceid intValue]) {
            
        
            if (proto.action.state == 0x6B) { //当前室内温度
                self.currentTemp.text = [NSString stringWithFormat:@"Current:%d°C",proto.action.RValue];
                self.currentDegree = proto.action.RValue;
                self.tempreturePan.transform = CGAffineTransformMakeRotation(self.currentDegree*MAX_TEMP_ROTATE_DEGREE/30);
                for (int i=1; i<16; i++) {
                    UIView *viewblue = [self.view viewWithTag:i+100+1];
                    viewblue.hidden = self.currentDegree - i<=16 || self.airMode == 1;
                    UIView *viewred = [self.view viewWithTag:i+200+1];
                    viewred.hidden = self.currentDegree - i<=16 || self.airMode == 0;
                }
            }
                
            if (proto.action.state == 0x6A) { //空调设置温度
                 self.showTemLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
            }
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {  //开关
                self.switcher.isOn = proto.action.state;
            }
        }
        
        if (proto.action.state == 0x8A) { // 湿度
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.wetLabel.text = valueString;
            [self.humidity_hand rotate:30+proto.action.RValue*300/100];
        }
        
        if (proto.action.state == 0x7F) { // PM2.5
            NSString *valueString = [NSString stringWithFormat:@"%d",proto.action.RValue];
            self.pmLabel.text = valueString;
            
            float value = 30+proto.action.RValue*200/100;
            if (proto.action.RValue>100 && proto.action.RValue<200) {
                value = 230+proto.action.RValue*40/100;
            }
            if (proto.action.RValue>200)
            {
                value = 240+proto.action.RValue*60/300;
            }
            [self.pm_clock_hand rotate:value];
        }
        
    }
}

- (IBAction)changeMode:(id)sender {
    uint8_t cmd=0;
    UIButton *btn = (UIButton *)sender;
    btn.selected = YES;
    self.currentMode=(int)btn.tag;

    for (UIButton *b in self.visitedBtns) {
        if(b.tag!=self.currentMode){
            b.selected = NO;
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    if (self.currentMode == 1) {
        self.showTemLabel.textColor = [UIColor colorWithRed:33/255.0 green:119/255.0 blue:175/255.0 alpha:1.0];
        self.airMode = !self.currentMode;
        [self.switcher setCustomKnobImage:nil
              inactiveBackgroundImage:[UIImage imageNamed:@"air_control_off"]
                activeBackgroundImage:[UIImage imageNamed:@"air_control_cool"]];
        }
    
    if (self.currentMode == 0){
        self.showTemLabel.textColor = [UIColor colorWithRed:215/255.0 green:57/255.0 blue:78/255.0 alpha:1.0];
        self.airMode = !self.currentMode;
        [self.switcher setCustomKnobImage:nil
                  inactiveBackgroundImage:[UIImage imageNamed:@"air_control_off"]
                    activeBackgroundImage:[UIImage imageNamed:@"air_control_heat"]];
    }
    if (self.airMode == 0) { //制冷
        [btn setTitleColor:[UIColor colorWithRed:33/255.0 green:119/255.0 blue:175/255.0 alpha:1.0] forState:UIControlStateSelected];//蓝色
    }else{ //制热
        
        if (btn.tag == 0) { //制热按钮
            [btn setTitleColor:[UIColor colorWithRed:215/255.0 green:57/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateSelected];//红色
        }else { // 其它按钮
            [btn setTitleColor:[UIColor colorWithRed:33/255.0 green:119/255.0 blue:175/255.0 alpha:1.0] forState:UIControlStateSelected]; //蓝色
        }
    }
    
    if (self.currentMode < 2) {
        for (int i=1; i<16; i++) {
            UIView *viewblue = [self.view viewWithTag:i+100];
            viewblue.hidden = i>self.currentDegree-15 || self.airMode == 1;
            UIView *viewred = [self.view viewWithTag:i+200];
            viewred.hidden = i>self.currentDegree-15 || self.airMode == 0;
        }
    }
    
    if (self.currentMode<1) {
        cmd = 0x39+self.currentMode;
    }else if (self.currentMode>3){
        cmd = 0x38;
    }else{
        cmd = 0x3F+self.currentMode;
    }
    
    
    if (![self.visitedBtns containsObject:sender]) {
        [self.visitedBtns addObject:sender];
    }
    
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(IBAction)changeButton:(id)sender
{
    UIButton *btn =(UIButton *)sender;
    
    NSInteger _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Crestron  1:C4
    if (_hostType == 1) {
        btn.tag = 2;
    }
    
    self.currentButton=(int)btn.tag;
    
    if (self.paramView) {
        [self.paramView dismisWithIndexPath:0];
        self.paramView = nil;
    }else{
        self.paramView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.paramView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.paramView.yalDelegate = self;
        //optional - implement menu items layout
        self.paramView.menuItemsSide = Left;
        self.paramView.menuItemsAppearanceDirection = FromBottomToTop;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"AirMenuCell" bundle:nil];
        [self.paramView registerNib:cellNib forCellReuseIdentifier:airCellIdentifier];
    
    
        // it is better to use this method only for proper animation
        int bottom = -70;
        if (ON_IPAD) {
            bottom = -140;
        }
        
       /* CGFloat offsetY = 230;
        if (ON_IPONE) {
            offsetY = 100;
        }*/
        [self.paramView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(0,0,bottom,0) animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSData *)createCmd:(uint8_t) cmd
{
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
    return [[DeviceInfo defaultManager] changeMode:cmd deviceID:self.deviceid roomID:device.airID];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}


- (void)changedCurrentTemperature:(CGFloat)currentValue {
    self.currentDegree = round(currentValue);
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
    NSData *data=[[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:self.currentDegree roomID:device.airID];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
    NSData *data=[[DeviceInfo defaultManager] toogleAirCon:self.switcher.isOn deviceID:self.deviceid roomID:device.airID];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [SQLManager updateAirPowerStatus:[self.deviceid intValue] power:self.switcher.isOn airID:device.airID];
    [NC postNotificationName:@"AirControllerStatusChangedNotifications" object:nil];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    NSString *img = @"air_control_cool";
    if (self.airMode == 0) {
        img = @"air_control_cool";
    }
    if (self.airMode == 1) {
        img = @"air_control_heat";
    }
    [switchObj setCustomKnobImage:nil
          inactiveBackgroundImage:[UIImage imageNamed:@"air_control_off"]
            activeBackgroundImage:[UIImage imageNamed:img]];
}

#pragma mark - UITouchDelegate
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tempreturePan.transform.b, self.tempreturePan.transform.a);
    CGFloat degree = radius * (180 / M_PI)+180;
    
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
    NSLog(@"degree:%f",degree);
    if (degree<MIX_TEMP_ROTATE_DEGREE) {
        if (angle<0) {
            return;
        }
    }else if (degree>MAX_TEMP_ROTATE_DEGREE) {
        if (angle>0) {
            return;
        }
    }
    self.tempreturePan.transform = CGAffineTransformRotate(self.tempreturePan.transform, angle);
    
    for (int i=1; i<16; i++) {
            UIView *viewblue = [self.view viewWithTag:i+100];
            viewblue.hidden = (degree <= MIX_TEMP_ROTATE_DEGREE+(i)*14) || self.airMode == 1;
            UIView *viewred = [self.view viewWithTag:i+200];
            viewred.hidden = (degree <= MIX_TEMP_ROTATE_DEGREE+(i)*14) || self.airMode == 0;
    }
    
    
    int tempreture = ((int)degree-MIX_TEMP_ROTATE_DEGREE)/14 + 15;
    tempreture = tempreture < 16 ? 16 : tempreture;
    tempreture = tempreture > 30 ? 30 : tempreture;
    self.showTemLabel.text = [NSString stringWithFormat:@"%d°C",tempreture];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self changedCurrentTemperature:[self.showTemLabel.text intValue]];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    uint8_t cmd=0;
    
    NSInteger _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Crestron  1:C4
    if (_hostType == 1) {
        if (self.currentButton == direction) {
            cmd = 0x35+(int)indexPath.row;
        }
        
    }else {
        if (self.currentButton == speed) {
            cmd = 0x35+(int)indexPath.row;
        }
        if (self.currentButton == direction) {
            cmd = 0x43+(int)indexPath.row;
        }
    }
    
   
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [tableView dismisWithIndexPath:indexPath];
    self.paramView = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Crestron  1:C4
    if (_hostType == 1) {
        return [self.params[self.currentButton-2] count];
    }else {
        return [self.params[self.currentButton-1] count];
    }
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:airCellIdentifier forIndexPath:indexPath];
    
    
        cell.backgroundColor = [UIColor clearColor];
    
    
    NSInteger _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Crestron  1:C4
    if (_hostType == 1) {
        cell.icon.image = [UIImage imageNamed:[self.params[self.currentButton-2] objectAtIndex:indexPath.row]];
    }else {
        cell.icon.image = [UIImage imageNamed:[self.params[self.currentButton-1] objectAtIndex:indexPath.row]];
    }
    
        [cell setContraint:self.currentButton];
    
    
    return cell;
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    if (btn.tag == 1) { //制冷
        ;
    }
}


@end
