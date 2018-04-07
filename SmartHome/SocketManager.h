//
//  SocketManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

enum{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@protocol TcpRecvDelegate<NSObject>

-(void)recv:(NSData *)data withTag:(long)tag;

@end

@interface SocketManager : NSObject<AsyncSocketDelegate,AsyncUdpSocketDelegate>

@property (nonatomic, strong) AsyncSocket    *socket;        //socket
@property (nonatomic, strong) AsyncSocket    *testHostServerConnectionStatusSocket;        //测试主机是否可以正常连接socket
@property (nonatomic, copy  ) NSString       *socketHost;    //socket的Host
@property (nonatomic, assign) UInt16          socketPort;     //socket的prot
@property (nonatomic, strong) AsyncUdpSocket *udpSocket;     //udpSocket
@property (nonatomic, retain) NSTimer        *connectTimer;  //计时器--->云端不可用的时候提示消息的
@property (nonatomic, strong) NSMutableData  *receiveData;   //心跳接收的数据
@property (nonatomic, strong) NSMutableData  *receivUdpData;   //心跳接收的数据
@property (nonatomic, assign) int             currentCount;  //当前提示次数
@property (nonatomic ,strong) NSTimer        *heartBeatTimer; //维持心跳连接
@property (nonatomic ,strong) NSTimer        *judgeTimer;     //判断云端、主机是否正常连接
@property (nonatomic ,strong) NSTimer        *checkTimer;     //当云端不可用的时候定时检查是否可用
@property (nonatomic,strong) id delegate;

+ (instancetype)defaultManager;
-(void)socketConnectHost;// socket连接
-(void)cutOffSocket; // 断开socket连接

-(void)initTcp:(NSString *)addr port:(int)port delegate:(id)delegate;
-(void)connectUDP:(int)port;
-(void)connectUDP:(int)port delegate:(id)delegate;
-(void)connectTcp;
- (void) handleUDP:(NSData *)data;



@end
