//
//  IpadSceneDetailVC.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadSceneDetailVC.h"
#import "NewLightCell.h"
#import "SQLManager.h"
#import "BgMusicController.h"
//#import "CollectionViewCell.h"
#import "TouchSubViewController.h"
#import "HttpManager.h"
#import "NewColourCell.h"
#import "FMTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "CurtainC4TableViewCell.h"
#import "ScreenCurtainCell.h"
#import "OtherTableViewCell.h"
#import "BjMusicTableViewCell.h"
#import "AddDeviceCell.h"
#import "IphoneNewAddSceneVC.h"
#import "IpadDVDTableViewCell.h"
#import "NewLightCell.h"
#import "IpadTVCell.h"
#import "AireTableViewCell.h"
#import "PowerLightCell.h"



@interface IpadSceneDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)  NSArray * lightArr;//灯光
@property (nonatomic,strong) NSMutableArray * AirArray;//空调
@property (nonatomic,strong) NSMutableArray * TVArray;//TV
@property (nonatomic,strong) NSMutableArray * FMArray;//FM
@property (nonatomic,strong) NSMutableArray * CurtainArray;//窗帘
@property (nonatomic,strong) NSMutableArray * DVDArray;//DVD
@property (nonatomic,strong) NSMutableArray * OtherArray;//其他
@property (nonatomic,strong) NSMutableArray * LockArray;//智能门锁
@property (nonatomic,strong) NSMutableArray * ColourLightArr;//调色
@property (nonatomic,strong) NSMutableArray * SwitchLightArr;//开关
@property (nonatomic,strong) NSMutableArray * lightArray;//调光
@property (nonatomic,strong) NSMutableArray * PluginArray;//智能单品
@property (nonatomic,strong) NSMutableArray * NetVArray;//机顶盒
@property (nonatomic,strong) NSMutableArray * CameraArray;//摄像头
@property (nonatomic,strong) NSMutableArray * ProjectArray;//投影
@property (nonatomic,strong) NSMutableArray * BJMusicArray;//背景音乐
@property (nonatomic,strong) NSMutableArray * MBArray;//幕布
@property (nonatomic,strong) NSMutableArray * IntelligentArray;//智能推窗器
@property (nonatomic,strong) NSMutableArray * PowerArray;//功放
@property (nonatomic,assign) NSInteger htypeID;
@property (weak, nonatomic) IBOutlet UIButton *gentleBtn;//柔和
@property (weak, nonatomic) IBOutlet UIButton *normalBtn;//正常
@property (weak, nonatomic) IBOutlet UIView *patternView;//三种模式的父视图

@property (weak, nonatomic) IBOutlet UIButton *brightBtn;//明亮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TableViewConstraint;

@end

