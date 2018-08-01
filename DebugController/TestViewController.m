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

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height - 65, self.view.bounds.size.width - 20, 50)];
    [button setTitle:@"调试控制器" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushDebuger) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blackColor];
    button.layer.borderColor = [UIColor cyanColor].CGColor;
    button.layer.borderWidth = 2;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
}

- (void)pushDebuger {
    DebugController *debugVC = [DebugController new];
    debugVC.rootViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate rootViewController];
    [self.navigationController pushViewController:debugVC animated:YES];
}

@end
