//
//  NewWindController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/9/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

//#import "CustomViewController.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "UIViewController+Navigator.h"
//#import "IphoneRoomView.h"
//#import "YALContextMenuTableView.h"
@interface NewWindController : UIViewController<TcpRecvDelegate>

@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *highSpeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *middleSpeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *lowSpeedBtn;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (nonatomic,assign) int roomID;
@property (nonatomic, strong) NSString *deviceID;
//@property (nonatomic,strong) YALContextMenuTableView* contextMenuTableView;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (nonatomic,strong) NSArray *menus;
@property (nonatomic,strong)NSMutableArray *deviceNames;
@property (nonatomic,strong)NSMutableArray *xfdeviceNames;//新风
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highSpeedBtnLeading;
@property (nonatomic,assign) long lightCatalog;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowSpeedBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highSpeedBtnBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleSpeedBtnBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowSpeedBtnBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *currentDeviceName;
- (IBAction)powerBtnClicked:(id)sender;
- (IBAction)highSpeedBtnClicked:(id)sender;
- (IBAction)middleSpeedBtnClicked:(id)sender;
- (IBAction)lowSpeedBtnClicked:(id)sender;
@end
