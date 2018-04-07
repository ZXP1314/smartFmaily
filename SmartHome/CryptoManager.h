//
//  CryptoManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import"GTMBase64.h"

#define DES_KEY @"ecloud88"

@interface NSString (CryptoExtensions)

- (NSString *) md5;
//加密
- (NSString *)encryptWithDes:(NSString *)key;
- (NSString *)decryptWithDes:(NSString *)key;
//将yyyy-MM-dd HH:mm:ss格式时间转换成时间戳
-(long)changeTimeToTimeSp:(NSString *)timeStr;
//生成签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict;

-(NSString *)getCurrentDayYYMMDD;
//编码
- (NSString *)encodeBase;
//解码
- (NSString *)decodeBase;

@end
