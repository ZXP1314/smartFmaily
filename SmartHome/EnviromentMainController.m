//
//  EnviromentMainController.m
//  SmartHome
//
//  Created by zhaona on 2018/1/21.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import "EnviromentMainController.h"
//#import "TitleLabel.h"
#import "SQLManager.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "TitleButton.h"
#import "MenuModel.h"
#import "AirController.h"
#import "NewWindController.h"

#define kLblWidth [UIScreen mainScreen].bounds.size.width/3
#define kLblHeight 40
static NSString *const menuCellIdentifier = @"rotationCell";

@interface EnviromentMainController ()<UITableViewDataSource,UITableViewDelegate,YALContextMenuTableViewDelegate,UIScrollViewDelegate>
//标题栏
@property (weak, nonatomic) IBOutlet UIScrollView *smallScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallScrollViewTopConstraint;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIView *contentView;
//@property (nonatomic,assign) long lightCatalog;
@property (nonatomic,strong)NSMutableArray *arrayList;
@property (nonatomic,strong)NSMutableArray *deviceNames;
@property (nonatomic,strong)NSMutableArray *xfdeviceNames;//新风
@property (nonatomic,strong)YALContextMenuTableView* contextMenuTableView;
@property (nonatomic, strong)NSString *deviceID;
@property (nonatomic,assign)NSInteger  currentIndex;

@end

@implementation EnviromentMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (Is_iPhoneX) {
        self.smallScrollViewTopConstraint.constant = 88;
    }
    [self commonInit];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self initFirstContent];
}
-(void)commonInit{
     NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 环境",roomName]];
      _deviceNames= [NSMutableArray array];
    self.menus = [SQLManager envDeviceNamesByRoom:self.roomID];
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        if (![_deviceNames containsObject:deviceName]) {
            [_deviceNames addObject:deviceName];
            MenuModel *title = [MenuModel new];
            title.hTypeId  = device.hTypeId;
            title.deviceName = deviceName;
            [self.arrayList addObject:title];
        }
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    //添加子标题
    [self addLabel];
    self.currentIndex = 0;
    //添加默认标题
    TitleButton *titleButton = [self.smallScrollView.subviews firstObject];
    titleButton.titleLabel.textColor = [UIColor redColor];
}
#pragma mark ***********************添加方法
/**
 添加label标题
 */
-(void)addLabel{
    for (int i=0; i<self.arrayList.count; i++) {
        CGFloat lblW = kLblWidth;
        CGFloat lblH = kLblHeight;
        CGFloat lblY = 0;
        CGFloat lblX = i*lblW;
        TitleButton *titleBtn = [TitleButton buttonWithType:UIButtonTypeCustom];
        MenuModel  *title = self.arrayList[i];
        [titleBtn setTitle:title.deviceName forState:UIControlStateNormal];
        titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        titleBtn.frame = CGRectMake(lblX, lblY, lblW, lblH);
        titleBtn.titleLabel.font = [UIFont fontWithName:@"HYQiHei" size:19];
        titleBtn.titleLabel.textColor = [UIColor whiteColor];
        [titleBtn setBackgroundImage:[UIImage imageNamed:@"light_bar"] forState:UIControlStateNormal];
       
        [self.smallScrollView addSubview:titleBtn];
        titleBtn.tag = i;
        titleBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblClick:)];
       [titleBtn addGestureRecognizer:tap];
    }
    self.smallScrollView.contentSize = CGSizeMake(kLblWidth*self.arrayList.count, 0);
    if (self.arrayList.count >= 1) {
        [self initFirstContent];
    }
}

/**
 初始化第一个内容界面
 **/
-(void)initFirstContent{
    MenuModel  *title = self.arrayList[0];
//    MenuModel *title = self.arrayList[index];
    [self initiateMenuOptions:title.hTypeId];
    NSString * deviceName = self.xfdeviceNames[0];
    self.deviceID  = [NSString stringWithFormat:@"%ld",[SQLManager deviceIDByDeviceName:deviceName]];
    MenuModel *titleModel = self.arrayList[self.currentIndex];
    self.deviceID  = [NSString stringWithFormat:@"%ld",[SQLManager deviceIDByDeviceName:_xfdeviceNames[0]]];
    if (titleModel.hTypeId == 31) {//空调
        UIStoryboard * deviceStoryBoard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
        AirController * airVC = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"AirController"];
        airVC.deviceid = self.deviceID;
        //把controller的view添加到内容的view上
        for (UIView * view in self.contentView.subviews) {
            [view removeFromSuperview];
        }
        airVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [airVC.view layoutSubviews];
        [self.contentView addSubview:airVC.view];
        airVC.view.hidden = YES;
        self.contextMenuTableView = nil;
    }
    if (titleModel.hTypeId == 30) {//新风
        UIStoryboard * deviceStoryBoard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
        NewWindController * newWindVC = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"NewWindController"];
        newWindVC.deviceID = self.deviceID;
        //把controller的view添加到内容的view上
        for (UIView * view in self.contentView.subviews) {
            [view removeFromSuperview];
        }
        newWindVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [newWindVC.view layoutSubviews];
        [self.contentView addSubview:newWindVC.view];
        newWindVC.view.hidden = YES;
        self.contextMenuTableView = nil;
    }
}
/**
 标题点击手势
 */
