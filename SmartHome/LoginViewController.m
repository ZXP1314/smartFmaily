//
//  LoginViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/21.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import "LoginViewController.h"
#import "UIView+Popup.h"
#import "STColorPicker.h"
#import "Version.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userType;

-(NSMutableArray *)hostIDS
{
    if(!_hostIDS)
    {
        _hostIDS = [NSMutableArray array];
    }
    return _hostIDS;
}

- (NSMutableArray *)homeNameArray {
    if(!_homeNameArray)
    {
        _homeNameArray = [NSMutableArray array];
    }
    return _homeNameArray;
}
- (NSMutableArray *)nickNameArray {
    if(!_nickNameArray)
    {
        _nickNameArray = [NSMutableArray array];
    }
    return _nickNameArray;
}
-(NSMutableArray *)detailArray
{
    if (!_detailArray) {
        _detailArray = [NSMutableArray array];
    }
    return _detailArray;
}
-(NSMutableArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self creatAPPCreatVreson];
    [self.nameTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.nameTextField.delegate = self;
    self.pwdTextField.delegate = self;
    userType = [[UD objectForKey:@"Type"] intValue];
    if ([[UD objectForKey:@"Account"] isEqualToString:@"DemoUser"]) {
        self.nameTextField.text = @"";
        self.pwdTextField.text = @"";
    }else {
        self.nameTextField.text = [UD objectForKey:@"Account"];
        self.pwdTextField.text = [[UD objectForKey:@"Password"] decryptWithDes:DES_KEY];
    }
    //判断滑动图是否出现过，第一次调用时“isScrollViewAppear” 这个key 对应的值是nil，会进入if中
    if (![@"YES" isEqualToString:[UD objectForKey:@"isScrollViewAppear"]]) {

        [self showScrollView];//显示滑动图
    }
    if (ON_IPAD) {
        self.loginBtnLeading.constant = 350;
        self.loginBtnTrailing.constant = 350;
        self.loginBtnBottom.constant = 80;
        self.registBtnLeading.constant = self.loginBtnLeading.constant;
        self.registBtnTrailing.constant = self.loginBtnTrailing.constant;
        self.registBtnBottom.constant = 30;
        self.line1Leading.constant = 260;
        self.line1Trailing.constant = 260;
        self.line2Leading.constant = self.line1Leading.constant;
        self.line2Trailing.constant = self.line1Trailing.constant;
        self.line3Leading.constant = self.line1Leading.constant;
        self.line3Trailing.constant = self.line1Trailing.constant;
        self.nameIconLeading.constant = self.line1Leading.constant + 30;
        self.pwdIconLeading.constant = self.nameIconLeading.constant;
        self.nameTextFieldLeading.constant = self.nameIconLeading.constant + 40;
        self.nameTextFieldWidth.constant = 300;
        self.pwdTextFieldLeading.constant = self.nameTextFieldLeading.constant;
        self.pwdTextFieldWidth.constant = self.nameTextFieldWidth.constant;
        self.forgetBtnLeading.constant = self.nameIconLeading.constant;
        self.tryBtnTrailing.constant = self.line1Trailing.constant + 30;
    }

}

#pragma mark - 滑动图

