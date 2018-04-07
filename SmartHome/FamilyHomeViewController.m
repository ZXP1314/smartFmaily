//
//  FamilyHomeViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyHomeViewController.h"

@interface FamilyHomeViewController ()
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (nonatomic,weak) NSString *deviceid;
@end

@implementation FamilyHomeViewController

- (void)setupNaviBar {
    [self setNaviBarTitle:[UD objectForKey:@"nickname"]]; //设置标题
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
    
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying == 0) {
        [MBProgressHUD showError:@"没有正在播放的设备"];
        return;
    }
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
        [self.view bringSubviewToFront:_nowMusicController.view];
    }else {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)onBgButtonClicked:(UIButton *)sender {
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (Is_iPhoneX) {
        self.RoomCollectionViewTop.constant = 88;
    }
    _hostType = [[UD objectForKey:@"HostType"] integerValue];
    [self addNotifications];
    [self setupNaviBar];
    [self showNetStateView];
    self.lightIcon.layer.cornerRadius =  self.lightIcon.frame.size.width/2;
    self.lightIcon.layer.masksToBounds = YES;
    self.lightIcon.backgroundColor = RGB(243, 152, 0, 1);
    
    self.avIcon.layer.cornerRadius =  self.avIcon.frame.size.width/2;
    self.avIcon.layer.masksToBounds = YES;
    self.avIcon.backgroundColor = RGB(217, 55, 75, 1);
    
    self.airIcon.layer.cornerRadius =  self.airIcon.frame.size.width/2;
    self.airIcon.layer.masksToBounds = YES;
    self.airIcon.backgroundColor = RGB(0, 172, 151, 1);
    
    //获取房间状态
    if (_hostType == 0) {  //Creston
        [self getRoomStateInfoByHttp];
    }else if (_hostType == 1) {   //C4
        [self getRoomStateInfoByTcp];
    }
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
}
//Creston
- (void)getRoomStateInfoByHttp {
    if (_roomArray == nil) {
        _roomArray = [NSMutableArray array];
    }
    
    [_roomArray removeAllObjects];
    [self getFamilyRoomStatusFromPlist];//获取缓存数据
    [self fetchRoomDeviceStatus];//获取房间设备状态，温度，湿度, PM2.5
}
//C4
- (void)getRoomStateInfoByTcp {
    if (_deviceArray == nil) {
        _deviceArray = [NSMutableArray array];
    }
    
    [_deviceArray removeAllObjects];
    
    if (_roomArray == nil) {
        _roomArray = [NSMutableArray array];
    }
    
    [_roomArray removeAllObjects];
    [_roomArray addObjectsFromArray:[SQLManager getAllRoomsInfoWithoutIsAll]];
    
    
    //查询所有房间的设备ID（灯，空调，影音）
    NSArray *lightIDs = [SQLManager getAllDevicesInfoBySubTypeID:1];
    NSArray *airIDs = [SQLManager getAllDevicesInfoBySubTypeID:2];
    NSArray *avIDs = [SQLManager getAllDevicesInfoBySubTypeID:3];
    
    /*NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    if (lightIDs.count >0) {
        [deviceIDs addObjectsFromArray:lightIDs];
    }
    
    if (airIDs.count >0) {
        [deviceIDs addObjectsFromArray:airIDs];
    }
    
    if (avIDs.count >0) {
        [deviceIDs addObjectsFromArray:avIDs];
    }*/
    

    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    _startDate = [NSDate date];
    
    
    //灯
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [lightIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Device *device = (Device *)obj;
            NSString *deviceID = [NSString stringWithFormat:@"%d", device.eID];
            
            if (device.hTypeId == air) {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID withRoom:device.airID];
                [sock.socket writeData:data withTimeout:1 tag:1];
                
            }else {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            
        }];
        
    });
    
    
    
    //空调
    delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [airIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Device *device = (Device *)obj;
            NSString *deviceID = [NSString stringWithFormat:@"%d", device.eID];
            
            if (device.hTypeId == air) {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID withRoom:device.airID];
                [sock.socket writeData:data withTimeout:1 tag:1];
                
            }else {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            
        }];
        
    });
    
    
    //影音
    delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [avIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Device *device = (Device *)obj;
            NSString *deviceID = [NSString stringWithFormat:@"%d", device.eID];
            
            if (device.hTypeId == air) {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID withRoom:device.airID];
                [sock.socket writeData:data withTimeout:1 tag:1];
                
            }else {
                NSData *data = [[DeviceInfo defaultManager] query:deviceID];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            
        }];
        
    });
    
    [_roomArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
        Room *room = (Room *)obj;
        
        //  PM2.5
        NSString *pmID = [SQLManager singleDeviceWithCatalogID:55 byRoom:room.rId];
        if (pmID.length >0) {
            NSData *data = [[DeviceInfo defaultManager] query:pmID];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        
        //  湿度
        NSString *humidityID = [SQLManager singleDeviceWithCatalogID:50 byRoom:room.rId];
        if (humidityID.length >0) {
            NSData *data = [[DeviceInfo defaultManager] query:humidityID];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
    }];
    
    
}

