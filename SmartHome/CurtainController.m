//
//  CurtainController.m
//  SmartHome
//
//  Created by Brustar on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainController.h"
#import "CurtainTableViewCell.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"

@interface CurtainController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCurtain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftConstraint;
@property (nonatomic,strong) NSMutableArray *curNames;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewRightConstraint;
@property (nonatomic,strong) NSMutableArray *curtainIDArr;
@property (weak, nonatomic) IBOutlet UIView *promptView;//用来提示开关状态正在设置中
@property (weak, nonatomic) IBOutlet UIImageView *originalImageview;//初始的图标
@property (weak, nonatomic) IBOutlet UIImageView *finishimageView;//要改变成的状态图标

@property (weak, nonatomic) IBOutlet UIWebView *webview;//加载动画
@property (nonatomic,assign)NSInteger currentCellTag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeft;

@end

@implementation CurtainController

-(NSMutableArray *)curtainIDArr
{
    if(!_curtainIDArr)
    {
        _curtainIDArr = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *curtainArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <curtainArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[curtainArr[i] intValue]];
                if([typeName isEqualToString:@"窗帘"])
                {
                    [_curtainIDArr addObject:curtainArr[i]];
                }
            }

        }else if(self.roomID){
            [_curtainIDArr addObjectsFromArray:[SQLManager getDeviceBysubTypeid:CURTAIN_DEVICE_TYPE andRoomID:self.roomID]];
        }else{
            [_curtainIDArr addObject:self.deviceid?self.deviceid:@"0"];
        }
        
        
    }
    return _curtainIDArr;
}

-(NSMutableArray *)curNames
{
    if(!_curNames)
    {
        _curNames = [NSMutableArray array];
        for(int i = 0; i < self.curtainIDArr.count; i++)
        {
            int curtainID = [self.curtainIDArr[i] intValue];
            [_curNames addObject:[SQLManager deviceNameByDeviceID:curtainID]];
        }
        
    }
    return _curNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostType = [[UD objectForKey:@"HostType"] integerValue];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 窗帘",roomName]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainC4TableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainC4TableViewCell"];//C4窗帘
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    for (id did in self.curtainIDArr) {
        //查询设备状态
        NSData *data = [[DeviceInfo defaultManager] query:did];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    [self.tableView reloadData];
    
    if (ON_IPAD) {
        self.tableLeft.constant = self.tableRight.constant = 100;
    }
}

