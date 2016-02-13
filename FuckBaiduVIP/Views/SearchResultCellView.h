//
//  SearchResultCellView.h
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Song.h"

@interface SearchResultCellView : NSTableCellView

- (void)setSong:(Song *)song;
- (void)setTarget:(id)target action:(SEL)action forDownloadingSongAtRow:(NSInteger)row;

@end
