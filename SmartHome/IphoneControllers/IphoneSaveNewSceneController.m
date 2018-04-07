//
//  IphoneFavorSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneSaveNewSceneController.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "IphoneNewAddSceneTimerVC.h"
#import "SQLManager.h"
#import "PhotoGraphViewConteoller.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "IphoneSceneController.h"
#import "SocketManager.h"

@interface IphoneSaveNewSceneController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,PhotoGraphViewConteollerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sceneName;//输入场景名的输入框
@property (weak, nonatomic) IBOutlet UIButton *sceneImageBtn;//选择场景图片的button
@property (nonatomic,strong) UIImage *selectSceneImg;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *PushBtn;//定时跳转按钮
@property (weak, nonatomic) IBOutlet UILabel *SceneTimingLabel;//显示场景的定时的具体时间段
@property (weak, nonatomic) IBOutlet UIButton *startSceneBtn;//是否立即启用场景
@property(nonatomic, assign) NSInteger isActive;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *repeatition;
@property(nonatomic, strong) NSMutableString *startValue;
@property(nonatomic, strong) NSMutableString *repeatString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SupViewConstraintLeading;//到做父视图左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SupViewTrailingConstraint;//到父视图右边的距离
@property (weak, nonatomic) IBOutlet UIView *supView;

@end

@implementation IphoneSaveNewSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
       [self.sceneName setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
       [self reachNotification];
       [self setupNaviBar];
       self.startSceneBtn.selected = YES;
       _isActive = 1;
      NSData *data=[[DeviceInfo defaultManager] scheduleScene:_isActive sceneID:[NSString stringWithFormat:@"%d",self.sceneID]];
      SocketManager *sock=[SocketManager defaultManager];
      [sock.socket writeData:data withTimeout:1 tag:1];
    NSLog(@"_isActive:%ld",(long)_isActive);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.SupViewConstraintLeading.constant = 200;
        self.SupViewTrailingConstraint.constant = 200;
        
        self.supView.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:29/255.0 alpha:1];
    }
  
}

- (void)setupNaviBar {
    [self setNaviBarTitle:@"保存场景"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    //    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFixTimeInfo:) name:@"AddSceneOrDeviceTimerNotification" object:nil];
    
}
-(void)getFixTimeInfo:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
 
    self.SceneTimingLabel.text = [NSString stringWithFormat:@"%@-%@,%@",dic[@"startDay"],dic[@"endDay"],dic[@"repeat"]];
    _startTime = dic[@"startDay"];
    _endTime = dic[@"endDay"];
    _repeatString = dic[@"repeat"];
}
-(void)rightBtnClicked:(UIButton *)bbi
{
     [_naviRightBtn setEnabled:NO];
    if ([self.sceneName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"场景名不能为空!"];
        return;
    }
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    _scene = [[Scene alloc]initWhithoutSchedule];
    [_scene setValuesForKeysWithDictionary:plistDic];

    [[DeviceInfo defaultManager] setEditingScene:NO];
     NSString *isDemo = [UD objectForKey:IsDemo];
    if ([isDemo isEqualToString:@"YES"]) {
        
        [MBProgressHUD showError:@"真实用户才可以操作"];
        
    }else {
        
        [[SceneManager defaultManager] addScene:_scene withName:self.sceneName.text withImage:self.selectSceneImg withiSactive:_isActive block:^(BOOL flag) {
            dispatch_async(dispatch_get_main_queue(), ^{
                  [IOManager writeUserdefault:@"1" forKey:@"IsAddSceneVC"];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            });
        }];
    }

}

- (IBAction)sceneImageBtn:(id)sender {
    
    UIAlertController * alerController;
    if (ON_IPAD) {
        
        alerController = [UIAlertController alertControllerWithTitle:@"温馨提示选择场景图片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
    }else{
          alerController = [UIAlertController alertControllerWithTitle:@"温馨提示选择场景图片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"现在就拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }]];
   
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
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
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从预设图库选" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *MainStoryBoard  = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        PhotoGraphViewConteoller *iconVC = [MainStoryBoard instantiateViewControllerWithIdentifier:@"PhotoGraphViewConteoller"];
            iconVC.delegate = self;
        [self.navigationController pushViewController:iconVC animated:YES];
        
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
    [self.sceneImageBtn setBackgroundImage:self.selectSceneImg forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)PhotoIconController:(PhotoGraphViewConteoller *)iconVC withImgName:(NSString *)imgName
{
//    self.chooseImgeName = imgName;
    self.selectSceneImg = [UIImage imageNamed:imgName];
    [self.sceneImageBtn setBackgroundImage:self.selectSceneImg forState:UIControlStateNormal];
}

- (IBAction)clickCancle:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
//跳转到定时界面
- (IBAction)PushBtn:(id)sender {
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    IphoneNewAddSceneTimerVC * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
    iphoneSaveNewScene.naviTitle = @"场景定时";
    // [self presentViewController:iphoneSaveNewScene animated:YES completion:nil];
    [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
    
}
//启用定时
- (IBAction)startSceneBtn:(id)sender {
   
    self.startSceneBtn.selected = !self.startSceneBtn.selected;
    if (self.startSceneBtn.selected) {
      
         [self.startSceneBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
    }else{
        
          [self.startSceneBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }
    _isActive = self.startSceneBtn.selected;
    NSData *data=[[DeviceInfo defaultManager] scheduleScene:_isActive sceneID:[NSString stringWithFormat:@"%d",self.sceneID]];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