-(void) showScrollView{

    UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //设置UIScrollView 的显示内容的尺寸，有n张图要显示，就设置 屏幕宽度*n ，这里假设要显示3张图
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, [UIScreen mainScreen].bounds.size.height);
    _scrollView.tag = 101;
    //设置翻页效果，不允许反弹，不显示水平滑动条，设置代理为自己
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    //在UIScrollView 上加入 UIImageView
    for (int i = 0 ; i < 3; i ++) {

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * i , 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

        //将要加载的图片放入imageView 中
        NSString *welcomeStr = @"welcome";

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            welcomeStr = @"iPadWelcome";
        }

        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", welcomeStr,i+1]];
        imageView.image = image;
        [_scrollView addSubview:imageView];
    }
    //初始化 UIPageControl 和 _scrollView 显示在 同一个页面中
    UIPageControl *pageConteol = [[UIPageControl alloc] initWithFrame:CGRectMake((UI_SCREEN_WIDTH-50)/2, self.view.frame.size.height - 60, 50, 40)];
    pageConteol.numberOfPages = 3;//设置pageConteol 的page 和 _scrollView 上的图片一样多
    pageConteol.tag = 201;

    [self.view addSubview:_scrollView];
    [self.view addSubview: pageConteol];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    // 记录scrollView 的当前位置，因为已经设置了分页效果，所以：位置/屏幕大小 = 第几页
    int current = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;

    //根据scrollView 的位置对page 的当前页赋值
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    page.currentPage = current;

    //当显示到最后一页时，让滑动图消失
    if (page.currentPage == 2) {

        //调用方法，使滑动图消失
        //[self scrollViewDisappear];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    int current = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;

    //根据scrollView 的位置对page 的当前页赋值
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    page.currentPage = current;

    //当显示到最后一页时，让滑动图消失
    if (page.currentPage == 2) {
        [self scrollViewDisappear];
    }
}
-(void)scrollViewDisappear{
    //拿到 view 中的 UIScrollView 和 UIPageControl
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:101];
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];

    //设置滑动图消失的动画效果图
    [UIView animateWithDuration:1.0f animations:^{

        scrollView.center = CGPointMake(-self.view.frame.size.width/2, self.view.frame.size.height/2);

    } completion:^(BOOL finished) {

        [scrollView removeFromSuperview];
        [page removeFromSuperview];
    }];

    //将滑动图启动过的信息保存到 NSUserDefaults 中，使得第二次不运行滑动图
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"YES" forKey:@"isScrollViewAppear"];
}
- (void)addNotifications {
    [NC addObserver:self selector:@selector(registSuccessNotification:) name:@"registSuccess" object:nil];
}
- (void)removeNotifications {
    [NC removeObserver:self];
}
- (void)registSuccessNotification:(NSNotification *)noti {
    NSString *phoneNum = (NSString *)noti.object;
    _nameTextField.text = phoneNum;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.nameTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

- (IBAction)forgetPwdBtnClicked:(id)sender {
    WebManager *web = [[WebManager alloc] initWithUrl:[[IOManager SmartHomehttpAddr] stringByAppendingString:@"/user/update_pwd.aspx"] title:@"找回密码"];
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)tryBtnClicked:(id)sender {
    //demo标识
    [UD setObject:@"YES" forKey:IsDemo];
    [UD synchronize];
    //加载动画
    [self launchingAnimationViewForDemo];
    [self performSelector:@selector(loginForDemo) withObject:nil afterDelay:5];// 5秒后执行登录
}

- (void)launchingAnimationViewForDemo {
    // 设定位置和大小
    CGRect frame = CGRectMake(0,0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    // 读取gif图片数据
    NSString *launchAnimation = @"iPhoneDemo";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        launchAnimation = @"iPadDemo";
    }
    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:launchAnimation ofType:@"gif"]];
    // view生成
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.userInteractionEnabled = NO;//用户不可交互
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.scalesPageToFit = YES;
    webView.tag = 20177;
    [self.view addSubview:webView];
}

- (void)loginForDemo {
    NSString *url = [NSString stringWithFormat:@"%@login/login.aspx",[IOManager SmartHomehttpAddr]];
    NSString *userName = @"ecloud";
    NSString *passwd = @"ecloud";
    DeviceInfo *info = [DeviceInfo defaultManager];
    //手机终端类型：1，手机 2，iPad
    NSInteger clientType = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clientType = 2;
    }
    NSInteger userNameType = 1;//用户名登录
    if([userName isMobileNumber])
    {
        userNameType = 2;//手机号登录
    }
    NSInteger currentHostId = 256;//  逸云智家
    NSDictionary *dict = @{
                           @"account":userName,
                           @"logintype":@(userNameType),
                           @"password":[passwd md5],
                           @"pushtoken":info.pushToken?info.pushToken:@" ",
                           @"devicetype":@(clientType),
                           @"hostid":@(currentHostId)
                           };
    NSLog(@"%@ === login params ===: ", dict);
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

