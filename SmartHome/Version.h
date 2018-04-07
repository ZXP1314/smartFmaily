//
//  Version.h
//  SmartHome
//
//  Created by zhaona on 2018/2/9.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Version : NSObject<NSCoding>

@property(nonatomic, strong) NSString *contentsStr;//版本更新内容
@property(nonatomic, strong) NSString *versionStr;//版本号
@property(nonatomic,strong)  NSString *addtimeStr;//时间
@property(nonatomic,strong)  NSString *isforce;//是否强制更新
@property(nonatomic,assign)  BOOL prompt;//是否提示过
@property(nonatomic,assign)  int promptNumber;//允许提示的次数

@end
