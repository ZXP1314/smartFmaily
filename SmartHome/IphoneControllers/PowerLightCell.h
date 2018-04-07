//
//  PowerLightCell.h
//  SmartHome
//
//  Created by zhaona on 2017/6/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PowerLightCellDelegate;

@interface PowerLightCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *powerLightNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *powerLightBtn;
@property (weak, nonatomic) IBOutlet UIButton *addPowerLightBtn;
@property(nonatomic, strong) NSString *deviceid;
@property (nonatomic,strong) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *powerBtnConstraint;
@property (nonatomic, assign) id<PowerLightCellDelegate>delegate;

-(void) query:(NSString *)deviceid delegate:(id)delegate;

@end

@protocol PowerLightCellDelegate <NSObject>

@optional
- (void)onPowerLightPowerBtnClicked:(UIButton *)btn deviceID:(int)deviceID;

@end
