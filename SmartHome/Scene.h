//
//  Scene.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCENE_FILE_NAME [[NSUserDefaults standardUserDefaults] objectForKey:@"HostID"]


@interface Scene : NSObject
//场景id
@property (nonatomic,assign) int sceneID;

//场景状态
@property (nonatomic, assign) int status;

//场景名称
@property (nonatomic,strong) NSString * sceneName;

//房间id
@property (nonatomic,assign) int roomID;

//房间名
@property (nonatomic, strong)  NSString  * roomName;

//场景图片url
@property (nonatomic,strong) NSString * picName;
//是否为收藏场景
@property(nonatomic,assign) BOOL isFavorite;
//户型id
@property (nonatomic) long masterID;
//是否系统场景
@property (nonatomic) bool readonly;
//设备列表
@property (strong,nonatomic) NSArray *devices;
//定时列表
@property (strong,nonatomic) NSArray *schedules;

//是否启用定时
@property (assign,nonatomic) int isactive;

//是否有定时
@property (nonatomic, assign) int isplan;

- (instancetype)initWhithoutSchedule;

@end
