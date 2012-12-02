//
//  MyApplication.m
//  TweetTag
//
//  Created by Brandon Krieger on 12/2/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKAppDelegate.h"

@interface MyApplication : UIApplication {
    
}

@end

@implementation MyApplication

-(BOOL)openURL:(NSURL *)url{
    if  ([self.delegate openURL:url])
        return YES;
    else
        return [super openURL:url];
}
@end
