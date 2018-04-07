//
//  packManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PackManager.h"
#import "CryptoManager.h"



@implementation PackManager

NSData *dataFromProtocol(Proto protcol)
{
   
    NSMutableData * mutableData = [[NSMutableData alloc] init];
    //头......1byte
    Byte headData[1];
    headData[0] = protcol.head;
    NSData * headData1 = [NSData dataWithBytes:&headData length:1];
    [mutableData appendData:headData1];
    // creston .....在家模式主机没有实现新协议所以暂时不加版本号和mac地址
    DeviceInfo * deviceInfo = [DeviceInfo defaultManager];
    //主机类型：0，creston   1, C4
    NSInteger hostType = [[UD objectForKey:@"HostType"] integerValue];
    if (hostType == 0) {//......creston
        if (deviceInfo.connectState == outDoor) {//在家模式连接到主机---->户外连接到云端
            // +版本号+mac_address+。。。。。7byte
            Byte finalData[7];
            finalData[0] = protcol.version;
            for(int i = 0; i < 6; i++) {
                finalData[i+1]=protcol.macAddress[i];
            }
            NSData * data1 = [NSData dataWithBytes:&finalData length:7];
            [mutableData appendData:data1];
        }
    }else{///.......C4
        // +版本号+mac_address+。。。。。7byte
        Byte finalData[7];
        finalData[0] = protcol.version;
        for(int i = 0; i < 6; i++) {
            finalData[i+1]=protcol.macAddress[i];
        }
        NSData * data1 = [NSData dataWithBytes:&finalData length:7];
        [mutableData appendData:data1];
    }
    //cmd。。。。。1byte
    Byte cmdData[1];
    cmdData[0] = protcol.cmd;
    NSData * cmdData1 = [NSData dataWithBytes:&cmdData length:1];
    [mutableData appendData:cmdData1];
    //hostid。。。。2byte
    NSData * data2 = [NSData dataWithBytes:&protcol.masterID length:sizeof(protcol.masterID)];
    [mutableData appendData:data2];
    //action。。。。。4byte
    Byte finalData1[4];
    finalData1[0] = protcol.action.state;
    finalData1[1] = protcol.action.RValue;
    finalData1[2] = protcol.action.G;
    finalData1[3] = protcol.action.B;
    NSData * data3 = [NSData dataWithBytes:&finalData1 length:4];
    [mutableData appendData:data3];
    //deviceID。。。。。2byte
    NSData * data4 = [NSData dataWithBytes:&protcol.deviceID length:sizeof(protcol.deviceID)];
    [mutableData appendData:data4];
    //deviceType。。。。1byte
    Byte finalData2[1];
    finalData2[0] = protcol.deviceType;
    NSData * data5 = [NSData dataWithBytes:&finalData2 length:1];
    [mutableData appendData:data5];
    //尾部。。。。。1byte
    Byte finalData3[1];
    finalData3[0] = protcol.tail;
    NSData * data6 = [NSData dataWithBytes:&finalData3 length:1];
    [mutableData appendData:data6];
    //  ec 02 01 1c 01 00 00 00 00 02 60 ea 旧的tcp协议格式12byte
    //  ec ff 00 00 00 00 00 00 02 01 1c 01 00 00 00 00 02 60 ea 新的tcp协议加了版本号1byte 加了主机的mac_address 6byte  共19byte
//    NSData *data = [NSData dataWithBytes:&protcol length:sizeof(protcol)];
    //
    
    NSLog(@"tcp sent:%@",mutableData);
    return mutableData;
}

