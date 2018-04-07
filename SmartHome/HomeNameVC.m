//
//  HomeNameVC.m
//  SmartHome
//
//  Created by zhaona on 2017/12/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "HomeNameVC.h"
#import "SQLManager.h"
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"
#import "DeviceInfo.h"

@interface HomeNameVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeNameTextfield;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic,assign) int homeid;
@end

@implementation HomeNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNaviBarTitle:@"更改家庭名称"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self.homeNameTextfield addTarget:self action:@selector(endediting) forControlEvents:UIControlEventEditingDidEnd];
    [self setNaviBarRightBtn:_naviRightBtn];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
    
}
-(void)endediting

{
    if (self.homeNameTextfield.text.length == 0) {
        _naviRightBtn.enabled = NO;
        [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }else{
        _naviRightBtn.enabled = YES;
    }
    NSLog(@"停止编辑");
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _naviRightBtn.enabled = NO;
    [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfomation = [SQLManager getUserInfo:userID];
    self.homeNameTextfield.text = [UD objectForKey:@"nickname"];
    
}
- (BOOL)becomeFirstResponder

{
    [super becomeFirstResponder];
    
    return [self.homeNameTextfield becomeFirstResponder];
    
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/home_nickname.aspx",[IOManager SmartHomehttpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    _homeid = [[UD objectForKey:@"home_id"] intValue];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"homeid":@(_homeid),@"nickname":self.homeNameTextfield.text};
        NSLog(@"%@",self.homeNameTextfield.text);
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
                [MBProgressHUD showSuccess:@"更新家庭昵称成功"];
//                [NC postNotificationName:@"nickname" object:self.homeNameTextfield.text];
            //更新家庭名
            [IOManager writeUserdefault:self.homeNameTextfield.text forKey:@"nickname"];
            
        }else{
               [MBProgressHUD showError:@"更新家庭昵称失败"];
        }
        
    }
    
}

-(void)rightBtnClicked:(UIButton *)bbt
{
    if (self.homeNameTextfield.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"没有输入名字，请重新填写" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSString *isDemo = [UD objectForKey:IsDemo];
        if ([isDemo isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"真实用户才可以修改成功"];
        }else{
            [self sendRequest];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
