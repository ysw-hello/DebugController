//
//  DataFetch_Debug.m
//  DebugController
//
//  Created by 闫士伟 on 2018/8/1.
//  Copyright © 2018年 com.ysw. All rights reserved.
//

#import "DataFetch_Debug.h"
#import "AFURLSessionManager+LogAddtions.h"

@implementation DataFetch_Model

@end

@implementation DataFetch_Debug

#pragma mark - public SEL
+ (instancetype)sharedInstance {
    static DataFetch_Debug *dataFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataFetcher = [DataFetch_Debug new];
        dataFetcher.dataArr = [NSMutableArray array];
        [AFURLSessionManager swizzleTaskRequest];
    });
    return dataFetcher;
}

- (void)showDataFetchView {
    
}

- (void)hideDataFetchView {
    
}



@end
