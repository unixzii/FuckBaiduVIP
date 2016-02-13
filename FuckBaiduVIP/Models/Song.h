//
//  Song.h
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

@property (copy, readonly) NSString *title;
@property (copy, readonly) NSString *album;
@property (copy, readonly) NSString *artist;
@property (copy, readonly, nonatomic) NSString *artworkURL;
@property (copy, readonly) NSString *mp3URL;
@property (copy, readonly) NSString *songId;

- (instancetype)initWithJSONObject:(id)object;
- (void)setArtworkURL:(NSString *)artworkURL;

@end