- (void)setupSegmentCurtain
{
    
    if (self.curNames == nil) {
        return;
    }
    
    [self.segmentCurtain removeAllSegments];
    
    for ( int i = 0; i < self.curNames.count; i++) {
        [self.segmentCurtain insertSegmentWithTitle:self.curNames[i] atIndex:i animated:NO];
    }
    
    self.segmentCurtain.selectedSegmentIndex = 0;
    self.deviceid=[self.curtainIDArr objectAtIndex:self.segmentCurtain.selectedSegmentIndex];
}
/*
-(IBAction) changeCurtain:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    long tag = slider.tag;
    NSString *deviceid = [self.curtainIDArr objectAtIndex:tag-100];
    NSData *data=[[DeviceInfo defaultManager] roll:slider.value * 100 deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
}

-(IBAction) toggleCurtain:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    long tag = btn.tag;
    
    UISlider *slider = [self.tableView viewWithTag:100+tag];
    
    NSString *deviceid = [self.curtainIDArr objectAtIndex:tag];
    btn.selected = !btn.selected;
    if (btn.selected) {
        slider.value=1;
        [btn setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
    }else{
        slider.value=0;
        [btn setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateNormal];
    }
    SocketManager *sock=[SocketManager defaultManager];
    NSData *data=[[DeviceInfo defaultManager] toogle:btn.selected deviceID:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:2];
}
*/
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    NSLog(@"%@",data);
    int devID = [[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)] intValue];
    uint8_t stateOn = 1;/// 表示打开状态
    if (![self.curtainIDArr containsObject:@(devID)]) {
        return;
    }
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (_hostType == 0) {  //Crestron
    
      CurtainTableViewCell *cell = [self.tableView viewWithTag:devID];
    
    
    //同步设备状态
    //场景、设备云端反馈状态cmd：01 ，本地反馈状态cmd：02---->新的tcp场景和设备分开了1、设备：云端反馈的cmd：E3、主机反馈的cmd：50   2、场景：云端反馈的cmd：单个场景E5、批量场景E6，主机反馈的cmd：单个场景的cmd：52、批量场景的cmd：53
    if(proto.cmd == 0x01 || proto.cmd == 0x02){
        if (proto.cmd == 0x02) {
            [IOManager writeUserdefault:@"1" forKey:@"SatteCondition"];
            // 收到状态反馈就执行 最少一秒追多五秒
//            [self performSelector:@selector(dimissAlert:)withObject: self.promptView afterDelay:1.0];
        }
         cell.open.selected = proto.action.state == PROTOCOL_ON;
    }
    
    if (tag==0 && (proto.action.state == 0x2A || proto.action.state == PROTOCOL_OFF || proto.action.state == stateOn)) {
        
        if (devID==[self.deviceid intValue]) {
            cell.slider.value=proto.action.RValue/100.0;
            if (proto.action.state == stateOn) {
                cell.slider.value=1;
                [cell.open setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
            }else{
                cell.slider.value=0;
                [cell.open setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateSelected];
            }
        }
    }
        
  }else { //C4
        CurtainC4TableViewCell *cell = [self.tableView viewWithTag:devID];
      
        //同步设备状态
      //场景、设备云端反馈状态cmd：01 ，本地反馈状态cmd：02---->新的tcp场景和设备分开了1、设备：云端反馈的cmd：E3、主机反馈的cmd：50   2、场景：云端反馈的cmd：单个场景E5、批量场景E6，主机反馈的cmd：单个场景的cmd：52、批量场景的cmd：53
        if(proto.cmd == 0x01 || proto.cmd == 0x02){
            if (proto.cmd == 0x02) {
                [IOManager writeUserdefault:@"1" forKey:@"SatteCondition"];
                // 收到状态反馈就执行 最少一秒追多五秒
//                [self performSelector:@selector(dimissAlert:)withObject: self.promptView afterDelay:1.0];
            }
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == stateOn) {
                cell.switchBtn.selected = proto.action.state;
                if (proto.action.state == stateOn) {
                [cell.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
                }else{
                [cell.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateSelected];
                }
            
            }
            [self.tableView reloadData];
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.curtainIDArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_hostType == 0) {  //Crestron
        CurtainTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CurtainTableViewCell" owner:self options:nil] lastObject];
        cell.slider.continuous = NO;
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.label.text = [self.curNames objectAtIndex:indexPath.row];
        cell.deviceid = [self.curtainIDArr objectAtIndex:indexPath.row];
        self.deviceid = cell.deviceid;
        cell.tag = [cell.deviceid integerValue];
        cell.slider.tag = 100+indexPath.row;
        cell.open.tag = indexPath.row;
        cell.AddcurtainBtn.hidden = YES;
        self.currentCellTag = cell.tag;
        cell.curtainContraint.constant = 10;
        [cell.open addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.slider addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }else if (_hostType == 1) {   //C4
        
        CurtainC4TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurtainC4TableViewCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = [self.curNames objectAtIndex:indexPath.row];
        cell.deviceid = [self.curtainIDArr objectAtIndex:indexPath.row];
        cell.tag = [cell.deviceid integerValue];
        self.currentCellTag = cell.tag;
        cell.switchBtn.tag = indexPath.row;
        cell.addBtn.hidden = YES;
        [cell.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
        [cell.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
        cell.switchBtnTrailingConstraint.constant = 10;
        [cell.switchBtn addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.closeBtn addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.stopBtn addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.openBtn addTarget:self action:@selector(OpenClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    return nil;
}

-(void)OpenClicked:(UIButton *)openBtn
{
    if (_hostType == 0) {  //Crestron
        CurtainTableViewCell *cell = [self.tableView viewWithTag:self.currentCellTag];
        if (cell.slider.value==1) {
            self.originalImageview.image = [UIImage imageNamed:@"bd_icon_wd_on"];
            self.finishimageView.image = [UIImage imageNamed:@"bd_icon_wd_off"];
        }else{
            self.originalImageview.image = [UIImage imageNamed:@"bd_icon_wd_off"];
            self.finishimageView.image = [UIImage imageNamed:@"bd_icon_wd_on"];
        }
    }else{   //C4
        CurtainC4TableViewCell *cell = [self.tableView viewWithTag:self.currentCellTag];
        if (cell.switchBtn.selected) {
            self.originalImageview.image = [UIImage imageNamed:@"bd_icon_wd_on"];
            self.finishimageView.image = [UIImage imageNamed:@"bd_icon_wd_off"];
        }else{
            self.originalImageview.image = [UIImage imageNamed:@"bd_icon_wd_off"];
            self.finishimageView.image = [UIImage imageNamed:@"bd_icon_wd_on"];
        }
        
    }
    self.promptView.hidden = NO;
    NSData *gif = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"curtainStar" ofType:@"gif"]];
    self.webview.userInteractionEnabled = NO;
    [self.webview setBackgroundColor:[UIColor clearColor]];
    self.webview.opaque = NO;
    [self.webview loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
     self.webview.scalesPageToFit = YES;
    [self.promptView bringSubviewToFront:self.view];
    self.view.userInteractionEnabled = NO;
    self.promptView.userInteractionEnabled = YES;

    // GCD定时器
    static dispatch_source_t _timer;
    NSTimeInterval period = 1.0; //设置时间间隔
    __block int count=0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
    // 这里写你要反复处理的代码，如网络请求
    count ++;
    NSString * SatteCondition = [UD objectForKey:@"SatteCondition"];
            if ([SatteCondition intValue] == 1) {
                 dispatch_source_cancel(_timer);
                 [self performSelector:@selector(dimissAlert:)withObject: self.promptView afterDelay:0.02];//有收到反馈执行
            }
            // 关闭定时器
            if (count == 5) {
                dispatch_source_cancel(_timer);
                 [self performSelector:@selector(dimissAlert:)withObject: self.promptView afterDelay:0.02];//有收到反馈执行
            }
        });
    });
    // 开启定时器
    dispatch_resume(_timer);
}

- (void) dimissAlert:(UIButton *)alert {
    
    self.promptView.hidden = YES;
    self.view.userInteractionEnabled = YES;
    NSString * SatteCondition = [UD objectForKey:@"SatteCondition"];
    if ([SatteCondition intValue] != 1) {
           [MBProgressHUD showError:@"窗帘操作失败，请重试"];
    }
     [IOManager writeUserdefault:@"0" forKey:@"SatteCondition"];
}
//设置表头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_hostType == 0) {  //Crestron
        
        if (ON_IPAD) {
            return 150.0f;
        }else{
            return 100;
        }
        
    }else if (_hostType == 1) {   //C4
        
        if (ON_IPAD) {
            return 100.0f;
        }else{
            return 100;
        }
    }
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if(indexPath.row == 1)
//    {
//        [self performSegueWithIdentifier:@"detail" sender:self];
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
