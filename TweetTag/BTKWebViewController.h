//
//  BTKWebViewController.h
//  TweetTag
//
//  Created by Brandon Krieger on 12/1/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKWebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSURL *url;
- (IBAction)forward:(id)sender;
- (IBAction)back:(id)sender;

@end
