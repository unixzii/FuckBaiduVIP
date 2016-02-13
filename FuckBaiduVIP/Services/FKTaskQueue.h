//
//  FKTaskQueue.h
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKHTTPFetcher.h"

@interface FKTaskQueue : NSObject

- (void)setTarget:(id)target action:(SEL)action;

- (void)addFetcher:(FKHTTPFetcher *)fetcher;
- (void)removeAllFetchers;

- (BOOL)isCompleted;

- (void)start;
- (void)cancel;

@end