- (void)fetchRoomDeviceStatus {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/room_status_list.aspx",[IOManager SmartHomehttpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(0)
                               };
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 4;
        [http sendPost:url param:dict showProgressHUD:NO];
    }
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block FamilyHomeViewController  *blockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState==outDoor) {
                [blockSelf setNetState:netState_outDoor_4G];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"外出模式-4g");
            }else if (info.connectState == atHome){
                [blockSelf setNetState:netState_atHome_4G];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"在家模式-4G");
                
            }else if (info.connectState == offLine) {
                [blockSelf setNetState:netState_notConnect];
                 [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
                NSLog(@"离线模式");
                
            }
            
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [blockSelf setNetState:netState_atHome_WIFI];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [blockSelf setNetState:netState_outDoor_WIFI];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [blockSelf setNetState:netState_notConnect];
                 [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [blockSelf setNetState:netState_notConnect];
             [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
            NSLog(@"离线模式");
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [blockSelf setNetState:netState_notConnect];
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
    [NC addObserver:self selector:@selector(refreshRoomDeviceStatus:) name:@"refreshRoomDeviceStatusNotification" object:nil];
}

- (void)refreshRoomDeviceStatus:(NSNotification *)noti {
    
    //获取房间设备状态，温度，湿度, PM2.5
    if (_hostType == 0) {  //Creston
        [self getRoomStateInfoByHttp];
    }else if (_hostType == 1) {   //C4
        [self getRoomStateInfoByTcp];
    }
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];//开启网络监视器；
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_afNetworkReachabilityManager.reachableViaWiFi) {
        NSLog(@"WIFI: %d", _afNetworkReachabilityManager.reachableViaWiFi);
    }
    
    if (_afNetworkReachabilityManager.reachableViaWWAN) {
        NSLog(@"WWAN: %d", _afNetworkReachabilityManager.reachableViaWWAN);
    }
    
    //[self performSelector:@selector(showRoomStatus) withObject:nil afterDelay:3];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getBgMusicStatus]; //查询背景音乐状态
    
    [LoadMaskHelper showMaskWithType:FamilyHome onView:self.tabBarController.view delay:0.5 delegate:self];
}

//查询背景音乐状态
- (void)getBgMusicStatus {
    if (_bgmusicIDS == nil) {
        _bgmusicIDS = [[NSMutableArray alloc] init];
    }else {
        [_bgmusicIDS removeAllObjects];
    }
    
    NSArray * roomArr = [SQLManager getAllRoomsInfo];
    for (int i = 0; i < roomArr.count; i ++) {
        Room * roomName = roomArr[i];
        if (![SQLManager isWholeHouse:roomName.rId]) {
            Device *device = [SQLManager getDeviceWithDeviceHtypeID:bgmusic roomID:roomName.rId];//查询某个房间的背景音乐
            
            if (device) {
                [_bgmusicIDS addObject:device];
                
                float delay = 0.1*i;
                
                // GCD 延时，非阻塞主线程 延时时间：delay
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    
                    NSData *data = [[DeviceInfo defaultManager] query:[NSString stringWithFormat:@"%d", device.eID]];
                    SocketManager *sock = [SocketManager defaultManager];
                    sock.delegate = self;
                    [sock.socket writeData:data withTimeout:1 tag:1];
                    
                });
                
            }
            
        }
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

#pragma  mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return self.roomArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"familyHomePageCell" forIndexPath:indexPath];
    
    Room *roomInfo = self.roomArray[indexPath.row];
    
    [cell setRoomAndDeviceStatus:roomInfo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    Room *roomInfo = self.roomArray[indexPath.row];
    vc.roomID = roomInfo.rId;
    vc.roomName = roomInfo.rName;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(iPadCollectionCellWidth, iPadCollectionCellWidth);
    }else {
        return CGSizeMake(CollectionCellWidth, CollectionCellWidth);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return maxSpace;
}

