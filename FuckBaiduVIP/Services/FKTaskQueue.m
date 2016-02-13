//
//  FKTaskQueue.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "FKTaskQueue.h"

@interface FKTaskQueue ()
{
    id _target;
    SEL _action;
}

@property (strong, nonatomic) NSMutableArray *queue;

@end

@implementation FKTaskQueue

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.queue = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)taskAction:(id)sender {
    FKHTTPFetcher *fetcher = sender;
    
    if ([fetcher isCompleted]) {
        [self.queue removeObjectAtIndex:0];
        
        if ([self.queue count] == 0) {
            if (_target && _action) {
                [_target performSelector:_action withObject:self];
            }
            return;
        }
        
        [self start];
    }
}

- (void)setTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)addFetcher:(FKHTTPFetcher *)fetcher {
    [self.queue addObject:fetcher];
    [fetcher setTarget:self action:@selector(taskAction:)];
}

- (void)removeAllFetchers {
    [self.queue removeAllObjects];
}

- (BOOL)isCompleted {
    return [self.queue count] == 0;
}

- (void)start {
    [[self.queue firstObject] start];
}

- (void)cancel {
    [[self.queue firstObject] cancel];
}

@end
