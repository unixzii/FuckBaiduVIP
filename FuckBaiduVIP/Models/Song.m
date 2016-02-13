//
//  Song.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "Song.h"

@interface Song ()

@property (copy, readwrite) NSString *title;
@property (copy, readwrite) NSString *album;
@property (copy, readwrite) NSString *artist;
@property (copy, readwrite, nonatomic) NSString *artworkURL;
@property (copy, readwrite) NSString *mp3URL;
@property (copy, readwrite) NSString *songId;

@end

@implementation Song

- (instancetype)initWithJSONObject:(id)object {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDictionary *dict = object;
    
    self.title = [[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"songName"];
    self.album = [[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"albumName"];
    self.artist = [[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"artistName"];
    self.mp3URL = [[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"songLink"];
    self.songId = [NSString stringWithFormat:@"%ld", [[[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"songId"] integerValue]];
    
    return self;
}

- (void)setArtworkURL:(NSString *)artworkURL {
    _artworkURL = artworkURL;
}

@end
