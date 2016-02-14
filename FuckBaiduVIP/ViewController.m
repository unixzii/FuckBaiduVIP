//
//  ViewController.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"
#import "SearchResultCellView.h"
#import "Song.h"
#import "SearchResult.h"
#import "FKTaskQueue.h"
#import "NSString+URLEscape.h"

@interface ViewController ()
{
    FKTaskQueue *_taskQueue;
    FKHTTPFetcher *_searchResultFetcher;
    FKHTTPFetcher *_mp3Fetcher;
}

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSButtonCell *dirButton;

@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) SearchResult *searchResult;
@property (copy, nonatomic) NSString *downloadingSongTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _taskQueue = [[FKTaskQueue alloc] init];
    [_taskQueue setTarget:self action:@selector(fetchInfoTasksDidFinished)];
    
    self.searchField.target = self;
    self.searchField.action = @selector(searchTextChanged);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setUsesAlternatingRowBackgroundColors:YES];
    [self.tableView setRowHeight:80];
    
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"SearchResultCellView" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:cellNib forIdentifier:@"Cell"];
    
    self.dirButton.target = self;
    self.dirButton.action = @selector(openDir);
    
    self.songs = [[NSMutableArray alloc] init];
}

- (void)viewDidDisappear {
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)searchTextChanged {
    [self beginSearchTaskWithKeywork:self.searchField.stringValue];
}

- (void)openDir {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) firstObject];
    
    [[NSWorkspace sharedWorkspace] openFile:path];
}

#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.songs count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 80;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    SearchResultCellView *cell = [self.tableView makeViewWithIdentifier:@"Cell" owner:self];

    [cell setSong:[self.songs objectAtIndex:row]];
    [cell setTarget:self action:@selector(downloadSongAtRow:) forDownloadingSongAtRow:row];
    [cell setTarget:self action:@selector(playSongAtRow:) forTryingSongAtRow:row];
    
    return cell;
}

#pragma mark - Networking

- (void)beginSearchTaskWithKeywork:(NSString *)keyword {
    [self.songs removeAllObjects];
    [self.tableView reloadData];
    [self.tableView setEnabled:NO];
    
    if (_searchResultFetcher) {
        [_searchResultFetcher cancel];
        [_searchResultFetcher setTarget:nil action:nil];
        _searchResultFetcher = nil;
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://sug.music.baidu.com/info/suggestion?format=json&word=%@&version=2&from=0", [keyword encodeToPercentEscapeString]]];
    _searchResultFetcher = [[FKHTTPFetcher alloc] init];
    _searchResultFetcher.fetchURL = URL;
    [_searchResultFetcher setTarget:self action:@selector(searchTaskStateDidChange:)];
    [_searchResultFetcher start];
}

- (void)searchTaskStateDidChange:(id)sender {
    if ([_searchResultFetcher isCompleted]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[_searchResultFetcher responseData] options:kNilOptions error:nil];
        
        if (!dict) {
            return;
        }
        
        self.searchResult = [[SearchResult alloc] initWithJSONObject:dict];
        [self beginFetchInfoTasks];
    }
}

- (void)beginFetchInfoTasks {
    [_taskQueue cancel];
    [_taskQueue removeAllFetchers];
    
    for (NSObject *songId in self.searchResult.songIds) {
        NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://fm.baidu.com/data/music/songlink?songIds=%@", songId]];
        FKHTTPFetcher *linkFetcher = [[FKHTTPFetcher alloc] init];
        linkFetcher.fetchURL = linkURL;
        FKHTTPFetcher * __weak weak_linkFetcher = linkFetcher;
        [linkFetcher setCompletion:^{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[weak_linkFetcher responseData] options:kNilOptions error:nil];
            
            if (!dict) {
                return;
            }
            
            Song *song = [[Song alloc] initWithJSONObject:dict];
            [self.songs addObject:song];
        }];
        [_taskQueue addFetcher:linkFetcher];
        
        NSURL *infoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://fm.baidu.com/data/music/songinfo?songIds=%@", songId]];
        FKHTTPFetcher *infoFetcher = [[FKHTTPFetcher alloc] init];
        infoFetcher.fetchURL = infoURL;
        FKHTTPFetcher * __weak weak_infoFetcher = infoFetcher;
        [infoFetcher setCompletion:^{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[weak_infoFetcher responseData] options:kNilOptions error:nil];
            
            if (!dict) {
                return;
            }
            
            Song *song = [self.songs lastObject];
            [song setArtworkURL:[[[[dict objectForKey:@"data"] objectForKey:@"songList"] objectAtIndex:0] objectForKey:@"songPicSmall"]];
        }];
        [_taskQueue addFetcher:infoFetcher];
    }
    
    [_taskQueue start];
}

- (void)fetchInfoTasksDidFinished {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView setEnabled:YES];
    });
}

- (void)downloadSongAtRow:(NSNumber *)row {
    if (_mp3Fetcher) {
        [_mp3Fetcher cancel];
        [_mp3Fetcher setTarget:nil action:nil];
        _mp3Fetcher = nil;
    }
    
    Song *songToDownload = [self.songs objectAtIndex:[row integerValue]];
    
    self.downloadingSongTitle = songToDownload.title;
    
    NSURL *mp3URL = [NSURL URLWithString:songToDownload.mp3URL];
    _mp3Fetcher = [[FKHTTPFetcher alloc] init];
    _mp3Fetcher.fetchURL = mp3URL;
    [_mp3Fetcher setTarget:self action:@selector(downloadStateDidChange:)];
    [_mp3Fetcher start];
}

- (void)downloadStateDidChange:(id)sender {
    NSString *path;
    
    if ([_mp3Fetcher isCompleted]) {
        path = [NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"FuckBaiduVIP"];
        
        [[[NSFileManager alloc] init] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
        path = [[path stringByAppendingPathComponent:self.downloadingSongTitle] stringByAppendingPathExtension:@"mp3"];
        
        [[_mp3Fetcher responseData] writeToFile:path atomically:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressBar.doubleValue = [_mp3Fetcher progress] * 100;
        
        if ([_mp3Fetcher isCompleted]) {
            self.progressBar.doubleValue = 0;
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
    });
}

#pragma mark - Player

- (void)playSongAtRow:(NSNumber *)row {
    NSString *mp3URL = ((Song *) [self.songs objectAtIndex:[row integerValue]]).mp3URL;
    NSURL *URL = [NSURL URLWithString:mp3URL];
    
    [self playWithURL:URL];
}

- (void)playWithURL:(NSURL *)URL {
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        self.player = nil;
    }
    
    self.player = [AVPlayer playerWithURL:URL];
    [self.player play];
}

@end