- (void)gotoIPhoneMainViewController {
    //先移除动画
    UIView *view = [self.view viewWithTag:20177];
    [view removeFromSuperview];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainTabBarController = [[BaseTabBarController alloc] init];
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    appDelegate.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:appDelegate.mainTabBarController];
    appDelegate.window.rootViewController = appDelegate.LeftSlideVC;
}

- (IBAction)loginBtnClicked:(id)sender {

    [UD setObject:@"NO" forKey:IsDemo]; //不是Demo版
    [UD synchronize];

    if ([self.nameTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入用户名或手机号"];
        return;
    }
    if ([self.pwdTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@login/login.aspx",[IOManager SmartHomehttpAddr]];
    userType = 1;//用户名登录
    if([self.nameTextField.text isMobileNumber])
    {
        userType = 2;//手机号登录
    }
    DeviceInfo *info=[DeviceInfo defaultManager];

    //手机终端类型：1，手机 2，iPad
    NSInteger clientType = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clientType = 2;
    }
    //判断是不是同一个用户，是同一个用户，传缓存的hostid, 不是同一个用户，传hostid为0
    NSInteger currentHostId = 0;//当前的hostId
    _isTheSameUser = NO;//是否是同一个用户标识
    NSString *account = [UD objectForKey:@"Account"];
    if ([account isEqualToString:self.nameTextField.text]) {//同一个用户
        _isTheSameUser = YES;
    }
    if (_isTheSameUser) {
        currentHostId = [[UD objectForKey:@"HostID"] integerValue];
    }
    NSDictionary *dict = @{
                           @"account":self.nameTextField.text,
                           @"logintype":@(userType),
                           @"password":[self.pwdTextField.text md5],
                           @"pushtoken":info.pushToken?info.pushToken:@" ",
                           @"devicetype":@(clientType),
                           @"hostid":@(currentHostId)
                           };
    NSLog(@"%@ === login params ===: ", dict);
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

- (IBAction)registBtnClicked:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:ON_IPAD?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
    alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;

    [alert addAction:[UIAlertAction actionWithTitle:@"扫描二维码注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
            static QRCodeReaderViewController *vc = nil;
            static dispatch_once_t onceToken;

            dispatch_once(&onceToken, ^{
                QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
                vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    vc.modalPresentationStyle = UIModalPresentationFormSheet;
                }
            });
            vc.delegate = self;

            [vc setCompletionWithBlock:^(NSString *resultAsString) {
                NSLog(@"Completion with result: %@", resultAsString);
            }];

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self presentViewController:vc animated:YES completion:NULL];
            }else {
                [self.navigationController pushViewController:vc animated:YES];
            }

        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"不能打开摄像头，请确认授权使用摄像头" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"体验账号注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"registFirstStepForPhoneVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)writeQRCodeStringToFile:(NSString *)string{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask, YES);//搜索沙盒路径下的document文件夹。
    NSString  *arrayPath = [[paths objectAtIndex:0]
             stringByAppendingPathComponent:@"QRCodeString.plist"];//在此文件夹下创建文件，相当于你的xxx.txt
    NSArray *array = [NSArray arrayWithObjects:
                  string, nil];//将你的数据放入数组中
    [array writeToFile:arrayPath atomically:YES];//将数组中的数据写入document下xxx.txt。
}

#pragma mark - QRCode Delegate
- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         [self dismissViewControllerAnimated:YES completion:NULL];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    NSArray * resultArr = [result componentsSeparatedByString:@"code="];
    if (resultArr.count>1) {
        result = resultArr[1];
        result=[result decryptWithDes:DES_KEY];
    }else{
        result=[result decryptWithDes:DES_KEY];
    }
   
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"registFirstStepVC"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:^{
            //result 格式： hostid @ hostname @ userType
            NSArray* list = [result componentsSeparatedByString:@"@"];
            if([list count] > 2)
            {
                self.masterId = list[0];
                self.hostName = list[1];
                [vc setValue:self.masterId forKey:@"masterStr"];
                [vc setValue:self.hostName forKey:@"hostName"];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
            //result 格式： hostid @ hostname @ userType
            NSArray* list = [result componentsSeparatedByString:@"@"];
            if([list count] > 2)
            {
                self.masterId = list[0];
                self.hostName = list[1];
                [vc setValue:self.masterId forKey:@"masterStr"];
                [vc setValue:self.hostName forKey:@"hostName"];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
    }

    [self.navigationController pushViewController:vc animated:YES];
    reader.delegate = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        reader.delegate = self;
    });
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^(){

        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-130, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished){
    }];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^(){

        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+130, self.view.frame.size.width, self.view.frame.size.height);


    } completion:^(BOOL finished){


    }];
}

