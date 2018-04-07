//
//  FirstViewController.h
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#define BLUETOOTH_MUSIC false

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "NowMusicController.h"
#import "AFNetworking.h"
#import "HostIDSController.h"
#import "LoadMaskHelper.h"
#import "UserInfo.h"

@interface FirstViewController : CustomViewController<NowMusicControllerDelegate, HostIDSControllerDelegate, SingleMaskViewDelegate>
@property (nonatomic, assign) NSInteger playState;//播放状态： 0:停止 1:播放
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, readonly) UIButton *naviMiddletBtn;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (weak, nonatomic) IBOutlet UIView *SupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *threeBtnLeadingConstraint;
@property (nonatomic, strong) UserInfo *userInfomation;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SupViewTopConstraint;
@property (nonatomic, strong) HostIDSController *hostListViewController;//主机列表
@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (nonatomic,strong) Scene * info1;
@property (nonatomic,strong) Scene * info2;
@property (nonatomic,strong) Scene * info3;

@property (weak, nonatomic) IBOutlet UIButton *test223;//转换器

@end