Proto protocolFromData(NSData *data)
{
    // make a new Protocol
    Proto proto;
    Byte *testByte = (Byte *)[data bytes];
    if (data.length == 19) {//第二个字节是ff是新协议19个字节

//        for(int i=0;i<[data length];i++)
            //头+版本号+mac_address+cmd。。。。。9byte
        proto.head = testByte[0];
        proto.version = testByte[1];
        for(int i = 0; i < 6; i++) {
            proto.macAddress[i] = testByte[i+2];
        }
        proto.cmd = testByte[8];
        //hostid。。。。2byte
        proto.masterID = CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue]);
        //场景查询协议 ec ff-->版本号 （6个字节-->mac_address（一个字节-->cmd） (2个字节-->hostid) (一个字节表示--激活场景个数) (两个字节一个场景：场景个数后面的列表是场景ID) ea
        if (proto.cmd == 0x06) {
            proto.SceneNumber = testByte[11];
            for (int k = 0; k < proto.SceneNumber; k++) {
                proto.SceneIDArray[k] = testByte[12+k];
            }
            proto.tail = testByte[data.length-1];
        }else{
            //action。。。。。4byte
            proto.action.state = testByte[11];
            proto.action.RValue = testByte[12];
            proto.action.G = testByte[13];
            proto.action.B = testByte[14];
            
            //deviceID。。。。。2byte 15 16
            Byte bytes[2];
            bytes[0] = testByte[16];// 41
            bytes[1] = testByte[15]; //35
            NSData *deviceID = [NSData dataWithBytes:bytes length:2];
            int datalength;
            [deviceID getBytes: &datalength length: sizeof(datalength)];
            int length=CFSwapInt16BigToHost(datalength);
            proto.deviceID = length;
            
            //尾部类型。。。。。1byte
            proto.deviceType = testByte[17];
            //尾部。。。。。1byte
            proto.tail = testByte[18];
        }
        
    }else{
         proto.head = testByte[0];
         proto.cmd = testByte[1];
         proto.masterID = CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue]);
        //action。。。。。4byte
        proto.action.state = testByte[4];
        proto.action.RValue = testByte[5];
        proto.action.G = testByte[6];
        proto.action.B = testByte[7];
        
        //deviceID。。。。。2byte 15 16
        Byte bytes[2];
        bytes[0] = testByte[9];// 41
        bytes[1] = testByte[8]; //35
        NSData *deviceID = [NSData dataWithBytes:bytes length:2];
        int datalength;
        [deviceID getBytes: &datalength length: sizeof(datalength)];
        int length=CFSwapInt16BigToHost(datalength);
        proto.deviceID = length;
        
        //尾部类型。。。。。1byte
        proto.deviceType = testByte[10];
        //尾部。。。。。1byte
        proto.tail = testByte[11];
       }
    return proto;
}

Proto createProto()
{
    Proto proto;
    proto.head=PROTOCOL_HEAD;
    proto.tail=PROTOCOL_TAIL;
    proto.version = PROTOCOL_VERSION;////-------NewTCP
    NSData* bytesData = [[UD objectForKey:@"mac_address"] dataUsingEncoding:NSUTF8StringEncoding];
    //    Byte * myByte = (Byte *)[bytes bytes];
    NSString *dataStr = [[NSString alloc] initWithData:bytesData encoding:NSUTF8StringEncoding];
    int j = 0;
    //    Byte bytes[6];
    for (int i=0; i<[dataStr length]; i++) {
        int int_ch;///两位16进制数转话后的10进制
        unichar hex_char1 = [dataStr characterAtIndex:i];///两位16进制数中的第一个（高伟*16）
        int int_ch1;
        if(hex_char1>='0' && hex_char1 <= '9'){
            int_ch1 = (hex_char1-48)*16;////0 的ASCII-48
        }else if(hex_char1 >='A' && hex_char1 <='F'){
            int_ch1 = (hex_char1-55)*16;//// A 的 ASCII-65
        }else {
            int_ch1 = (hex_char1-87)*16;///a的ASCII-97
        }
        i++;
        unichar hex_char2 = [dataStr characterAtIndex:i];//两位16进制数中的第二位（低位）
        int int_ch2;
        if(hex_char2>='0' && hex_char2<='9'){
            int_ch2 = (hex_char2-48);
        }else if(hex_char2 >='A' && hex_char2 <='F'){
            int_ch2 = hex_char2-55;
        }else{
            int_ch2 = hex_char2-87;
        }
        int_ch = int_ch1+int_ch2;
        proto.macAddress[j] = int_ch;///将转化后的数放入Byte数组里
        j++;
    }
    proto.cmd = 0;
    proto.action.RValue = 0;
    proto.action.G = 0;
    proto.action.B = 0;
    proto.action.state = 0;
    
    proto.masterID = CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue]);
    return proto;
}

