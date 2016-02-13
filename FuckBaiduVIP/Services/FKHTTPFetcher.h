//
//  FKHTTPFetcher.h
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKHTTPFetcher : NSObject

@property (strong, nonatomic) NSURL *fetchURL;

- (void)setTarget:(id)target action:(SEL)action;

- (void)setCompletion:(void (^)())block;

- (NSData *)responseData;

- (double)progress;
- (BOOL)isCompleted;

- (void)start;
- (void)cancel;

@end
