//
//  SocketManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SocketManager.h"
#import "AsyncUdpSocket.h"
#import "PackManager.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "NetStatusManager.h"
#import "STPingTool.h"

@implementation SocketManager
{
    NSString *_hostServerIP;
    int       _hostServerPort;
    CGFloat   _lossPersent;
}
+ (instancetype)defaultManager {
    static SocketManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        // 如果有问题，注释这里的代码
        [sharedInstance startheartBeat];
    });
    
    return sharedInstance;
}
///启动心跳连接
-(void)startheartBeat{
    self.heartBeatTimer = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(timeInterval:) userInfo:nil repeats:YES];
    self.judgeTimer = [NSTimer timerWithTimeInterval:63.0 target:self selector:@selector(receiveTimer:) userInfo:nil repeats:YES];
    // 如果不把timer2添加到RunLoop中是无法正常工作的(注意如果想要在滚动UIScrollView时timer2可以正常工作可以将NSDefaultRunLoopMode改为NSRunLoopCommonModes)
    [[NSRunLoop currentRunLoop] addTimer:self.heartBeatTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:self.judgeTimer forMode:NSDefaultRunLoopMode];
    
}
///心跳连接要做的事情
-(void)timeInterval:(NSTimer *)timer{
    NSLog(@"心跳连接。。。。APP心跳指令");
    
    NSData *data = [[DeviceInfo defaultManager] heartbeat];
    [self.socket writeData:data withTimeout:1 tag:1];

}
//如果接收到心跳反馈的data说明主机、云端连接正常反之手动断掉socket
-(void)receiveTimer:(NSTimer *)receiveTimer
{
      DeviceInfo * deviceinfo = [DeviceInfo defaultManager];
    if (self.receiveData.length >0) {
        Proto proto=protocolFromData(self.receiveData);
        //一分钟左右如果没有收到心跳指令说明主机 、云端、与APP断链
        if (proto.cmd == 0x32 && proto.masterID == CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue])){
            NSLog(@"主机、云端是正常在线");
            //清空数据
            [self.receiveData resetBytesInRange:NSMakeRange(0, self.receiveData.length)];
            [self.receiveData setLength:0];
        }
    }else{
        if (deviceinfo.connectState == atHome) {//在家
                if (deviceinfo.connectState == atHome) {
                    [self cutOffSocket];//断开socket
                    [self connectTcp];//连接云端
                }
        }
        if (deviceinfo.connectState == outDoor || deviceinfo.connectState == offLine) {//外出
                if (deviceinfo.connectState == outDoor) {
                    [self cutOffSocket];//断开socket
                    deviceinfo.connectState = offLine;//界面制成掉线状态
                    [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
                    self.connectTimer = [NSTimer timerWithTimeInterval:70.0 target:self selector:@selector(massageTimer) userInfo:nil repeats:YES];//定时提醒云端不可用
                    self.checkTimer  = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(CurrentcheckTimer) userInfo:nil repeats:YES];//定时检查云端是否可用
                    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSDefaultRunLoopMode];
                    [[NSRunLoop currentRunLoop] addTimer:self.checkTimer forMode:NSDefaultRunLoopMode];
                }
        }
        
        return;
    }
    
}

// socket连接
-(void)socketConnectHost
{
//    self.socket = nil;
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort error:&error];
}


// 切断socket
-(void)cutOffSocket{
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
//    [self.connectTimer invalidate];
    [self.socket disconnect];
}
-(void)connectUDP:(int)port
{
    if (![NetStatusManager isEnableWIFI]) {
        [self connectTcp];
        return;
    }
    [self connectUDP:port delegate:self];
}

-(void)connectUDP:(int)port delegate:(id)delegate
{
    NSError *bindError = nil;
    self.udpSocket=[[AsyncUdpSocket alloc] initWithDelegate:delegate];//创建udp并设置代理
    [self.udpSocket enableBroadcast:YES error:&bindError];//允许发送消息的设置
    [self.udpSocket bindToPort:port error:&bindError];//绑定端口号
    
    if (bindError) {
        [self connectTcp];
        NSLog(@"bindError = %@",bindError);
        return;
    }
    [self connectTcp];///UDP监听的时候先连接云端
    [self.udpSocket receiveWithTimeout:-1 tag:1]; //接收数据如果设置receiveWithTimeout参数，参数过期就不在接受如果设置为-1时间永远不会超时
    NSLog(@"start udp server");
}

