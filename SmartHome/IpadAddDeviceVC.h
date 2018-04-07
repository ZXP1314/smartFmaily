//
//  IpadAddDeviceVC.h
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@class IpadAddDeviceVC;

@protocol IpadAddDeviceVCDelegate <NSObject>

-(void)IpadAddDeviceVC:(IpadAddDeviceVC *)centerListVC selected:(NSString *)textStr;

@end

@interface IpadAddDeviceVC : CustomViewController

@property (nonatomic,assign) int roomID;
//场景id
@property (nonatomic,assign) int sceneID;

@property (nonatomic,strong) NSArray * Array;

@property (nonatomic,weak) id<IpadAddDeviceVCDelegate> delegate;

@end
