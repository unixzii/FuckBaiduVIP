//
//  FKHTTPFetcher.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "FKHTTPFetcher.h"

@interface FKHTTPFetcher ()
{
    NSURLSession *_session;
    NSURLSessionTask *_task;
    NSData *_data;
    id _target;
    SEL _action;
    void (^_completionBlock)();
}
@end

@implementation FKHTTPFetcher

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _session = [NSURLSession sharedSession];
    
    return self;
}

- (void)dealloc {
    [_task removeObserver:self forKeyPath:@"countOfBytesReceived"];
    [_task removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {    
    if (object == _task) {
        if (_target && _action) {
            [_target performSelector:_action withObject:self];
        }
    }
}

- (void)setTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)setCompletion:(void (^)())block {
    _completionBlock = block;
}

- (NSData *)responseData {
    return _data;
}

- (double)progress {
    if (!_task) {
        return 0;
    }
    
    return _task.countOfBytesReceived / (double) _task.countOfBytesExpectedToReceive;
}

- (BOOL)isCompleted {
    if (!_task) {
        return NO;
    }
    
    return _task.state == NSURLSessionTaskStateCompleted && [self responseData];
}

- (void)start {
    if (_task) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.fetchURL];
    _task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _data = data;
        if ([self isCompleted]) {
            if (_completionBlock) {
                _completionBlock();
            }
        }
        
        if (_target && _action) {
            [_target performSelector:_action withObject:self];
        }
    }];
    [_task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew context:nil];
    [_task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    
    [_task resume];

}

- (void)cancel {
    if (_task) {
        [_task cancel];
    }
}

@end