//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager SmartHomehttpAddr],str];
    NSString *md5Json = [IOManager md5JsonByScenes:[NSString stringWithFormat:@"%ld",[DeviceInfo defaultManager].masterID]];
    NSDictionary *dic = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"md5Json":md5Json,
                          @"change_host":@(0)//是否是切换家庭 0:否  1:是
                          };
    if ([UD objectForKey:@"room_version"]) {
        dic = @{
                @"token":[UD objectForKey:@"AuthorToken"],
                @"room_ver":[UD objectForKey:@"room_version"],
                @"equipment_ver":[UD objectForKey:@"equipment_version"],
                @"scence_ver":[UD objectForKey:@"scence_version"],
                @"tv_ver":[UD objectForKey:@"tv_version"],
                @"fm_ver":[UD objectForKey:@"fm_version"],
                @"source_ver":[UD objectForKey:@"source_version"],
                //@"chat_ver":[UD objectForKey:@"chat_version"],
                @"md5Json":md5Json,
                @"change_host":@(0)//是否是切换家庭 0:否  1:是
                };
        }
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dic];
}

//写设备配置信息到sql
-(void)writDevicesConfigDatesToSQL:(NSArray *)rooms
{
    if(rooms.count ==0 || rooms == nil)
    {
        return;
    }
    [SQLManager writeDevices:rooms];
}
//写影音设备数据源配置信息到sql
-(void)writSourcesConfigDatesToSQL:(NSArray *)sources
{
    if(sources.count == 0 || sources == nil)
    {
        return;
    }
    [SQLManager writeSource:sources];
}
//写房间配置信息到SQL
-(void)writeRoomsConfigDataToSQL:(NSDictionary *)responseObject
{
    NSArray *roomList = responseObject[@"roomlist"];
    if(roomList.count == 0 || roomList == nil)
    {
        return;
    }
    [SQLManager writeRooms:roomList];
}

//写场景配置信息到SQL
-(void)writeScensConfigDataToSQL:(NSArray *)rooms
{
    if(rooms.count == 0 || rooms == nil)
    {
        return;
    }
    NSArray *plists = [SQLManager writeScenes:rooms];
    for (NSString *s in plists) {
        if (![s isEqualToString:@""]) {
            [self downloadPlsit:s];
        }
    }
}

//下载场景plist文件到本地
-(void)downloadPlsit:(NSString *)urlPlist
{
    AFHTTPSessionManager *session=[AFHTTPSessionManager manager];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlPlist]];
    NSURLSessionDownloadTask *task=[session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

        //下载进度
        NSLog(@"%@",downloadProgress);

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            //self.pro.progress=downloadProgress.fractionCompleted;
        }];

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        //下载到哪个文件夹
        NSString *path = [[IOManager scenesPath] stringByAppendingPathComponent:response.suggestedFilename];
        [IOManager removeFile:path];

        return [NSURL fileURLWithPath:path];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载完成了 %@",filePath);
    }];
    [task resume];

}
//写电视频道配置信息到SQL
-(void)writeChannelsConfigDataToSQL:(NSArray *)responseObject withParent:(NSString *)parent
{
    [SQLManager writeChannels:responseObject parent:parent];
}

