//
//  BTKAddTagViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKAddTagViewController.h"

@implementation BTKAddTagViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navBarItem.rightBarButtonItem = rightButton;
    self.navBarItem.leftBarButtonItem = leftButton;
    
}

- (void) save {
    [self back];
}

- (void) back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
