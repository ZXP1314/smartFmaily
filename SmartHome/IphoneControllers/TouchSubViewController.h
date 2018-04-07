//
//  TouchSubViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@protocol TouchSubViewDelegate <NSObject>

//收藏
-(void)collectSecene;
//关闭
-(void)colseSecene;

@end

@interface TouchSubViewController : CustomViewController

@property (weak,nonatomic)id<TouchSubViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *sceneName;
@property (weak, nonatomic) IBOutlet UILabel *sceneDescribe;
@property (weak, nonatomic) IBOutlet UIView *sceneView;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) int roomID;


//- (instancetype)initWithTitle:(NSString *)title;
-(void)setSceneName:(UILabel *)sceneName;
-(void)setSceneDescribe:(UILabel *)sceneDescribe;
@end
