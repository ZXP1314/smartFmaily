//
//  systemInfomationController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SystemInfomationController.h"
#import "HttpManager.h"
#import "HomeNameVC.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"


@interface SystemInfomationController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSMutableArray * dicArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewLeadingConstraint;//左边距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewTrailingConstraint;//右边距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1TrailingConstraint;//右边距离

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1LeadingConstraint;//左边距离

@end

@implementation SystemInfomationController
-(NSMutableArray *)dicArr
{
    if (!_dicArr) {
        _dicArr = [NSMutableArray array];
    }
    
    return _dicArr;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableviewLeadingConstraint.constant = 20;
    self.tableviewTrailingConstraint.constant = 20;
    self.view1LeadingConstraint.constant = 20;
    self.view1TrailingConstraint.constant = 20;
    [self.tableView reloadData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
   
       [self setNaviBarTitle:@"系统信息"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
       self.automaticallyAdjustsScrollViewInsets = NO;
       self.titles = @[@"家庭名称",@"主机编号",@"主机品牌",@"主机型号"];
       self.tableView.tableFooterView = [UIView new];

}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array;
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"gainHome.plist"];
    array = [[NSArray alloc] initWithContentsOfFile:filePath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell的点击颜色
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    if (ON_IPAD) {
        cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    }
    if ([cell.textLabel.text isEqualToString:@"家庭名称"]) {
         cell.detailTextLabel.text = [UD objectForKey:@"nickname"];
    }else if ([cell.textLabel.text isEqualToString:@"主机编号"]){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",array[1]];
    }else if ([cell.textLabel.text isEqualToString:@"主机品牌"]){
        cell.detailTextLabel.text = array[2];
    }else if ([cell.textLabel.text isEqualToString:@"主机型号"]){
        cell.detailTextLabel.text = array[3];
    }
   
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 1) {//主人身份
           if (indexPath.row == 0) {
              UIStoryboard * myinfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
              HomeNameVC * homenameVC = [myinfoStoryBoard instantiateViewControllerWithIdentifier:@"HomeNameVC"];
              [self.navigationController pushViewController:homenameVC animated:YES];
         }
    }else{
             [MBProgressHUD showError:@"只有主人才可以修改家庭名称"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
