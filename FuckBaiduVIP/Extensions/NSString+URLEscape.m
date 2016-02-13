//
//  NSString+URLEscape.m
//  FuckBaiduVIP
//
//  Created by 杨弘宇 on 16/2/13.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "NSString+URLEscape.h"

@implementation NSString (URLEscape)

- (NSString *)encodeToPercentEscapeString {
    NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    
    return result;
}

@end
