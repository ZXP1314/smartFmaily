//
//  IpadAddDeviceTypeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//
// SplitViewController 右边视图控制器 Ipad添加设备界面

#import "IpadAddDeviceTypeVC.h"
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
#import "MBProgressHUD+NJ.h"
#import "NewLightCell.h"
#import "IpadTVCell.h"
#import "AireTableViewCell.h"
#import "IpadDVDTableViewCell.h"
#import "PowerLightCell.h"
#import "PackManager.h"


@interface IpadAddDeviceTypeVC ()<UITableViewDelegate,UITableViewDataSource>

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

@end

@implementation IpadAddDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
       self.tableView.tableFooterView = [UIView new];
       self.tableView.allowsSelection = NO;
    
}
-(void)refreshData:(NSArray *)data
{

    self.deviceIdArr = data;
     [self getUI];
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
        if (self.deviceIdArr.count == 0) {
            [MBProgressHUD showSuccess:@"此房间没有此类设备"];
        }
        _htypeID = [SQLManager deviceHtypeIDByDeviceID:[self.deviceIdArr[i] intValue]];
        if (_htypeID == 2) {//调光灯
        [_lightArray addObject:self.deviceIdArr[i]];

        }else if (_htypeID == 1){//开关灯
            [_SwitchLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 3){//调色灯
            [_ColourLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 31){//空调
            [_AirArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 21){//窗帘
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
        return _OtherArray.count;//其他
   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//调灯光
        
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        cell.NewLightNameLabel.text = device.name;
        cell.roomID = self.roomID;
        cell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        cell.deviceid = _lightArray[indexPath.row];
        cell.NewLightSlider.continuous = NO;
        cell.NewLightSlider.hidden = NO;
        cell.deviceid = _lightArray[indexPath.row];
        cell.NewLightPowerBtn.selected = device.power;//开关状态
        cell.NewLightSlider.value = (float)device.bright/100.0f;//亮度状态

//        [cell query:[NSString stringWithFormat:@"%d", device.eID]];
         [cell query:[NSString stringWithFormat:@"%d", device.eID] delegate:self];

        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        cell.scene = _scene;

        
        return cell;
    }if (indexPath.section == 1) {//调色灯
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
        newColourCell.colourNameLabel.text = device.name;
        newColourCell.roomID = self.roomID;
        newColourCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        newColourCell.deviceid = _ColourLightArr[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];

//        [newColourCell query:[NSString stringWithFormat:@"%d", device.eID]];
         [newColourCell query:[NSString stringWithFormat:@"%d", device.eID] delegate:self];

        newColourCell.scene = _scene;

        
        return newColourCell;
    }if (indexPath.section == 2) {//开关灯
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        PowerLightCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"PowerLightCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_SwitchLightArr[indexPath.row] intValue]];
        newColourCell.powerLightNameLabel.text = device.name;
        newColourCell.roomID = self.roomID;
        newColourCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        newColourCell.deviceid = _SwitchLightArr[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];

//        [newColourCell query:[NSString stringWithFormat:@"%d", device.eID]];
         [newColourCell query:[NSString stringWithFormat:@"%d", device.eID] delegate:self];

        newColourCell.scene = _scene;

        
        return newColourCell;
    }
    if (indexPath.section == 3) {//空调
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor =[UIColor clearColor];
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_AirArray[indexPath.row] intValue]];
        aireCell.AireNameLabel.text = device.name;
        aireCell.deviceid = _AirArray[indexPath.row];
        aireCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        aireCell.deviceid = _AirArray[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [aireCell query:[NSString stringWithFormat:@"%d", device.eID]];
        aireCell.scene = _scene;

        
        return aireCell;
    }if (indexPath.section == 4) {//窗帘
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        
        if (_hostType == 0) { //crestron
            CurtainTableViewCell * CurtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
            CurtainCell.backgroundColor = [UIColor clearColor];
            CurtainCell.roomID = self.roomID;
            CurtainCell.sceneid = self.sceneid;
            Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
            CurtainCell.label.text = device.name;
            CurtainCell.deviceid = _CurtainArray[indexPath.row];
            CurtainCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            CurtainCell.deviceid = _CurtainArray[indexPath.row];
            _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
            [CurtainCell query:[NSString stringWithFormat:@"%d", device.eID] delegate:self];
            
            CurtainCell.scene = _scene;
            
            
            return CurtainCell;
        }else { //C4
            CurtainC4TableViewCell * CurtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainC4TableViewCell" forIndexPath:indexPath];
            CurtainCell.backgroundColor = [UIColor clearColor];
            CurtainCell.roomID = self.roomID;
            CurtainCell.sceneid = self.sceneid;
            Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
            CurtainCell.name.text = device.name;
            CurtainCell.deviceid = _CurtainArray[indexPath.row];
            CurtainCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            CurtainCell.deviceid = _CurtainArray[indexPath.row];
            _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
            [CurtainCell query:[NSString stringWithFormat:@"%d", device.eID] delegate:self];
            
            CurtainCell.scene = _scene;
            
            
            return CurtainCell;
        }
        
        
    }if (indexPath.section == 5) {//TV
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        IpadTVCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"IpadTVCell" forIndexPath:indexPath];
        TVCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        TVCell.TVNameLabel.text = device.name;
        TVCell.roomID = self.roomID;
        TVCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        TVCell.deviceid = _TVArray[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [TVCell query:[NSString stringWithFormat:@"%d", device.eID]];
        [TVCell initWithFrame];
        TVCell.scene = _scene;

        
        return TVCell;
    }if (indexPath.section == 6) {//DVD
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        IpadDVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"IpadDVDTableViewCell" forIndexPath:indexPath];
        DVDCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        DVDCell.DVDNameLabel.text = device.name;
        DVDCell.roomID = self.roomID;
        DVDCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        DVDCell.deviceid = _DVDArray[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [DVDCell query:[NSString stringWithFormat:@"%d", device.eID]];
         [DVDCell initWithFrame];
        DVDCell.scene = _scene;

        
        return DVDCell;
    }if (indexPath.section == 7) {//投影
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ProjectArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _ProjectArray[indexPath.row];
        otherCell.roomID = self.roomID;
        otherCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        otherCell.deviceid = _ProjectArray[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [otherCell query:[NSString stringWithFormat:@"%d", device.eID]];
        otherCell.scene = _scene;

        
        return otherCell;
    }if (indexPath.section == 8) {//FM
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
        FMCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_FMArray[indexPath.row] intValue]];
        FMCell.FMNameLabel.text = device.name;
        FMCell.deviceid = _FMArray[indexPath.row];
        FMCell.roomID = self.roomID;
        FMCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [FMCell query:[NSString stringWithFormat:@"%d", device.eID]];
        FMCell.scene = _scene;

        
        return FMCell;
    }if (indexPath.section == 9) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _NetVArray[indexPath.row];
        otherCell.roomID = self.roomID;
        otherCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        otherCell.deviceid = _NetVArray[indexPath.row];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [otherCell query:[NSString stringWithFormat:@"%d", device.eID]];
        otherCell.scene = _scene;

        
        
        return otherCell;
    }if (indexPath.section == 10) {//幕布
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        ScreenCell.ScreenCurtainLabel.text = device.name;
        ScreenCell.deviceid = _MBArray[indexPath.row];
        ScreenCell.roomID = self.roomID;
        ScreenCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [ScreenCell query:[NSString stringWithFormat:@"%d", device.eID]];
        ScreenCell.scene = _scene;

        
        return ScreenCell;
    }if (indexPath.section == 11) {//背景音乐
         [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        BjMusicCell.BjMusicNameLb.text = device.name;
        BjMusicCell.deviceid = _BJMusicArray[indexPath.row];
        BjMusicCell.roomID = self.roomID;
        BjMusicCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        [BjMusicCell query:[NSString stringWithFormat:@"%d", device.eID]];
        [BjMusicCell initWithFrame];
        BjMusicCell.scene = _scene;

        
        return BjMusicCell;
    }
     [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
     [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        otherCell.deviceid = _OtherArray[indexPath.row];
        otherCell.roomID = self.roomID;
        otherCell.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        _scene=[[SceneManager defaultManager] readSceneByID:self.sceneID];
        otherCell.scene = _scene;

        if (_OtherArray.count) {
            Device *device = [SQLManager getDeviceWithDeviceID:[_OtherArray[indexPath.row] intValue]];
            [otherCell query:[NSString stringWithFormat:@"%d", device.eID]];
            if (device.name == nil) {
                otherCell.NameLabel.text = @"";
            }else{
                otherCell.NameLabel.text = device.name;
            }
            
        }
        
        return otherCell;

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
        UITableViewCell *cell;
        if (devID) {
          cell  = [self.tableView viewWithTag:[devID intValue]];
        }
        if(proto.action.state == 0x1A){
            if (proto.deviceType == 2) {
                ((NewLightCell *)cell).NewLightSlider.value = (float)proto.action.RValue/100.0f;
            }
            if (proto.deviceType == 3) {
                ((NewColourCell *)cell).colourSlider.value = (float)proto.action.RValue/100.0f;
            }
        }
        if (proto.action.state == PROTOCOL_ON || proto.action.state == PROTOCOL_OFF) {
            switch (proto.deviceType) {
                case 2:
                    ((NewLightCell *)cell).NewLightPowerBtn.selected = proto.action.state;
                    break;
                case 1:
                    ((PowerLightCell *)cell).powerLightBtn.hidden = !proto.action.state;
                    break;
                case 3:
                    ((NewColourCell *)cell).AddColourLightBtn.hidden = !proto.action.state;
                    break;
                case air:
                    ((AireTableViewCell *)cell).AddAireBtn.hidden = !proto.action.state;
                    break;
                case curtain:
                    
                    if (_hostType == 0) {  //Crestron
                        ((CurtainTableViewCell *)cell).open.selected = proto.action.state;
                        ((CurtainTableViewCell *)cell).AddcurtainBtn.hidden = !proto.action.state;
                    }else { //C4
                        ((CurtainC4TableViewCell *)cell).switchBtn.selected = proto.action.state;
                        ((CurtainC4TableViewCell *)cell).addBtn.hidden = !proto.action.state;
                    }
                    break;
                case TVtype:
                    ((IpadTVCell *)cell).AddTvDeviceBtn.hidden = !proto.action.state;
                    break;
                case DVDtype:
                    ((IpadDVDTableViewCell *)cell).AddDvdBtn.hidden = !proto.action.state;
                    break;
                case FM:
                    ((FMTableViewCell *)cell).AddFmBtn.hidden = !proto.action.state;
                    break;
                case screen:
                    ((ScreenCurtainCell *)cell).AddScreenCurtainBtn.hidden = !proto.action.state;
                    break;
                case bgmusic:
                    ((BjMusicTableViewCell *)cell).AddBjmusicBtn.hidden = !proto.action.state;
                    break;
                default:
                    ((OtherTableViewCell *)cell).AddOtherBtn.hidden = !proto.action.state;
                    break;
            }
        }
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 10 || indexPath.section == 11 || indexPath.section == 1  || indexPath.section == 4) {
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
