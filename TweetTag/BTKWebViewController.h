//
//  BTKWebViewController.h
//  TweetTag
//
//  Created by Brandon Krieger on 12/1/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKWebViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate> {
    
    UIWebView *webView;
    NSURL *url;
    
    UIToolbar* toolbar;
    
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *actionButton;
}
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) UIToolbar* toolbar;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, retain) UIBarButtonItem *actionButton;

- (id) initWithURL:(NSURL*)u;
- (void) doAction;

- (void)goBack;
- (void)goForward;

- (void)reload;
- (void)stop;


@end
