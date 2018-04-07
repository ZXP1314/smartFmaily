//
//  IphoneSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//iphone和ipad场景首页


#define cellWidth self.collectionView.frame.size.width/2  - 20
#define cellH self.collectionView.frame.size.height
#define  minSpace 20

#import "IphoneSceneController.h"
#import "Room.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "Scene.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "SceneManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SocketManager.h"
#import "TouchSubViewController.h"
#import "AFNetworking.h"
#import "VoiceOrderController.h"
#import "SearchViewController.h"
#import "BgMusicController.h"
#import "HostIDSController.h"
#import "AppDelegate.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"
#import "TVIconController.h"
#import "IphoneNewAddSceneVC.h"
#import "DeviceInfo.h"
#import "PhotoGraphViewConteoller.h"
#import "AddIpadSceneVC.h"
#import "IpadDeviceListViewController.h"
#import "PackManager.h"
#import "IphoneSaveNewSceneController.h"

#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)  

@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,CYPhotoCellDelegate,UIViewControllerPreviewingDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PhotoGraphViewConteollerDelegate,TcpRecvDelegate>


//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,assign) int sum;
@property (nonatomic,strong)NSMutableArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic,assign) int selectedRoomID;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@property (nonatomic,assign) int sceneID;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (nonatomic,strong) HostIDSController *hostVC;
@property (nonatomic,strong) UICollectionView * FirstCollectionView;
@property (nonatomic,strong) UILongPressGestureRecognizer *lgPress;
@property (nonatomic,strong) UIImage *selectSceneImg;
@property (nonatomic,strong) CYPhotoCell *currentCell;
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;
@property (weak,nonatomic) NSString *deviceid;

@end

@implementation IphoneSceneController

static NSString * const CYPhotoId = @"photo";

- (void)setupNaviBar {
    
    [self setNaviBarTitle:[UD objectForKey:@"nickname"]]; //设置标题
    
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)leftBtnClicked:(UIButton *)btn {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }else {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.LeftSlideVC.closed)
    {
        [appDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [appDelegate.LeftSlideVC closeLeftView];
    }
  }
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
//      [self addNotifications];
      self.automaticallyAdjustsScrollViewInsets = NO;
      [self showNetStateView];
      self.roomList = [SQLManager getAllRoomsInfo];
      [self setUI];
      [self setUpRoomView];
    //有新版本的提示
    NSInteger IsVersion = [[UD objectForKey:@"IsVersion"] integerValue];
    if (IsVersion == 1) {
        [self showMassegeLabel];
    }
     self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
    _AddSceneBtn.layer.cornerRadius = _AddSceneBtn.bounds.size.width / 2.0; //圆角半径
    _AddSceneBtn.layer.masksToBounds = YES; //圆角
    self.navigationItem.rightBarButtonItems = nil;
    UIImage *image=[UIImage imageNamed:@"4@2x"];
    //    不让tabbar底部有渲染的关键代码
    image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.view.backgroundColor = [UIColor blueColor];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate = self;
