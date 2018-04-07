//
//  NewLightCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewLightCellDelegate;

@interface NewLightCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *NewLightNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *NewLightPowerBtn;
@property (weak, nonatomic) IBOutlet UISlider *NewLightSlider;
@property(nonatomic, copy)  NSString *deviceid;
@property (nonatomic,weak)  NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
//@property (nonatomic,assign) NSInteger sceneID;
@property (weak, nonatomic) IBOutlet UIButton *AddLightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supImageViewHeight;

@property (nonatomic, assign) id<NewLightCellDelegate> delegate;
-(void) query:(NSString *)deviceid delegate:(id)delegate;
@end


@protocol NewLightCellDelegate <NSObject>

@optional
- (void)onLightPowerBtnClicked:(UIButton *)btn deviceID:(int)deviceID;
- (void)onLightSliderValueChanged:(UISlider *)slider deviceID:(int)deviceID;

@end
