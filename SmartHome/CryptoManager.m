//
//  CryptoManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CryptoManager.h"

#define MD5_KEY @"ecloud88"

@implementation NSString (CryptoExtensions)

//生成签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        
        NSString * str = @"";
        
        if (![[dict objectForKey:categoryId] isKindOfClass:[NSString class]]) {
            
            str = [NSString stringWithFormat:@"%@",[dict objectForKey:categoryId]];
        }
        else
        {
            str = [dict objectForKey:categoryId];
        }
        
        if (![str isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            && str
            && ![str isEqual:[NSNull class]]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    
    contentString = [NSMutableString stringWithString:[contentString substringToIndex:contentString.length -1]];
    //添加key字段
    [contentString appendFormat:@"%@",MD5_KEY];
    
    //得到MD5 sign签名
    NSString * md5Sign = [contentString md5];
    
    //输出Debug Info
    
    return md5Sign;
}

//MD5加密
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
///MARK: - --- 时间戳格式化
+ (NSString *)timeToFormat:(NSInteger )time{
    time = time / 1000;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *theday = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *day = [dateFormatter stringFromDate:theday];
    return day;
}
-(NSString *)getCurrentDayYYMMDD{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}

//将yyyy-MM-dd HH:mm:ss格式时间转换成时间戳
-(long)changeTimeToTimeSp:(NSString *)timeStr
{
    long time;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:timeStr];
    time= (long)[fromdate timeIntervalSince1970];
    NSLog(@"%ld",time);
    return time;
}
- (NSString *)encryptWithDes:(NSString *)key
{
    //kCCEncrypt 加密
    return [self encrypt:key encryptOrDecrypt:kCCEncrypt];
}

- (NSString *)decryptWithDes:(NSString *)key
{
    //kCCDecrypt 解密
    return [self encrypt:key encryptOrDecrypt:kCCDecrypt];
}

- (NSString *)encrypt:(NSString *)key encryptOrDecrypt:(CCOperation)encryptOperation
{
    const void *dataIn;
    size_t dataInLength;
    
    if (encryptOperation == kCCDecrypt)//传递过来的是decrypt 解码
    {
        //解码 base64
        NSData *decryptData = [GTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];//转成utf-8并decode
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    }
    else  //encrypt
    {
        NSData* encryptData = [self dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    //CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    
    NSString *initIv = @"12345678";
    const void *vkey = (const void *) [key UTF8String];
    const void *iv = (const void *) [initIv UTF8String];
    
    //CCCrypt函数 加密/解密
    CCCrypt(encryptOperation,//  加密/解密
                       kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       vkey,  //密钥    加密和解密的密钥必须一致
                       kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)//encryptOperation==1  解码
    {
        //得到解密出来的data数据，改变为utf-8的字符串
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    }
    else //encryptOperation==0  （加密过程中，把加好密的数据转成base64的）
    {
        //编码 base64
        NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
        result = [GTMBase64 stringByEncodingData:data];
    }
    
    return result;
}

//编码
- (NSString *)encodeBase;
{
    NSData *data = [self dataUsingEncoding:NSUTF16StringEncoding];
    return [GTMBase64 stringByEncodingData:data];
}
//解码
- (NSString *)decodeBase;
{
    NSData *data = [GTMBase64 decodeString:self];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
    }else{
        return self;
    }
}
@end
