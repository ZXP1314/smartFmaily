//
//  AmplifierController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface AmplifierController : CustomViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (nonatomic,assign) BOOL isAddDevice;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *projectSources;
@end
