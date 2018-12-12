//
//  TestViewController.m
//  DebugController
//
//  Created by 闫士伟 on 2018/7/31.
//  Copyright © 2018年 com.ysw. All rights reserved.
//

#import "TestViewController.h"
#import "DebugController.h"
#import "AppDelegate.h"
#import "NetWorkingManager.h"
#import "UIView+Debug_Additions.h"
#import "DebugAlertView.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    self.title = @"调试Demo";
    
    [self testRequest_Get];
    [self testRequest_Post];
    [self testDebuger];
}

- (void)testRequest_Get {
    [self creatButtonWithFrame:CGRectMake(10, 100, self.view.width - 20, 50) selector:@selector(startGetRequest) title:@"触发GET请求"];
}

- (void)testRequest_Post {
    [self creatButtonWithFrame:CGRectMake(10, 200, self.view.width - 20, 50) selector:@selector(startPostRequest) title:@"触发POST请求"];
}

- (void)testDebuger {
    [self creatButtonWithFrame:CGRectMake(10, self.view.bounds.size.height - 65, self.view.bounds.size.width - 20, 50) selector:@selector(pushDebuger) title:@"潘多拉魔盒"];
}




- (UIButton *)creatButtonWithFrame:(CGRect)frame selector:(SEL)selector title:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blackColor];
    button.layer.borderColor = [UIColor cyanColor].CGColor;
    button.layer.borderWidth = 2;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
    return button;
}

#pragma mark - action
- (void)startGetRequest {
    NSString *ld = [NSString stringWithFormat:@"2037934916%07u",arc4random() % 10000000];
    NSString *sdk_key = @"SaSlM3UNCktNEZWPu_w7X_2XUmzOnxzDWQzuTRFgA72OgTpTTkg4kicCTaaEWTS1zPvRs960H8PyhDVEyBJfux";
    NSDictionary *paramDic = @{@"dx":@568,
                               @"dy":@320,
                               @"platform":@"ios",
                               @"etf":@334,
                               @"accept":@"video",
                               @"carrier":@"%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8",
                               @"locale":@"zh_CN",
                               @"sdk_version":@"4.2.1",
                               @"require":@"VIDEOA",
                               @"preloading":@YES,
                               @"cookie":@"",
                               @"network":@"wifi",
                               @"ld":ld,
                               @"volume":@18,
                               @"si":@1,
                               @"brand":@"Apple",
                               @"m":@"DIRECT",
                               @"model":@"iPhone",
                               @"ct":@(-1),
                               @"idfa":[NSUUID UUID].UUIDString,
                               @"format":@"json",
                               @"revision":@"iPhone8,1",
                               @"li":@1,
                               @"orientation_lock":@"landscape",
                               @"os":@"10.2.1",
                               @"country_code":@"CN",
                               @"api_did":@"10c843161502a2bb4d",
                               @"tz_offset":@8,
                               @"size":@"INTER",
                               @"dt":@"58097.11098670959",
                               @"ntf":@"wifi",
                               @"pd":@0,
                               @"ia":@"1515999693000",
                               @"vz":@"41ae1985866e8c5b",
                               @"sdk_key":sdk_key,
                               @"app_version":@38,
                               @"dnt":@NO
                               };
    
    [[NetWorkingManager shareManager] GET:@"https://a.applovin.com/3.0/ad" parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Get请求成功回调");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Get请求失败回调");
    }];
}
- (void)startPostRequest {
    NSString *idfaStr = [NSUUID UUID].UUIDString;
    NSDictionary *paramDic =  @{@"ifa": idfaStr,
                                @"pubAppId": @"59542a7029f68805550026ef",
                                @"deviceInfo": @{
                                        @"volume": @(0.5),
                                        @"connectionDetail": @"wifi",
                                        @"userAgent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Mobile/14D27",
                                        @"batteryState": @"charging",
                                        @"dim": @{
                                                @"width": @(1136),
                                                @"height": @(640)
                                                },
                                        @"batteryLevel": @(0.85),
                                        @"bytesAvailable": @(7033507840),
                                        @"osVersion": @"11.1.1",
                                        @"ifa": idfaStr,
                                        @"adTrackingEnabled": @(YES),
                                        @"platform": @"iOS",
                                        @"connection": @"wifi",
                                        @"batterySaverEnabled": @(NO),
                                        @"idfv": [NSUUID UUID].UUIDString,
                                        @"model": @"iPhone10,2"
                                        }
                                
                                };
    [[NetWorkingManager shareManager] POST:@"https://api.vungle.com/api/v3/requestAd" parameters:paramDic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Post请求成功回调");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [task cancel];
        NSLog(@"Post请求失败回调");
    }];

}

- (void)pushDebuger {
    DebugController *debugVC = [DebugController new];
    debugVC.rootViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;
    debugVC.UIDStr = @"123456";
    __weak typeof(debugVC) debugVC_weak = debugVC;
    debugVC.hostChangeBlock = ^{
        [DebugAlertView createAlertWithTitle:@"环境切换" content:@"可以配置也可以手动输入域名" textFieldPlaceorder: @"例如：https://www.zybang.com" hostPrefixBtnStrArr:@[@"test", @"qatest", @"phptest"] hostNameBtnStrArr:@[@".suanshubang.com", @".zybang.com"] bottomBtnStrArr:@[@"取消", @"确定"] bottomBtnTouchedHandler:^(NSInteger index, NSString *inputStr) {
            if (index == 1) {
//                [ZYBHideConfigModel sharedInstance].debugAddress = alert.inputString;
//                [ZYBSocketService changeSocketHost:alert.inputString];
//                [[ZYBHideConfigModel sharedInstance] save];
                debugVC_weak.hostName = inputStr;
                NSLog(@"最终的host为:%@", inputStr);
            }
        }];
    };
    [self.navigationController pushViewController:debugVC animated:YES];
}


@end
