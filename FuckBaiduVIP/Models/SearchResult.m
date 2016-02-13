//
//  SearchResult.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "SearchResult.h"

@interface SearchResult ()

@property (strong, readwrite, nonatomic) NSMutableArray *songIds;

@end

@implementation SearchResult

- (instancetype)initWithJSONObject:(id)object {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDictionary *dict = object;
    
    self.songIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *song in [[dict objectForKey:@"data"] objectForKey:@"song"]) {
        [self.songIds addObject:[song objectForKey:@"songid"]];
    }
    
    return self;
}

@end