- (void)getFamilyRoomStatusFromPlist {
    NSString *familyRoomStatusPath = [[IOManager familyRoomStatusPath] stringByAppendingPathComponent:@"FamilyRoomStatusList.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:familyRoomStatusPath];
    if (dictionary) {
        NSArray *roomStatusList = dictionary[@"room_status_list"];
        if (roomStatusList && [roomStatusList isKindOfClass:[NSArray class]]) {
            for (NSDictionary *roomStatus in roomStatusList) {
                if ([roomStatus isKindOfClass:[NSDictionary class]]) {
                    Room *roomStatusInfo = [[Room alloc] init];
                    roomStatusInfo.rId = [roomStatus[@"roomid"] intValue];
                    roomStatusInfo.rName = roomStatus[@"roomname"];
                    roomStatusInfo.tempture = [roomStatus[@"temperature"] integerValue];
                    roomStatusInfo.humidity = [roomStatus[@"humidity"] integerValue];
                    roomStatusInfo.pm25 = [roomStatus[@"pm"] integerValue];
                    roomStatusInfo.lightStatus = [roomStatus[@"light"] integerValue];
                    roomStatusInfo.avStatus = [roomStatus[@"media"] integerValue];
                    roomStatusInfo.airStatus = [roomStatus[@"aircondition"] integerValue];
                    
                    [_roomArray addObject:roomStatusInfo];
                    
                }
            }
        }
        [self.roomCollectionView reloadData];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 4) {
        if ([responseObject[@"result"] intValue] == 0) {
            [_roomArray removeAllObjects];
            NSArray *roomStatusList = responseObject[@"room_status_list"];
            if ([roomStatusList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *roomStatus in roomStatusList) {
                    if ([roomStatus isKindOfClass:[NSDictionary class]]) {
                        Room *roomStatusInfo = [[Room alloc] init];
                        roomStatusInfo.rId = [roomStatus[@"roomid"] intValue];
                        roomStatusInfo.rName = roomStatus[@"roomname"];
                        roomStatusInfo.tempture = [roomStatus[@"temperature"] integerValue];
                        roomStatusInfo.humidity = [roomStatus[@"humidity"] integerValue];
                        roomStatusInfo.pm25 = [roomStatus[@"pm"] integerValue];
                        roomStatusInfo.lightStatus = [roomStatus[@"light"] integerValue];
                        roomStatusInfo.avStatus = [roomStatus[@"media"] integerValue];
                        roomStatusInfo.airStatus = [roomStatus[@"aircondition"] integerValue];
                        
                        [_roomArray addObject:roomStatusInfo];
                    }
                }
                
                //保存至plist(缓存)
                NSString *familyRoomStatusPath = [[IOManager familyRoomStatusPath] stringByAppendingPathComponent:@"FamilyRoomStatusList.plist"];
                [responseObject writeToFile:familyRoomStatusPath atomically:YES];
            }
            
            [self.roomCollectionView reloadData];
        }
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
        if(proto.cmd == 0x01 || proto.cmd == 0x02) {
            
            NSString *devID = [SQLManager getDeviceIDByENumberForC4:CFSwapInt16BigToHost(proto.deviceID) airID:proto.action.B];
            Device *device = [SQLManager getDeviceWithDeviceID:devID.intValue airID:proto.action.B];
            
            if (device) {
                device.actionState = proto.action.state;
            
                if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) { //开关
                    device.power = proto.action.state;
                    
                    /*if (proto.deviceType == 0x14) {
                        NSDate *endDate  =  [NSDate date];
                        NSLog(@"背景音乐  时间： %f", [endDate timeIntervalSinceDate:_startDate]);
                        NSLog(@"背景音乐---开关---  %d", proto.action.state);
                        
                   }*/
                    
                    /*if (proto.deviceType == 0x11) {
                        NSDate *endDate  =  [NSDate date];
                        NSLog(@"电视  时间： %f", [endDate timeIntervalSinceDate:_startDate]);
                        NSLog(@"电视---开关---  %d", proto.action.state);
                    }
                    
                    if (proto.deviceType == 0x13) {
                        NSDate *endDate  =  [NSDate date];
                        NSLog(@"DVD  时间： %f", [endDate timeIntervalSinceDate:_startDate]);
                        NSLog(@"DVD---开关---  %d", proto.action.state);
                    }
                    
                    if (proto.deviceType == 0x18) {
                        NSDate *endDate  =  [NSDate date];
                        NSLog(@"功放  时间： %f", [endDate timeIntervalSinceDate:_startDate]);
                        NSLog(@"功放---开关---  %d", proto.action.state);
                    }*/
                    
                }
                
                else if (proto.action.state==0x6B) { //温度
                    device.currTemp  = proto.action.RValue;
                    NSLog(@"当前温度：%d", device.currTemp);    
                    
                }
                
                else if (proto.action.state==0x8A) { // 湿度
                    NSLog(@"humidity_timeInterval: %f", [[NSDate date] timeIntervalSinceDate:_startDate]);
                    device.humidity = proto.action.RValue;
                }
                
                else if (proto.action.state==0x7F) { // PM2.5
                    NSLog(@"pm25_timeInterval: %f", [[NSDate date] timeIntervalSinceDate:_startDate]);
                    device.pm25 = proto.action.RValue;
                }
                
                 @synchronized (_deviceArray) {
                
                     [_deviceArray addObject:device];
                 }
            }
            
        
    
            [self showRoomStatus];
            
            
            ///////////////     背景音乐     ////////////////
            [self.bgmusicIDS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                Device *device = (Device *)obj;
                if (devID.intValue == device.eID) {
                    if (proto.action.state == PROTOCOL_ON) { //背景音乐正在播放
                        device.power = 1;
                    }else if (proto.action.state == PROTOCOL_OFF) { //背景音乐未播放
                        device.power = 0;
                    }
                }
                
            }];
            
            [self refreshBgMusicIcon];//刷新正在播放图标
            
        }
}

