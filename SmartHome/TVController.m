 //
//  TVController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVController.h"
#import "TV.h"
#import "SceneManager.h"
#import "TVChannel.h"
#import "DVCollectionViewCell.h"
#import "UIView+Popup.h"
#import "MBProgressHUD+NJ.h"
#import "KxMenu.h"
#import "VolumeManager.h"
#import "IphoneRoomView.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "PackManager.h"
#import "TVIconController.h"
#import "UploadManager.h"
#import "UIImageView+WebCache.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+Navigator.h"
#import "KeypadView.h"


@interface TVController ()<UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *unstoreLabel;

@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (weak, nonatomic) IBOutlet UICollectionView *tvLogoCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *numbersCollectionView;

@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;

//编辑电视属性
@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (weak, nonatomic) IBOutlet UITextField *channeNumber;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *editChannelImgBtn;
@property (nonatomic,strong) NSString *eNumber;
@property (nonatomic,strong) NSString *chooseImg;
@property (nonatomic,strong) UIImage *chooseImage;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIView *IRContainer;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnUP;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;

@property (weak, nonatomic) IBOutlet UIButton *btnCHUP;
@property (weak, nonatomic) IBOutlet UIButton *btnCHDown;
@property (weak, nonatomic) IBOutlet UIButton *btnPower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mButtonLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRight;
@property (weak, nonatomic) IBOutlet UIButton *keypad;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *ear;
@property (weak, nonatomic) IBOutlet UIButton *CHDown;
@property (weak, nonatomic) IBOutlet UIButton *CHUP;

@end

@implementation TVController

-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [SQLManager getAllChannelForFavoritedForType:@"tv" deviceID:[self.deviceid intValue]];
        if(_allFavourTVChannels == nil || _allFavourTVChannels.count == 0)
        {
            self.unstoreLabel.hidden = NO;
            self.tvLogoCollectionView.backgroundColor = [UIColor whiteColor];
        }
    }
    return _allFavourTVChannels;
}

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID){
        self.deviceid = [SQLManager singleDeviceWithCatalogID:TVtype byRoom:self.roomID];
        if(self.sceneid > 0)
        {
            NSArray *tvArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <tvArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[tvArr[i] intValue]];
                if([typeName isEqualToString:@"网络电视"])
                {
                    self.deviceid = tvArr[i];
                }
            }
        }
    }
}

- (IBAction)controlCmd:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    UIButton *btn =(UIButton *)sender;
    long tag = btn.tag;
    
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    switch (tag) {
        case 1:
            data=[device menu:self.deviceid];
            break;
        case 2:
            data=[device sweepUp:self.deviceid];
            break;
        case 3:
            data=[device sweepLeft:self.deviceid];
            break;
        case 4:
            data=[device sweepSURE:self.deviceid];
            break;
        case 5:
            data=[device sweepRight:self.deviceid];
            break;
        case 6:
            data=[device sweepDown:self.deviceid];
            break;
        case 7:
            data=[device next:self.deviceid];
            break;
        case 8:
            btn.selected = !btn.selected;
            data=[device toogle:btn.selected deviceID:self.deviceid];
            break;
        case 9:
            data=[device previous:self.deviceid];
            break;
        case 10:
            data=[device home:self.deviceid];
            break;
        case 11:
            data=[device back:self.deviceid];
            break;
            
        case 15:
        {
            int value = [self.voiceValue.text intValue]-1;
            if (value>=0) {
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
            }
            data=[device volumeDown:self.deviceid];
            break;
        }
        case 16:
        {
            int value = [self.voiceValue.text intValue]+1;
            if (value<=100) {
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
            }

            data=[device volumeUp:self.deviceid];
            break;
        }
        default:
            break;
    }
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    int index=0,i=0;
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
        if (device.hTypeId == TVtype) {
            index = i;
        }
        i++;
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 40)];

    menu.dataArray = deviceNames;
    menu.delegate = self;

    [menu setSelectButton:index];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (IBAction)keyChannel:(id)sender {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"keyPad" owner:self options:nil];
    
    KeypadView *view = array[0];
    view.deviceid = self.deviceid;
    if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight) {
        view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else{
        view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    [view show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 网络电视",roomName];
    [self setNaviBarTitle:self.title];

    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:nil];
    
    [self initSlider];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    [self initChannelContainer];
    self.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainer.hidden = NO;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = self.cLeft.constant = 0;
        self.vLeft.constant = self.vRight.constant = self.IRLeft.constant = self.IRight.constant =  100;
        self.mButtonLeft.constant = 530;
        self.cRight.constant = -200;
        self.mButtonTop.constant =40;
        self.cBottom.constant = 440;
        self.keypad.hidden = self.btnHome.hidden = self.btnBack.hidden = self.btnSwitch.hidden = self.CHUP.hidden = self.CHDown.hidden = self.ear.hidden = NO;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSlider
{
    [self.volume setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.volume.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.volume.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}

-(void)initChannelContainer
{
    self.allFavourTVChannels = [SQLManager getAllChannelForFavoritedForType:@"tv" deviceID:[self.deviceid intValue]];
    for(TVChannel *ch in self.allFavourTVChannels)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentMode = UIViewContentModeScaleAspectFit;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ch.channel_pic]];
        [btn setImage:[[UIImage alloc] initWithData:data] forState:UIControlStateNormal];
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             NSData *data = [[DeviceInfo defaultManager] switchProgram:ch.channel_number deviceID:self.deviceid];
             SocketManager *sock=[SocketManager defaultManager];
             [sock.socket writeData:data withTimeout:1 tag:1];
         }];
        [self.channelContainer addArrangedSubview:btn];
        [self.channelContainer layoutIfNeeded];
    }
}