@implementation IpadSceneDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostType = [[UD objectForKey:@"HostType"] integerValue];
    _currentBrightness = 50;
      self.tableView.tableFooterView = [UIView new];
    _isGloom = NO;
    _isRomantic = NO;
    _isSprightly = NO;
    [self.gentleBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_choose_prd"] forState:UIControlStateSelected];
    [self.normalBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_choose_prd"] forState:UIControlStateSelected];
    [self.brightBtn setBackgroundImage:[UIImage imageNamed:@"ipad-btn_choose_prd"] forState:UIControlStateSelected];
    
}

-(void)refreshData:(NSArray *)data
{
    
    self.deviceIdArr = data;
    [self getUI];
    if (_lightArray.count == 0) {
        self.patternView.hidden = YES;
        self.TableViewConstraint.constant = 44;
        
    }else{
        self.patternView.hidden = NO;
        self.TableViewConstraint.constant = 106;
    }
    [self.tableView reloadData];
}

-(void)getUI
{
    _lightArr = [[NSMutableArray alloc] init];//场景下的所有设备
    _lightArray = [[NSMutableArray alloc] init];
    _ColourLightArr = [[NSMutableArray alloc] init];
    _SwitchLightArr = [[NSMutableArray alloc] init];
    _CurtainArray = [[NSMutableArray alloc] init];
    _AirArray = [[NSMutableArray alloc] init];
    _FMArray = [[NSMutableArray alloc] init];
    _TVArray = [[NSMutableArray alloc] init];
    _LockArray = [[NSMutableArray alloc] init];
    _DVDArray = [[NSMutableArray alloc] init];
    _OtherArray = [[NSMutableArray alloc] init];
    _NetVArray = [[NSMutableArray alloc] init];
    _CameraArray = [[NSMutableArray alloc] init];
    _ProjectArray = [[NSMutableArray alloc] init];
    _PluginArray = [[NSMutableArray alloc] init];
    _BJMusicArray = [[NSMutableArray alloc] init];
    _MBArray = [[NSMutableArray alloc] init];
    _PowerArray =[[NSMutableArray alloc] init];
    _IntelligentArray = [[NSMutableArray alloc] init];
    _ColourLightArr = [[NSMutableArray alloc] init];
    _SwitchLightArr = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainC4TableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainC4TableViewCell"];//窗帘(C4)
    [self.tableView registerNib:[UINib nibWithNibName:@"IpadTVCell" bundle:nil] forCellReuseIdentifier:@"IpadTVCell"];//网络电视
    [self.tableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"IpadDVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"IpadDVDTableViewCell"];//DVD
    [self.tableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.tableView registerNib:[UINib nibWithNibName:@"AddDeviceCell" bundle:nil] forCellReuseIdentifier:@"AddDeviceCell"];//添加设备的cell
    [self.tableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//调光灯
    [self.tableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM
     [self.tableView registerNib:[UINib nibWithNibName:@"PowerLightCell" bundle:nil] forCellReuseIdentifier:@"PowerLightCell"];//开关灯
//    NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
    
    for(int i = 0; i <self.deviceIdArr.count; i++)
    {
        _htypeID = [SQLManager deviceHtypeIDByDeviceID:[self.deviceIdArr[i] intValue]];
        if (_htypeID == 2) {//调光灯
            [_lightArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 1){//开关灯
            [_SwitchLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 3){//调色灯
            [_ColourLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 31){//空调
            [_AirArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 21 || _htypeID == 22){//窗帘:21开合帘；22卷帘
            [_CurtainArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 11){//网路电视
            [_TVArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 13){//DVD
            [_DVDArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 16){//投影
            [_ProjectArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 12){//机顶盒
            [_NetVArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 15){//FM
            [_FMArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 14){//背景音乐
            [_BJMusicArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 17){//幕布
            [_MBArray addObject:self.deviceIdArr[i]];
        }else{
            [_OtherArray addObject:self.deviceIdArr[i]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UItableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 13;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _lightArray.count;//调光灯
    }if (section == 1){//调色灯
        return _ColourLightArr.count;
    }if (section == 2){//开关灯
        return _SwitchLightArr.count;
    }
    if (section == 3){
        return _AirArray.count;//空调
    }if (section == 4){
        return _CurtainArray.count;//窗帘
    }if (section == 5){
        return _TVArray.count;//TV
    }if (section == 6){
        return _DVDArray.count;//DVD
    }if (section == 7){
        return _ProjectArray.count;//投影
    }if (section == 8){
        return _FMArray.count;//FM
    }if (section == 9){
        return _NetVArray.count;//机顶盒
    }if (section == 10){
        return _MBArray.count;//幕布
    }if (section == 11){
        return _BJMusicArray.count;//背景音乐
    }
//    if (section == 12){
        return _OtherArray.count;//其他
//    }
//    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *hostID = SCENE_FILE_NAME;
    int deviceID = 0;
    int ispower;
    int  brightness;
    //读取场景文件
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",hostID,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
    
    if (indexPath.section == 0) {//调灯光
        NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.AddLightBtn.hidden = YES;
        cell.LightConstraint.constant = 10;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        cell.NewLightNameLabel.text = device.name;
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        cell.deviceid = _lightArray[indexPath.row];
        cell.NewLightSlider.continuous = NO;
        cell.NewLightSlider.hidden = NO;
        if(dictionary)
        {
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_lightArray[indexPath.row] intValue]) {
                    
                    ispower = [dic[@"isPoweron"] intValue];
                    brightness =[dic[@"brightness"] intValue];
                    cell.NewLightPowerBtn.selected = ispower;
                    cell.NewLightSlider.value = (float)brightness / 100.0f;
                }
                
            }
        }
        if (_isGloom) {
            cell.NewLightPowerBtn.selected = YES;//开关状态
            cell.NewLightSlider.value = _currentBrightness/100.0f;//亮度状态
        }else if (_isRomantic) {
            cell.NewLightPowerBtn.selected = YES;//开关状态
            cell.NewLightSlider.value = _currentBrightness/100.0f;//亮度状态
        }else if (_isSprightly) {
            cell.NewLightPowerBtn.selected = YES;//开关状态
            cell.NewLightSlider.value = _currentBrightness/100.0f;//亮度状态
        }
        
        return cell;
    }if (indexPath.section == 1) {//调色灯
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.AddColourLightBtn.hidden = YES;
        newColourCell.ColourLightConstraint.constant = 10;
        newColourCell.backgroundColor =[UIColor clearColor];
        newColourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
        if(dictionary)
        {
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_ColourLightArr[indexPath.row] intValue]) {
                    
                    ispower = [dic[@"isPoweron"] intValue];
                    newColourCell.colourBtn.selected = ispower;//开关状态
                    
                }
                
            }
        }
        if (_isGloom || _isRomantic || _isSprightly) {
            newColourCell.colourBtn.selected = YES;
        }
        newColourCell.colourNameLabel.text = device.name;
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        newColourCell.deviceid = _ColourLightArr[indexPath.row];
        
        return newColourCell;
    }if (indexPath.section == 2) {//开关灯
        PowerLightCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"PowerLightCell" forIndexPath:indexPath];
        newColourCell.addPowerLightBtn.hidden = YES;
        newColourCell.powerBtnConstraint.constant = 10;
        newColourCell.backgroundColor =[UIColor clearColor];
        newColourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_SwitchLightArr[indexPath.row] intValue]];
        newColourCell.powerLightNameLabel.text = device.name;
        newColourCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        
        if(dictionary)
        {
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_SwitchLightArr[indexPath.row] intValue]) {
                    
                    ispower = [dic[@"isPoweron"] intValue];
                    newColourCell.powerLightBtn.selected = ispower;//开关状态
                    
                }
                
            }
        }
        if (_isGloom || _isRomantic || _isSprightly) {
            newColourCell.powerLightBtn.selected = YES;
        }
        
        return newColourCell;
    }
    if (indexPath.section == 3) {//空调
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.AddAireBtn.hidden = YES;
        aireCell.AireConstraint.constant = 10;
        aireCell.backgroundColor =[UIColor clearColor];
        aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
        aireCell.roomID = self.roomID; 
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_AirArray[indexPath.row] intValue]];
        aireCell.AireNameLabel.text = device.name;
        if(dictionary)
        {
            int poweron;
            int temperature;
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_AirArray[indexPath.row] intValue]) {
                    
                    poweron = [dic[@"poweron"] intValue];
                    temperature = [dic[@"temperature"] intValue];
                    aireCell.AireSwitchBtn.selected = poweron;
                    aireCell.AireSlider.value = temperature;
                    aireCell.temperatureLabel.text = [NSString stringWithFormat:@"%ld°C", lroundf(aireCell.AireSlider.value)];
                    
                }
                
            }
        }
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        aireCell.deviceid = _AirArray[indexPath.row];
        
        
        return aireCell;
    }if (indexPath.section == 4) {//窗帘
        
    if (_hostType == 0) {  //Crestron
        
        CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor = [UIColor clearColor];
        aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
        aireCell.AddcurtainBtn.hidden = YES;
        aireCell.curtainContraint.constant = 10;
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int openvalue;
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_CurtainArray[indexPath.row] intValue]) {
                    
                    openvalue = [dic[@"openvalue"] intValue];
                    aireCell.slider.value = (float)openvalue/100.0f;
                    if (aireCell.slider.value > 0) {
                        aireCell.open.selected = YES;
                    }if (aireCell.slider.value == 0) {
                        aireCell.open.selected = NO;
                    }
                    
                }
                
            }
        }
        aireCell.label.text = device.name;
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        aireCell.deviceid = _CurtainArray[indexPath.row];
        
        
        return aireCell;
    }else {
        CurtainC4TableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainC4TableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor = [UIColor clearColor];
        aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
        aireCell.addBtn.hidden = YES;
        aireCell.switchBtnTrailingConstraint.constant = 10;
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int openvalue;
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_CurtainArray[indexPath.row] intValue]) {
                    
                    openvalue = [dic[@"openvalue"] intValue];
                    
                    if ((float)openvalue/100.0f > 0) {
                        aireCell.switchBtn.selected = YES;
                    }if ((float)openvalue/100.0f == 0) {
                        aireCell.switchBtn.selected = NO;
                    }
                    
                }
                
            }
        }
        
        aireCell.deviceid = _CurtainArray[indexPath.row];
        aireCell.name.text = device.name;
        
        
        return aireCell;
    }
}
    
    
    
    
    if (indexPath.section == 5) {//TV
        IpadTVCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"IpadTVCell" forIndexPath:indexPath];
        TVCell.TVConstraint.constant = 10;
        TVCell.AddTvDeviceBtn.hidden = YES;
        TVCell.backgroundColor =[UIColor clearColor];
        TVCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int poweron;//开关
            int volume;//音量
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_TVArray[indexPath.row] intValue]) {
                    
                    poweron = [dic[@"poweron"] intValue];
                    volume = [dic[@"volume"] intValue];
                    TVCell.TVSwitchBtn.selected = poweron;
                    TVCell.TVSlider.value = (float)volume/100.f;
                    
                }
                
            }
        }
        TVCell.TVNameLabel.text = device.name;
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        TVCell.deviceid = _TVArray[indexPath.row];
        
        return TVCell;
    }if (indexPath.section == 6) {//DVD
        IpadDVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"IpadDVDTableViewCell" forIndexPath:indexPath];
        DVDCell.AddDvdBtn.hidden = YES;
        DVDCell.DVDConstraint.constant = 10;
        DVDCell.backgroundColor =[UIColor clearColor];
        DVDCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int poweron;//开关
            int dvolume;//音量
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_DVDArray[indexPath.row] intValue]) {
                    poweron = [dic[@"poweron"] intValue];
                    dvolume = [dic[@"dvolume"] intValue];
                    DVDCell.DVDSwitchBtn.selected = poweron;
                    DVDCell.DVDSlider.value = (float)dvolume/100.f;
                }
            }
        }
        DVDCell.DVDNameLabel.text = device.name;
