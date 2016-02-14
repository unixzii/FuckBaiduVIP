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
    
    id _target2;
    SEL _action2;
    NSInteger _row2;
}

@property (weak) IBOutlet NSImageView *artwork;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextField *metaInfo;
@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSButton *trialButton;

@end

@implementation SearchResultCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.downloadButton.target = self;
    self.downloadButton.action = @selector(downloadButtonDidClick);
    
    self.trialButton.target = self;
    self.trialButton.action = @selector(trialButtonDidClick);
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

- (void)trialButtonDidClick {
    if (_target && _action) {
        [_target2 performSelector:_action2 withObject:[NSNumber numberWithInteger:_row2]];
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

- (void)setTarget:(id)target action:(SEL)action forTryingSongAtRow:(NSInteger)row {
    _target2 = target;
    _action2 = action;
    _row2 = row;
}

@end
