//
//  BTKWebViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 12/1/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKWebViewController.h"
#import "BTKApplication.h"

typedef enum {
	BUTTON_RELOAD,
	BUTTON_STOP,
} ToolbarButton;

@interface BTKWebViewController (Private)
- (void)updateToolbar:(ToolbarButton)state;
@end;

@implementation BTKWebViewController

@synthesize webView;
@synthesize url;

@synthesize toolbar, backButton, forwardButton, actionButton;

- (id) initWithURL:(NSURL *)u
{
    if ( self = [super init] )
    {
        backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
        actionButton  = [[UIBarButtonItem	alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(doAction)];
        
        toolbar = [UIToolbar new];
        toolbar.barStyle  = UIBarStyleDefault;
        
        [toolbar sizeToFit];
        CGFloat toolbarHeight = [toolbar frame].size.height;
        CGRect mainViewBounds = self.view.bounds;
        [toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
                                     CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
                                     CGRectGetWidth(mainViewBounds),
                                     toolbarHeight)];
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height-86)];
        webView.delegate        = self;
        webView.scalesPageToFit = YES;
        
        url = [u copy];
        
        [self.view addSubview:webView];
        [self.view addSubview:toolbar];
        
        
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *items = [NSArray arrayWithObjects: flexItem, backButton, flexItem, flexItem, flexItem, forwardButton,
                          flexItem, flexItem, flexItem, flexItem, flexItem, flexItem,
                          actionButton, flexItem, flexItem, flexItem, actionButton, flexItem, nil];
        [self.toolbar setItems:items animated:NO];
        
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark WebViewActions

- (void)reload
{
    [webView reload];
    [self updateToolbar:BUTTON_STOP];
}

- (void)stop
{
    [webView stopLoading];
    [self updateToolbar:BUTTON_RELOAD];
}

- (void) goBack
{
    [webView goBack];
}

- (void) goForward
{
    [webView goForward];
}

- (void) doAction
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[self.url absoluteString]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open with Safari", nil];
    
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) return;
    
    if (buttonIndex == 0) {
        [(BTKApplication*)[UIApplication sharedApplication] openURLinSafari:self.url];
    }
}

#pragma mark -
#pragma mark UIWebView

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateToolbar:BUTTON_STOP];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbar:BUTTON_RELOAD];
    self.url = aWebView.request.mainDocumentURL;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)updateToolbar:(ToolbarButton)button
{
    NSMutableArray *items = [toolbar.items mutableCopy];
    UIBarButtonItem *newItem;
    
    if (button == BUTTON_STOP) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityView startAnimating];
        newItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    }
    else {
        newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    }
    
    [items replaceObjectAtIndex:12 withObject:newItem];
    [toolbar setItems:items animated:false];
    
    // workaround to change toolbar state
    backButton.enabled = true;
    forwardButton.enabled = true;
    backButton.enabled = false;
    forwardButton.enabled = false;
    
    backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
}

@end