//        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        DVDCell.deviceid = _DVDArray[indexPath.row];
        
        return DVDCell;
    }if (indexPath.section == 7) {//投影
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
        otherCell.backgroundColor = [UIColor clearColor];
        otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_ProjectArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _ProjectArray[indexPath.row];
        
        return otherCell;
    }if (indexPath.section == 8) {//FM
        FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
        FMCell.backgroundColor =[UIColor clearColor];
        FMCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_FMArray[indexPath.row] intValue]];
        FMCell.FMNameLabel.text = device.name;
        FMCell.deviceid = _FMArray[indexPath.row];
        FMCell.AddFmBtn.hidden = YES;
        FMCell.FMLayouConstraint.constant = 5;
        
        return FMCell;
    }if (indexPath.section == 9) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
        otherCell.backgroundColor =[UIColor clearColor];
        otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _NetVArray[indexPath.row];
        
        return otherCell;
    }if (indexPath.section == 10) {//幕布
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.AddScreenCurtainBtn.hidden = YES;
        ScreenCell.ScreenCurtainConstraint.constant = 10;
        ScreenCell.backgroundColor =[UIColor clearColor];
        ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int waiting;//开关
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                    
                }
                if (deviceID == [_MBArray[indexPath.row] intValue]) {
                    waiting = [dic[@"waiting"] intValue];
                    ScreenCell.ScreenCurtainBtn.selected = waiting;
                }
            }
        }
        ScreenCell.ScreenCurtainLabel.text = device.name;
        ScreenCell.deviceid = _MBArray[indexPath.row];
        
        return ScreenCell;
    }if (indexPath.section == 11) {//背景音乐
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        BjMusicCell.selectionStyle = UITableViewCellSelectionStyleNone;
        BjMusicCell.AddBjmusicBtn.hidden = YES;
        BjMusicCell.BJmusicConstraint.constant = 10;
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        if(dictionary)
        {
            int poweron;//开关
            int bgvolume;//音量
            for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                if([dic objectForKey:@"deviceID"])
                {
                    deviceID = [dic[@"deviceID"] intValue];
                }
                if (deviceID == [_BJMusicArray[indexPath.row] intValue]) {
                    poweron = [dic[@"poweron"] intValue];
                    bgvolume = [dic[@"bgvolume"] intValue];
                    BjMusicCell.BjPowerButton.selected = poweron;
                    BjMusicCell.BjSlider.value = (float)bgvolume / 100.0f;
                }
            }
        }
        BjMusicCell.BjMusicNameLb.text = device.name;
        BjMusicCell.deviceid = _BJMusicArray[indexPath.row];
        
        return BjMusicCell;
    }