//获取房间配置信息
-(void)gainHome_room_infoDataTo:(NSDictionary *)responseObject
{
    self.home_room_infoArr = [NSMutableArray array];
    NSInteger home_id  = [responseObject[@"hostid"] integerValue];
    NSString * hostbrand = responseObject[@"hostbrand"];
    NSString * host_brand_number = responseObject[@"host_brand_number"];
    NSString * homename = responseObject[@"nickname"];
    NSString * city = responseObject[@"city"];
    [IOManager writeUserdefault:city forKey:@"host_city"];//家庭主机所在城市

    if (homename == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:homename];
    }
    if (hostbrand == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:hostbrand];
    }
    if (host_brand_number == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:host_brand_number];
    }
    [self.home_room_infoArr addObject:[NSNumber numberWithInteger:home_id]];
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    if(!docDir) {

        NSLog(@"Documents 目录未找到");

    }
    NSArray *array = [[NSArray alloc] initWithObjects:homename,[NSNumber numberWithInteger:home_id],hostbrand,host_brand_number,nil];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"gainHome.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]==NO) {
        [array writeToFile:filePath atomically:YES];
    }else{

        //删除文件夹
        [fileManager removeItemAtPath:filePath error:nil];
        [array writeToFile:filePath atomically:YES];
    }
}
//保存每日提醒
-(void)remindListTo:(NSArray *)dic
{
    if ([dic isKindOfClass:[NSArray class]]) {
        for(NSDictionary *dicDetail in dic)
        {
            [self.titleArray addObject:dicDetail[@"title"]];
            [self.detailArray addObject:dicDetail[@"detail"]];
        }
    }
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    if(!docDir) {

        NSLog(@"Documents 目录未找到");

    }
    NSArray *DetailArray = [NSArray arrayWithArray:self.detailArray];
    NSString * filePath1 = [docDir stringByAppendingPathComponent:@"Detail.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath1]==NO) {
        [DetailArray writeToFile:filePath1 atomically:YES];
    }else{
        //删除文件夹
        [fileManager removeItemAtPath:filePath1 error:nil];
        [DetailArray writeToFile:filePath1 atomically:YES];
    }

}
-(void) writeChatListConfigDataToSQL:(NSArray *)users
{
    if(users.count == 0 || users == nil)
    {
        return;
    }
    [SQLManager writeChats:users];
}

#pragma mark -  http delegate
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    DeviceInfo *info = [DeviceInfo defaultManager];
    //升级版本的提示信息
