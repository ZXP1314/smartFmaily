//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Light : NSObject

//设备id
@property (nonatomic) int deviceID;
//开关状态
@property (nonatomic) bool isPoweron;
//颜色
@property (nonatomic) NSArray *color;
//亮度
@property (nonatomic) int brightness;
//根据从服务器或者中控传过来的数据初始化设备状态，子类自己实现，实现完以后，(或许发一个notice？上层view接受来更新？)
-(bool) syncFromData:(const Byte*)bytes len:(NSInteger) length;

@end