-(void) changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.volume.value=proto.action.RValue/100.0;
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",proto.action.RValue];
            }
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                self.btnSwitch.selected = proto.action.state;
                self.btnPower.selected = proto.action.state;
            }
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setValue:@(self.roomID) forKey:@"roomID"];
}

- (IBAction)domute:(id)sender
{
    self.volume.value=0.0;
    
    NSData *data=[[DeviceInfo defaultManager] mute:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue];
        [self changeVolume];
    }
}


-(IBAction)switchProgram:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if ([self.timer isValid]) {
        self.retChannel = self.retChannel*10+[button.titleLabel.text intValue];
        
        NSData *data=[[DeviceInfo defaultManager] switchProgram:self.retChannel deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }else{
        button.backgroundColor = [UIColor grayColor];
        self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changecolor) userInfo:sender repeats:NO];
        self.retChannel=[button.titleLabel.text intValue];
    }
}

-(void)changecolor
{
    UIButton *button=[self.timer userInfo];
    button.backgroundColor = [UIColor clearColor];
    if (self.retChannel<10) {
        self.retChannel=[button.titleLabel.text intValue];
        NSLog(@"%d",self.retChannel);
        NSData *data=[[DeviceInfo defaultManager] switchProgram:self.retChannel deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    [self.timer invalidate];
}

-(void)showCoverView
{
    self.coverView.hidden = NO;
    self.editView.hidden = NO;
}

-(void)hiddenCoverView{
    self.coverView.hidden = YES;
    self.editView.hidden = YES;
}

#pragma mark - 编辑完成后保存电视频道
- (IBAction)clickSureBtnAfterEdited:(id)sender
{
    if(self.chooseImg)
    {
        [self sendStoreChannelRequest];
    }else{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];

        [self saveImage:self.chooseImage withName:fileName];
        
        NSString *url = [NSString stringWithFormat:@"%@TVChannelUpload.aspx",[IOManager SmartHomehttpAddr]];
        NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
        NSDictionary *dic = @{@"AuthorToken":authorToken,@"EID":self.deviceid,@"Cnumber":self.channeNumber.text,@"CName":self.channelName.text,@"ImgFileName":fileName,@"ImgFile":@""};
        
        if (self.chooseImg && url && dic && fileName) {
            
            [[UploadManager defaultManager] uploadImage:self.chooseImage url:url dic:dic fileName:fileName completion:^(id responseObject) {
                [self storChannelToSql:responseObject];
            }];
        }else{
            
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"电视图标要添加" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
   
    [self hiddenCoverView];
}


-(void)sendStoreChannelRequest
{
    NSString *url = [NSString stringWithFormat:@"%@TVChannelUpload.aspx",[IOManager SmartHomehttpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"EID":self.deviceid,@"Cnumber":self.channeNumber.text,@"CName":self.channelName.text,@"ImgFileName":self.chooseImg,@"ImgFile":@""};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
    
    [self hiddenCoverView];
}

-(void)storChannelToSql:(NSDictionary *)responseObject
{
    //保存成功后存到数据库
    [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"TV"];
    self.allFavourTVChannels = [SQLManager getAllChannelForFavoritedForType:@"tv" deviceID:[self.deviceid intValue]];
    self.unstoreLabel.hidden = YES;
    self.tvLogoCollectionView.backgroundColor = [UIColor lightGrayColor];
    [self.tvLogoCollectionView reloadData];

}

-(void)writeTVChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    FMDatabase *db = [SQLManager connectdb];
    int cNumber = [self.channeNumber.text intValue];
    if([db open])
    {
       
        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@','%ld')",[responseObject[@"cId"] intValue],[self.deviceid intValue],0,cNumber,self.channelName.text,responseObject[@"imgUrl"],parent,1,self.eNumber,[[DeviceInfo defaultManager] masterID]];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
    }
    [db close];
}

- (IBAction)cancelEdit:(id)sender
{
    self.channelName.text = nil;
    self.channeNumber.text = nil;
    [self.editChannelImgBtn setBackgroundImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    [self hiddenCoverView];
}

- (IBAction)editChannelImgBtn:(UIButton *)sender
{
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat y = view.frame.origin.y -(view.frame.size.width - btn.frame.size.width);
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(view.frame.origin.x, y , view.frame.size.width, view.frame.size.height) menuItems:@[
                                                                      [KxMenuItem menuItem:@"预置台标"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(preset:)],
                                                                      [KxMenuItem menuItem:@"本地图库"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(selectPhoto:)],
                                                                      [KxMenuItem menuItem:@"现在拍摄"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(takePhoto:)],
                                                                      ]];
}

-(void)preset:(KxMenuItem *)item{
    [self performSegueWithIdentifier:@"TVSegue" sender:self];
}

-(void)tvIconController:(TVIconController *)iconVC withImgName:(NSString *)imgName
{
    
    self.chooseImg = imgName;
    [self.editChannelImgBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}

- (void)selectPhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    self.chooseImage = info[UIImagePickerControllerOriginalImage];
  
    [self.editChannelImgBtn setBackgroundImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

- (IBAction)storeTVChannel:(UIBarButtonItem *)sender {
    [self showCoverView];
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