//连接socket
-(void)initTcp:(NSString *)addr port:(int)port delegate:(id)delegate
{
    self.socketHost = addr;
    self.socketPort = port;
    self.delegate = delegate;
    // 在连接前先进行手动断开
    [self cutOffSocket];
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    if (addr != 0 && port != 0)//如果ip、port是0会崩溃
    {
        [self socketConnectHost];//连接Socket

    }
}
//连接云端
- (void) connectTcp
{
    //请求协调服务器
    [self initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] delegate:nil];///
    DeviceInfo *device=[DeviceInfo defaultManager];
    device.masterPort=[IOManager tcpPort];
    device.masterIP=[IOManager tcpAddr];
    device.connectState=outDoor;
    
    NSData *data=[device author];
    [self.socket writeData:data withTimeout:1 tag:1000];
    [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:1000];
}

- (void) handleUDP:(NSData *)data//主机广播
{
    NSString *  tcpcount = [UD objectForKey:@"TCPTure"];//主机和云端在线
    DeviceInfo *info=[DeviceInfo defaultManager];
    if ([PackManager checkProtocol:data cmd:0x80] || [PackManager checkProtocol:data cmd:0x81]) {//UDP广播指令：80或者获取服务器IP：81
        NSData *host;
        NSData *ip;
        NSData *port;
        if (data.length == 12) {
            host = [data subdataWithRange:NSMakeRange(2, 2)];//旧的的是加7
            ip=[data subdataWithRange:NSMakeRange(4, 4)];//旧的的是加7
            port =[data subdataWithRange:NSMakeRange(8, 2)];//旧的的是加7
            
        }
        if (data.length == 19) {
            host = [data subdataWithRange:NSMakeRange(9, 2)];
            ip=[data subdataWithRange:NSMakeRange(11, 4)];
            port =[data subdataWithRange:NSMakeRange(15, 2)];
            
        }
        if(info.masterID!=(int)[PackManager dataToUInt16:host]) {
            if (info.connectState == offLine || info.connectState == atHome) {//连接云端成功
                if ([tcpcount intValue] == 1) {//云端可用
                    [self connectTcp];//连接云端
                }
                return;
            }
        }
        info.masterIP=[PackManager NSDataToIP:ip];
        info.connectState=atHome;
        
        [[STPingTool shareInstance] pingHostWithHostIP:[PackManager NSDataToIP:ip] andBlock:^(NSString *hostIP, CGFloat lossPresent) {
            NSLog(@"丢包率->lossPresent:%f",lossPresent);
            _lossPersent = lossPresent;
            
            if (_lossPersent > 0) {///如果有丢包，说明主机不通，
                //                NSLog(@"丢包率：%f",_lossPersent);
            }else{ // 如果没有丢包，则说明主机通
                [IOManager writeUserdefault:@"0" forKey:@"testHostSeverConnect"];
                
                [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];//连接主机
                [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
            }
        }];
//        //release 不能马上去连，要暂停0.1S,再连从服务器，不然会崩溃
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
////
////             [self testHostserverTcpConnectionStatusWithIP:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];
////
////                NSString * tst = [UD objectForKey:@"testHostSeverConnect"];
//
//           });
    }else{
        if (info.connectState == offLine || info.connectState == atHome) {
            if ([tcpcount intValue] == 1) {//云端可用
                [self connectTcp];//连接云端
            }
        }
    }
}

//MARK:测试主机连接是否可用
-(BOOL)testHostserverTcpConnectionStatusWithIP:(NSString *)ip port:(int)port delegate:(id)delegate{
    self.testHostServerConnectionStatusSocket = nil;
    self.testHostServerConnectionStatusSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    return  [self.testHostServerConnectionStatusSocket connectToHost:ip onPort:port error:&error];
}

- (void) handleTCP:(NSData *)data
{
    if (![PackManager checkProtocol:data cmd:0xef]) {
        NSData *ip;
        NSData *port;
        NSData *masterID;
        if (data.length == 12) {
            ip=[data subdataWithRange:NSMakeRange(4, 4)];
            port=[data subdataWithRange:NSMakeRange(8, 2)];
            masterID =[data subdataWithRange:NSMakeRange(2, 2)];
        }else{
            ip=[data subdataWithRange:NSMakeRange(11, 4)];//旧的的是减7
            port=[data subdataWithRange:NSMakeRange(15, 2)];//旧的的是减7
            masterID =[data subdataWithRange:NSMakeRange(9, 2)];//旧的的是减7
        }
       
        //release 不能马上去连，要暂停0.1S,再连从服务器，不然会崩溃
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            
//            NSString * test223Button = [UD objectForKey:@"test223Button"];
//            if ([test223Button intValue] == 1) {
//                NSString * ip =@"192.168.199.145";
//                NSString * port = @"7000";
//                [self initTcp:ip port:[port intValue] delegate:nil];///转换器
//            }else{
//                [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];//云端
//            }
            
             [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];//云端
          
            DeviceInfo *device=[DeviceInfo defaultManager];
            device.masterPort=(int)[PackManager dataToUInt16:port];
            device.masterIP = [PackManager NSDataToIP:ip];
            device.masterID =(long)[PackManager dataToUInt16:masterID];
            
            //[self.socket writeData:[[DeviceInfo defaultManager] author] withTimeout:-1 tag:0];
            [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
        });
        
    }
}

