//
//  DialogManager.h
//  SmartHome
//
//  Created by Brustar on 16/6/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "MBProgressHUD+NJ.h"
#import "CustomViewController.h"
#import "WeChatPayManager.h"
#import "DeliveryAddressSettingViewController.h"

@interface WebManager : CustomViewController <UIWebViewDelegate, UIAlertViewDelegate, CustomNaviBarViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *oauthUrl;
@property (nonatomic, retain) NSString *html;

@property (nonatomic, retain) NSArray *platformNameArray;
@property (nonatomic, retain) NSArray *platformGameObjectArray;
@property (nonatomic, strong) NSString *naviTitle;
@property (nonatomic, assign) BOOL isShowInSplitView;

- (id)initWithHtml:(NSString *)html;
- (id)initWithUrl:(NSString *)aUrl title:(NSString *)title;
+ (void) show:(NSString *)aUrl;

@end
