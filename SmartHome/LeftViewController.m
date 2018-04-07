 //
//  LeftViewController.m
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//


#import "LeftViewController.h"
#import "AppDelegate.h"


@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIView * buttonView;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self getUserInfoFromDB];
    
//    NSString *cameraURL =
    [SQLManager deviceUrlByDeviceID:-1];
    NSInteger camera_url = [[UD objectForKey:@"camera_url"] integerValue];
    if (camera_url == 1) {
        _itemArray = @[@"家庭成员",@"视频动态",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];
        _iconArray = @[@"my_family",@"my_scene",@"my_cloud",@"my_msg",@"my_alert",@"my_exchange"];
    }else {
        _itemArray = @[@"家庭成员",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];
        _iconArray = @[@"my_family",@"my_cloud",@"my_msg",@"my_alert",@"my_exchange"];
    }
    _bgButton = [[UIButton alloc] initWithFrame:self.view.frame];
    [_bgButton setBackgroundImage:[UIImage imageNamed:@"my_bg_side_nol"] forState:UIControlStateNormal];
    [_bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bgButton];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    UIView *bgView = [[UIView alloc] initWithFrame:_myTableView.frame];
    bgView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1.0];
    _myTableView.backgroundView = bgView;
    _myTableView.dataSource = self;
    _myTableView.delegate  = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _myTableView.tableHeaderView = [self setupTableHeader];
//    _myTableView.tableFooterView = [self setupTableFooter];
    [self.view addSubview:_myTableView];
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1.0];
    if (ON_IPAD) {
        [self creatButtonView];
    }
}
-(void)creatButtonView
{
    _buttonView = [[UIView alloc] init];
    _buttonView.frame = CGRectMake(0, kScreenHeight-60,kScreenWidth/4,60);
        _buttonView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1.0];
    //设置
    CGFloat settingY = 20.0f;
    CGFloat settingX = 180.0f;
    if (UI_SCREEN_WIDTH == 320) {
        settingX = 150.0f;
    }
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, settingY, 50, 20)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"my_setting"] forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:settingBtn];
    NSInteger IsVersion = [[UD objectForKey:@"IsVersion"] integerValue];
    //版本升级的提示
    UILabel * massegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, settingY, 6, 6)];
    massegeLabel.backgroundColor = [UIColor redColor];
    massegeLabel.layer.masksToBounds = YES;
    massegeLabel.layer.cornerRadius = 3;
    if (IsVersion == 1) {
        [self.buttonView addSubview:massegeLabel];
    }
    //皮肤
    UIButton *skinBtn = [[UIButton alloc] initWithFrame:CGRectMake(settingX, settingY, 50, 20)];
    [skinBtn setTitle:@"皮肤" forState:UIControlStateNormal];
    [skinBtn setImage:[UIImage imageNamed:@"skin"] forState:UIControlStateNormal];
    skinBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [skinBtn addTarget:self action:@selector(skinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:skinBtn];
    [self.view addSubview:_buttonView];
    
}
- (void)showMaskViewNotification:(NSNotification *)noti {
    [LoadMaskHelper showMaskWithType:LeftView onView:self.view delay:0.5 delegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)bgButtonClicked:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(onBackgroundBtnClicked:)]) {
        [_delegate onBackgroundBtnClicked:btn];
    }
}

- (void)getUserInfoFromDB {
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfo = [SQLManager getUserInfo:userID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_iconArray objectAtIndex:indexPath.row]];
        
    if (_itemArray.count < 6) {
        if (indexPath.row == 2) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(90, 12, 20, 20)];
            label.backgroundColor = [UIColor redColor];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = 10;
            [cell addSubview:label];
            if (_sum == 0) {
                label.hidden = YES;
            }else{
                label.hidden = NO;
            }
            label.text = [NSString stringWithFormat:@"%d",_sum];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
        }
    }else {
        if (indexPath.row == 3) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(90, 12, 20, 20)];
            label.backgroundColor = [UIColor redColor];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = 10;
            [cell addSubview:label];
            if (_sum == 0) {
                label.hidden = YES;
            }else{
                label.hidden = NO;
            }
            label.text = [NSString stringWithFormat:@"%d",_sum];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
   
    return cell;
}

- (void)removeNotifications {
    [NC removeObserver:self];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self checkNetWork]) {
        return;
    }
    
    NSString *item = [_itemArray objectAtIndex:indexPath.row];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:)]) {
            [_delegate didSelectItem:item];
        }
    }else {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *myInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    UIStoryboard *familyStoryBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    if ([item isEqualToString:@"故障及保修记录"]) {
        ProfileFaultsViewController *profileFaultsVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
        profileFaultsVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:profileFaultsVC animated:YES];

    }else if ([item isEqualToString:@"家庭成员"]) {
        //家庭成员(聊天页面)
        [self setRCIM];
        
    }else if ([item isEqualToString:@"智能账单"]) {

        MySubEnergyVC *mySubEnergyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"MySubEnergyVC"];
        mySubEnergyVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mySubEnergyVC animated:YES];
        
    }else if ([item isEqualToString:@"视频动态"]) {
         //视频动态
       if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 1) { //如果是主人，
           
           //如果有摄像头，才进入
           NSString *cameraURL = [SQLManager deviceUrlByDeviceID:-1];
           if (cameraURL.length >0) {
               FamilyDynamicViewController *vc = [familyStoryBoard instantiateViewControllerWithIdentifier:@"FamilyDynamicVC"];
               vc.hidesBottomBarWhenPushed = YES;
               [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
           }else {
               [MBProgressHUD showError:@"无视频动态"];
           }
           
       }else {
           [MBProgressHUD showError:@"你是普通用户无权查看"];
       }
    
    }else if ([item isEqualToString:@"通知"]) {
        MSGController *msgVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MSGController"];
        msgVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:msgVC animated:YES];
        
    }else if ([item isEqualToString:@"切换家庭账号"]) {
       
        HostListViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"HostListVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
    }
        
  }
    
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


