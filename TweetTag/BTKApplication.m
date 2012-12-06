//
//  BTKApplication.m
//  TweetTag
//
//  Created by Brandon Krieger on 12/2/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKAppDelegate.h"
#import "BTKApplication.h"


@implementation BTKApplication


-(BOOL)openURL:(NSURL *)url {
    //make sure we only try to open link inside app if it is a website (as opposed to opening an app)
    if ([[[url absoluteString] substringToIndex:4] isEqualToString:@"http"]) {
        if  ([((BTKAppDelegate*)self.delegate) openURL:url])
            return YES;
        else
            return [super openURL:url];
    } else {
        return [super openURL:url];
    }
    
}

-(BOOL)openURLinSafari:(NSURL *)url {
    return [super openURL:url];
}
@end