//    if (indexPath.section == 12) {//其他
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
        otherCell.backgroundColor = [UIColor clearColor];
        otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
        otherCell.deviceid = _OtherArray[indexPath.row];
        if (_OtherArray.count) {
            Device *device = [SQLManager getDeviceWithDeviceID:[_OtherArray[indexPath.row] intValue]];
            if(dictionary)
            {
                int waiting;//开关
                for (NSDictionary *dic in [dictionary objectForKey:@"devices"]){
                    
                    if([dic objectForKey:@"deviceID"])
                    {
                        deviceID = [dic[@"deviceID"] intValue];
                        
                    }
                    if (deviceID == [_OtherArray[indexPath.row] intValue]) {
                        waiting = [dic[@"waiting"] intValue];
                        otherCell.OtherSwitchBtn.selected = waiting;
                    }
                }
            }
            if (device.name == nil) {
                otherCell.NameLabel.text = @"";
            }else{
                otherCell.NameLabel.text = device.name;
            }
            
        }
        
        return otherCell;
//    }
//    AddDeviceCell * addDeviceCell = [tableView dequeueReusableCellWithIdentifier:@"AddDeviceCell" forIndexPath:indexPath];
//    addDeviceCell.backgroundColor = [UIColor clearColor];
//    
//    return addDeviceCell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 13) {
        UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        IphoneNewAddSceneVC * devicesVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
        devicesVC.roomID = self.roomID;
        devicesVC.sceneID = self.sceneID;
        [self.navigationController pushViewController:devicesVC animated:YES];
        //        [self performSegueWithIdentifier:@"NewAddDeviceSegue" sender:self];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 10 || indexPath.section == 11 || indexPath.section == 1 || indexPath.section == 4) {
        
        if (indexPath.section == 4 && _hostType != 0) {
            return 100;
        }
        
        return 150;
    }
    if (indexPath.section == 9 || indexPath.section == 7 || indexPath.section == 12 || indexPath.section == 2) {
        return 80;
    }
    if (indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 8 ) {
        return 210;
    }
    return 100;
}

