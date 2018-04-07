//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Light.h"

@implementation Light
//根据从服务器或者中控传过来的数据初始化设备状态，子类自己实现，实现完以后，(或许发一个notice？上层view接受来更新？)
-(bool) syncFromData:(const Byte*)bytes len:(NSInteger) length
{
//    if([super syncFromData:bytes len:length])
//        return true;
//    Byte action = bytes[12];
//    if(action == [self getActionCode:@"亮度"])
//    {
//        //Byte b1 = bytes[13];
//        //        Byte b2 = bytes[14];
//        [self willChangeValueForKey:@"_light"];
//        _light = bytes[13];
//        [self didChangeValueForKey:@"_light"];
//        return true;
//    }
//    else if(action == [self getActionCode:@"颜色"])
//    {
//        Byte b1 = bytes[13];
//        Byte b2 = bytes[14];
//        Byte b3 = bytes[15];
//        [self willChangeValueForKey:@"_color"];
//        _color = (b1 << 16)+ (b2 << 8)+ b3;
//        [self didChangeValueForKey:@"_color"];
//        return true;
//    }
//
    return true;
}
@end
