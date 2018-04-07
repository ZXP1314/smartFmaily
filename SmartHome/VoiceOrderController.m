//
//  VoiceOrderController.m
//  SmartHome
//
//  Created by Brustar on 16/8/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "VoiceOrderController.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "IATConfig.h"
#import "FMDatabase.h"
#import "SceneManager.h"
#import "SQLManager.h"
#import "RegexKitLite.h"
#import "SCSiriWaveformView.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIView+Popup.h"

@interface VoiceOrderController ()
@property (weak, nonatomic) IBOutlet UIView *exmapleView;
@property (weak, nonatomic) IBOutlet UILabel *sampleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnLeadingConstrain;

@property (nonatomic,assign) int sceneID;

@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@end

@implementation VoiceOrderController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ON_IPAD) {
        
        self.btnLeadingConstrain.constant = 110;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviBarTitle:@"语音控制"];
    
    //[self naviToHome];
    
    // Do any additional setup after loading the view.
    //通过appid连接讯飞语音服务器，把@"53b5560a"换成你申请的appid
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",@"5743ac2d",@"20000"];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    //创建合成对象，为单例模式
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    
    //设置语音合成的参数
    //合成的语速,取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    //合成的音量;取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个性化发音人列表
    [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    //音频采样率,目前支持的采样率有 16000 和 8000
    [_iFlySpeechSynthesizer setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    ////asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iFlySpeechSynthesizer setParameter:@"tts.pcm" forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
    
    
    
    [self setUpWaveLine];
}
-(void)setUpWaveLine
{
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
        return;
    }
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.waveformView setWaveColor:[UIColor whiteColor]];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0];
    

}
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
}
//输入语音的按钮
- (IBAction)startVoice:(id)sender {
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];

    self.sampleLabel.text = @"";
    self.exmapleView.hidden = YES;
    [self.resultLabel setText:@""];
    [self.resultLabel resignFirstResponder];
    //self.isCanceled = NO;
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        
    }else{
        NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateMeters
{
    CGFloat normalizedValue;
    [self.recorder updateMeters];
    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
    
    [self.waveformView updateWithLevel:normalizedValue];
}

#pragma mark - Private

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}



#pragma mark - IFlySpeechRecognizerDelegate
- (void) onError:(IFlySpeechError *) error
{
}

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    self.resultLabel.hidden = NO;
    [self.recorder stop];
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    //NSString *result =[NSString stringWithFormat:@"%@%@", self.resultLabel.text,resultString];
    
    NSString * resultFromJson =  [self stringFromJson:resultString];
    NSString *result= [NSString stringWithFormat:@"%@%@", self.resultLabel.text,resultFromJson];
    self.resultLabel.text = [result stringByMatching:@"^([\\u4e00-\\u9fa5\\w]+).*" capture:1L];
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试", result);
        NSLog(@"resultFromJson=%@",resultFromJson);
        NSLog(@"isLast=%d,_textView.text=%@",isLast,self.resultLabel.text);
        
        NSArray *scenes = [SQLManager fetchScenes:self.resultLabel.text];
        if ([scenes count]>0) {
            self.sampleLabel.text = @"找到匹配项";
            if ([scenes count]>1) {
                [self pickScenes:scenes];
                return;
            }
            self.sceneID = ((Scene *)[scenes firstObject]).sceneID;
            [[SceneManager defaultManager] startScene:self.sceneID];
            [self performSegueWithIdentifier:@"sceneSegue" sender:self];
        }else{
            self.sampleLabel.text = @"找不到匹配项，请重新说";
        }
    }
}

- (void)pickScenes:(NSArray*)scenes {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 400.0)];
    view.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    int i = 0;
    for (Scene *scene in scenes) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = [NSString stringWithFormat:@"%@:%@",scene.roomName,scene.sceneName];
        [btn setTitle:title forState:UIControlStateNormal];
        
        btn.frame = CGRectMake(50.0, 25.0+i*50, 200.0, 35.0);
        [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             self.sceneID = scene.sceneID;
             [view dismiss];
             [[SceneManager defaultManager] startScene:self.sceneID];
             [self performSegueWithIdentifier:@"sceneSegue" sender:self];
         }];
        [view addSubview:btn];
        i++;
    }
    if (ON_IPAD) {
        if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight) {
            view.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else{
            view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    }
    [view show];
}


- (NSString *)stringFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //返回的格式必须为utf8的,否则发生未知错误
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:[NSNumber numberWithInt:self.sceneID] forKey:@"sceneID"];
    int roomId = [SQLManager getRoomID:self.sceneID];
    
    [theSegue setValue:[NSNumber numberWithInt:roomId] forKey:@"roomID"];
    
}

@end
