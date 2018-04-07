//
//  planeScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "planeScene.h"

@implementation planeScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //self.planeimg=[[TouchImage alloc] initWithFrame:CGRectMake(100, 40, 625, 500)];
    self.planeimg = [[TouchImage alloc] initWithFrame:self.view.frame];
    self.planeimg.contentMode = UIViewContentModeScaleAspectFit;
    self.planeimg.image = [UIImage imageNamed:@"ecloud_2"];
    self.planeimg.userInteractionEnabled = YES;
    self.planeimg.viewFrom=PLANE_IMAGE;
    self.planeimg.delegate = self;
    [self.view addSubview:self.planeimg];
    
    
    DeviceInfo *device = [DeviceInfo defaultManager];
    [self sendRequestForGettingSceneConfig:@"Cloud/scene_config_list.aspx" withTag:1];//平面配置请求
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

//获取平面配置
- (void)sendRequestForGettingSceneConfig:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    NSDictionary *dic = @{
                          @"token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],
                          
                          @"optype" : @(1)
                          };
    
    NSLog(@"request param: %@", dic);
    
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
    NSLog(@"Request URL:%@", url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"responseObject:%@", responseObject);
        if ([responseObject[@"Result"] integerValue] == 0) {
            NSDictionary *infoDict = responseObject[@"info"];
            if ([infoDict isKindOfClass:[NSDictionary class]]) {
                NSString *bgImgUrl = infoDict[@"imgpath"];//设置平面背景
                if (bgImgUrl.length >0) {
                    [self.planeimg sd_setImageWithURL:[NSURL URLWithString:bgImgUrl] placeholderImage:[UIImage imageNamed:@"ecloud_2"] options:SDWebImageRetryFailed];
                }
                NSString *plistURL = infoDict[@"plist_path"];
                if (plistURL.length >0) {
                    //下载plist
                    [self downloadPlist:plistURL];
                }
            }
        }
    }
}

//下载场景plist文件到本地
-(void)downloadPlist:(NSString *)plistURL
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:plistURL]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        NSLog(@"%@",downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *path = [[IOManager planeScenePath] stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"planeScenePlistFile下载完了 %@",filePath);
        
        NSString *plistFilePath = [[filePath absoluteString] substringFromIndex:7];
        //保存到UD
        [UD setObject:plistFilePath forKey:@"Plane_Scene_PlistFile"];
        [UD synchronize];
        
        //获取所有设备和所有房间
        [self getAllDevicesAndRoomsWithPlistFilePath:plistFilePath];
        
    }];
    
    [task resume];
}

//根据plist文件获取全屋设备和所有房间
- (void)getAllDevicesAndRoomsWithPlistFilePath:(NSString *)plistFilePath {
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSLog(@"planeScenePlistFilePath: %@", plistFilePath);
    NSLog(@"planeScenePlistDict: %@", plistDic);
    
    //获取全屋设备
    NSArray *deviceArray = [plistDic objectForKey:@"devices"];
    if ([deviceArray isKindOfClass:[NSArray class]] && deviceArray.count >0) {
        [self addLights:deviceArray];
    }
    
    //获取所有房间
    NSArray *roomArray = [plistDic objectForKey:@"rooms"];
    if ([roomArray isKindOfClass:[NSArray class]] && roomArray.count >0) {
        [self.planeimg addRoom:roomArray];
    }
}

- (void)addLights:(NSArray *)lightArr {
    for (NSDictionary *dict in lightArr) {
        //灯位置
        NSString *lightRectStr = [dict objectForKey:@"rect"];
        CGRect lightRect = CGRectFromString(lightRectStr);
        UIButton *lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(lightRect.origin.x, lightRect.origin.y, 50, 50)];
        [lightBtn setImage:[UIImage imageNamed:@"light_off.png"] forState:UIControlStateNormal];
        [lightBtn setImage:[UIImage imageNamed:@"light_on.png"] forState:UIControlStateSelected];
        lightBtn.tag = [[dict objectForKey:@"deviceID"] integerValue];
        [lightBtn addTarget:self action:@selector(lightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.planeimg addSubview:lightBtn];
    }
}

- (void)lightBtnClicked:(UIButton *)btn {
    NSInteger deviceID = btn.tag;
    NSString *deviceIDStr = [NSString stringWithFormat:@"%@", @(deviceID)];
    if (btn.selected) { //关灯
        [self closeDeviceWithDeviceID:deviceIDStr];
        btn.selected = NO;
    }else {  //开灯
        [self openDeviceWithDeviceID:deviceIDStr];
        btn.selected = YES;
    }
    
}

- (void)openDeviceWithDeviceID:(NSString *)deviceID {
    SocketManager *sock = [SocketManager defaultManager];
    NSData *data = [[DeviceInfo defaultManager] open:deviceID];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)closeDeviceWithDeviceID:(NSString *)deviceID {
    SocketManager *sock = [SocketManager defaultManager];
    NSData *data = [[DeviceInfo defaultManager] close:deviceID];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     id theSegue = segue.destinationViewController;
     [theSegue setValue:[NSString stringWithFormat:@"%d", self.deviceID] forKey:@"deviceid"];
}

- (void)openRoom:(NSNumber *)roomId {
    //鉴权一下
    int roomAuth = [SQLManager getRoomAuthority:roomId.intValue];
    if (roomAuth == 1) {
        NSLog(@"打开房间 %@", roomId);
        UIStoryboard * mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RoomDetailViewController *roomDetailVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RoomDetailVC"];
        roomDetailVC.roomID = [roomId intValue];
        [self.navigationController pushViewController:roomDetailVC animated:YES];
    }else {
        [MBProgressHUD showError:@"你无权限打开此房间"];
    }
}

@end
