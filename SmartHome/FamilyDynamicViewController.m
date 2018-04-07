//
//  FamilyDynamicViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyDynamicViewController.h"

@interface FamilyDynamicViewController ()

@end

@implementation FamilyDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showMessage:@"请稍后...."];
    if ([self checkNetWork]) {
        [self initDataSource];
        [self initUI];
        
        _startDate = [NSDate date];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MBProgressHUD hideHUD];
}

- (BOOL)checkNetWork {
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络异常，请检查网络"];
        return NO;
    }else {
        return YES;
    }
}

- (void)initUI {
    NSInteger n = _cameraIDArray.count;
    CGFloat gap = 10.0f;
    CGFloat itemHeight = 260.0f;
    if (ON_IPAD) {
        itemHeight = 480;
    }
    _cameraList.contentSize = CGSizeMake(0, (itemHeight+gap)*n);
    for (NSInteger i = 0; i < n ; i++) {
        NSString *cameraURL = [SQLManager getCameraUrlByDeviceID:[_cameraIDArray[i] intValue]];
        NSInteger rID = [SQLManager getRoomIDByDeviceID:[_cameraIDArray[i] intValue]];
        NSArray *b = [cameraURL componentsSeparatedByString:@";"];//b[0]主机 b[1]外网
        NSString *roomName = [SQLManager getRoomNameByRoomID:(int)rID];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        MonitorViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MonitorVC"];
        vc.delegate = self;
        vc.adjustBtn.tag = i;
        DeviceInfo *device=[DeviceInfo defaultManager];
        if (b.count>1) {
            if (device.connectState == atHome) {
                 vc.cameraURL = b[0];
            }if (device.connectState == outDoor) {
                 vc.cameraURL = b[1];
            }
        }else{
              vc.cameraURL = cameraURL;
        }
        vc.roomName = roomName;
        vc.deviceid = [_cameraIDArray[i] stringValue];
        vc.view.frame = CGRectMake(0, gap*(i+1) + i*itemHeight, FW(self.cameraList), itemHeight);
        [self.cameraList addSubview:vc.view];
        [self addChildViewController:vc];
    }
    [self setNaviBarTitle:@"视频动态"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarLeftBtn:nil];
    }
}

- (void)initDataSource {
    _cameraIDArray = [NSMutableArray array];
    NSArray *cameraIDs = [SQLManager getDeviceIDsByHtypeID:@"45"];
    if (cameraIDs.count >0) {
        [_cameraIDArray addObjectsFromArray:cameraIDs];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MonitorViewControllerDelegate
- (void)onAdjustBtnClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *cameraURL = [SQLManager getCameraUrlByDeviceID:[_cameraIDArray[index] intValue]];
    NSInteger rID = [SQLManager getRoomIDByDeviceID:[_cameraIDArray[index] intValue]];
    NSString *roomName = [SQLManager getRoomNameByRoomID:(int)rID];
    NSArray *b = [cameraURL componentsSeparatedByString:@";"];//b[0]主机 b[1]外网
    UIStoryboard *familyStoryBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyDynamicDeviceAdjustViewController *vc = [familyStoryBoard instantiateViewControllerWithIdentifier:@"FamilyDynamicDeviceAdjustVC"];
    vc.roomID = rID;
    vc.roomName = roomName;
    DeviceInfo *device=[DeviceInfo defaultManager];
    if (b.count>1) {
        if (device.connectState == atHome) {
            vc.cameraURL = b[0];
        }if (device.connectState == outDoor) {
            vc.cameraURL = b[1];
        }
    }else{
        vc.cameraURL = cameraURL;
    }
    vc.deviceid = [_cameraIDArray[index] stringValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onFullScreenBtnClicked:(UIButton *)sender  cameraImageView:(UIImageView *)imageView {
    UIView *fullScreenBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)];
    fullScreenBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    CGFloat fullHeight = 300;
    CGFloat full_Y = 200;
    if (ON_IPAD) {
        fullHeight = 768;
        full_Y = 0;
    }
    _fullScreenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, full_Y, UI_SCREEN_WIDTH, fullHeight)];
    [fullScreenBg addSubview:_fullScreenImageView];
    self.fullScreenViewBg = fullScreenBg;
    [self.tabBarController.view addSubview:fullScreenBg];
    _fullScreenImageView.image = imageView.image;
    fullScreenBg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
    [fullScreenBg addGestureRecognizer:tapGesture];
    [self shakeToShow:fullScreenBg];
}

- (void)showFullScreenViewByImage:(UIImage *)img {
    if (_fullScreenImageView) {
        _fullScreenImageView.image = img;
    }
}

- (void)timeoutTimerWillStop:(BOOL)stop {
    if (!stop) {
        _endDate = [NSDate date];
        NSTimeInterval seconds = [_endDate timeIntervalSinceDate:_startDate];
        if (seconds >10) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请求超时，请稍后再试"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)closeView {
    [self.fullScreenViewBg removeFromSuperview];
    _fullScreenImageView = nil;
}
- (void)shakeToShow:(UIView *)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

@end