- (void)refreshBgMusicIcon {
    [IOManager writeUserdefault:@"0" forKey:@"IsPlaying"];
    
    [self.bgmusicIDS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        Device *device = (Device *)obj;
        if (device.power == 1) { //有正在播放的背景音乐
            [IOManager writeUserdefault:@"1" forKey:@"IsPlaying"];
            
            UIImageView *bgImageView = _naviRightBtn.imageView;
            if (![bgImageView isAnimating]) {
                bgImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"Ipad-NowMusic-red2"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red3"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red4"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red5"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red6"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red7"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red8"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red9"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red10"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red11"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red12"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red13"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red14"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red15"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red16"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red17"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red18"],
                                               [UIImage imageNamed:@"Ipad-NowMusic-red19"],
                                               nil];
                
                bgImageView.animationDuration = 2.0; //设置动画总时间
                bgImageView.animationRepeatCount = 0; //设置重复次数，0表示无限
                
                //开始动画
                [bgImageView startAnimating];
            }
            
        }
    }];
    
    if ([[UD objectForKey:@"IsPlaying"] isEqualToString:@"0"]) {
        UIImageView *bgImageView = _naviRightBtn.imageView;
        [bgImageView stopAnimating];
    }
    
}

- (void)showRoomStatus {
    // 处理接收到的数据
    [self handleData];
    [self.roomCollectionView reloadData];
}

- (void)handleData {
    [_roomArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        Room *room = (Room *)obj;
        
        @synchronized (_deviceArray) {
            [_deviceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                
                Device *device = (Device *)obj;
                
                if (device.airID >0) { //空调
                    Device *dev = [SQLManager getDeviceWithDeviceHtypeID:air roomID:room.rId];
                    if (dev.airID == device.airID) {
                        if (device.actionState == 0x6B) {   //温度
                            room.tempture = device.currTemp;
                        }else if (device.actionState == PROTOCOL_ON) {   // 开
                            
                                room.airStatus = 1;
                    
                        }
                    }
                }else {
                    if (device.rID == room.rId) {
                        
                        if (device.actionState == 0x8A) {   // 湿度
                            room.humidity = device.humidity;
                        }else if (device.actionState == 0x7F) {   //PM2.5
                            room.pm25 = device.pm25;
                        }else if (device.actionState == PROTOCOL_OFF) {  // 关
                            
                        }else if (device.actionState == PROTOCOL_ON) {   // 开
                            if (device.subTypeId == 1) {   //灯光
                                room.lightStatus = 1;
                            }else if (device.subTypeId == 3) {    //影音
                                room.avStatus = 1;
                            }
                        }
                        
                        
                    }
                }
                
                
                
            }];
        }
        
        
    
    }];
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    if (self.roomArray.count >1) {
        Room *roomInfo = self.roomArray[1];
        vc.roomID = roomInfo.rId;
        vc.roomName = roomInfo.rName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
    [UD synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    if (self.roomArray.count >1) {
        Room *roomInfo = self.roomArray[1];
        vc.roomID = roomInfo.rId;
        vc.roomName = roomInfo.rName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

@end
