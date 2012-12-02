//
//  BTKWebViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 12/1/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKWebViewController.h"

@interface BTKWebViewController ()

@end

@implementation BTKWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height-20-44-44)];
    [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    self.webView = webView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forward:(id)sender {
    if(self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (IBAction)back:(id)sender {
    if(self.webView.canGoBack) {
        [self.webView goBack];
    }
}
@end
