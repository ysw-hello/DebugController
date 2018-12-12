//
//  NetStatusViewController.m
//  DebugController
//
//  Created by TimmyYan on 2018/11/24.
//  Copyright © 2018年 com.ysw. All rights reserved.
//

#import "NetStatusViewController.h"
#import <LDNetDiagnoService/LDNetDiagnoService.h>
#import "Debug_NetSpeed.h"
#import "RealReachability.h"

@interface NetStatusViewController () <LDNetDiagnoServiceDelegate, UITextFieldDelegate> {
    UIActivityIndicatorView *_indicatorView;
    UIButton *_btn;
    UITextView *_txtView_log;
    UITextField *_txtfield_dormain;
    
    NSString *_logInfo;
    LDNetDiagnoService *_netDiagnoService;
    BOOL _isRunning;
}

/**
 网络状态
 */
@property (nonatomic, strong) UILabel *netStatusLabel;

/**
 上传速度
 */
@property (nonatomic, strong) UILabel *uploadSpeedLabel;
/**
 下载速度
 */
@property (nonatomic, strong) UILabel *downloadSpeedLabel;

/**
 定时器
 */
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation NetStatusViewController

/**
 开启定时监测网速
 */
- (void)startNetMonitor {
    if (!_timer) {
        __block NSUInteger wifiSent = 0, wifiReceive = 0, WWANSent = 0, WWANReceive = 0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(self.timer, ^{
            NSArray *arr = [Debug_NetSpeed getDataCounters];
//            NSLog(@"网卡流量吞吐为：%@", arr);
            
            NSUInteger followWiFiSent = 0, followWiFiReceive = 0, followWWANSent = 0, followWWANReceive = 0;
            switch ([GLobalRealReachability currentReachabilityStatus]) {
                case RealStatusViaWiFi:
                    followWiFiSent = [arr[0] integerValue];
                    followWiFiReceive = [arr[1] integerValue];
                    if (wifiSent == 0 || wifiReceive == 0 || (followWiFiSent - wifiSent < 1 && followWiFiReceive - wifiReceive < 1)) {
                        wifiSent = followWiFiSent;
                        wifiReceive = followWiFiReceive;
                        return;
                    }
                    break;
                    
                case RealStatusViaWWAN:
                    followWWANSent = [arr[2] integerValue];
                    followWWANReceive = [arr[3] integerValue];
                    if (WWANSent == 0 || WWANReceive == 0 || (followWWANSent - WWANSent < 1 && followWWANReceive - WWANReceive < 1)) {
                        WWANSent = followWWANSent;
                        WWANReceive = followWWANReceive;
                        return;
                    }
                    break;
                    
                default:
                    break;
            }
           
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat dSpeed = 0.00, uSpeed = 0.00;
                switch ([GLobalRealReachability currentReachabilityStatus]) {
                    case RealStatusViaWiFi:
                        dSpeed = (followWiFiReceive - wifiReceive) / 1024.f;
                        uSpeed = (followWiFiSent - wifiSent) / 1024.f;
                        _uploadSpeedLabel.text = [NSString stringWithFormat:@"上传速度:%.2fKB/s", uSpeed];
                        _downloadSpeedLabel.text = [NSString stringWithFormat:@"下载速度:%.2fKB/s", dSpeed];
                        wifiSent = followWiFiSent;
                        wifiReceive = followWiFiReceive;
                        break;
                    
                    case RealStatusViaWWAN:
                        dSpeed = (followWWANReceive - WWANReceive) / 1024.f;
                        uSpeed = (followWWANSent - WWANSent) / 1024.f;
                        _uploadSpeedLabel.text = [NSString stringWithFormat:@"上传速度:%.2fKB/s", uSpeed];
                        _downloadSpeedLabel.text = [NSString stringWithFormat:@"下载速度:%.2fKB/s", dSpeed];
                        WWANSent = followWWANSent;
                        WWANReceive = followWWANReceive;
                        break;
                        
                    default:
                        _uploadSpeedLabel.text = @"上传速度:0.00KB/s";
                        _downloadSpeedLabel.text = @"下载速度:0.00KB/s";
                        break;
                }
            });
            
        });
        dispatch_resume(self.timer);
    }
}

