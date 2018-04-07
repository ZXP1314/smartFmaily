//
//  DeviceTimerSettingViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimerSettingViewController.h"

@interface DeviceTimerSettingViewController ()

@end

@implementation DeviceTimerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    self.device = [SQLManager getDeviceWithDeviceID:self.device.eID];
    [self initUI];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:@"定时设置"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}

- (void)rightBtnClicked:(UIButton *)btn {
    
    if (_isEditMode) {
        [self editDeviceTimer];
    }else {
        [self addDeviceTimer];
    }
}

- (void)editDeviceTimer {
    
    if (_startTime.length <=0 || _endTime.length <=0) {
        [MBProgressHUD showError:@"请选择时段"];
        return;
    }
    
    if (_repeatition.length <= 0 && self.repeatString.length <= 0) {
        [MBProgressHUD showError:@"请选择重复选项"];
        return;
    }
    NSString *timerFile = [NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], [SQLManager getENumberByDeviceID:self.device.eID]];
    NSString *timerPath = [[IOManager deviceTimerPath] stringByAppendingPathComponent:timerFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:timerPath];
    
    DeviceSchedule *_timer = [[DeviceSchedule alloc] initWithoutScheduleByDeviceID:self.device.eID];
    if(plistDic)
    {
        [_timer setValuesForKeysWithDictionary:plistDic];
    }
    //开始设备定时
    [[SceneManager defaultManager] addDeviceTimer:_timer isEdited:NO  mode:2 isActive:1 block:^(BOOL flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag == YES) {
                [MBProgressHUD showSuccess:@"修改定时成功"];
                [NC postNotificationName:@"AddDeviceTimerSucceedNotification" object:nil];
                
                //启动定时
                //发送8A指令通知C4主机下载plist文件
                
                //发TCP定时指令给主机
                NSData *data = [[DeviceInfo defaultManager] scheduleDevice:1 deviceID:[NSString stringWithFormat:@"%d", _timer.deviceID]];
                SocketManager *sock = [SocketManager defaultManager];
                [sock.socket writeData:data withTimeout:1 tag:1];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else {
                [MBProgressHUD showError:@"修改定时失败"];
            }
            
        });
    }];
}

- (void)addDeviceTimer {
    
    if (_startTime.length <=0 || _endTime.length <=0) {
        [MBProgressHUD showError:@"请选择时段"];
        return;
    }
    
    if (_repeatition.length <= 0) {
        [MBProgressHUD showError:@"请选择重复选项"];
        return;
    }
    
    NSString *timerFile = [NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], [SQLManager getENumberByDeviceID:self.device.eID]];
    NSString *timerPath = [[IOManager deviceTimerPath] stringByAppendingPathComponent:timerFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:timerPath];
    
    DeviceSchedule *_timer = [[DeviceSchedule alloc] initWithoutScheduleByDeviceID:self.device.eID];
    if(plistDic)
    {
        [_timer setValuesForKeysWithDictionary:plistDic];  
    }

    //开始设备定时
    [[SceneManager defaultManager] addDeviceTimer:_timer isEdited:NO mode:1 isActive:1 block:^(BOOL flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag == YES) {
                [MBProgressHUD showSuccess:@"添加成功"];
                [NC postNotificationName:@"AddDeviceTimerSucceedNotification" object:nil];
                
                //启动定时
                //发送8A指令通知C4主机下载plist文件
                    //发TCP定时指令给主机
                    NSData *data = [[DeviceInfo defaultManager] scheduleDevice:1 deviceID:[NSString stringWithFormat:@"%d", _timer.deviceID]];
                    SocketManager *sock = [SocketManager defaultManager];
                    [sock.socket writeData:data withTimeout:1 tag:1];
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[DeviceListTimeVC class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            }else {
                [MBProgressHUD showError:@"添加失败"];
            }
            
        });
    }];
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"添加成功"];
            [NC postNotificationName:@"AddDeviceTimerSucceedNotification" object:nil];
            
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[DeviceListTimeVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
            
        }else if ([responseObject[@"result"] intValue] == 500) { //该设备已添加定时
            [MBProgressHUD showError:responseObject[@"msg"]];
        }else {
            [MBProgressHUD showError:@"添加失败"];
        }
    }else if (tag == 2) {
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"修改成功"];
            [NC postNotificationName:@"AddDeviceTimerSucceedNotification" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            [MBProgressHUD showSuccess:@"修改失败"];
        }
    }
}