+ (NSData *) fireflyProtocol:(NSString *)cmd
{
    NSData* bytes = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    long len=[cmd length]+4;
    Byte array[]={0,0,0,0,0,0,0,0,0,0,0,0,len,0,0,0,2};
    NSData *data = [NSData dataWithBytes: array length: sizeof(array)];
    NSMutableData *ret=[[NSMutableData alloc] initWithData:data];
    [ret appendData:bytes];
    return ret;
}

+ (BOOL) checkSum:(NSData *)data
{
    NSData *sum = [data subdataWithRange:NSMakeRange([data length]-2, 1)];
    long ret=0x00;
    for (int i=1; i<[data length]-2; i++) {
        ret = ret ^ [self dataToUInt16:[data subdataWithRange:NSMakeRange(i, 1)]];
    }
    return [self dataToUInt16:sum]==ret;
}

+ (BOOL) checkProtocol:(NSData *)data cmd:(long)value
{
    NSData *head;
    NSData *cmd ;
    NSData *tail;
    if (data.length == 12) {
        head = [data subdataWithRange:NSMakeRange(0, 1)];
        cmd  = [data subdataWithRange:NSMakeRange(1, 1)];
        tail = [data subdataWithRange:NSMakeRange([data length]-1, 1)];
    }if (data.length == 19) {
        head = [data subdataWithRange:NSMakeRange(0, 1)];
        cmd  = [data subdataWithRange:NSMakeRange(8, 1)];
        tail = [data subdataWithRange:NSMakeRange([data length]-1, 1)];
    }
   
    return [self dataToUInt16:head]==0xEC && [self dataToUInt16:cmd]==value && [self dataToUInt16:tail]==0xEA;
}

+ (uint16_t) dataToUInt16:(NSData *)data
{
    NSString *result = [NSString stringWithFormat:@"0x%@",[[data description] substringWithRange:NSMakeRange(1, [[data description] length]-2)]];
    unsigned long ret = strtoul([result UTF8String],0,16);
    return ret;
}

+ (NSString *) NSDataToIP:(NSData *)ip
{
    NSData *ip1=[ip subdataWithRange:NSMakeRange(0, 1)];
    NSData *ip2=[ip subdataWithRange:NSMakeRange(1, 1)];
    NSData *ip3=[ip subdataWithRange:NSMakeRange(2, 1)];
    NSData *ip4=[ip subdataWithRange:NSMakeRange(3, 1)];
    
    return [NSString stringWithFormat:@"%hu.%hu.%hu.%hu",[self dataToUInt16:ip1],[self dataToUInt16:ip2],[self dataToUInt16:ip3],[self dataToUInt16:ip4]];
}

+ (NSData*)dataFormHexString:(NSString*)hexString
{
    hexString=[[hexString uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!(hexString && [hexString length] > 0 && [hexString length]%2 == 0)) {
        return nil;
    }
    Byte tempbyte[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyte[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyte length:1];
    }
    return bytes;
}

+ (NSString *)hexStringFromData:(NSData*)data
{
    return [[[[NSString stringWithFormat:@"%@",data]
              stringByReplacingOccurrencesOfString: @"<" withString: @""]
             stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
}

+(uint8_t)dataToUint8:(NSData *)data
{
    Byte* bytes = (Byte*)([data bytes]);
    
    return bytes[0];
}

+ (uint8_t) NSDataToUint8:(NSString *)string
{
    NSString *result = [NSString stringWithFormat:@"0x%@",string];
    unsigned char ret = strtoul([result UTF8String],0,16);
    return ret;
}

+ (uint16_t) NSDataToUint16:(NSString *)string
{
    NSString *result = [NSString stringWithFormat:@"0x%@",string];
    unsigned short ret = strtoul([result UTF8String],0,16);
    return ret;
}
//十进制转换成十六进制
- (NSString *)getHexByDecimal:(NSInteger)decimal
{
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}
@end