- (void)destroyTimer {
    if (_timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

/**
 监测网速
 */
- (void)monitorNetSpeed {
    CGFloat margin = 10;
    CGFloat width = (self.view.frame.size.width - margin*3) / 2;
    CGFloat height = 30;
    CGFloat top = 64 + 40;
    
    _downloadSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, top, width, height)];
    _downloadSpeedLabel.textColor = [UIColor blueColor];
    _downloadSpeedLabel.text = @"下载速度:0.00KB/s";
    _downloadSpeedLabel.font = [UIFont systemFontOfSize:16];
    _downloadSpeedLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_downloadSpeedLabel];
    
    _uploadSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin + width + margin, top, width, height)];
    _uploadSpeedLabel.textColor = [UIColor blueColor];
    _uploadSpeedLabel.text = @"上传速度:0.00KB/s";
    _uploadSpeedLabel.font = [UIFont systemFontOfSize:16];
    _uploadSpeedLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_uploadSpeedLabel];
    
    //开始读取网卡数据
    [self startNetMonitor];

}

/**
 监测网络状态
 */
- (void)monitorNetStatus {
    
    _netStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 64 + 10, self.view.frame.size.width - 20, 20)];
    _netStatusLabel.textColor = [UIColor blueColor];
    _netStatusLabel.text = @"当前联网状态为：--";
    _netStatusLabel.font = [UIFont systemFontOfSize:16];
    _netStatusLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_netStatusLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(VPNStatusChanged:)
                                                 name:kRRVPNStatusChangedNotification
                                               object:nil];
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    NSLog(@"Initial reachability status:%@",@(status));
    
    [self setupFlagLabelWithStatus:status
                           isVPNOn:[GLobalRealReachability isVPNOn]
                        accessType:[GLobalRealReachability currentWWANtype]];
}
- (void)networkChanged:(NSNotification *)notification {
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    [self setupFlagLabelWithStatus:status
                           isVPNOn:[GLobalRealReachability isVPNOn]
                        accessType:[GLobalRealReachability currentWWANtype]];
}
- (void)VPNStatusChanged:(NSNotification *)notification {
    // refreshing the status.
    [self setupFlagLabelWithStatus:[GLobalRealReachability currentReachabilityStatus]
                           isVPNOn:[GLobalRealReachability isVPNOn]
                        accessType:[GLobalRealReachability currentWWANtype]];
}
- (void)setupFlagLabelWithStatus:(ReachabilityStatus)status isVPNOn:(BOOL)isVPNOn accessType:(WWANAccessType)accessType {
    NSMutableString *labelStr = [@"" mutableCopy];
    switch (status) {
        case RealStatusNotReachable:
            [labelStr appendString:@"网络连接异常"];
            break;
            
        case RealStatusUnknown:
            [labelStr appendString:@"网络连接发生异常错误"];
            break;
            
        case RealStatusViaWiFi:
            [labelStr appendString:@"当前联网状态为：WiFi"];
            break;
            
        case RealStatusViaWWAN:
            [labelStr appendString:@"当前联网状态为："];
            break;
            
        default:
            [labelStr appendString:@"当前联网状态为：--"];
            break;
    }
    
    if (isVPNOn) {
        [labelStr appendString:@"(VPN已打开)"];
    }
    
    if (status == RealStatusViaWWAN) {
        NSString *descStr;
        if (accessType == WWANType2G) {
            descStr = @"2G";
        } else if (accessType == WWANType3G) {
            descStr = @"3G";
        } else if (accessType == WWANType4G) {
            descStr = @"4G";
        } else {
            descStr = @"--";
        }
        
        [labelStr appendString:descStr];
    }
    
    self.netStatusLabel.text = [labelStr copy];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self destroyTimer];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self destroyTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"网络诊断Demo";
    
    //网络状态相关
    [self monitorNetStatus];
    
    //网速相关
    [self monitorNetSpeed];

    
    _indicatorView = [[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = CGRectMake(10.0f, 150.0f, 100.0f, 50.0f);
    [_btn setBackgroundColor:[UIColor lightGrayColor]];
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_btn.titleLabel setNumberOfLines:2];
    [_btn setTitle:@"开始诊断" forState:UIControlStateNormal];
    [_btn addTarget:self
            action:@selector(startNetDiagnosis)
  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    
    
    _txtfield_dormain =
    [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 150.0f, 180.0f, 50.0f)];
    _txtfield_dormain.delegate = self;
    _txtfield_dormain.returnKeyType = UIReturnKeyDone;
    _txtfield_dormain.text = @"www.zybang.com";
    [self.view addSubview:_txtfield_dormain];
    
    
    _txtView_log = [[UITextView alloc] initWithFrame:CGRectZero];
    _txtView_log.layer.borderWidth = 1.0f;
    _txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtView_log.backgroundColor = [UIColor whiteColor];
    _txtView_log.font = [UIFont systemFontOfSize:10.0f];
    _txtView_log.textAlignment = NSTextAlignmentLeft;
    _txtView_log.scrollEnabled = YES;
    _txtView_log.editable = NO;
    _txtView_log.frame = CGRectMake(0.0f, 210.0f, self.view.frame.size.width, self.view.frame.size.height - 190.0f);
    [self.view addSubview:_txtView_log];
    
    // Do any additional setup after loading the view, typically from a nib.
    _netDiagnoService = [[LDNetDiagnoService alloc] initWithAppCode:@"NetStatus"
                                                            appName:@"网络诊断应用"
                                                         appVersion:@"1.0.0"
                                                             userID:@"TimmyYan"
                                                           deviceID:nil
                                                            dormain:_txtfield_dormain.text
                                                        carrierName:nil
                                                     ISOCountryCode:nil
                                                  MobileCountryCode:nil
                                                      MobileNetCode:nil];
    _netDiagnoService.delegate = self;
    _isRunning = NO;
}


