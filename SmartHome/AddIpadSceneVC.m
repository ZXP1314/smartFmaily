//
//  AddIpadSceneVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//ipad添加场景

#import "AddIpadSceneVC.h"
#import "IpadAddDeviceVC.h"
#import "SQLManager.h"
#import "IpadAddDeviceTypeVC.h"
#import "CustomViewController.h"
#import "DeviceListTimeVC.h"
#import "IphoneEditSceneController.h"
#import "DeviceTimingViewController.h"
#import "SceneManager.h"
#import "IphoneSaveNewSceneController.h"
#import "IpadDeviceListViewController.h"

@interface AddIpadSceneVC ()<IpadAddDeviceVCDelegate>

@property (nonatomic,strong)CustomViewController * customViewVC;
@property (nonatomic,strong)UIButton * rightBtn;
@property (nonatomic,strong)IpadAddDeviceVC * leftVC;
@property (nonatomic,strong)IpadAddDeviceTypeVC * rightVC;
@property (nonatomic,strong) NSArray * viewControllerArrs;

@end

@implementation AddIpadSceneVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化分割视图控制器
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    
    //初始化左边视图控制器
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
     self.leftVC= [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadAddDeviceVC"];

    self.leftVC.delegate = self;
    self.leftVC.roomID = self.roomID;
    //初始化右边视图控制器
    self.rightVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadAddDeviceTypeVC"];
    self.rightVC.roomID = self.roomID;
    self.rightVC.sceneID = self.sceneID;
     _scene = self.rightVC.scene;
    
    // 设置分割面板的 2 个视图控制器
    splitViewController.viewControllers = @[self.leftVC, self.rightVC];
    
    // 添加到窗口
    [self addChildViewController:splitViewController];
    //配置分屏视图界面外观
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    splitViewController.preferredPrimaryColumnWidthFraction = 0.25;
    
    [self.view addSubview:splitViewController.view];
//    _scene = [[Scene alloc] init];
    [self setupNaviBar];
    
}

- (void)setupNaviBar {
    
    [self setNaviBarTitle:@"添加设备"]; //设置标题

    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"下一步" target:self action:@selector(rightBtnClicked:)];
   
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
   
    _viewControllerArrs =self.navigationController.viewControllers;
    NSInteger vcCount = _viewControllerArrs.count;
    UIViewController * lastVC = _viewControllerArrs[vcCount -2];
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    DeviceListTimeVC * deviceListVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneDeviceListTimeVC"];
    
    IpadDeviceListViewController * ipadDeviceListVC = [[IpadDeviceListViewController alloc] init];
    
    if ([lastVC isKindOfClass:[deviceListVC class]]) {
        DeviceTimingViewController * deviceTimingVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"DeviceTimingViewController"];
        [self.navigationController pushViewController:deviceTimingVC animated:YES];
        
    }else if ([lastVC isKindOfClass:[ipadDeviceListVC class]]) {
        Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        NSMutableArray *ds = [[scene devices] mutableCopy];
        NSArray *devices = [[SceneManager defaultManager] readSceneByID:0].devices;
        for(int i = 0;i<ds.count;i++){
            for (int j=0; j<devices.count; j++) {
                if ([[ds objectAtIndex:i] class] == [[devices objectAtIndex:j] class] && [[ds objectAtIndex:i] deviceID] == [[devices objectAtIndex:j] deviceID] ) {
                    [ds removeObjectAtIndex:i];
                }
            }
        }
        NSArray *temp = [ds arrayByAddingObjectsFromArray:devices];
        
        scene.devices = temp;
        
        NSString *isDemo = [UD objectForKey:IsDemo];
        if ([isDemo isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以操作"];
        }else{
            [[SceneManager defaultManager] editScene:scene];
        }
        
    }else{
         _scene = self.rightVC.scene;
         _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        if (_scene.devices.count != 0) {
        
            IphoneSaveNewSceneController * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
            iphoneSaveNewScene.roomId = self.roomID;
            [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
        }

        else{
            [MBProgressHUD showSuccess:@"请先选择设备"];
            
        }
    
    }

}
// SplitViewController 左边视图控制器的点击cell的事件
-(void)IpadAddDeviceVC:(IpadAddDeviceVC *)centerListVC selected:(NSString *)textStr
{

     self.rightVC.roomID = self.roomID;
     self.rightVC.sceneID = self.sceneID;
    
//    switch (textStr) {
    if ([textStr isEqualToString:@"灯光"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"灯光"];
        self.leftVC.Array = self.devices;
        
        [self.rightVC refreshData:self.devices];
    }if ([textStr isEqualToString:@"影音"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"影音"];
        self.leftVC.Array = self.devices;
        [self.rightVC refreshData:self.devices];
    }if ([textStr isEqualToString:@"环境"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"环境"];
        self.leftVC.Array = self.devices;
        [self.rightVC refreshData:self.devices];
    }if ([textStr isEqualToString:@"窗帘"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"窗帘"];
        self.leftVC.Array = self.devices;
        [self.rightVC refreshData:self.devices];
    }if ([textStr isEqualToString:@"智能单品"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"智能单品"];
        self.leftVC.Array = self.devices;
        [self.rightVC refreshData:self.devices];
    }
    if ([textStr isEqualToString:@"安防"]) {
        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"安防"];
        self.leftVC.Array = self.devices;
        [self.rightVC refreshData:self.devices];
    }
      
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