#pragma mark  - TCP delegate

//连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功,host:%@,port:%d",host,port);
    if ([sock isEqual:self.testHostServerConnectionStatusSocket]) {
        
        [IOManager writeUserdefault:@"1" forKey:@"testHostSeverConnect"];
        
        self.testHostServerConnectionStatusSocket.userData = SocketOfflineByUser;
        [self.testHostServerConnectionStatusSocket disconnect];
        self.testHostServerConnectionStatusSocket = nil;
//        [self sendTestAppCommandToHost];
    }if ([sock isEqual:self.socket]) {
        NSLog(@"当前的socket");
    }
    self.currentCount = 0;
    //连接成功的时候停掉提醒和重连的定时器
    [self.connectTimer invalidate];//取消定时器
    [self.checkTimer invalidate];//取消定时器
    self.connectTimer = nil;
    self.checkTimer    = nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    if (port == device.masterPort) {
        device.connectState=outDoor;
    }else{
        device.connectState=atHome;
    }
    [self.socket writeData:[[DeviceInfo defaultManager] author] withTimeout:-1 tag:0];
    [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
    
    [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
}

//遇到错误时关闭连接
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
//    DeviceInfo * deviceinfo = [DeviceInfo defaultManager];
//    if (deviceinfo.connectState == atHome) {
//        if (err.code == 5) {//Write operation timed out
//            [self connectTcp];//连接云端
//            return;
//        }if (err.code == 60) {//Operation timed out操作超时
//            [self connectTcp];//连接云端
//            return;
//        }
//    }if (deviceinfo.connectState == offLine) {
//        if (err.code == 60) {
//        [self connectTcp];//连接云端
//            return;
//        }
//    }
    
    if (err.code == 64 || err.code == 65) {//Host is down主机被关闭 || No route to host
        [self connectTcp];//连接云端
        return;
    }
    
}