- (void)initUI {
    [self setupNaviBar];
    _startValue = [NSMutableString string];
    [_startValue appendString:@"01000000"];//默认开
    
    CGFloat tableWidth = UI_SCREEN_WIDTH;
    if (ON_IPAD) {
        tableWidth = UI_SCREEN_WIDTH*3/4;
    }
    
    _timerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, tableWidth, UI_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _timerTableView.dataSource = self;
    _timerTableView.delegate = self;
    _timerTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _timerTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _timerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.timerTableView registerNib:[UINib nibWithNibName:@"PowerLightCell" bundle:nil] forCellReuseIdentifier:@"PowerLightCell"];//开关灯
    [self.timerTableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.timerTableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    if (ON_IPAD) {
        [self.timerTableView registerNib:[UINib nibWithNibName:@"IpadTVCell" bundle:nil] forCellReuseIdentifier:@"IpadTVCell"];//网络电视
    }else {
        [self.timerTableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    }
    [self.timerTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//投影仪ScreenTableViewCell
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    if (ON_IPAD) {
        [self.timerTableView registerNib:[UINib nibWithNibName:@"IpadDVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"IpadDVDTableViewCell"];//DVD
    }else {
        [self.timerTableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    }
    [self.timerTableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.timerTableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM收音机
    
    [self.view addSubview:_timerTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return footer;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {  //设备cell
        return 60.0f;
    }else if (indexPath.section == 1) {
        return 60.0f;
    }
    
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (self.device.subTypeId == 1) { //灯光
            if (self.device.hTypeId == 1) { //开关灯
                PowerLightCell * powerCell = [tableView dequeueReusableCellWithIdentifier:@"PowerLightCell" forIndexPath:indexPath];
                powerCell.selectionStyle = UITableViewCellSelectionStyleNone;
                powerCell.backgroundColor = [UIColor clearColor];
                powerCell.powerBtnConstraint.constant = 10;
                powerCell.powerLightNameLabel.text = self.device.name;
                powerCell.powerLightNameLabel.font = [UIFont systemFontOfSize:16];
                powerCell.addPowerLightBtn.hidden = YES;
                powerCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                powerCell.powerLightBtn.selected = self.device.power;//开关状态
                return powerCell;
            }else if (self.device.hTypeId == 2) { //调光灯
                NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddLightBtn.hidden = YES;
                cell.LightConstraint.constant = 10;
                cell.NewLightNameLabel.text = self.device.name;
                cell.NewLightNameLabel.font = [UIFont systemFontOfSize:16];
                cell.NewLightSlider.continuous = NO;
                cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                cell.NewLightPowerBtn.selected = self.power;
                cell.NewLightSlider.value = (float)self.bright/100.0f;
                return cell;
                
            }else if (self.device.hTypeId == 3) {  //调色灯
                NewColourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
                cell.delegate = self;
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddColourLightBtn.hidden = YES;
                cell.ColourLightConstraint.constant = 10;
                cell.colourNameLabel.text = self.device.name;
                cell.colourNameLabel.font = [UIFont systemFontOfSize:16];
                cell.colourSlider.continuous = NO;
                cell.colourSlider.hidden = NO;
                cell.supimageView.hidden = NO;
                cell.lowImageView.hidden = NO;
                cell.highImageView.hidden = NO;
                cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                cell.colourBtn.selected = self.power;
                return cell;
            }
            
        }else if (self.device.subTypeId == 7) { //窗帘
            CurtainTableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
            curtainCell.delegate = self;
            curtainCell.backgroundColor =[UIColor clearColor];
            curtainCell.selectionStyle = UITableViewCellSelectionStyleNone;
            curtainCell.AddcurtainBtn.hidden = YES;
            curtainCell.curtainContraint.constant = 10;
            curtainCell.roomID = (int)self.roomID;
            curtainCell.label.text = self.device.name;
            curtainCell.label.font = [UIFont systemFontOfSize:16];
            curtainCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            curtainCell.open.selected = self.power;
            curtainCell.slider.value = (float)self.position/100.0f;
            return curtainCell;
        }else if (self.device.hTypeId == 31) {  //空调
            AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
            aireCell.delegate = self;
            aireCell.backgroundColor = [UIColor clearColor];
            aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
            aireCell.AddAireBtn.hidden = YES;
            aireCell.AireConstraint.constant = 10;
            aireCell.roomID = (int)self.roomID;
            aireCell.AireNameLabel.text = self.device.name;
            aireCell.AireNameLabel.font = [UIFont systemFontOfSize:16];
            aireCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            aireCell.AireSwitchBtn.selected = self.power;
            aireCell.AireSlider.value = self.temperature;
            return aireCell;
        }else if (self.device.hTypeId == 14) { //背景音乐
            BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
            BjMusicCell.delegate = self;
            BjMusicCell.backgroundColor = [UIColor clearColor];
            BjMusicCell.selectionStyle = UITableViewCellSelectionStyleNone;
            BjMusicCell.AddBjmusicBtn.hidden = YES;
            BjMusicCell.BJmusicConstraint.constant = 10;
            BjMusicCell.BjMusicNameLb.text = self.device.name;
            BjMusicCell.BjMusicNameLb.font = [UIFont systemFontOfSize:16];
            BjMusicCell.BjPowerButton.selected = self.power;
            BjMusicCell.BjSlider.value = (float)self.volume/100.0f;
            return BjMusicCell;
        }else if (self.device.hTypeId == 13) { //DVD
            
            if (ON_IPAD) {
                IpadDVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"IpadDVDTableViewCell" forIndexPath:indexPath];
                dvdCell.backgroundColor =[UIColor clearColor];
                dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dvdCell.AddDvdBtn.hidden = YES;
                dvdCell.DVDConstraint.constant = 10;
                dvdCell.DVDNameLabel.text = self.device.name;
                dvdCell.DVDNameLabel.font = [UIFont systemFontOfSize:16];
                dvdCell.DVDSwitchBtn.selected = self.device.power;//开关
                dvdCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                return dvdCell;
            }else {
            
            DVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
            dvdCell.delegate = self;
            dvdCell.backgroundColor =[UIColor clearColor];
            dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dvdCell.AddDvdBtn.hidden = YES;
            dvdCell.DVDConstraint.constant = 10;
            dvdCell.DVDNameLabel.text = self.device.name;
            dvdCell.DVDNameLabel.font = [UIFont systemFontOfSize:16];
            dvdCell.DVDSwitchBtn.selected = self.power;
            dvdCell.DVDSlider.value = (float)self.volume/100.0f;
            return dvdCell;
            }
        }else if (self.device.hTypeId == 15) { //FM收音机
            FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
            FMCell.delegate = self;
            FMCell.backgroundColor =[UIColor clearColor];
            FMCell.selectionStyle = UITableViewCellSelectionStyleNone;
            FMCell.AddFmBtn.hidden = YES;
            FMCell.FMLayouConstraint.constant = 10;
            FMCell.FMNameLabel.text = self.device.name;
            FMCell.FMNameLabel.font = [UIFont systemFontOfSize:16];
            FMCell.FMSwitchBtn.selected = self.power;
            FMCell.FMSlider.value = (float)self.volume/100.0f;
            return FMCell;
        }else if (self.device.hTypeId == 17) { //幕布
            ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
            ScreenCell.delegate = self;
            ScreenCell.backgroundColor =[UIColor clearColor];
            ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ScreenCell.AddScreenCurtainBtn.hidden = YES;
            ScreenCell.ScreenCurtainConstraint.constant = 10;
            ScreenCell.ScreenCurtainLabel.text = self.device.name;
            ScreenCell.ScreenCurtainLabel.font = [UIFont systemFontOfSize:16];
            
            return ScreenCell;
        }else if (self.device.hTypeId == 16) { //投影仪(只有开关)
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor = [UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            otherCell.NameLabel.font = [UIFont systemFontOfSize:16];
            otherCell.OtherSwitchBtn.selected = self.power;
            return otherCell;
        }else if (self.device.hTypeId == 11) { //电视（以前叫机顶盒）
            
            if (ON_IPAD) {
                IpadTVCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"IpadTVCell" forIndexPath:indexPath];
                tvCell.backgroundColor =[UIColor clearColor];
                tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
                tvCell.AddTvDeviceBtn.hidden = YES;
                tvCell.TVConstraint.constant = 10;
                tvCell.TVNameLabel.text = self.device.name;
                tvCell.TVNameLabel.font = [UIFont systemFontOfSize:16];
                tvCell.TVSwitchBtn.selected = self.device.power;//开关
                tvCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
                return tvCell;
            }else {
            
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.delegate = self;
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = self.device.name;
            tvCell.TVNameLabel.font = [UIFont systemFontOfSize:16];
            tvCell.TVSwitchBtn.selected = self.power;
            tvCell.TVSlider.value = (float)self.volume/100.0f;
            return tvCell;
            }
        }/*else if (self.device.hTypeId == 12) { //网络电视
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = self.device.name;
            return tvCell;
        }*/else if (self.device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            otherCell.NameLabel.font = [UIFont systemFontOfSize:16];
            otherCell.OtherSwitchBtn.selected = self.power;
            return otherCell;
        }else { //其他类型: 智能浇花，智能投食，推窗器
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            otherCell.NameLabel.font = [UIFont systemFontOfSize:16];
            otherCell.OtherSwitchBtn.selected = self.power;
            return otherCell;
        }
        
    }else if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        //应用时段
        UILabel *timeLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(6, 10, 100, 20)];
        timeLabelTitle.textColor = [UIColor whiteColor];
        timeLabelTitle.backgroundColor = [UIColor clearColor];
        timeLabelTitle.textAlignment = NSTextAlignmentLeft;
        timeLabelTitle.font = [UIFont systemFontOfSize:16];
        timeLabelTitle.text = @"应用时段";
        [cell.contentView addSubview:timeLabelTitle];
        
        //时间段 label
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 38, UI_SCREEN_WIDTH-40, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.adjustsFontSizeToFitWidth = YES;
        
        if (!_isEditMode) {
            if (_startTime.length >0 && _endTime.length >0 && _repeatition.length >0) {
                timeLabel.text = [NSString stringWithFormat:@"%@-%@, %@", _startTime, _endTime, _repeatition];
            }
        }else { //编辑模式
            
            if (_repeatition.length >0) {
                timeLabel.text = [NSString stringWithFormat:@"%@-%@, %@", _startTime, _endTime, _repeatition];
            }else {
                timeLabel.text = [NSString stringWithFormat:@"%@-%@, %@", self.startTime, self.endTime, [self repeatString:self.repeatString]];
            }
            
        }
        
        [cell.contentView addSubview:timeLabel];
        
        return cell;
    }else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UILabel *timeLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(6, 10, 100, 20)];
        timeLabelTitle.textColor = [UIColor whiteColor];
        timeLabelTitle.backgroundColor = [UIColor clearColor];
        timeLabelTitle.textAlignment = NSTextAlignmentLeft;
        timeLabelTitle.font = [UIFont systemFontOfSize:16];
        timeLabelTitle.text = @"启用定时";
        [cell.contentView addSubview:timeLabelTitle];
        
        
        //启动按钮
        CGFloat width = UI_SCREEN_WIDTH;
        if (ON_IPAD) {
            width = UI_SCREEN_WIDTH*3/4;
        }
        UIButton *activeBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-52-16, 8, 52, 34)];
        activeBtn.selected = self.isActive;
        [activeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        [activeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        [activeBtn addTarget:self action:@selector(activeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:activeBtn];
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)activeBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    _isActive = btn.selected;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
        UIStoryboard * sceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        IphoneNewAddSceneTimerVC * timerVC = [sceneStoryBoard  instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
        timerVC.isDeviceTimer = YES;
        timerVC.timer = [[DeviceSchedule alloc] initWithoutScheduleByDeviceID:self.device.eID];
        if (_repeatition.length >0) {
            timerVC.repeatitionStr = _repeatition;
        }else {
            timerVC.repeatitionStr = [self repeatString:self.repeatString];
        }
        
        if (_startTime.length >0) {
             timerVC.startTimeStr = _startTime;
        }
        
        if (_endTime.length >0) {
            timerVC.endTimeStr = _endTime;
        }
       
        
        timerVC.isShowInSplitView = YES;
        timerVC.naviTitle = @"设备定时";
        [self.navigationController pushViewController:timerVC animated:YES];
        
        
    }
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(deviceTimerNotification:) name:@"AddSceneOrDeviceTimerNotification" object:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)deviceTimerNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    
    _startTime = dic[@"startDay"];
    _endTime = dic[@"endDay"];
    _repeatition = dic[@"repeat"];
    
    [_timerTableView reloadData];
    
    NSArray *weekArray = dic[@"weekArray"];
    _repeatString =  [NSMutableString string];
    if (weekArray && [weekArray isKindOfClass:[NSArray class]] && weekArray.count >0) {
        
        for (int i=0; i < 7; i++) {
            if ([weekArray[i] intValue] == 1) {
                [_repeatString appendString:[NSString stringWithFormat:@"%d,", i]];
            }
        }
    }
    
}

- (void)dealloc {
    [self removeNotifications];
}


#pragma mark - NewLightCellDelegate
- (void)onLightPowerBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

#pragma mark - ColorLightCellDelegate
- (void)onColourSwitchBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

#pragma mark - CurtainCellDelegate
- (void)onCurtainOpenBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onCurtainSliderBtnValueChanged:(UISlider *)slider deviceID:(int)deviceID {
    
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"2A%@0000", hexString];
    }else {
        _sliderBtnString = @"2AFF0000";//默认值
    }
}

