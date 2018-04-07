//
//  ColourTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ColourTableViewCell.h"

@implementation ColourTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)lightSwitchChanged:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(lightSwitchValueChanged: deviceID:)]) {
        [_delegate lightSwitchValueChanged:sender deviceID:self.deviceid];
    }
}
@end