//读取数据完成时回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"received %ld data:%@",tag,data);
//    DeviceInfo * deviceinfo = [DeviceInfo defaultManager];
    Proto proto=protocolFromData(data);
    //一分钟左右如果没有收到心跳指令说明主机 、云端、与APP断链
    if (proto.cmd == 0x32 && proto.masterID == CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue])) {
         self.receiveData = [NSMutableData dataWithData:data];
    }
    if (proto.cmd == 0xc0 && proto.masterID == CFSwapInt16BigToHost([[UD objectForKey:@"HostID"] intValue])) {//云端和主机是断开状态---->云端不可用
        if (proto.action.state == 0x00) {
            //1秒后手动切掉云端的socket连接。。。。进行搜索主机。。。。。15秒后主机也连接不上就提示用户当前APP不可用请检查网络或主机是否可用
            [IOManager writeUserdefault:@"0" forKey:@"TCPTure"];//云端不可用
            self.connectTimer = [NSTimer timerWithTimeInterval:70.0 target:self selector:@selector(massageTimer) userInfo:nil repeats:YES];//定时提醒云端不可用
            self.checkTimer  = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(CurrentcheckTimer) userInfo:nil repeats:YES];//定时检查云端是否可用
            [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] addTimer:self.checkTimer forMode:NSDefaultRunLoopMode];
            [self cutOffSocket];//断掉云端的socket
            DeviceInfo *device=[DeviceInfo defaultManager];
            device.connectState = offLine;//界面制成掉线状态
            [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
            if (self.currentCount == 0) {
                [MBProgressHUD showError:@"目前主机和云端是断开状态"];
            }
            self.currentCount ++;
        }if (proto.action.state == 0x01) {
            [IOManager writeUserdefault:@"1" forKey:@"TCPTure"];//云端可用
            [self.connectTimer invalidate];//取消提醒云端不可用的定时器
            [self.checkTimer invalidate];//取消定时检查云端不可用的定时器
            self.connectTimer = nil;
            self.checkTimer   = nil;
        }
      
    }
    if (proto.cmd == 0x8B) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KICK_OUT object:nil];
        return;
    }
    if (tag == 1000) {//获取重服务器ip
        [self handleTCP:data];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(recv:withTag:)]) {
            [self.delegate recv:data withTag:tag];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
    });
}

-(void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"Received bytes: %ld",partialLength);
}
//掉线重连
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    DeviceInfo *device=[DeviceInfo defaultManager];
    device.connectState=offLine;
    if (sock.userData == SocketOfflineByServer) {// 服务器掉线，重连
        if([NetStatusManager isEnableWWAN])//使用GPRS或者3G网络连接
        {
            [self connectTcp];  //请求协调服务器
        }else{
            [self connect];//重启udp
        }
    }
//    else if (sock.userData == SocketOfflineByUser) {// 如果由用户断开，不进行重连
//        NSString * tcpcount = [UD objectForKey:@"TCPTure"];
//        if ([tcpcount intValue] == 1) {//云端可用
//            [self connectTcp];//连接云端
//        }
//        return;
//    }
}

#pragma mark  - UDP delegate
//已经收到udp广播
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"已经收到udp广播,onUdpSocket:%@",data);
    
    if (data.length == 12) {//旧协议
        [self.heartBeatTimer invalidate];//定时心跳
        self.heartBeatTimer = nil;
        [self.judgeTimer invalidate];
        self.judgeTimer = nil;
    }else{
        [self.heartBeatTimer isValid];
        [self.judgeTimer isValid];
    }
    DeviceInfo *device=[DeviceInfo defaultManager];
    if(device.connectState!=atHome)//没有连接主机
    {
        if (tag == 1) {
            if (data) {
            [self handleUDP:data];
            }
        }
    }
    //接收数据如果设置receiveWithTimeout参数，参数过期就不在接受如果设置为-1时间永远不会超时
    [self.udpSocket receiveWithTimeout:-1 tag:1];
    return YES;
}
//没有发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag.");
}
//没有接受到消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    if(device.connectState!=atHome)
    {
        [self connectTcp];
    }
   NSLog(@"没有接受到消息,didNotReceiveDataWithTag.");
}
//已发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag.");
}
//断开连接
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"断开连接,onUdpSocketDidClose.");
    [self connectTcp];//连接云端
}
- (void)connect
{
    SocketManager *sock = [SocketManager defaultManager];
    if ([[UD objectForKey:@"HostType"] intValue]) {
        [sock connectUDP:[IOManager C4Port]];
    }else{
        [sock connectUDP:[IOManager crestronPort]];
    }
    sock.delegate = self;
}
-(void)massageTimer
{
    [MBProgressHUD showError:@"目前主机和云端是断开状态"];
}
//检查云端是否可用
- (void)CurrentcheckTimer
{
    [self connectTcp];//连接云端
}
@end