- (void)backBtnClicked:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:)]) {
        [_delegate didSelectItem:@"返回"];
    }
}

- (UIView *)setupTableHeader {
    
    CGFloat headerWidth = UI_SCREEN_WIDTH-100;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        headerWidth = UI_SCREEN_WIDTH/4;
    }
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, 250)];
    view.backgroundColor = [UIColor clearColor];
    
    if (ON_IPAD) {
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
        [backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:backBtn];
    }
    
    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headButton.frame = CGRectMake((CGRectGetWidth(view.frame)-100)/2, 60, 100, 100);
    headButton.layer.cornerRadius = 50;
    headButton.layer.masksToBounds = YES;
    [headButton sd_setImageWithURL:[NSURL URLWithString:_userInfo.headImgURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"portrait"]];
    [view addSubview:headButton];
    [headButton addTarget:self action:@selector(headButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _headerBtn = headButton;
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headButton.frame)+10, headerWidth, 20)];
    nameLabel.text = _userInfo.nickName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    
    _nickNameLabel = nameLabel;
    
      //VIP
        UIButton *vipBtn = [[UIButton alloc] initWithFrame:CGRectMake(FX(headButton)+10, CGRectGetMaxY(nameLabel.frame)+10, 30, 15)];
        vipBtn.userInteractionEnabled = NO;
        
        if ([_userInfo.vip isEqualToString:@"1"]) {   //VIP: 1(会员)   0(非会员)
           [vipBtn setBackgroundImage:[UIImage imageNamed:@"VIP_icon"] forState:UIControlStateNormal];
        }else {
           [vipBtn setBackgroundImage:[UIImage imageNamed:@"NoVIP_icon"] forState:UIControlStateNormal];
        }
    
        vipBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        vipBtn.titleLabel.textColor = [UIColor whiteColor];
        [vipBtn setTitle:@"VIP" forState:UIControlStateNormal];
        [view addSubview:vipBtn];
        
        UILabel *vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(vipBtn.frame)+10, FY(vipBtn), 50, FH(vipBtn))];
        vipLabel.font = [UIFont boldSystemFontOfSize:11];
        vipLabel.textAlignment = NSTextAlignmentLeft;
        vipLabel.backgroundColor = [UIColor clearColor];
        vipLabel.textColor = [UIColor whiteColor];
        vipLabel.text = @"VIP会员";
        [view addSubview:vipLabel];

    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)skinBtnClicked:(UIButton *)btn {
    [MBProgressHUD showError:@"待开发"];
}

- (void)settingBtnClicked:(UIButton *)btn {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:)]) {
            [_delegate didSelectItem:@"设置"];
        }
    }else {
    
     UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
    mysettingVC.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
        
    }
}

- (void)headButtonClicked:(UIButton *)btn {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:)]) {
            [_delegate didSelectItem:@"头像"];
        }
    }else {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"userinfoVC"];
    vc.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
  }
}

//进入聊天页面
-(void)setRCIM
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];

    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *_conversationVC = [[ConversationViewController alloc] init];
    _conversationVC.conversationType = ConversationType_GROUP;
    _conversationVC.targetId = aGroupInfo.groupId;
    [_conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    _conversationVC.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:_conversationVC animated:YES];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(refreshPortrait:) name:@"refreshPortrait" object:nil];
    [NC addObserver:self selector:@selector(showMaskViewNotification:) name:@"ShowMaskViewNotification" object:nil];
    [NC addObserver:self selector:@selector(refreshNickName:) name:@"refreshNickName" object:nil];
    [NC addObserver:self selector:@selector(SumNumber:) name:@"SumNumber" object:nil];
    [NC addObserver:self selector:@selector(refreshMenuItems:) name:@"RefreshMenuItemsNotification" object:nil];
}

- (void)refreshMenuItems:(NSNotification *) noti {
//    NSString *cameraURL =
    [SQLManager deviceUrlByDeviceID:-1];
    NSInteger camera_url = [[UD objectForKey:@"camera_url"] integerValue];
    if (camera_url == 1) {
        _itemArray = @[@"家庭成员",@"视频动态",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];
        _iconArray = @[@"my_family",@"my_scene",@"my_cloud",@"my_msg",@"my_alert",@"my_exchange"];
    }else {
        _itemArray = @[@"家庭成员",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];
        _iconArray = @[@"my_family",@"my_cloud",@"my_msg",@"my_alert",@"my_exchange"];
    }
    
    [_myTableView reloadData];
}

- (void)refreshPortrait:(NSNotification *)noti {
    NSString *portraitUrl = noti.object;
    [_headerBtn sd_setImageWithURL:[NSURL URLWithString:portraitUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"portrait"]];
}
-(void)refreshNickName:(NSNotification *)fication
{
    NSString * nickName = fication.object;
    _nickNameLabel.text = nickName;

}
-(void)SumNumber:(NSNotification *)no
{
    NSString * sumNumber = no.object;
    _sum = [sumNumber intValue];
    
}
- (void)dealloc {
    [self removeNotifications];
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
    mysettingVC.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewSettingView];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
    [UD synchronize];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    if (btn.tag == 1) { // 点击头像
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
        UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"userinfoVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
        
    }else if (btn.tag == 2) {  //点击设置
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
        
        MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
        mysettingVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
    }
}

@end