#pragma mark - AirCellDelegate
- (void)onAirSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onAirSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)lroundf(slider.value)]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"6A%@0000", hexString];
    }else {
        _sliderBtnString = @"6AFF0000";//默认值
    }
}

#pragma mark - TVTableViewCellDelegate
- (void)onTVSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onTVSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (电视音量)
    }
}

#pragma mark - DVDTableViewCellDelegate
- (void)onDVDSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onDVDSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (DVD音量)
    }
}

#pragma mark - BjMusicTableViewCellDelegate
- (void)onBjPowerButtonClicked:(UIButton *)btn deviceID:(int)deviceID {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onBjSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (背景音乐音量)
    }
}

#pragma mark - FMTableViewCellDelegate
- (void)onFMSwitchBtnClicked:(UIButton *)btn {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}

- (void)onFMSliderValueChanged:(UISlider *)slider {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)slider.value*100]];
    if (hexString.length == 2) {
        _sliderBtnString = [NSString stringWithFormat:@"AA%@0000", hexString];
    }else {
        _sliderBtnString = @"AAFF0000";//默认值 (FM音量)
    }
}

- (void)onFMChannelSliderValueChanged:(UISlider *)slider {
    float frequence = 80+slider.value*40;// frequence取整后，作为高字节
    int dec = (int)((frequence - (int)frequence)*10);// 小数部分 作为低字节
    
    NSString *hexString_frequence = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", (int)frequence]];
    NSString *hexString_dec = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%2x", dec]];
    if (hexString_frequence.length == 2 && hexString_dec.length == 2) {
        _FMChannelSliderString = [NSString stringWithFormat:@"3A%@%@00", hexString_frequence, hexString_dec];
    }else {
        _FMChannelSliderString = @"3AFFFF00";
    }
}

