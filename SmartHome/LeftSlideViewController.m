//
//  LeftSlideViewController.m
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "LeftSlideViewController.h"
#import "AppDelegate.h"


@interface LeftSlideViewController ()<UIGestureRecognizerDelegate>
{
    CGFloat _scalef;  //实时横向位移
    
}

@property (nonatomic,assign) CGFloat leftTableviewW;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UITableView *leftTableview;
@property (nonatomic,strong)UIView * buttonView;

@end

@implementation LeftSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ON_IPONE) {
        [self creatSettButtonView];//设置/换肤View
    }
}

/**
 @brief 初始化侧滑控制器
 @param leftVC 左视图控制器
 mainVC 中间视图控制器
 @result instancetype 初始化生成的对象
 */
- (instancetype)initWithLeftView:(UIViewController *)leftVC
                     andMainView:(UIViewController *)mainVC
{
    if(self = [super init]){
        self.speedf = vSpeedFloat;
        
        self.leftVC = (LeftViewController *)leftVC;
        self.leftVC.delegate = self;
        self.mainVC = mainVC;
        
        //滑动手势
        self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        self.pan.delegate = self;
        
        self.leftVC.view.hidden = YES;
        
        [self.view addSubview:self.leftVC.view];
        
        //蒙版
        UIView *view = [[UIView alloc] init];
        view.frame = self.leftVC.view.bounds;
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        self.contentView = view;
        [self.leftVC.view addSubview:view];
        
        //获取左侧tableview
        for (UIView *obj in self.leftVC.view.subviews) {
            if ([obj isKindOfClass:[UITableView class]]) {
                self.leftTableview = (UITableView *)obj;
            }
        }
        
        self.leftTableview.backgroundColor = [UIColor clearColor];
        self.leftTableview.frame = CGRectMake(0, 0, kScreenWidth - kMainPageDistance, kScreenHeight-60);
        //设置左侧tableview的初始位置和缩放系数
//        self.leftTableview.transform = CGAffineTransformMakeScale(kLeftScale, kLeftScale);
//        self.leftTableview.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
        
        [self.view addSubview:self.mainVC.view];
        self.closed = YES;//初始时侧滑窗关闭
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.leftVC.view.hidden = NO;
}

#pragma mark - 滑动手势

//滑动手势
- (void) handlePan: (UIPanGestureRecognizer *)rec{
    
    CGPoint point = [rec translationInView:self.view];
    _scalef = (point.x * self.speedf + _scalef);

    BOOL needMoveWithTap = YES;  //是否还需要跟随手指移动
    if (((self.mainVC.view.x <= 0) && (_scalef <= 0)) || ((self.mainVC.view.x >= (kScreenWidth - kMainPageDistance )) && (_scalef >= 0)))
    {
        //边界值管控
        _scalef = 0;
        needMoveWithTap = NO;
    }
    
    //根据视图位置判断是左滑还是右边滑动
    if (needMoveWithTap && (rec.view.frame.origin.x >= 0) && (rec.view.frame.origin.x <= (kScreenWidth - kMainPageDistance)))
    {
        CGFloat recCenterX = rec.view.center.x + point.x * self.speedf;
        if (recCenterX < kScreenWidth * 0.5 - 2) {
            recCenterX = kScreenWidth * 0.5;
        }
        
        CGFloat recCenterY = rec.view.center.y;
        
        rec.view.center = CGPointMake(recCenterX,recCenterY);

        //scale 1.0~kMainPageScale
        CGFloat scale = 1 - (1 - kMainPageScale) * (rec.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
    
        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,scale, scale);
        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
        
        CGFloat leftTabCenterX = kLeftCenterX + ((kScreenWidth - kMainPageDistance) * 0.5 - kLeftCenterX) * (rec.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        
        
        //leftScale kLeftScale~1.0
        CGFloat leftScale = kLeftScale + (1 - kLeftScale) * (rec.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        
        self.leftTableview.center = CGPointMake(leftTabCenterX, kScreenHeight * 0.5);
        self.leftTableview.transform = CGAffineTransformScale(CGAffineTransformIdentity, leftScale,leftScale);
        
        //tempAlpha kLeftAlpha~0
        CGFloat tempAlpha = kLeftAlpha - kLeftAlpha * (rec.view.frame.origin.x / (kScreenWidth - kMainPageDistance));
        self.contentView.alpha = tempAlpha;

    }
    else
    {
        //超出范围，
        if (self.mainVC.view.x < 0)
        {
            [self closeLeftView];
            _scalef = 0;
        }
        else if (self.mainVC.view.x > (kScreenWidth - kMainPageDistance))
        {
            [self openLeftView];
            _scalef = 0;
        }
    }
    
    //手势结束后修正位置,超过约一半时向多出的一半偏移
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (fabs(_scalef) > vCouldChangeDeckStateDistance)
        {
            if (self.closed)
            {
                [self openLeftView];
            }
            else
            {
                [self closeLeftView];
            }
        }
        else
        {
            if (self.closed)
            {
                [self closeLeftView];
            }
            else
            {
                [self openLeftView];
            }
        }
        _scalef = 0;
    }
}


#pragma mark - 单击手势
-(void)handeTap:(UITapGestureRecognizer *)tap{
    
    if ((!self.closed) && (tap.state == UIGestureRecognizerStateEnded))
    {
        [UIView beginAnimations:nil context:nil];
        //tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        //tap.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        self.mainVC.view.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        self.closed = YES;
        
        self.leftTableview.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
        self.leftTableview.transform = CGAffineTransformScale(CGAffineTransformIdentity,kLeftScale,kLeftScale);
        self.contentView.alpha = kLeftAlpha;
        [self.view bringSubviewToFront:self.mainVC.view];
        
        [UIView commitAnimations];
        _scalef = 0;
        [self removeSingleTap];
    }
    
}

#pragma mark - LeftViewControllerDelegate
- (void)onBackgroundBtnClicked:(UIButton *)btn {
    if (!self.closed)
    {
        [UIView beginAnimations:nil context:nil];
        self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        self.mainVC.view.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        self.closed = YES;
        
//        self.leftTableview.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
//        self.leftTableview.transform = CGAffineTransformScale(CGAffineTransformIdentity,kLeftScale,kLeftScale);
        self.contentView.alpha = kLeftAlpha;
        [self.view bringSubviewToFront:self.mainVC.view];
        
        [UIView commitAnimations];
        _scalef = 0;
    }
}

#pragma mark - 修改视图位置
/**
 @brief 关闭左视图
 */
- (void)closeLeftView
{
    [UIView beginAnimations:nil context:nil];
    self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    self.mainVC.view.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    self.closed = YES;
    
//    self.leftTableview.center = CGPointMake(kLeftCenterX, kScreenHeight * 0.5);
//    self.leftTableview.transform = CGAffineTransformScale(CGAffineTransformIdentity,kLeftScale,kLeftScale);
    self.contentView.alpha = kLeftAlpha;
    [self.view bringSubviewToFront:self.mainVC.view];
    
    [UIView commitAnimations];
    [self removeSingleTap];
}

/**
 @brief 打开左视图
 */
- (void)openLeftView
{
    [UIView beginAnimations:nil context:nil];
    self.mainVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kMainPageScale,kMainPageScale);
    //self.mainVC.view.center = kMainPageCenter;
    self.mainVC.view.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    self.closed = NO;
    
//    self.leftTableview.center = CGPointMake((kScreenWidth - kMainPageDistance) * 0.5, kScreenHeight * 0.5);
//    self.leftTableview.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    [self.view bringSubviewToFront:self.leftVC.view];
    [self.view bringSubviewToFront:_buttonView];
//    [self.leftVC refreshUI];
    self.contentView.alpha = 0;
    
    [UIView commitAnimations];
    //[self disableTapButton];
}

#pragma mark - 行为收敛控制
- (void)disableTapButton
{
    for (UIButton *tempButton in [_leftVC.view subviews])
    {
        [tempButton setUserInteractionEnabled:YES];
    }
    //单击
    if (!self.sideslipTapGes)
    {
        //单击手势
        self.sideslipTapGes= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handeTap:)];
        [self.sideslipTapGes setNumberOfTapsRequired:1];
        
        [self.leftVC.view addGestureRecognizer:self.sideslipTapGes];
        self.sideslipTapGes.cancelsTouchesInView = YES;  //点击事件盖住其它响应事件,但盖不住Button;
    }
}