- (void)startNetDiagnosis {
    [_txtfield_dormain resignFirstResponder];
    _netDiagnoService.dormain = _txtfield_dormain.text;
    if (!_isRunning) {
        [_indicatorView startAnimating];
        [_btn setTitle:@"停止诊断" forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [_btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        _txtView_log.text = @"";
        _logInfo = @"";
        _isRunning = !_isRunning;
        [_netDiagnoService startNetDiagnosis];
    } else {
        [_indicatorView stopAnimating];
        _isRunning = !_isRunning;
        [_btn setTitle:@"开始诊断" forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
        [_btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        [_netDiagnoService stopNetDialogsis];
    }
}

- (void)delayMethod {
    [_btn setBackgroundColor:[UIColor lightGrayColor]];
    [_btn setUserInteractionEnabled:TRUE];
}



#pragma mark NetDiagnosisDelegate
- (void)netDiagnosisDidStarted {
    NSLog(@"开始诊断～～～");
}

- (void)netDiagnosisStepInfo:(NSString *)stepInfo {
    NSLog(@"%@", stepInfo);
    _logInfo = [_logInfo stringByAppendingString:stepInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        _txtView_log.text = _logInfo;
    });
}


- (void)netDiagnosisDidEnd:(NSString *)allLogInfo;
{
    NSLog(@"logInfo>>>>>\n%@", allLogInfo);
    //可以保存到文件，也可以通过邮件发送回来
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        [_btn setTitle:@"开始诊断" forState:UIControlStateNormal];
        _isRunning = NO;
    });
}

- (void)emailLogInfo {
    [_netDiagnoService printLogInfo];
}


#pragma mark -
#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
