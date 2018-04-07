//
//  FMTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMTableViewCellDelegate;

@interface FMTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *FMNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *FMSlider;//音量
@property (weak, nonatomic) IBOutlet UISlider *FMChannelSlider;//调节频道
@property (weak, nonatomic) IBOutlet UILabel *FMChannelLabel;
@property (weak, nonatomic) IBOutlet UIButton *AddFmBtn;
@property (weak, nonatomic) IBOutlet UIButton *FMSwitchBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FMLayouConstraint;

@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<FMTableViewCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IpadHomePageBgHeight;//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FMchoiceHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fmchannelSliderTopConstraint;
-(void) query:(NSString *)deviceid;
//-(void) query:(NSString *)deviceid withRoom:(uint8_t)rid;
@end


@protocol FMTableViewCellDelegate <NSObject>

@optional
- (void)onFMSwitchBtnClicked:(UIButton *)btn;
- (void)onFMSliderValueChanged:(UISlider *)slider;
- (void)onFMChannelSliderValueChanged:(UISlider *)slider;

@end
