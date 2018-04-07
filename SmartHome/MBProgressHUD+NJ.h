//
//  MBProgressHUD+NJ.h
//  SmartHome
//
//  Created by Brustar on 16/7/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (NJ)

+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;
+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;
//+(id)showCustomRightDailog:(NSString *)string TwoStr:(NSString *)towStr;//自定义图片
@end