//    [sock.socket writeData:data withTimeout:1 tag:1];
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    //tcp链接状态
    NSInteger TCPConnected = [[UD objectForKey:@"TCPConnected"] integerValue];
    if (TCPConnected == 0) {//链接成功当值没有改变的时候发查询scene的指令并缓存scene的状态--->断开重链就请求
        
    }

}
- (void)refreshUI {
    DeviceInfo *info = [DeviceInfo defaultManager];
    if([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) { //手机自带网络
        if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
            [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
            NSLog(@"离线模式");
            
        }else{
            [self setNetState:netState_outDoor_4G];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
            NSLog(@"外出模式-4G");
        }
    }else if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) { //WIFI
        
        if (info.connectState == atHome) {
            [self setNetState:netState_atHome_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
            NSLog(@"在家模式-WIFI");
            
            
        }else if (info.connectState == outDoor){
            [self setNetState:netState_outDoor_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
            NSLog(@"外出模式-WIFI");
            
        }else if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
            NSLog(@"离线模式");
        }
        
    }else {
        [self setNetState:netState_notConnect];
        [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
        NSLog(@"离线模式");
    }
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block IphoneSceneController * FirstBlockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
       // [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
        
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
                 [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
                NSLog(@"离线模式");
            }else{
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"外出模式-4G");
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                 [IOManager writeUserdefault:@"1" forKey:@"TCPConnected"];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                 [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
             [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
             [IOManager writeUserdefault:@"0" forKey:@"TCPConnected"];
            NSLog(@"离线模式");
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
     [NC addObserver:self selector:@selector(SumNumber:) name:@"SumNumber" object:nil];
    [NC addObserver:self selector:@selector(changeHostRefreshUINotification:) name:@"ChangeHostRefreshUINotification" object:nil];
   
}

- (void)changeHostRefreshUINotification:(NSNotification *)noti {
    self.roomList = [SQLManager getAllRoomsInfo];
    [self setUpRoomView];
}

-(void)SumNumber:(NSNotification *)no
{
    NSString * sumNumber = no.object;
    _sum = [sumNumber intValue];
    
    if (_sum != 0) {
        [self showMassegeLabel];
    }
}
- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [self refreshUI];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}
  // 创建CollectionView
-(void)setUI
{
    CGFloat collectionW = self.view.frame.size.width-50;
    CGFloat collectionH = self.view.frame.size.height-200;
    CGRect frame = CGRectMake(25, 130, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    layout.itemS = (int)self.scenes.count;
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device deviceGenaration];
    if (([UIScreen mainScreen].bounds.size.height <= 568.0)) {
        layout.itemSize = CGSizeMake(collectionW-50, collectionH-20);
    }else{
        layout.itemSize = CGSizeMake(collectionW-90, collectionH-20);
    }
    if (ON_IPAD) {
        layout.itemSize = CGSizeMake(320, 540);
    }
    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.FirstCollectionView.dataSource = self;
    self.FirstCollectionView.delegate = self;
    [self.view addSubview:self.FirstCollectionView];
    //    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;//
    // 注册
    [self.FirstCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
    
}

- (void)menuBtnAction:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.LeftSlideVC.closed)
    {
        [appDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [appDelegate.LeftSlideVC closeLeftView];
    }
}

-(void)setNavi
{
    self.titleButton = [[UIButton alloc]init];
    self.titleButton.frame = CGRectMake(0, 0, 180, 40);
    NSArray *roomList = [SQLManager getAllRoomsInfo];
    Room *room = roomList[0];
    [self.titleButton setTitle:room.rName forState:UIControlStateNormal];
    [self.titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 160, 0, 0);
    [self.titleButton addTarget:self action:@selector(clickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleButton;
}

-(void)clickTitleButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"roomListSegue" sender:self];
}
//切换房间的视图
-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.roomList) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    if ([self.roomList count]>0) {
        [self iphoneRoomView:self.roomView didSelectButton:0];
    }
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    Room *room = self.roomList[index];
    NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
    self.selectedRoomID = room.rId;
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"AddSceneBtn";
    [self.scenes addObject:imageName];
    ((CYLineLayout*)self.FirstCollectionView.collectionViewLayout).itemS = (int)self.scenes.count;
    [self.FirstCollectionView reloadData];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //查询场景状态
    NSData *data = [[DeviceInfo defaultManager] inquiry:self.scenes sceneCount:(int)self.scenes.count-1];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    
    [self addNotifications];
    
    NSString *KeyStr = [UD objectForKey:ShowMaskViewScene];
    if(KeyStr.length <=0){
        [LoadMaskHelper showMaskWithType:SceneHome onView:self.tabBarController.view delay:0.5 delegate:self];
    }else {
        NSString *KeyStr = [UD objectForKey:ShowMaskViewSceneAdd];
        if(KeyStr.length <=0) {
            [LoadMaskHelper showMaskWithType:SceneHomeAdd onView:self.tabBarController.view delay:0.5 delegate:self];
        }
    }
    [self setupNaviBar];//初始化导航栏
    [self getBgMusicStatus]; //查询背景音乐状态
    
    NSInteger IsAddSceneVC = [[UD objectForKey:@"IsAddSceneVC"] integerValue];
    if (IsAddSceneVC) {
      [self freshUICollectionViewCell];
      [IOManager writeUserdefault:@"0" forKey:@"IsAddSceneVC"];
    }
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //查询场景状态
    NSData *data = [[DeviceInfo defaultManager] inquiry:self.scenes sceneCount:(int)self.scenes.count-1];
    [sock.socket writeData:data withTimeout:1 tag:1];
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

-(void)freshUICollectionViewCell
{
    //刷新collectionview
    Room *room = self.roomList[self.roomIndex];
    NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
    self.selectedRoomID = room.rId;
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"AddSceneBtn";
    [self.scenes addObject:imageName];
    [self.FirstCollectionView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        baseTabbarController.tabbarPanel.hidden = NO;
    }
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
     TouchSubViewController * touchSubViewVC = [storyboard instantiateViewControllerWithIdentifier:@"TouchSubViewController"];
      touchSubViewVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
//      touchSubViewVC.sceneID = self.scene.sceneID;
      touchSubViewVC.sceneID = self.selectedSId;
      touchSubViewVC.roomID = self.roomID;
    
    return touchSubViewVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:NO];
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.row+1 >= self.scenes.count) {
        cell.imageView.image = [UIImage imageNamed:@"AddScene-ImageView"];
        cell.subImageView.image = [UIImage imageNamed:@"AddSceneBtn"];
        cell.sceneID = 0;
        cell.SceneName.text = @"点击添加场景";
        cell.SceneNameTopConstraint.constant = 40;
        cell.deleteBtn.hidden = YES;
        cell.powerBtn.hidden = YES;
        cell.seleteSendPowBtn.hidden = YES;
    
        return cell;
    }else{
        Scene *scene = self.scenes[indexPath.row];
        cell.sceneID = scene.sceneID;
        cell.roomID = self.selectedRoomID;
        cell.sceneStatus = scene.status;
        cell.isplan = scene.isplan;
        cell.isactive = scene.isactive;
        cell.sType = scene.readonly;
        cell.SceneNameTopConstraint.constant = 5;
        if (self.scenes.count == 0) {
            [MBProgressHUD showSuccess:@"暂时没有全屋场景"];
        }
        //场景是否有定时
        if (cell.isplan == 0) {
            cell.seleteSendPowBtn.hidden = YES;
            cell.PowerBtnCenterContraint.constant = 35;
        }else{
            cell.seleteSendPowBtn.hidden = NO;
            cell.PowerBtnCenterContraint.constant = 0;
        }
        self.selectedSId = cell.sceneID;
      
        cell.subImageView.image = [UIImage imageNamed:@"Scene-bedroomTSQ"];
        cell.tag = scene.sceneID;
        cell.SceneName.text = scene.sceneName;
        self.lgPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        self.lgPress.delegate = self;
        [cell addGestureRecognizer:self.lgPress];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PhotoIcon9"]];
        [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
        cell.deleteBtn.hidden = NO;
        cell.powerBtn.hidden = NO;
        //场景是否开启
        cell.powerBtn.selected = scene.status == 1;

        //场景定时是否启动
        cell.seleteSendPowBtn.selected = scene.isactive == 1;

        //是否是系统场景：是的话不允许删除场景，按钮为禁止状态
        if([SQLManager sceneBySceneID:cell.sceneID].readonly == YES)
        {
            [cell.deleteBtn setEnabled:NO];
        }else{
            [cell.deleteBtn setEnabled:YES];
        }
        return cell;
    }
    
}
//长按cell可以更换场景的图片
-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
    NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
    if (userType == 2) { //客人不允许更换场景图片
        [MBProgressHUD showError:@"非主人不允许更换场景图片"];
        return;
    }
    
    NSIndexPath *indexPath = [self.FirstCollectionView indexPathForItemAtPoint:[lgr locationInView:self.FirstCollectionView]];
    self.currentCell = (CYPhotoCell *)[self.FirstCollectionView cellForItemAtIndexPath:indexPath];
    UIAlertController * alerController;
    if (ON_IPAD) {
        alerController = [UIAlertController alertControllerWithTitle:@"更换场景图片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    }else{
         alerController = [UIAlertController alertControllerWithTitle:@"更换场景图片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    }
    [alerController addAction:[UIAlertAction actionWithTitle:@"现在就拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UD objectForKey:IsDemo] isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以操作"];
        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UD objectForKey:IsDemo] isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以操作"];
        }else{
            [DeviceInfo defaultManager].isPhotoLibrary = YES;
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                return;
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [picker shouldAutorotate];
            [picker supportedInterfaceOrientations];
            [self presentViewController:picker animated:YES completion:nil];
        }
       
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从预设图库选" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UD objectForKey:IsDemo] isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以操作"];
        }else{
            UIStoryboard *MainStoryBoard  = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
            PhotoGraphViewConteoller *PhotoIconVC = [MainStoryBoard instantiateViewControllerWithIdentifier:@"PhotoGraphViewConteoller"];
            PhotoIconVC.delegate = self;
            [self.navigationController pushViewController:PhotoIconVC animated:YES];
        }
      
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alerController animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectSceneImg = info[UIImagePickerControllerEditedImage];
    //场景ID不变
    Scene *scene = [[SceneManager defaultManager] readSceneByID:self.currentCell.sceneID];
    scene.roomID = self.roomID;
    [[SceneManager defaultManager] editScene:scene newSceneImage:self.selectSceneImg];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    [self.currentCell.imageView setImage:self.selectSceneImg];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)PhotoIconController:(PhotoGraphViewConteoller *)iconVC withImgName:(NSString *)imgName
{
    self.selectSceneImg = [UIImage imageNamed:imgName];
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [self.currentCell.imageView setImage:self.selectSceneImg];
    //场景ID不变
    Scene *scene = [[SceneManager defaultManager] readSceneByID:self.currentCell.sceneID];
    scene.roomID = self.roomID;
    [[SceneManager defaultManager] editScene:scene newSceneImage:self.selectSceneImg];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    [self.currentCell.imageView setImage:self.selectSceneImg];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //最后一个cell是添加场景的
     if (indexPath.row+1 >= self.scenes.count) {
         NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
         if (userType == 2) { //客人不允许增加自定义场景
             [MBProgressHUD showError:@"非主人不允许增加自定义场景"];
             return;
         }
         if (ON_IPAD) {
             AddIpadSceneVC * AddIpadVC = [[AddIpadSceneVC alloc] init];
             AddIpadVC.roomID = self.selectedRoomID;
             
             [self.navigationController pushViewController:AddIpadVC animated:YES];
         }else{
             UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
             IphoneNewAddSceneVC * iphoneNewAddSceneVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
             iphoneNewAddSceneVC.roomID = self.selectedRoomID;
             [self.navigationController pushViewController:iphoneNewAddSceneVC animated:YES];
         }
         
     }else{
        //其他的点击是进入场景详情
         Scene *scene = self.scenes[indexPath.row];
         self.selectedSId = scene.sceneID;
         CYPhotoCell *cell = (CYPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
         NSString *isDemo = [UD objectForKey:IsDemo];
         if ([isDemo isEqualToString:@"YES"]) {
             [MBProgressHUD showSuccess:@"真实用户才可以启动场景"];
         }else{
            if (scene.status == 0) {
                 [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
                 [[SceneManager defaultManager] startScene:scene.sceneID];
                 [SQLManager updateSceneStatus:1 sceneID:scene.sceneID roomID:scene.roomID];
             }
         }
         if (ON_IPAD) {
             IpadDeviceListViewController * listVC = [[IpadDeviceListViewController alloc] init];
             listVC.roomID = self.selectedRoomID;
             listVC.sceneID = self.selectedSId;
             [self.navigationController pushViewController:listVC animated:YES];
         }else{
             [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
         }
              [self freshUICollectionViewCell];
     }
  
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

//添加场景
- (IBAction)AddSceneBtn:(id)sender {
    
    [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
}

- (void)rightBarButtonItemClicked:(UIBarButtonItem *)sender {
    
      [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
}

-(void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status
{

}
//删除场景
-(void)sceneDeleteAction:(CYPhotoCell *)cell
{
    NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
    if (userType == 2) { //客人不允许删除自定义场景
        [MBProgressHUD showError:@"非主人不允许删除自定义场景"];
        return;
    }
    self.currentCell = cell;
    self.sceneID = (int)cell.tag;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除“%@”场景？",self.currentCell.SceneName.text] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
         NSString *isDemo = [UD objectForKey:IsDemo];
        if ([isDemo isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以操作"];
        }else{
            NSString *url = [NSString stringWithFormat:@"%@Cloud/scene_delete.aspx",[IOManager SmartHomehttpAddr]];
            NSDictionary *dict = @{@"token":[UD objectForKey:@"AuthorToken"], @"scenceid":@(self.sceneID),@"optype":@(1)};
            HttpManager *http=[HttpManager defaultManager];
            http.delegate=self;
            http.tag = 1;
            [http sendPost:url param:dict];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)refreshTableView:(CYPhotoCell *)cell
{
    NSArray *tmpArr = [SQLManager getScensByRoomId:self.selectedRoomID];
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"AddSceneBtn";
    [self.scenes addObject:imageName];    
    [self.FirstCollectionView reloadData];

}
-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
            {
                //删除数据库记录
                BOOL delSuccess = [SQLManager deleteScene:self.sceneID];
                if (delSuccess) {
                    //删除场景文件
                    Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
                    if (scene) {
                        [[SceneManager defaultManager] delScene:scene];
                        [MBProgressHUD showSuccess:@"删除成功"];
                        self.roomID = [SQLManager getRoomID:scene.sceneID];
                        if ([self.roomList containsObject:@(self.roomID)]) {
                            NSInteger Currentindex = [self.roomList indexOfObject:@(self.roomID)];
                            NSLog(@"%ld",Currentindex);
                        }
                        [self setUpRoomView];
                    }else {
                        NSLog(@"scene 不存在！");
                        [MBProgressHUD showSuccess:@"删除失败"];
                    }
                }else {
                    NSLog(@"数据库删除失败（场景表）");
                    [MBProgressHUD showSuccess:@"删除失败"];
                }
        
          [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if (tag == 2) { //启动／停止 场景定时
        if([responseObject[@"result"] intValue] == 0) {
            BOOL success = [SQLManager updateSceneIsActive:_isActive.integerValue sceneID:_timeSceneID roomID:self.roomID];
            if (success) {
                [MBProgressHUD showSuccess:responseObject[@"msg"]];
                [self freshUICollectionViewCell];
            }else {
                [MBProgressHUD showError:@"操作失败"];
            }
            
        }else {
            [MBProgressHUD showError:@"操作失败"];
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Room *room = self.roomList[self.roomIndex];
    if([segue.identifier isEqualToString:@"IphoneNewAddSceneVC"])
    {
        [IOManager removeTempFile];

        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomId"];
    }else if([segue.identifier isEqualToString:@"iphoneEditSegue"]){
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSId] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomID"];
    }
}

#pragma mark - CYPhotoCellDelegate 场景定时
- (void)onTimingBtnClicked:(UIButton *)sender sceneID:(int)sceneID {
    
    Scene * scene = [SQLManager sceneBySceneID:sceneID];
    if (scene.isactive == 0) {
//        _isActive = [NSNumber numberWithInt:1];
         sender.selected = NO;
    }else{
//        _isActive = [NSNumber numberWithInt:0];
        sender.selected = YES;
    }
    _timeSceneID = sceneID;
    NSString *url = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager SmartHomehttpAddr]];
    NSDictionary *dict = @{@"token":[UD objectForKey:@"AuthorToken"],@"optype":@(8), @"sceneid":@(_timeSceneID),@"isactive":@(sender.selected)};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 2;
    [http sendPost:url param:dict];
    
    //发TCP定时指令给主机
    NSData *data=[[DeviceInfo defaultManager] scheduleScene:sender.selected sceneID:[NSString stringWithFormat:@"%d",_timeSceneID]];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate = self;
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - lazy load
-(NSMutableArray *)scenes{
    if (!_scenes) {
        _scenes = [NSMutableArray new];
        NSString *imageName = @"AddSceneBtn";
        [_scenes addObject:imageName];
    }
    return _scenes;
}

- (void)dealloc {
    [self removeNotifications];
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
        //  背景音乐的反馈
        NSString *devID = [SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if (devID) {
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
        //场景控制的主机反馈
        NSString * sceneID = [SQLManager getSceneIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if (sceneID) {
            // 将collectionView在控制器view的中心点转化成collectionView上的坐标
            CGPoint pInView = [self.view convertPoint:self.FirstCollectionView.center toView:self.FirstCollectionView];
            // 获取这一点的indexPath
            NSIndexPath *indexPathNow = [self.FirstCollectionView indexPathForItemAtPoint:pInView];
                Scene * scene =self.scenes[indexPathNow.row];
                self.roomID = [SQLManager getRoomID:scene.sceneID];
                if (sceneID.intValue == scene.sceneID) {
                    if (proto.action.state == PROTOCOL_ON) { //场景启动
                        scene.status = 1;
                        [SQLManager updateSceneStatus:1 sceneID:scene.sceneID roomID:self.roomID];//更新数据库
                    }else if (proto.action.state == PROTOCOL_OFF) { //场景未启动
                        scene.status = 0;
                        [SQLManager updateSceneStatus:0 sceneID:self.sceneID roomID:self.roomID];//更新数据库
                    }
                 }
             [self freshUICollectionViewCell];
        }
    }
    //场景查询的主机反馈
    if (proto.cmd == 0x06) {
        int bufferSize = 2;
        int j = 0;
        while (j < proto.SceneNumber) {
            Byte enumberByte[2];
            enumberByte[0] = proto.SceneIDArray[j*bufferSize];
            enumberByte[1] = proto.SceneIDArray[j*bufferSize+1];
            NSData *adata = [[NSData alloc] initWithBytes:enumberByte length:2];
             NSString *aString = [PackManager hexStringFromData:adata];
            NSString *sceneID = [SQLManager getSceneIDByENumber:[aString integerValue]];
             self.roomID = [SQLManager getRoomID:[sceneID intValue]];
            [SQLManager updateSceneStatus:1 sceneID:[sceneID intValue] roomID:self.roomID];//更新数据库
            NSLog(@"sceneID:%@",sceneID);
            [self freshUICollectionViewCell];
            j += bufferSize;
        }
        
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

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    if (pageType == SceneHome) {
        NSInteger index = 0;
        //    if (ON_IPAD) {
        //        index = 1;
        //    }
        
        Scene *scene = self.scenes[index];
        self.selectedSId = scene.sceneID;
        CYPhotoCell *cell = (CYPhotoCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:index]];
        if (scene.status == 0) {
            [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
            [[SceneManager defaultManager] startScene:scene.sceneID];
            [SQLManager updateSceneStatus:1 sceneID:scene.sceneID roomID:scene.roomID];
        }
        
        if (ON_IPAD) {
            IpadDeviceListViewController * listVC = [[IpadDeviceListViewController alloc] init];
            listVC.roomID = self.selectedRoomID;
            listVC.sceneID = self.selectedSId;
            [self.navigationController pushViewController:listVC animated:YES];
        }else{
            [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
        }
        NSArray *tmpArr = [SQLManager getScensByRoomId:self.selectedRoomID];
        [self.scenes removeAllObjects];
        [self.scenes addObjectsFromArray:tmpArr];
        NSString *imageName = @"AddSceneBtn";
        [self.scenes addObject:imageName];
        [self.FirstCollectionView reloadData];
    }else if (pageType == SceneHomeAdd) {
        [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
    }
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    if (pageType == SceneHome) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneDetail];
        [UD synchronize];
        
        [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
        
        return;
    }
    
    if (pageType == SceneHomeAdd) {
        [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
        return;
    }
    
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    
    if (btn.tag == 1) {
        Scene *scene = self.scenes[0];
        self.selectedSId = scene.sceneID;
        CYPhotoCell *cell = (CYPhotoCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
        if (scene.status == 0) {
            [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
            [[SceneManager defaultManager] startScene:scene.sceneID];
            [SQLManager updateSceneStatus:1 sceneID:scene.sceneID roomID:scene.roomID];
        }
        
        if (ON_IPAD) {
            IpadDeviceListViewController * listVC = [[IpadDeviceListViewController alloc] init];
            listVC.roomID = self.selectedRoomID;
            listVC.sceneID = self.selectedSId;
            [self.navigationController pushViewController:listVC animated:YES];
        }else{
            [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
        }
        NSArray *tmpArr = [SQLManager getScensByRoomId:self.selectedRoomID];
        [self.scenes removeAllObjects];
        [self.scenes addObjectsFromArray:tmpArr];
        NSString *imageName = @"AddSceneBtn";
        [self.scenes addObject:imageName];
        [self.FirstCollectionView reloadData];
    }else if (btn.tag == 2) { //添加场景
        if (ON_IPAD) {
            AddIpadSceneVC * AddIpadVC = [[AddIpadSceneVC alloc] init];
            AddIpadVC.roomID = self.selectedRoomID;
            
            [self.navigationController pushViewController:AddIpadVC animated:YES];
        }else{
            UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
            IphoneNewAddSceneVC * iphoneNewAddSceneVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
            iphoneNewAddSceneVC.roomID = self.selectedRoomID;
            [self.navigationController pushViewController:iphoneNewAddSceneVC animated:YES];
        }
    }
    
}

@end