#pragma mark - ScreenCurtainCellDelegate
- (void)onUPBtnClicked:(UIButton *)btn {
    _switchBtnString = @"33000000"; //幕布--升
}

- (void)onDownBtnClicked:(UIButton *)btn {
    _switchBtnString = @"34000000"; //幕布--降
}

- (void)onStopBtnClicked:(UIButton *)btn {
    _switchBtnString = @"32000000"; //幕布--停
}

#pragma mark - OtherTableViewCellDelegate
- (void)onOtherSwitchBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    if (btn.selected) {
        _switchBtnString = @"01000000";//开
    }else {
        _switchBtnString = @"00000000";//关
    }
}


- (NSString *)repeatString:(NSString *)weekString {
    if (weekString.length <= 0) {
        return @"永不";
    }else {
        NSMutableArray *weekArray = [NSMutableArray array];
        NSArray *arr = [weekString componentsSeparatedByString:@","];
        if (arr.count >0) {
            [weekArray addObjectsFromArray:arr];
        }
        
        //weekArray 删除最后一个元素, 最后一个元素是空白字符
        [weekArray removeObjectAtIndex:weekArray.count-1];
        
        if (weekArray.count >0) {
            NSMutableDictionary *weeksDict = [NSMutableDictionary dictionary];
            for(NSString *weekStr in weekArray) {
                weeksDict[weekStr] = @"1";
            }
            
            int week[7] = {0}; //初始化 7天全为0
            
            for (NSString *key in [weeksDict allKeys]) {
                int index = [key intValue];
                int select = [weeksDict[key] intValue];
                
                week[index] = select;
            }
            
            NSMutableString *display = [NSMutableString string];
            
            if (week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 0 && week[6] == 0) {
                [display appendString:@"永不"];
            }
            else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 1 && week[6] == 1) {
                [display appendString:@"每天"];
            }
            else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 0 && week[6] == 0) {
                [display appendString:@"工作日"];
            }
            else if ( week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 1 && week[6] == 1 ) {
                [display appendString:@"周末"];
            }
            else {
                for (int i = 1; i < 7; i++) {
                    if (week[i] == 1) {
                        switch (i) {
                            case 1:
                                [display appendString:@"周一、"];
                                break;
                                
                            case 2:
                                [display appendString:@"周二、"];
                                break;
                                
                            case 3:
                                [display appendString:@"周三、"];
                                break;
                                
                            case 4:
                                [display appendString:@"周四、"];
                                break;
                                
                            case 5:
                                [display appendString:@"周五、"];
                                break;
                                
                            case 6:
                                [display appendString:@"周六、"];
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
                if (week[0] == 1) {
                    [display appendString:@"周日、"];
                }
            }
            
            return display;
            
        }else {
            return @"永不";
        }
        
    }
}

@end
