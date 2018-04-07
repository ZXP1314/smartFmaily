//
//  TitleButton.m
//  SmartHome
//
//  Created by zhaona on 2018/1/21.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import "TitleButton.h"
static const CGFloat NormalSize = 14.0f;
static const CGFloat SelectSize = 18.0f;
@implementation TitleButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.titleLabel.font = [UIFont systemFontOfSize:NormalSize];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.change = 0.0;
    }
    return self;
}

- (void)setChange:(CGFloat)change {
    // 调整文字大小
    CGFloat size = (SelectSize / NormalSize) - 1;
    CGFloat value = size * change;
    self.transform = CGAffineTransformMakeScale(1 + value, 1 + value);
    
    // 调整颜色
    self.titleLabel.textColor = [UIColor colorWithRed:change green:0.0 blue:0.0 alpha:1.0];
//    self.textColor = [UIColor colorWithRed:change green:0.0 blue:0.0 alpha:1.0];
}
@end
