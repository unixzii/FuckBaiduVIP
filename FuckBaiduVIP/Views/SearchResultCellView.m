//
//  SearchResultCellView.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "SearchResultCellView.h"

@interface SearchResultCellView ()
{
    id _target;
    SEL _action;
    NSInteger _row;
}

@property (weak) IBOutlet NSImageView *artwork;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextField *metaInfo;
@property (weak) IBOutlet NSButton *downloadButton;

@end

@implementation SearchResultCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.downloadButton.target = self;
    self.downloadButton.action = @selector(downloadButtonDidClick);
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    
    if (backgroundStyle == NSBackgroundStyleDark) {
        [self.title setTextColor:[NSColor whiteColor]];
        [self.metaInfo setTextColor:[NSColor secondarySelectedControlColor]];
    } else {
        [self.title setTextColor:[NSColor blackColor]];
        [self.metaInfo setTextColor:[NSColor secondaryLabelColor]];
    }
}

- (void)downloadButtonDidClick {
    if (_target && _action) {
        [self.downloadButton setHidden:YES];
        [_target performSelector:_action withObject:[NSNumber numberWithInteger:_row]];
    }
}

- (void)setSong:(Song *)song {
    self.title.stringValue = song.title;
    self.metaInfo.stringValue = [NSString stringWithFormat:@"%@ - %@", song.album, song.artist];
    [self.downloadButton setHidden:NO];
    [self.artwork setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:song.artworkURL]]];
}

- (void)setTarget:(id)target action:(SEL)action forDownloadingSongAtRow:(NSInteger)row {
    _target = target;
    _action = action;
    _row = row;
}

@end
