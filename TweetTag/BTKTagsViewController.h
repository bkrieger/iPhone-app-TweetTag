//
//  BTKTagsViewController.h
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTKTagsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property BOOL isAdding;
@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *addButton;
@property UIBarButtonItem *cancelButton;
@property UIBarButtonItem *saveButton;

@end
