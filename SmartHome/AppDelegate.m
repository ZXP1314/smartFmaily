//
//  AppDelegate.m
//  SmartHome
//
//  Created by Brustar on 16/4/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AppDelegate.h"
#import "PackManager.h"
#import "RCDataManager.h"
#import "WXApi.h"
#import "WeChatPayManager.h"
#import "LaunchingViewController.h"
#import "IQKeyboardManager.h"
#import "SceneManager.h"
#import "IphoneEditSceneController.h"


@implementation AppDelegate

+(void) initialize {
    //注册微信
    [WXApi registerApp:@"wxc5cab7f2a6ed90b3" withDescription:@"EcloudApp2.1"];
    //初始化数据库
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device initConfig];
    [device deviceGenaration];
    //注册融云
    [[RCIM sharedRCIM] initWithAppKey:@"8brlm7uf8tsb3"];
    [RCIM sharedRCIM].userInfoDataSource = [RCDataManager shareManager];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
}

- (void) init3DTouch
{
    if ([[UIDevice currentDevice] systemVersion].floatValue < 9.0) {
        return;
    }
    UIApplication *application = [UIApplication sharedApplication];
    //动态加载自定义的ShortcutItem
    if (application.shortcutItems.count == 0) {
        UIMutableApplicationShortcutItem *itemVoice =[[UIMutableApplicationShortcutItem alloc]initWithType:@"1" localizedTitle:@"语音控制" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"Voice"] userInfo:nil];
        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"2" localizedTitle:@"回家" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"scene-3DTouchIcon"] userInfo:nil];
         UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"3" localizedTitle:@"离家" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"scene-3DTouchGo"] userInfo:nil];
           application.shortcutItems = @[itemVoice,item2,item3];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self init3DTouch];
    //app未开启时处理推送
    if (launchOptions) {
        //截取apns推送的消息
        NSDictionary* userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        //获取推送详情
        [self handlePush:userInfo];
        return YES;
    }
    [self loadingLaunchingViewController];
    [self performSelector:@selector(loadingLoginViewController) withObject:nil afterDelay:6];//动画启动页执行完毕后，执行登录／tabbar页面
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kickout) name:KICK_OUT object:nil];
    return YES;
}

- (void)loadingLaunchingViewController {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        LaunchingViewController *launchingVC = [[LaunchingViewController alloc] init];
        self.window.rootViewController = launchingVC;
        [self.window makeKeyAndVisible];
}

- (void)loadingLoginViewController {
    DeviceInfo *device=[DeviceInfo defaultManager];
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    //已登录时,自动登录
    if ([UD objectForKey:@"AuthorToken"]) {
        self.mainTabBarController = [[BaseTabBarController alloc] init];
        LeftViewController *leftVC = [[LeftViewController alloc] init];
        self.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainTabBarController];
        self.window.rootViewController = self.LeftSlideVC;
        if (device.masterID == 0) {
            device.masterID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HostID"] intValue];
        }
    }else {
        UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//未登录，进入登录页面
        self.window.rootViewController = vc;
    }
}
-(void)kickout
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"重复登录" message:@"你的帐号已在其他地方登录，请确认是否本人登录" preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"是本人" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //退出登录
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"不是我" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //改密码
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
}

#pragma mark - 推送代理
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.pushToken=[PackManager hexStringFromData:deviceToken];
    NSLog(@"deviceToken: %@", info.pushToken);
    [[RCIMClient sharedRCIMClient] setDeviceToken:info.pushToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"token error:  %@",err);
}

//app在后台运行时
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo:  %@",userInfo);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //alert
        NSString *msg=[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] description];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"通知" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [self.window.rootViewController presentViewController: alertVC animated:YES completion:nil];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //跳转
            int item=[[userInfo objectForKey:@"itemID"] intValue];
            if(item)
            {
                //跳转
                [self gotoMSG];
            }else{
                [self gotoConversation];
            }
            
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancelAction];
        [alertVC addAction:sureAction];
        return;
    }
    [self handlePush:userInfo];
}

-(void) gotoMSG
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MSGController *MSG = [storyBoard instantiateViewControllerWithIdentifier:@"MSGController"];
    
    [self loadingLoginViewController];
    [self.mainTabBarController.selectedViewController pushViewController:MSG animated:YES];
    
}

-(void) gotoConversation
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"nickname"];
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = aGroupInfo.groupId;
    [conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    
    [self.mainTabBarController.selectedViewController pushViewController:conversationVC animated:YES];
}

