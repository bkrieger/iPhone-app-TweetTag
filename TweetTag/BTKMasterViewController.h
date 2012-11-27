//
//  BTKMasterViewController.h
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKMasterViewController : UITableViewController

@property int sortType;
@property int defaultNumTweets;
@property int currentNumTweets;
@property BOOL loading;
@property BOOL noMore;
@property NSString *nextPage;

@end