//柔和
- (IBAction)gentleBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isGloom = YES;
        self.normalBtn.selected = NO;
        self.brightBtn.selected = NO;
        _isRomantic = NO;
        _isSprightly = NO;
    }
    
    if (_lightArray.count >0) {
        if (_currentBrightness <=0) {
            NSNumber *lightID = _lightArray[0];
            Device *light = [SQLManager getDeviceWithDeviceID:lightID.intValue];
            _currentBrightness = (int)light.bright - 5;
        }else {
            _currentBrightness -= 5;
        }
        if (_currentBrightness < 20) {
            _currentBrightness = 20;
        }
        [[SceneManager defaultManager] gloomForRoomLights:_lightArray brightness:_currentBrightness];
    }
    [self.tableView reloadData];
    
}

//正常
- (IBAction)normalBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isRomantic = YES;
        self.gentleBtn.selected = NO;
        self.brightBtn.selected = NO;
        _isGloom = NO;
        _isSprightly = NO;
        
        if (_lightArray.count >0) {
            _currentBrightness = 50;
            [[SceneManager defaultManager] romanticForRoomLights:_lightArray];
        }
        
        [self.tableView reloadData];
    }
}

//明亮
- (IBAction)brightBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isSprightly = YES;
        self.gentleBtn.selected = NO;
        self.normalBtn.selected = NO;
        _isGloom = NO;
        _isRomantic = NO;
    }
    
    if (_lightArray.count >0) {
        if (_currentBrightness <=0) {
            NSNumber *lightID = _lightArray[0];
            Device *light = [SQLManager getDeviceWithDeviceID:lightID.intValue];
            _currentBrightness = (int)light.bright + 5;
        }else {
            _currentBrightness += 5;
        }
        if (_currentBrightness > 100) {
            _currentBrightness = 100;
        }
        [[SceneManager defaultManager] sprightlyForRoomLights:_lightArray brightness:_currentBrightness];
    }
    
    [self.tableView reloadData];
}


@end
