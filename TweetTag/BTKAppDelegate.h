//
//  BTKAppDelegate.h
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
-(BOOL)openURL:(NSURL *)url;

@end
