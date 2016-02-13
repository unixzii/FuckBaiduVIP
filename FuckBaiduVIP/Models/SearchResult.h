//
//  SearchResult.h
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (strong, readonly, nonatomic) NSMutableArray *songIds;

- (instancetype)initWithJSONObject:(id)object;

@end