//关闭行为收敛
- (void)removeSingleTap
{
    for (UIButton *tempButton in [self.leftVC.view  subviews])
    {
        [tempButton setUserInteractionEnabled:YES];
    }
    [self.leftVC.view removeGestureRecognizer:self.sideslipTapGes];
    self.sideslipTapGes = nil;
}

/**
 *  设置滑动开关是否开启
 *
 *  @param enabled YES:支持滑动手势，NO:不支持滑动手势
 */

- (void)setPanEnabled: (BOOL) enabled
{
    [self.pan setEnabled:enabled];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if(touch.view.tag == vDeckCanNotPanViewTag)
    {
//        NSLog(@"不响应侧滑");
        return NO;
    }
    else
    {
//        NSLog(@"响应侧滑");
        return YES;
    }
}
//设置/换肤View
-(void)creatSettButtonView
{
    _buttonView = [[UIView alloc] init];
    _buttonView.frame = CGRectMake(0, kScreenHeight-60,kScreenWidth - kMainPageDistance,60);
    _buttonView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1.0];
    //设置
    CGFloat settingY = 20.0f;
    CGFloat settingX = 180.0f;
        if (UI_SCREEN_WIDTH == 320) {
            settingX = 150.0f;
        }
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, settingY, 50, 20)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"my_setting"] forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:settingBtn];
    
    NSInteger IsVersion = [[UD objectForKey:@"IsVersion"] integerValue];
    //版本升级的提示
    UILabel * massegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, settingY, 6, 6)];
    massegeLabel.backgroundColor = [UIColor redColor];
    massegeLabel.layer.masksToBounds = YES;
    massegeLabel.layer.cornerRadius = 3;
    if (IsVersion == 1) {
        [self.buttonView addSubview:massegeLabel];
    }
   
    //皮肤
    UIButton *skinBtn = [[UIButton alloc] initWithFrame:CGRectMake(settingX, settingY, 50, 20)];
    [skinBtn setTitle:@"皮肤" forState:UIControlStateNormal];
    [skinBtn setImage:[UIImage imageNamed:@"skin"] forState:UIControlStateNormal];
    skinBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [skinBtn addTarget:self action:@selector(skinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:skinBtn];
    [self.view addSubview:_buttonView];
  
}
- (void)settingBtnClicked:(UIButton *)btn {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        if (_delegate && [_delegate respondsToSelector:@selector(didSelectItem:)]) {
//            [_delegate didSelectItem:@"设置"];
//        }
        [self didSelectItem:@"设置"];
    }else {
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate.LeftSlideVC closeLeftView];
         [self closeLeftView];//关闭左侧抽屉
        
        MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
        mysettingVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
        
    }
}

- (void)skinBtnClicked:(UIButton *)btn {
    [MBProgressHUD showError:@"待开发"];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