//    [self creatAPPCreatVreson];
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0) {

            //登录成功，才缓存用户账号，密码，登录类型
            NSString *isDemo = [UD objectForKey:IsDemo];
            if ([isDemo isEqualToString:@"YES"]) {
                [IOManager writeUserdefault:@"DemoUser" forKey:@"Account"];
            }else {
                [IOManager writeUserdefault:self.nameTextField.text forKey:@"Account"];
            }
            [IOManager writeUserdefault:[NSNumber numberWithInteger:self.userType] forKey:@"Type"];
            [IOManager writeUserdefault:[self.pwdTextField.text encryptWithDes:DES_KEY] forKey:@"Password"];
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            [IOManager writeUserdefault:responseObject[@"username"] forKey:@"UserName"];
            [IOManager writeUserdefault:responseObject[@"userid"] forKey:@"UserID"];
            [IOManager writeUserdefault:responseObject[@"usertype"] forKey:@"UserType"];
            [IOManager writeUserdefault:responseObject[@"hosttype"] forKey:@"HostType"];
            [IOManager writeUserdefault:responseObject[@"tcpport"] forKey:@"TcpPort"];
            [IOManager writeUserdefault:responseObject[@"tcppath"] forKey:@"TcpPath"];
            [IOManager writeUserdefault:responseObject[@"vip"] forKey:@"vip"];

            //保存登录用户信息

            UserInfo *userInfo = [[UserInfo alloc] init];
            userInfo.userID = [responseObject[@"userid"] integerValue];
            userInfo.userName = responseObject[@"username"];
            userInfo.nickName = responseObject[@"nickname"];
            userInfo.userType = [responseObject[@"usertype"] integerValue]; //1:主人  2:客人
            userInfo.vip = responseObject[@"vip"];
            userInfo.headImgURL = responseObject[@"portrait"];
            userInfo.age = 30;
            userInfo.sex = 1;
            userInfo.signature = @"";
            userInfo.phoneNum = @"";

           BOOL succeed = [SQLManager insertOrReplaceUser:userInfo];// 登录用户基本信息入库
            if (succeed) {
                NSLog(@"登录用户基本信息入库成功");
            }else {
                NSLog(@"登录用户基本信息入库失败");
            }
            NSArray *hostList = responseObject[@"hostlist"];
            for(NSDictionary *host in hostList)
            {
                if (host[@"hostid"]) {
                    [self.hostIDS addObject:host[@"hostid"]];
                }
                if (host[@"homename"]) {
                    [self.homeNameArray addObject:host[@"homename"]];
                }
                if (host[@"nickname"]) {
                    [self.nickNameArray addObject:host[@"nickname"]];
                }
            }
            //缓存HostIDS， HomeNameList
            if (self.hostIDS) {
                [IOManager writeUserdefault:self.hostIDS forKey:@"HostIDS"];
            }

            if (self.homeNameArray) {
                [IOManager writeUserdefault:self.nickNameArray forKey:@"HomeNameList"];
            }
                if ([self.hostIDS count] >0) {

                    [UD removeObjectForKey:@"room_version"];
                    [UD removeObjectForKey:@"equipment_version"];
                    [UD removeObjectForKey:@"scence_version"];
                    [UD removeObjectForKey:@"tv_version"];
                    [UD removeObjectForKey:@"fm_version"];
                    [UD removeObjectForKey:@"source_version"];
                    [UD synchronize];
                }
            //更新UD的@"HostID"， 更新DeviceInfo的 masterID
            [IOManager writeUserdefault:@([responseObject[@"hostid"] integerValue]) forKey:@"HostID"];
            info.masterID = [responseObject[@"hostid"] integerValue];

            [IOManager writeUserdefault:responseObject[@"rctoken"] forKey:@"rctoken"];
            [IOManager writeUserdefault:responseObject[@"homename"] forKey:@"homename"];
            [self writeChatListConfigDataToSQL:responseObject[@"userlist"]];
            [self sendRequestForGettingConfigInfos:@"Cloud/load_config_data.aspx" withTag:2];

            //直接登录主机
            //[self sendRequestToHostWithTag:2 andRow:0];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }else if(tag == 2) {
        if ([responseObject[@"result"] intValue] == 0)
        {
            NSDictionary *versioninfo = responseObject[@"version_info"];
            //执久化配置版本号
            [versioninfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [IOManager writeUserdefault:obj forKey:key];
            }];
            //保存楼层信息
            NSNumber *floor = responseObject[@"home_room_info"][@"floor_number"];
            [IOManager writeUserdefault:floor forKey:@"floor_number"];
            //保存mac_address
            NSString * mac_address = responseObject[@"home_room_info"][@"mac_address"];
            [IOManager writeUserdefault:mac_address forKey:@"mac_address"];
            //保存host_ip
            NSString * host_ip = responseObject[@"home_room_info"][@"host_ip"];
            [IOManager writeUserdefault:host_ip forKey:@"host_ip"];
            //保存host_port
            NSString * host_port = responseObject[@"home_room_info"][@"host_port"];
            [IOManager writeUserdefault:host_port forKey:@"host_port"];
            //保存家庭id
            NSNumber *home_id = responseObject[@"home_room_info"][@"home_id"];
            [IOManager writeUserdefault:home_id forKey:@"home_id"];
            //保存家庭昵称
            NSString *nickname = responseObject[@"home_room_info"][@"nickname"];
            [IOManager writeUserdefault:nickname forKey:@"nickname"];
            //写房间配置信息到sql
            [self writeRoomsConfigDataToSQL:responseObject[@"home_room_info"]];
            //写场景配置信息到sql
            [self writeScensConfigDataToSQL:responseObject[@"room_scence_list"]];
            //写设备配置信息到sql
            [self writDevicesConfigDatesToSQL:responseObject[@"room_equipment_list"]];
            //写影音设备数据源配置信息到sql
            [self writSourcesConfigDatesToSQL:responseObject[@"equipment_source_list"]];
            //写TV频道信息到sql
            [self writeChannelsConfigDataToSQL:responseObject[@"tv_store_list"] withParent:@"tv"];

            //写FM频道信息到sql
            [self writeChannelsConfigDataToSQL:responseObject[@"fm_store_list"] withParent:@"fm"];
            [self gainHome_room_infoDataTo:responseObject[@"home_room_info"]];
            //写每日提醒
            [self remindListTo:responseObject[@"remind_list"]];
            //写每日提醒新版
//            [self remindListLaterTo:responseObject[@"remind_list_later"]];
            [self gotoIPhoneMainViewController];
            /*
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                [self gotoIPhoneMainViewController];
            }else {
                [self goToViewController];
            }*/
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }if (tag == 9) {

      if ([responseObject[@"result"] intValue]==0) {

        Version * version = [[Version alloc] init];
        version.versionStr  = responseObject[@"data"][@"version"];
        version.contentsStr = responseObject[@"data"][@"contents"];
        version.isforce     = responseObject[@"data"][@"isforce"];
//        version.prompt      = false;
        NSMutableArray * dataArray = [[NSMutableArray alloc] init];
        //将version类型变为NSData类型
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:version];
        //存放数据的数组将data加入进去
        [dataArray addObject:data];
        [IOManager writeUserdefault:data forKey:@"oneStudent"];
        //获取AppStore的版本号
        NSString *versionStr_int=[version.versionStr stringByReplacingOccurrencesOfString:@"."withString:@""];
        //获取本地的版本号
        NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
        NSString * currentVersion = [infoDic valueForKey:@"CFBundleShortVersionString"];
        NSString *currentVersion_int=[currentVersion stringByReplacingOccurrencesOfString:@"."withString:@""];
        int current=[currentVersion_int intValue];
        //AppStore的版本号>本地版本号就提示更新版本
            if ([versionStr_int intValue]>current) {

                [IOManager writeUserdefault:@"1" forKey:@"IsVersion"];

            }else{

                   [IOManager writeUserdefault:@"0" forKey:@"IsVersion"];

            }
        }else{
                [MBProgressHUD showError:responseObject[@"Msg"]];
          }
     }
}
-(void)creatAPPCreatVreson
{
    NSString *url = [NSString stringWithFormat:@"%@app/common/v1.0/check_version.aspx",[IOManager SmartHomehttpAddr]];
    //    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    //    NSLog(@"%@",PrivateKey);
    NSString * deviceToken = @"89898080sedefrfrg";
    NSString * timeStr = [self getCurrentDayYYMMDD];
    long timestamp = [self changeTimeToTimeSp:timeStr];
    NSString * signStr = [NSString stringWithFormat:@"%@%ld%d%@",PrivateKey,timestamp,0,deviceToken];

    //    if (auothorToken) {
    NSDictionary *dict = @{@"platform":[NSNumber numberWithInteger:0],@"timestamp":@(timestamp),@"sign":[signStr md5],@"deviceToken":deviceToken}; //platform:平台标识，0为iOS，1为Android
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 9;
    http.delegate = self;
    [http sendPost:url param:dict];
    //    }
}
-(NSString *)getCurrentDayYYMMDD{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}

//将yyyy-MM-dd HH:mm:ss格式时间转换成时间戳
-(long)changeTimeToTimeSp:(NSString *)timeStr
{
    long time;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:timeStr];
    time= (long)[fromdate timeIntervalSince1970];
    NSLog(@"%ld",time);
    return time;
}
-(void)sendRequestToHostWithTag:(int)tag andRow:(int)row
{
    NSString *url = [NSString stringWithFormat:@"%@UserLoginHost.aspx",[IOManager SmartHomehttpAddr]];

    NSString *authorToken = [IOManager getUserDefaultForKey:@"AuthorToken"];
    NSString *hostID = self.hostIDS[row];

    NSDictionary *dict = nil;
    if (authorToken.length >0 && hostID.length >0) {

        dict = @{@"AuthorToken":authorToken,
                 @"HostID":hostID

                 };
    }
    [IOManager writeUserdefault:hostID forKey:@"HostID"];
    [IOManager writeUserdefault:self.nameTextField.text forKey:@"Account"];

    if (dict) {
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dict];
    }else {
        NSLog(@"请求参数dict为 nil");
    }
}


@end