//处理推送及跳转,发送请求更新badge 消息itemID
-(void) handlePush:(NSDictionary *)userInfo
{
    int item=[[userInfo objectForKey:@"itemID"] intValue];
    
    if(item)
    {
        //跳转
        [self gotoMSG];
    }else{
        [self gotoConversation];
    }
}

//向服务器申请发送token 判断事前有没有发送过
- (void)registerForRemoteNotificationToGetToken
{
    NSLog(@"Registering for push notifications...");
    //注册Device Token, 需要注册remote notification
    DeviceInfo *info=[DeviceInfo defaultManager];
    if (!info.pushToken)   //如果没有注册到令牌 则重新发送注册请求
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[[UIDevice currentDevice]systemVersion]floatValue] >=8.0)
            {
                [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                   settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge)
                                                                                   categories:nil]];
                [[UIApplication sharedApplication]registerForRemoteNotifications];
            }
        });
    }
    
    //将远程通知的数量置零
    dispatch_async(dispatch_get_main_queue(), ^{
        //1 hide the local badge
        if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == 0) {
            return;
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    });
    
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([DeviceInfo defaultManager].isPhotoLibrary) {
        return UIInterfaceOrientationMaskAll;
    }else {
        if (ON_IPAD) {
            return UIInterfaceOrientationMaskLandscape;
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    NSLog(@"shortcutItems:%@",shortcutItem);
    NSString *type = shortcutItem.type;
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    if (auothorToken.length >0) {
        switch (type.integerValue) {
            case 1: 
            {
                //要进行的操作
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
                UIViewController *voiceOrderVC = [storyBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
                
                [self loadingLoginViewController];
                [self.mainTabBarController.selectedViewController pushViewController:voiceOrderVC animated:YES];
            }
                break;
            case 2: //回家场景
            {
                [self loadingLoginViewController];
                self.mainTabBarController.selectedIndex = 2;
                self.mainTabBarController.tabbarPanel.sliderBtn.center = self.mainTabBarController.tabbarPanel.sceneBtn.center;
                [self.mainTabBarController.tabbarPanel.sliderBtn setTitle:@"场景" forState:UIControlStateNormal];
                
                NSArray *scenes = [SQLManager fetchScenes:@"欢迎"];
                self.sceneID = ((Scene *)[scenes firstObject]).sceneID;
                self.RoomID = [SQLManager getRoomID:self.sceneID];
                 [[SceneManager defaultManager] startScene:self.sceneID];//打开场景
                 [SQLManager updateSceneStatus:1 sceneID:self.sceneID roomID:self.RoomID];//更新数据库
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
                IphoneEditSceneController *EditSceneVC = [storyBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
                EditSceneVC.sceneID = self.sceneID;
                EditSceneVC.roomID = self.RoomID;
                [self.mainTabBarController.selectedViewController pushViewController:EditSceneVC animated:YES];
                [[SceneManager defaultManager] startScene:self.sceneID];
            }
                break;
            case 3: //离家场景
            {
                [self loadingLoginViewController];
                self.mainTabBarController.selectedIndex = 2;
                self.mainTabBarController.tabbarPanel.sliderBtn.center = self.mainTabBarController.tabbarPanel.sceneBtn.center;
                [self.mainTabBarController.tabbarPanel.sliderBtn setTitle:@"场景" forState:UIControlStateNormal];
                 NSArray *scenes = [SQLManager fetchScenes:@"离开"];
                self.sceneID = ((Scene *)[scenes firstObject]).sceneID;
                [[SceneManager defaultManager] startScene:self.sceneID];//打开场景
                [SQLManager updateSceneStatus:1 sceneID:self.sceneID roomID:self.RoomID];//更新数据库
                self.RoomID = [SQLManager getRoomID:self.sceneID];
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
                IphoneEditSceneController *EditSceneVC = [storyBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
                EditSceneVC.sceneID = self.sceneID;
                EditSceneVC.roomID = self.RoomID;
                [self.mainTabBarController.selectedViewController pushViewController:EditSceneVC animated:YES];
                 [[SceneManager defaultManager] startScene:self.sceneID];
            }
                break;
        }
        
    }else {
        [MBProgressHUD showError:@"请先登录"];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"进入后台");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
      NSLog(@"进入前台");
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //每次醒来都需要去判断是否得到device token
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(registerForRemoteNotificationToGetToken) userInfo:nil repeats:NO];
    //hide the badge
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    if ([url.absoluteString hasPrefix:@"wxc5cab7f2a6ed90b3"]) {
        return [WXApi handleOpenURL:url delegate:[WeChatPayManager sharedInstance]];
    }
    
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KICK_OUT object:nil];
}

@end
