//
//  DeviceAlertView.m
//  SmartHome
//
//  Created by zhaona on 2018/3/5.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import "DeviceAlertView.h"

@implementation DeviceAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.subView = [[UIView alloc]init];
        [self addSubview:self.subView];
    }
    return self;
}
- (void)layoutSubviews {
    // 一定要调用super的方法
    [super layoutSubviews];
    
    // 确定子控件的frame（这里得到的self的frame/bounds才是准确的）
    CGFloat width = 200;
    CGFloat height = 80;
    self.subView.frame = CGRectMake(0, 0, width, height);
    self.subView.backgroundColor = [UIColor lightGrayColor];
}

@end