-(void)lblClick:(UITapGestureRecognizer *)tap{
    TitleButton *titleBtn = (TitleButton *)tap.view;
    NSInteger index = titleBtn.tag;
    NSLog(@"点击了标题。。。:%ld",index);
    self.currentIndex = index;
    MenuModel *title = self.arrayList[index];
    [self initiateMenuOptions:title.hTypeId];
    // init YALContextMenuTableView tableView
    if (self.contextMenuTableView) {
        [titleBtn setBackgroundImage:[UIImage imageNamed:@"light_bar"] forState:UIControlStateNormal];
        [self.contextMenuTableView dismisWithIndexPath:0];
        self.contextMenuTableView = nil;
    }else{
        if ([_deviceNames count]>0) {
            [titleBtn setBackgroundImage:[UIImage imageNamed:@"light_bar_pressed"] forState:UIControlStateNormal];
            self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
            self.contextMenuTableView.animationDuration = 0.05;
            self.contextMenuTableView.yalDelegate = self;
            self.contextMenuTableView.menuItemsSide = Left;
            self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
            UINib *cellNib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
            [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
            if (Is_iPhoneX) {
                 [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(104+22,0,0,0) animated:YES];
            }else{
                 [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(80+22,0,0,0) animated:YES];
            }
           
        }
    }
}
#pragma mark - Local methods
- (void)initiateMenuOptions:(long)catalogID {
    _xfdeviceNames= [NSMutableArray array];
    self.menus = [SQLManager envDeviceNamesByRoom:self.roomID];
    for (Device *device in self.menus) {
        NSString * deviceName = [SQLManager deviceNameByDeviceID:device.eID];
        if (device.hTypeId == catalogID) {
            [_xfdeviceNames addObject:deviceName];
        }
    }
    [self.contextMenuTableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _xfdeviceNames.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    cell.menuTitleLabel.text =_xfdeviceNames[indexPath.row];
    [cell setContraint:self.currentIndex+1];
    
    return cell;
}
//#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * deviceName = self.xfdeviceNames[indexPath.row];
    self.deviceID  = [NSString stringWithFormat:@"%ld",[SQLManager deviceIDByDeviceName:deviceName]];
    MenuModel *titleModel = self.arrayList[self.currentIndex];

    if (titleModel.hTypeId == 31) {//空调
        UIStoryboard * deviceStoryBoard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
        AirController * airVC = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"AirController"];
        airVC.deviceid = self.deviceID;
        airVC.roomID = self.roomID;
       //把controller的view添加到内容的view上
        for (UIView * view in self.contentView.subviews) {
            [view removeFromSuperview];
        }
        airVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self.contentView addSubview:airVC.view];
        [tableView dismisWithIndexPath:indexPath];
        self.contextMenuTableView = nil;
    }
    if (titleModel.hTypeId == 30) {//新风
        UIStoryboard * deviceStoryBoard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
        NewWindController * newWindVC = [deviceStoryBoard instantiateViewControllerWithIdentifier:@"NewWindController"];
        newWindVC.deviceID = self.deviceID;
        newWindVC.roomID = self.roomID;
        //把controller的view添加到内容的view上
        for (UIView * view in self.contentView.subviews) {
            [view removeFromSuperview];
        }
         newWindVC.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self.contentView addSubview:newWindVC.view];
        [tableView dismisWithIndexPath:indexPath];
        self.contextMenuTableView = nil;
    }
}
#pragma mark -******************scrollView代理方法
/**
 滚动结束后调用 （代码导致）
 */
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    
}
/**
 滚动结束，手势导致
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self scrollViewDidEndScrollingAnimation:scrollView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- lazy load
-(NSMutableArray *)arrayList{
    if (_arrayList == nil) {
        _arrayList = [NSMutableArray new];
    }
    return  _arrayList;
}

@end
